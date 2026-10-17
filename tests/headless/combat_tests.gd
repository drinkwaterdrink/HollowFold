extends SceneTree

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func _run() -> void:
	check(ResourceLoader.exists("res://scripts/combat/actor_state.gd"), "shared combat actor state exists")
	if failures == 0:
		_suite()
	print("COMBAT_TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

func arena() -> RefCounted:
	var grid: RefCounted = load("res://scripts/world/region_grid.gd").new(11, 9)
	grid.cells.fill(0)
	grid.spawn_cell = Vector2i(2, 4)
	grid.entrance_cell = grid.spawn_cell
	return grid

func encounter(overrides: Dictionary = {}) -> Array[Dictionary]:
	var enemy: Dictionary = {"id": "mite-001", "name": "Hollow mite", "cell": [3,4], "max_hp": 18,
		"max_stamina": 8, "offense": 4, "accuracy": 75, "evasion": 10, "armor": 1,
		"stamina_cost": 2, "attack_cost": 120, "ai": "hostile"}
	enemy.merge(overrides, true)
	return [{"id": "player", "cell": [2,4]}, enemy]

func count_event(result: RefCounted, type: String) -> int:
	return result.events.filter(func(e: Dictionary) -> bool: return e["type"] == type).size()

func _suite() -> void:
	var Session: Script = load("res://scripts/game_session/simulation_session.gd")
	var Command: Script = load("res://scripts/game_session/action_command.gd")
	var Actor: Script = load("res://scripts/combat/actor_state.gd")
	var Attack: Script = load("res://scripts/combat/attack_resolver.gd")
	var Status: Script = load("res://scripts/combat/status_effects.gd")
	var AI: Script = load("res://scripts/combat/enemy_ai.gd")
	var Scheduler: Script = load("res://scripts/game_session/turn_scheduler.gd")
	var grid: RefCounted = arena()
	var specs: Array[Dictionary] = encounter()
	var a: RefCounted = Actor.from_spec(specs[0])
	var b: RefCounted = Actor.from_spec(specs[1])
	check(Attack.damage(a,b) == 6, "physical armor subtracts before resistance")
	b.resistances["physical"] = 100
	check(Attack.damage(a,b) == 0, "100 percent resistance prevents damage")
	b.resistances["physical"] = -100
	check(Attack.damage(a,b) == 12, "vulnerability capped at double damage")
	b.resistances["physical"] = 50
	check(Attack.damage(a,b) == 3, "fractional resistance floors integer damage")
	b.armor = 100
	check(Attack.damage(a,b) == 0, "armor cannot heal or make damage negative")
	a.penetration = 200
	check(Attack.damage(a,b) == 3, "penetration cannot make effective armor negative")
	b.shield = 100
	check(Attack.damage(a,b) == 0, "flat shield absorbs after armor")
	check(not Attack.resolve(a,b,99)["hit"] and Attack.resolve(a,b,0)["hit"], "hit/miss chance bounded and deterministic")
	check(Status.apply(a,"guarded",2) and Status.evasion_bonus(a) == 10, "representative shared status modifier")
	check(Status.apply(a,"guarded",1) and a.statuses[0]["duration"] == 2, "refresh keeps longer duration")
	check(Status.apply(a,"guarded",1,"ignore") and a.statuses[0]["duration"] == 2, "ignore stacking does not duplicate")
	check(Status.apply(a,"guarded",1,"replace") and a.statuses.size() == 1, "replace stacking bounded")
	check(not Status.apply(a,"poison",2) and not Status.apply(a,"guarded",101), "unknown and excessive duration rejected")
	check(Status.tick(a).size() == 1 and a.statuses.is_empty(), "expiry removes once with event")
	var session: RefCounted = Session.new(1337,grid,"i004-v1",specs)
	var before: String = session.state_hash()
	var rng: Array = session.rng_states()
	var r: RefCounted = session.submit(Command.attack(1,"missing"))
	check(r.code == "TARGET_UNAVAILABLE" and session.state_hash() == before and session.rng_states() == rng, "missing target costs no turn/resource/RNG")
	r = session.submit(Command.attack(2,"mite-001"))
	check(r.success and r.cost == 100 and session.action_index == 1 and session.simulation_time == 100, "attack advances exactly defined time once")
	check(session.actor_view("player")["stamina"] == 9 and count_event(r,"attack_resolved") == 1, "attack spends stamina exactly once")
	check(count_event(r,"damage") + count_event(r,"miss") == 1, "one structured hit or miss")
	before = session.state_hash()
	check(session.submit(Command.attack(2,"mite-001")).code == "DUPLICATE" and session.state_hash() == before, "repeated attack ID cannot apply twice")
	r = session.submit(Command.inspect(3,Vector2i(3,4)))
	check(r.inspection.has("actor") and session.state_hash() == before, "visible monster Inspect free with combat details")
	var detached: Dictionary = session.actor_view("player")
	detached["hp"] = 0
	detached["statuses"].append({"id":"forged"})
	var view: RefCounted = session.view()
	view.actors.clear()
	check(session.state_hash() == before, "detached actor/grid/status snapshots cannot mutate combat state")
	specs[1]["hp"] = 0
	check(session.actor_view("mite-001")["alive"], "caller encounter definition detached")
	var streams_before: Array = session.rng_states()
	session.submit(Command.wait(4))
	var streams_after: Array = session.rng_states()
	check(streams_before.slice(1) == streams_after.slice(1), "combat never draws loot/events/NPC streams")
	var cost_specs: Array[Dictionary] = encounter({"ai":"none"})
	cost_specs[0]["attack_cost"] = 150
	var costly: RefCounted = Session.new(1337,grid,"i004-v1",cost_specs)
	r = costly.submit(Command.attack(1,"mite-001"))
	check(r.cost == 150 and costly.simulation_time == 150 and costly.actor_view("player")["stamina"] == 9, "actor attack cost controls scheduler horizon and charges resources once")
	var distant: RefCounted = Session.new(1,grid,"i004-v1",encounter({"cell":[6,4]}))
	before = distant.state_hash()
	check(distant.submit(Command.attack(1,"mite-001")).code == "OUT_OF_RANGE" and distant.state_hash() == before, "visible out-of-range attack free")
	var blocked_grid: RefCounted = arena()
	blocked_grid.set_terrain(Vector2i(3,4),1)
	a = Actor.from_spec({"id":"player","cell":[2,4],"attack_range":8})
	b = Actor.from_spec({"id":"enemy","cell":[5,4]})
	check(Attack.validate(blocked_grid,a,b) == "OBSTRUCTED", "ranged attack through solid wall rejected")
	var wall_specs: Array[Dictionary] = [{"id":"player","cell":[2,4],"attack_range":8},{"id":"enemy","cell":[5,4],"ai":"hostile"}]
	var hidden: RefCounted = Session.new(1,blocked_grid,"i004-v1",wall_specs)
	before = hidden.state_hash()
	r = hidden.submit(Command.attack(1,"enemy"))
	check(not r.success and hidden.state_hash() == before, "session wall-hidden target rejected with no hidden-information leak or cost")
	check(hidden.submit(Command.inspect(2,Vector2i(5,4))).inspection.is_empty(), "hidden combat Inspect reveals no actor")
	var actors: Dictionary = {"player":a,"enemy":b}
	check(AI.decide(blocked_grid,actors,b,a)["behavior"] == "idle", "enemy behind wall cannot know player location")
	b.cell = Vector2i(10,8)
	check(AI.decide(grid,actors,b,a)["behavior"] == "idle", "out-of-range enemy idle even with clear LOS")
	b.cell = Vector2i(5,4)
	check(AI.decide(grid,actors,b,a)["kind"] == "move", "visible healthy enemy pursues")
	var decision: Dictionary = AI.decide(grid,actors,b,a)
	check(AI.legal_step(grid,actors,b.id,b.cell,decision["direction"]), "pursue decision legal and unoccupied")
	b.hp = 1
	decision = AI.decide(grid,actors,b,a)
	check(decision["behavior"] == "retreat" and (b.cell+decision["direction"]-a.cell).length_squared() > (b.cell-a.cell).length_squared(), "injured sensed enemy retreats from danger")
	b.cell = Vector2i(3,4)
	check(not AI.legal_step(grid,actors,a.id,a.cell,Vector2i.RIGHT), "occupied destination blocked")
	check(not AI.legal_step(grid,actors,a.id,a.cell,Vector2i(1,1)), "occupied orthogonal corner blocks diagonal")
	var shortage_specs: Array[Dictionary] = encounter({"ai":"none"})
	shortage_specs[0]["stamina"] = 0
	var shortage: RefCounted = Session.new(1,grid,"i004-v1",shortage_specs)
	before = shortage.state_hash()
	check(shortage.submit(Command.attack(1,"mite-001")).code == "INSUFFICIENT_STAMINA" and shortage.state_hash() == before, "stamina shortage free structured rejection")
	r = shortage.submit(Command.wait(2))
	check(shortage.actor_view("player")["stamina"] == 4 and r.cost == 100 and count_event(r,"status_applied") == 1, "Wait recovers bounded stamina and applies representative guard")
	check(shortage.submit(Command.attack(3,"mite-001")).success and shortage.actor_view("player")["stamina"] == 1, "Wait recovers ability to attack")
	var lethal_specs: Array[Dictionary] = encounter({"max_hp":1,"evasion":0})
	lethal_specs[0]["accuracy"] = 200
	var lethal: RefCounted = Session.new(1337,grid,"i004-v1",lethal_specs)
	r = lethal.submit(Command.attack(1,"mite-001"))
	check(count_event(r,"actor_died") == 1 and lethal.actor_view("mite-001").is_empty(), "lethal hit emits one death event; dead target not in active view")
	check(not str(lethal.canonical_state()[6]).contains("mite-001"), "dead enemy removed from scheduler")
	before = lethal.state_hash()
	check(lethal.submit(Command.attack(2,"mite-001")).code == "TARGET_UNAVAILABLE" and lethal.state_hash() == before, "dead target cannot be hit again or consume turns")
	r = lethal.submit(Command.wait(3))
	check(count_event(r,"actor_died") == 0 and count_event(r,"attack_resolved") == 0, "defeated enemy never acts again")
	var death_specs: Array[Dictionary] = encounter({"offense":1000,"accuracy":200})
	death_specs[0]["max_hp"] = 1
	var death: RefCounted = Session.new(1337,grid,"i004-v1",death_specs)
	death.submit(Command.wait(1))
	r = death.submit(Command.wait(2))
	check(death.is_defeated() and count_event(r,"actor_died") == 1, "scheduled enemy attack can defeat player once")
	before = death.state_hash()
	check(death.submit(Command.wait(3)).code == "PLAYER_DEFEATED" and death.state_hash() == before, "defeat prevents all further gameplay")
	check(not str(death.canonical_state()[6]).contains("player"), "dead player removed from active scheduler")
	var schedule: RefCounted = Scheduler.new()
	schedule.add_actor("dead")
	schedule.remove_actor("dead")
	check(schedule.preview(100)["ready"].is_empty(), "scheduler remove excludes future readiness")
	for seed_value in range(50):
		var generated: RefCounted = Session.new(seed_value,null,"i004-v1")
		var enemy: Dictionary = generated.actor_record("mite-001")
		check(not enemy.is_empty() and enemy["cell"] != [generated.player_cell.x,generated.player_cell.y] and generated.actor_record("player")["hp"] == 30, "safe reachable encounter seeded placement " + str(seed_value))
		var generated_grid: RefCounted = load("res://scripts/world/local_region_generator.gd").generate(seed_value)
		var destination := Vector2i(enemy["cell"][0],enemy["cell"][1])
		var distances: Dictionary = {generated.player_cell:0}
		var queue: Array[Vector2i] = [generated.player_cell]
		var cursor: int = 0
		while cursor < queue.size() and not distances.has(destination):
			var at: Vector2i = queue[cursor]
			cursor += 1
			for direction: Vector2i in AI.DIRECTIONS:
				var next: Vector2i = at+direction
				if not distances.has(next) and generated_grid.can_step(at,direction):
					distances[next] = distances[at]+1
					queue.append(next)
		check(generated_grid.is_walkable(destination) and distances.get(destination,-1) >= 6, "encounter reachable over legal terrain with safe initial separation")
		check(generated.state_hash() == Session.new(seed_value,null,"i004-v1").state_hash(), "same seed actors and RNG deterministic " + str(seed_value))
	var sensory: RefCounted = Session.new(3,blocked_grid,"i004-v1",wall_specs)
	var enemy_before: Dictionary = sensory.actor_record("enemy")
	for request in range(1,6):
		var sensory_result: RefCounted = sensory.submit(Command.wait(request))
		check(sensory.actor_record("enemy")["cell"] == enemy_before["cell"] and sensory.actor_record("enemy")["behavior"] == "idle", "scheduled unseen enemy does not track hidden player")
		check(count_event(sensory_result,"enemy_moved") == 0, "hidden idle enemy emits no positional information")
		check(not sensory_result.events.any(func(event: Dictionary) -> bool: return event.get("actor_id", "") == "enemy"), "hidden enemy identity/readiness not published to UI")
	var boundary_grid: RefCounted = arena()
	boundary_grid.set_terrain(Vector2i(4,3),1)
	var boundary: RefCounted = Session.new(1,boundary_grid,"i004-v1",encounter({"cell":[5,4],"hp":6}))
	check(not boundary.actor_view("mite-001").is_empty(), "retreat boundary starts visible")
	boundary.submit(Command.wait(1))
	var vanished: RefCounted = boundary.submit(Command.wait(2))
	check(boundary.actor_view("mite-001").is_empty(), "retreat can leave player line of sight")
	check(not vanished.events.any(func(event: Dictionary) -> bool: return event.has("to") and event["to"] == [6,3]), "retreat event must not reveal hidden destination")
	check(count_event(vanished,"enemy_left_sight") == 1, "visibility boundary emits departure instead of hidden movement")
	var wide_grid: RefCounted = load("res://scripts/world/region_grid.gd").new(15,9)
	wide_grid.cells.fill(0)
	wide_grid.spawn_cell = Vector2i(2,4)
	var entering: RefCounted = Session.new(1,wide_grid,"i004-v1",encounter({"cell":[12,4],"detection":12}))
	entering.submit(Command.wait(1))
	entering.submit(Command.wait(2))
	var entered: RefCounted = entering.submit(Command.wait(3))
	check(count_event(entered,"enemy_entered_sight") == 1, "larger justified sensory radius uses arrival event")
	check(not entered.events.any(func(event: Dictionary) -> bool: return event.has("from") and event["from"] == [11,4]), "arrival event cannot disclose previously hidden origin")
	var invalid_actor: RefCounted = Command.attack(99,"player","mite-001")
	before = sensory.state_hash()
	check(sensory.submit(invalid_actor).code == "INVALID_ACTOR" and sensory.state_hash() == before, "UI cannot command hostile actors")
	var crowded: RefCounted = Session.new(1,grid,"i004-v1",encounter())
	before = crowded.state_hash()
	check(crowded.submit(Command.move(1,Vector2i.RIGHT)).code == "OCCUPIED" and crowded.state_hash() == before, "occupied player move free")
	check(crowded.submit(Command.move(2,Vector2i(1,1))).code == "OCCUPIED" and crowded.state_hash() == before, "occupied diagonal corner free")
	var budget_specs: Array[Dictionary] = encounter({"attack_cost":1})
	var budget: RefCounted = Session.new(1,grid,"i004-v1",budget_specs)
	before = budget.state_hash()
	check(budget.submit(Command.attack(1,"mite-001")).code == "BUDGET_EXCEEDED" and budget.state_hash() == before, "scheduler overload rejects before damage/resources/RNG")
	var two_turn_specs: Array[Dictionary] = encounter({"max_hp":1,"attack_cost":50})
	two_turn_specs[0]["accuracy"] = 200
	var two_turn: RefCounted = Session.new(1337,grid,"i004-v1",two_turn_specs)
	r = two_turn.submit(Command.attack(1,"mite-001"))
	check(count_event(r,"actor_died") == 1 and count_event(r,"attack_resolved") == 1 and count_event(r,"actor_ready") == 1, "lethal immediate action skips already-previewed enemy slots")
	var extreme: RefCounted = Actor.from_spec({"id":"clamped","cell":[0,0],"max_hp":2,"hp":999,"stamina":-99,"resistances":{"physical":999}})
	check(extreme.hp == 2 and extreme.stamina == 0 and extreme.resistances["physical"] == 100, "actor content cannot introduce invalid HP/resource/resistance bounds")
	var dead_actor: RefCounted = Actor.from_spec({"id":"dead","cell":[0,0],"hp":0})
	check(Attack.validate(grid,dead_actor,a) == "ACTOR_DEAD" and Attack.validate(grid,a,dead_actor) == "TARGET_UNAVAILABLE", "dead attackers/targets revalidated by shared resolver")
	var branch_a: RefCounted = Session.new(9,grid,"i004-v1",encounter())
	var branch_b: RefCounted = Session.new(9,grid,"i004-v1",encounter({"hp":17}))
	check(branch_a.state_hash() != branch_b.state_hash(), "canonical world hash covers combat HP")
	var runtime: RefCounted = Session.new(1337,null,"i004-v1")
	var runtime_grid: RefCounted = load("res://scripts/world/local_region_generator.gd").generate(1337)
	var saw_retreat: bool = false
	var wins: int = 0
	for request in range(1,101):
		var enemy: Dictionary = runtime.actor_record("mite-001")
		if not enemy["alive"]:
			wins += 1
			break
		if runtime.is_defeated():
			break
		var target := Vector2i(enemy["cell"][0],enemy["cell"][1])
		var delta: Vector2i = target-runtime.player_cell
		var outcome: RefCounted
		if maxi(absi(delta.x),absi(delta.y)) == 1 and not runtime.actor_view("mite-001").is_empty():
			outcome = runtime.submit(Command.attack(request,"mite-001")) if runtime.actor_view("player")["stamina"] >= 3 else runtime.submit(Command.wait(request))
		else:
			var queue: Array[Vector2i] = [runtime.player_cell]
			var first: Dictionary = {runtime.player_cell:Vector2i.ZERO}
			var cursor: int = 0
			var direction := Vector2i.ZERO
			while cursor < queue.size():
				var at: Vector2i = queue[cursor]
				cursor += 1
				var distance: Vector2i = target-at
				if maxi(absi(distance.x),absi(distance.y)) == 1 and load("res://scripts/game_session/visibility.gd").has_line(runtime_grid,at,target):
					direction = first[at]
					break
				for step: Vector2i in AI.DIRECTIONS:
					var next: Vector2i = at+step
					if next != target and not first.has(next) and runtime_grid.can_step(at,step):
						first[next] = step if at == runtime.player_cell else first[at]
						queue.append(next)
			outcome = runtime.submit(Command.move(request,direction))
		for event: Dictionary in outcome.events:
			if event["type"] == "enemy_moved" and event["behavior"] == "retreat":
				saw_retreat = true
	check(wins == 1 and not runtime.is_defeated(), "actual seed1337 default encounter is winnable through production commands")
	check(saw_retreat, "default encounter exercises injured retreat before defeat")
	_replay(Session,Command)

func _replay(Session: Script, Command: Script) -> void:
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/i004_combat_v1.json"))
	var actors: Array[Dictionary] = []
	for actor: Dictionary in spec["actors"]:
		actors.append(actor)
	var first: RefCounted = Session.new(int(spec["seed"]),arena(),spec["content_version"],actors)
	var second: RefCounted = Session.new(int(spec["seed"]),arena(),spec["content_version"],actors)
	var events: Array = []
	for record: Dictionary in spec["commands"]:
		var r: RefCounted = first.submit(Command.from_record(record))
		var other: RefCounted = second.submit(Command.from_record(record))
		check(r.record() == other.record() and first.state_hash() == second.state_hash(), "combat replay prefix events/state deterministic")
		events.append_array(r.events)
	check(first.is_defeated(), "fixed replay ends in temporary player defeat")
	check(events.filter(func(e: Dictionary) -> bool: return e["type"] == "actor_died").size() == 1, "replay one death despite later rejected inputs")
	print("COMBAT_FIXTURE_HASH: ",first.state_hash(), " EVENTS: ",JSON.stringify(events).sha256_text())
	check(first.state_hash() == spec["sha256"], "versioned full combat canonical golden hash")
	check(JSON.stringify(events).sha256_text() == spec["events_sha256"], "combat golden event/damage history")
	check(events.any(func(e: Dictionary) -> bool: return e["type"] == "actor_died"), "replay includes lethal outcome")
	check(events.any(func(e: Dictionary) -> bool: return e["type"] == "enemy_moved"), "replay includes enemy approach")
	check(events.any(func(e: Dictionary) -> bool: return e["type"] == "damage"), "replay includes damage")
