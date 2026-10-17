extends RefCounted
## Single writer. Callers receive detached views/results, never the private canonical state.

const Grid = preload("res://scripts/world/region_grid.gd")
const Generator = preload("res://scripts/world/local_region_generator.gd")
const Command = preload("res://scripts/game_session/action_command.gd")
const Result = preload("res://scripts/game_session/action_result.gd")
const Scheduler = preload("res://scripts/game_session/turn_scheduler.gd")
const Rng = preload("res://scripts/game_session/rng_streams.gd")
const Sight = preload("res://scripts/game_session/visibility.gd")
const ACTION_COST: int = 100

signal result_published(result: Result)

var player_cell: Vector2i:
	get: return _player_cell
var action_index: int:
	get: return _action_index
var simulation_time: int:
	get: return _scheduler.time
var _terrain: Grid
var _player_cell: Vector2i
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


func _init(seed_value: int, fixture: Grid = null, content_version: String = "i003-v1") -> void:
	_seed = seed_value
	_content_version = content_version
	_terrain = _copy_grid(fixture if fixture != null else Generator.generate(seed_value))
	_player_cell = _terrain.spawn_cell
	assert(_terrain.is_walkable(_player_cell), "Simulation requires legal initial spawn")
	_scheduler.add_actor("player")
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
	return copy


func rng_states() -> Array:
	return _rng.snapshot()


func canonical_state() -> Array:
	return [_content_version, _seed, _terrain.fingerprint(), [_player_cell.x, _player_cell.y],
		_action_index, _scheduler.time, _scheduler.snapshot(), _rng.snapshot(), _visible.hex_encode(), _discovered.hex_encode()]


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
	if command.kind not in [Command.Kind.MOVE, Command.Kind.WAIT, Command.Kind.INSPECT]:
		return _publish(_result(command, "INVALID_COMMAND"))
	var result: Result = _result(command, "OK")
	if command.kind == Command.Kind.INSPECT:
		if not _terrain.contains(command.target) or _visible[command.target.y * _terrain.width + command.target.x] == 0:
			return _publish(_result(command, "NOT_VISIBLE"))
		result.inspection = {"cell": [command.target.x, command.target.y], "terrain": _terrain.terrain_at(command.target)}
		result.events = [{"type": "command_accepted"}, {"type": "tile_inspected", "details": result.inspection.duplicate(true)}]
		return _publish(result)
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
		result.to_cell = target
	var plan: Dictionary = _scheduler.preview(ACTION_COST)
	if not plan["ok"]:
		return _publish(_result(command, "BUDGET_EXCEEDED"))
	_player_cell = result.to_cell
	_scheduler.commit(plan)
	_action_index += 1
	result.cost = ACTION_COST
	result.action_index = _action_index
	result.time = _scheduler.time
	result.events = [{"type": "command_accepted"}]
	if command.kind == Command.Kind.MOVE:
		_reveal()
		result.events.append({"type": "player_moved", "from": [result.from_cell.x, result.from_cell.y], "to": [result.to_cell.x, result.to_cell.y]})
		result.events.append({"type": "visibility_changed"})
	else:
		result.events.append({"type": "player_waited"})
	for ready: Dictionary in plan["ready"]:
		result.events.append({"type": "actor_ready", "actor_id": ready["actor_id"], "time": ready["time"]})
	result.events.append({"type": "turn_completed", "action_index": _action_index, "time": _scheduler.time, "cost": ACTION_COST})
	return _publish(result)
