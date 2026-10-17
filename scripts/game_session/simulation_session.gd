extends RefCounted
## Single writer. Callers receive detached views/results, never the private canonical state.

const Grid = preload("res://scripts/world/region_grid.gd")
const Generator = preload("res://scripts/world/local_region_generator.gd")
const Command = preload("res://scripts/game_session/action_command.gd")
const Result = preload("res://scripts/game_session/action_result.gd")
const Scheduler = preload("res://scripts/game_session/turn_scheduler.gd")
const Rng = preload("res://scripts/game_session/rng_streams.gd")
const Sight = preload("res://scripts/game_session/visibility.gd")
const Actor = preload("res://scripts/combat/actor_state.gd")
const Attack = preload("res://scripts/combat/attack_resolver.gd")
const AI = preload("res://scripts/combat/enemy_ai.gd")
const Status = preload("res://scripts/combat/status_effects.gd")
const ACTION_COST: int = 100

signal result_published(result: Result)

var player_cell: Vector2i:
	get: return _player_cell
var action_index: int:
	get: return _action_index
var simulation_time: int:
	get: return _scheduler.time
var _terrain: Grid
var _actors: Dictionary = {}
var _combat: bool = false
var _player_cell: Vector2i:
	get: return _actors["player"].cell
	set(value): _actors["player"].cell = value
var _action_index: int = 0
var _seed: int
var _content_version: String
var _scheduler := Scheduler.new()
var _rng: Rng
var _visible: PackedByteArray
var _discovered: PackedByteArray
var _last_request: int = 0
var _event_sequence: int = 0
var _resolving: bool = false


func _init(seed_value: int, fixture: Grid = null, content_version: String = "i003-v1", encounter: Array[Dictionary] = []) -> void:
	_seed = seed_value
	_content_version = content_version
	_terrain = _copy_grid(fixture if fixture != null else Generator.generate(seed_value))
	_combat = content_version == "i004-v1"
	var player_spec: Dictionary = {"id": "player", "cell": [_terrain.spawn_cell.x, _terrain.spawn_cell.y]}
	_actors["player"] = Actor.from_spec(player_spec)
	if _combat:
		if encounter.is_empty():
			var cell: Vector2i = AI.encounter_cell(_terrain)
			assert(cell.x >= 0, "Region requires reachable safe encounter placement")
			encounter = [{"id": "mite-001", "name": "Hollow mite", "cell": [cell.x,cell.y],
				"max_hp": 18, "max_stamina": 8, "offense": 4, "accuracy": 75,
				"stamina_cost": 2, "attack_cost": 120, "ai": "hostile"}]
		for spec: Dictionary in encounter:
			var actor: RefCounted = Actor.from_spec(spec)
			if actor.id == "player":
				_actors.erase("player")
			assert(not actor.id.is_empty() and not _actors.has(actor.id), "Unique stable actor IDs required")
			assert(_terrain.is_walkable(actor.cell) and not AI.occupied(_actors,actor.cell), "Legal nonoverlapping actor placement required")
			_actors[actor.id] = actor
	assert(_terrain.is_walkable(_player_cell), "Simulation requires legal initial spawn")
	var ids: Array = _actors.keys()
	ids.sort()
	for id: String in ids:
		var actor: RefCounted = _actors[id]
		if actor.alive:
			var registered: bool = _scheduler.add_actor(id, actor.attack_cost, actor.speed)
			assert(registered, "Valid scheduler profile required")
	_rng = Rng.new(seed_value)
	_discovered.resize(_terrain.cells.size())
	_reveal()


func _copy_grid(source: Grid) -> Grid:
	var copy := Grid.new(source.width, source.height)
	copy.cells = source.cells.duplicate()
	copy.seed_value = source.seed_value
	copy.spawn_cell = source.spawn_cell
	copy.entrance_cell = source.entrance_cell
	return copy


func view() -> Grid:
	var copy: Grid = _copy_grid(_terrain)
	copy.player_cell = _player_cell
	copy.visible = _visible.duplicate()
	copy.discovered = _discovered.duplicate()
	for index in range(copy.cells.size()):
		if _discovered[index] == 0:
			copy.cells[index] = Grid.Terrain.UNKNOWN
	if _combat:
		for id: String in _sorted_actor_ids():
			var record: Dictionary = actor_view(id)
			if not record.is_empty():
				copy.actors.append(record)
	return copy


func _sorted_actor_ids() -> Array:
	var ids: Array = _actors.keys()
	ids.sort()
	return ids


func actor_record(id: String) -> Dictionary:
	# Canonical diagnostics, like canonical_state(); never used as a perceived UI view.
	return _actors[id].snapshot() if _actors.has(id) else {}


func actor_view(id: String) -> Dictionary:
	if not _combat or not _actors.has(id):
		return {}
	var actor: RefCounted = _actors[id]
	if id != "player" and (not actor.alive or not _is_visible(actor.cell)):
		return {}
	return actor.snapshot()


func _is_visible(cell: Vector2i) -> bool:
	return _terrain.contains(cell) and _visible[cell.y * _terrain.width + cell.x] != 0


func is_defeated() -> bool:
	return _combat and not _actors["player"].alive


func rng_states() -> Array:
	return _rng.snapshot()


func canonical_state() -> Array:
	var state: Array = [_content_version, _seed, _terrain.fingerprint(), [_player_cell.x, _player_cell.y],
		_action_index, _scheduler.time, _scheduler.snapshot(), _rng.snapshot(), _visible.hex_encode(), _discovered.hex_encode()]
	if _combat:
		var actors: Array = []
		for id: String in _sorted_actor_ids():
			actors.append(_actors[id].snapshot())
		state.append(actors)
	return state


func state_hash() -> String:
	return JSON.stringify(canonical_state()).sha256_text()


func _reveal() -> void:
	_visible = Sight.calculate(_terrain, _player_cell)
	for index in range(_visible.size()):
		_discovered[index] = maxi(_discovered[index], _visible[index])


func _result(command: Command, code: String) -> Result:
	var result := Result.new()
	result.request_id = command.request_id if command != null else 0
	result.code = code
	result.success = code == "OK"
	result.from_cell = _player_cell
	result.to_cell = _player_cell
	result.action_index = _action_index
	result.time = _scheduler.time
	return result


func _publish(result: Result) -> Result:
	if not result.success:
		result.events.append({"type": "command_rejected", "code": result.code})
	for event in result.events:
		_event_sequence += 1
		event["sequence"] = _event_sequence
		event["request_id"] = result.request_id
	result_published.emit(result)
	_resolving = false
	return result


func submit(command: Command) -> Result:
	# Reentrant calls get a structured BUSY result, with no recursive signal dispatch.
	if _resolving:
		return _result(command, "BUSY")
	_resolving = true
	if command == null or command.request_id <= 0:
		return _publish(_result(command, "INVALID_COMMAND"))
	if command.request_id <= _last_request:
		return _publish(_result(command, "DUPLICATE"))
	_last_request = command.request_id
	if command.actor_id != "player":
		return _publish(_result(command, "INVALID_ACTOR"))
	if is_defeated():
		return _publish(_result(command, "PLAYER_DEFEATED"))
	if command.kind not in [Command.Kind.MOVE, Command.Kind.WAIT, Command.Kind.INSPECT, Command.Kind.ATTACK] or (command.kind == Command.Kind.ATTACK and not _combat):
		return _publish(_result(command, "INVALID_COMMAND"))
	var result: Result = _result(command, "OK")
	if command.kind == Command.Kind.INSPECT:
		if not _terrain.contains(command.target) or _visible[command.target.y * _terrain.width + command.target.x] == 0:
			return _publish(_result(command, "NOT_VISIBLE"))
		result.inspection = {"cell": [command.target.x, command.target.y], "terrain": _terrain.terrain_at(command.target)}
		if _combat:
			for id: String in _sorted_actor_ids():
				var actor: RefCounted = _actors[id]
				if actor.alive and actor.cell == command.target:
					result.inspection["actor"] = actor_view(id)
		result.events = [{"type": "command_accepted"}, {"type": "tile_inspected", "details": result.inspection.duplicate(true)}]
		return _publish(result)
	var cost: int = ACTION_COST
	if command.kind == Command.Kind.ATTACK:
		# Identity plus live visibility prevents probing hidden enemies with guessed IDs.
		if not _actors.has(command.target_id) or actor_view(command.target_id).is_empty():
			return _publish(_result(command, "TARGET_UNAVAILABLE"))
		var code: String = Attack.validate(_terrain, _actors["player"], _actors[command.target_id])
		if code != "OK":
			return _publish(_result(command, code))
		cost = _actors["player"].attack_cost
	if command.kind == Command.Kind.MOVE:
		var direction: Vector2i = command.direction
		if direction == Vector2i.ZERO or absi(direction.x) > 1 or absi(direction.y) > 1:
			return _publish(_result(command, "INVALID_COMMAND"))
		var target: Vector2i = _player_cell + direction
		if not _terrain.contains(target):
			return _publish(_result(command, "OUT_OF_BOUNDS"))
		if not _terrain.is_walkable(target):
			return _publish(_result(command, "BLOCKED"))
		if not _terrain.can_step(_player_cell, direction):
			return _publish(_result(command, "CORNER_BLOCKED"))
		if _combat and not AI.legal_step(_terrain,_actors,"player",_player_cell,direction):
			return _publish(_result(command, "OCCUPIED"))
		result.to_cell = target
	var plan: Dictionary = _scheduler.preview(cost)
	if not plan["ok"]:
		return _publish(_result(command, "BUDGET_EXCEEDED"))
	_player_cell = result.to_cell
	_scheduler.commit(plan)
	_action_index += 1
	result.cost = cost
	result.action_index = _action_index
	result.time = _scheduler.time
	result.events = [{"type": "command_accepted"}]
	if _combat:
		result.events.append_array(Status.tick(_actors["player"]))
	if command.kind == Command.Kind.MOVE:
		_reveal()
		result.events.append({"type": "player_moved", "from": [result.from_cell.x, result.from_cell.y], "to": [result.to_cell.x, result.to_cell.y]})
		result.events.append({"type": "visibility_changed"})
	elif command.kind == Command.Kind.ATTACK:
		_execute_attack("player",command.target_id,result.events,_scheduler.time - cost)
	else:
		result.events.append({"type": "player_waited"})
		if _combat:
			_recover(_actors["player"])
			if Status.apply(_actors["player"],"guarded",1):
				result.events.append({"type": "status_applied", "actor_id": "player", "status_id": "guarded", "duration": 1})
	for ready: Dictionary in plan["ready"]:
		var id: String = ready["actor_id"]
		if _combat and (not _actors[id].alive or is_defeated()):
			continue
		# Hidden NPC readiness is internal scheduling, not perceived information.
		if not _combat or id == "player" or _is_visible(_actors[id].cell):
			result.events.append({"type": "actor_ready", "actor_id": id, "time": ready["time"]})
		if _combat and id != "player" and _actors[id].ai == "hostile":
			_enemy_turn(id,result.events,ready["time"])
	result.events.append({"type": "turn_completed", "action_index": _action_index, "time": _scheduler.time, "cost": cost})
	return _publish(result)


func _recover(actor: RefCounted) -> void:
	actor.stamina = mini(actor.max_stamina,actor.stamina + 4)


func _execute_attack(attacker_id: String, target_id: String, events: Array[Dictionary], time: int) -> bool:
	var attacker: RefCounted = _actors.get(attacker_id)
	var target: RefCounted = _actors.get(target_id)
	# Revalidate live identity/range/LOS/resources immediately before resolution.
	if Attack.validate(_terrain,attacker,target) != "OK":
		return false
	var resolution: Dictionary = Attack.resolve(attacker,target,_rng.draw("combat") % 100)
	attacker.stamina -= attacker.stamina_cost
	events.append({"type":"attack_resolved","actor_id":attacker_id,"target_id":target_id,"time":time,
		"stamina_cost":attacker.stamina_cost,"details":resolution.duplicate(true)})
	if not resolution["hit"]:
		events.append({"type":"miss","actor_id":attacker_id,"target_id":target_id,"time":time})
		return true
	var amount: int = mini(target.hp,resolution["damage"])
	target.hp = maxi(0,target.hp - amount)
	events.append({"type":"damage","actor_id":attacker_id,"target_id":target_id,"amount":amount,
		"damage_type":resolution["damage_type"],"hp":target.hp,"time":time})
	if target.hp == 0 and target.alive:
		target.alive = false
		_scheduler.remove_actor(target_id)
		events.append({"type":"actor_died","actor_id":target_id,"source_id":attacker_id,"time":time})
	return true


func _enemy_turn(id: String, events: Array[Dictionary], time: int) -> void:
	var actor: RefCounted = _actors[id]
	var decision: Dictionary = AI.decide(_terrain,_actors,actor,_actors["player"])
	actor.behavior = decision["behavior"]
	var observed: bool = _is_visible(actor.cell)
	var status_events: Array[Dictionary] = Status.tick(actor)
	if observed:
		events.append_array(status_events)
	if decision["kind"] == "attack":
		if not _execute_attack(id,"player",events,time):
			_recover(actor)
	elif decision["kind"] == "move":
		var direction: Vector2i = decision["direction"]
		if AI.legal_step(_terrain,_actors,id,actor.cell,direction):
			var from: Vector2i = actor.cell
			actor.cell += direction
			var now_visible: bool = _is_visible(actor.cell)
			if observed and now_visible:
				events.append({"type":"enemy_moved","actor_id":id,"from":[from.x,from.y],
					"to":[actor.cell.x,actor.cell.y],"behavior":actor.behavior,"time":time})
			elif observed:
				events.append({"type":"enemy_left_sight","actor_id":id,"from":[from.x,from.y],"time":time})
			elif now_visible:
				events.append({"type":"enemy_entered_sight","actor_id":id,"to":[actor.cell.x,actor.cell.y],"time":time})
	else:
		_recover(actor)
