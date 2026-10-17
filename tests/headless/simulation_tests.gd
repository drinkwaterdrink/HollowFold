extends SceneTree

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func _run() -> void:
	check(ResourceLoader.exists("res://scripts/game_session/simulation_session.gd"), "simulation session exists")
	if failures == 0:
		_suite()
	print("SIMULATION_TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)


func _suite() -> void:
	var Session: Script = load("res://scripts/game_session/simulation_session.gd")
	var Command: Script = load("res://scripts/game_session/action_command.gd")
	var Grid: Script = load("res://scripts/world/region_grid.gd")
	var Scheduler: Script = load("res://scripts/game_session/turn_scheduler.gd")
	var Rng: Script = load("res://scripts/game_session/rng_streams.gd")
	var Sight: Script = load("res://scripts/game_session/visibility.gd")
	var grid: RefCounted = Grid.new(7, 7)
	grid.cells.fill(0)
	grid.spawn_cell = Vector2i(2, 2)
	grid.entrance_cell = grid.spawn_cell
	grid.set_terrain(Vector2i(3, 2), 1)
	grid.set_terrain(Vector2i(2, 3), 2)
	var session: RefCounted = Session.new(42, grid)
	var published: Array = []
	session.result_published.connect(func(result: RefCounted) -> void: published.append(result))
	var initial: String = session.state_hash()
	var rng_before: Array = session.rng_states()
	var result: RefCounted = session.submit(Command.move(1, Vector2i.RIGHT))
	check(result.code == "BLOCKED" and session.action_index == 0 and session.simulation_time == 0, "blocked wall costs no time")
	check(session.state_hash() == initial, "rejection leaves canonical world unchanged")
	result = session.submit(Command.move(2, Vector2i(1, -1)))
	check(result.code == "CORNER_BLOCKED" and session.player_cell == Vector2i(2, 2) and session.action_index == 0, "invalid diagonal leaves state/time")
	result = session.submit(Command.move(3, Vector2i.DOWN))
	check(result.code == "BLOCKED" and session.simulation_time == 0, "water costs no time")
	result = session.submit(Command.move(4, Vector2i(-1, 0)))
	check(result.success and result.cost == 100 and session.player_cell == Vector2i(1, 2), "valid Move commits one cell with defined cost")
	check(session.action_index == 1 and session.simulation_time == 100, "Move advances action index and time exactly once")
	check(published.size() == 4, "one published result per top-level command")
	var committed: String = session.state_hash()
	result = session.submit(Command.move(4, Vector2i.LEFT))
	check(result.code == "DUPLICATE" and session.state_hash() == committed, "duplicate ID cannot reapply action")
	result = session.submit(Command.wait(5))
	check(result.success and result.cost == 100 and session.action_index == 2 and session.simulation_time == 200, "Wait predictable cost")
	var before_inspect: String = session.state_hash()
	result = session.submit(Command.inspect(6, session.player_cell))
	check(result.success and result.cost == 0 and result.inspection.get("terrain") == 0, "visible Inspect returns terrain without action cost")
	check(session.state_hash() == before_inspect and session.rng_states() == rng_before, "Inspect changes neither canonical world nor RNG")
	result = session.submit(Command.inspect(7, Vector2i(5, 2)))
	check(result.code == "NOT_VISIBLE" and result.inspection.is_empty(), "wall-hidden Inspect reveals no terrain")
	var detached: RefCounted = session.view()
	detached.player_cell = Vector2i(6, 6)
	detached.cells.fill(0)
	detached.visible.fill(1)
	check(session.state_hash() == before_inspect, "scene read view cannot mutate authoritative state")
	grid.cells.fill(0)
	check(session.state_hash() == before_inspect, "caller-supplied fixture cannot mutate authoritative terrain")
	var invalid: RefCounted = Command.move(8, Vector2i(2, 0))
	check(session.submit(invalid).code == "INVALID_COMMAND", "invalid direction rejected")
	invalid = Command.wait(9)
	invalid.actor_id = "missing"
	check(session.submit(invalid).code == "INVALID_ACTOR", "unknown actor rejected")
	invalid = Command.wait(10)
	invalid.kind = 99
	check(session.submit(invalid).code == "INVALID_COMMAND", "unknown command kind rejected")
	check(session.submit(null).code == "INVALID_COMMAND", "null command rejected safely")
	var last_sequence: int = 0
	for outcome: RefCounted in published:
		for event: Dictionary in outcome.events:
			check(event["sequence"] == last_sequence + 1, "stable contiguous event ordering")
			last_sequence += 1
	check(published[3].events.map(func(event: Dictionary) -> String: return event["type"]) == ["command_accepted", "player_moved", "visibility_changed", "actor_ready", "turn_completed"], "successful move event phase order")
	var nested: Array = []
	var reentrant: RefCounted = Session.new(42)
	reentrant.result_published.connect(func(_outcome: RefCounted) -> void: nested.append(reentrant.submit(Command.wait(2))))
	reentrant.submit(Command.wait(1))
	check(nested.size() == 1 and nested[0].code == "BUSY" and reentrant.action_index == 1, "reentrant callback is bounded and cannot double commit")
	for connection: Dictionary in reentrant.result_published.get_connections():
		reentrant.result_published.disconnect(connection["callable"])
	var scheduler: RefCounted = Scheduler.new()
	check(scheduler.add_actor("slow", 100, 50) and scheduler.add_actor("fast", 100, 200), "scheduler accepts unequal speed profiles")
	var plan: Dictionary = scheduler.preview(200)
	check(plan["ok"] and plan["ready"].size() == 5, "different energy rates yield bounded readiness counts")
	check(plan["ready"][0] == {"actor_id": "fast", "time": 50} and plan["ready"][4] == {"actor_id": "slow", "time": 200}, "chronological readiness and stable actor-ID ties")
	scheduler.commit(plan)
	var schedule_before: Array = scheduler.snapshot()
	check(not scheduler.preview(100000)["ok"] and scheduler.snapshot() == schedule_before, "budget overflow previews fail atomically")
	check(not scheduler.add_actor("zero", 0, 100), "invalid zero action cost rejected")
	var costly: RefCounted = Scheduler.new()
	costly.add_actor("costly", 200, 100)
	check(costly.preview(100)["ready"].is_empty() and costly.preview(200)["ready"].size() == 1, "different action costs affect readiness")
	var rng_a: RefCounted = Rng.new(42)
	var rng_b: RefCounted = Rng.new(42)
	randi() # Presentation/global randomness does not influence named streams.
	check(rng_a.draw("combat") == rng_b.draw("combat"), "named RNG reproducible despite visual/global random calls")
	var loot_before: String = str(rng_a.snapshot()[1])
	rng_a.draw("combat")
	check(str(rng_a.snapshot()[1]) == loot_before, "named streams isolated")
	var sight_grid: RefCounted = Grid.new(9, 9)
	sight_grid.cells.fill(0)
	sight_grid.set_terrain(Vector2i(4, 3), 1)
	check(Sight.has_line(sight_grid, Vector2i(3, 3), Vector2i(4, 3)), "blocking wall itself visible")
	check(not Sight.has_line(sight_grid, Vector2i(3, 3), Vector2i(5, 3)), "wall occludes beyond")
	check(not Sight.has_line(sight_grid, Vector2i(3, 3), Vector2i(4, 4)), "no diagonal corner peeking")
	sight_grid.set_terrain(Vector2i(4, 3), 2)
	check(Sight.has_line(sight_grid, Vector2i(3, 3), Vector2i(5, 3)), "water transmits sight")
	var fog: RefCounted = Session.new(1337)
	var fog_view: RefCounted = fog.view()
	check(fog_view.terrain_at(Vector2i(30, 38)) == 4, "undiscovered read-view terrain masked")
	check(fog.submit(Command.inspect(1, Vector2i(30, 38))).inspection.is_empty(), "undiscovered Inspect has empty payload")
	var open_grid: RefCounted = Grid.new(25, 25)
	open_grid.cells.fill(0)
	open_grid.spawn_cell = Vector2i(12, 12)
	var memory: RefCounted = Session.new(7, open_grid)
	var rng_memory: Array = memory.rng_states()
	for id in range(1, 10):
		check(memory.submit(Command.move(id, Vector2i.RIGHT)).success, "visibility-memory walk commits")
	var remembered: RefCounted = memory.view()
	var origin_index: int = 12 * 25 + 12
	check(remembered.discovered[origin_index] == 1 and remembered.visible[origin_index] == 0 and remembered.terrain_at(Vector2i(12, 12)) == 0, "explored terrain retained beyond current sight radius")
	check(memory.submit(Command.inspect(10, Vector2i(12, 12))).code == "NOT_VISIBLE", "remembered-but-unseen tile cannot be live-inspected")
	check(memory.rng_states() == rng_memory and memory.simulation_time == 900, "visibility/rejected Inspect consume no RNG/extra time")
	check(memory.canonical_state()[7] == memory.rng_states() and memory.canonical_state()[8] == remembered.visible.hex_encode() and memory.canonical_state()[9] == remembered.discovered.hex_encode(), "canonical state explicitly covers RNG, current visibility and fog memory")
	# Golden replay is verified against both fresh sessions and a committed fixture.
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/i003_replay_v1.json"))
	var replay_a: RefCounted = Session.new(int(fixture["seed"]))
	var replay_b: RefCounted = Session.new(int(fixture["seed"]))
	var event_order_a: Array = []
	var event_order_b: Array = []
	for item: Dictionary in fixture["commands"]:
		var command: RefCounted = Command.from_record(item)
		var out_a: RefCounted = replay_a.submit(command)
		var out_b: RefCounted = replay_b.submit(Command.from_record(item))
		event_order_a.append(out_a.record())
		event_order_b.append(out_b.record())
		check(replay_a.state_hash() == replay_b.state_hash(), "identical command prefix -> identical canonical state")
	check(event_order_a == event_order_b, "replay results/events identical")
	check(replay_a.state_hash() == fixture["sha256"], "canonical replay hash fixture")
	check(replay_a.action_index == int(fixture["action_index"]) and replay_a.simulation_time == int(fixture["time"]), "replay fixture action/time")
	check(replay_a.state_hash() != Session.new(int(fixture["seed"])).state_hash(), "hash covers simulation state beyond terrain")
	check(Session.new(1337, null, "other-content").state_hash() != Session.new(1337).state_hash(), "canonical hash includes content version")
