extends SceneTree

const Command = preload("res://scripts/game_session/action_command.gd")
var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func touch(screen: Control, index: int, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	screen.call("_input", event)


func _run() -> void:
	var scene: PackedScene = load("res://scenes/boot.tscn")
	var boot: Control = scene.instantiate()
	root.add_child(boot)
	await process_frame
	boot.get_node("%NewRunButton").pressed.emit()
	boot.get_node("%ExploreRegion").pressed.emit()
	await process_frame
	await process_frame
	var screen: Control = boot.get_node("%RegionScreen")
	var simulation: RefCounted = screen.get("simulation")
	var initial: String = simulation.state_hash()
	screen.get_node("%Wait").pressed.emit()
	screen.get_node("%Wait").pressed.emit()
	screen.get_node("%East").pressed.emit()
	check(simulation.action_index == 1 and simulation.simulation_time == 100, "rapid overlapping button signals admit one command per input frame")
	check(screen.get("result_history").size() == 1, "one command outcome applied once")
	var idle_hash: String = simulation.state_hash()
	for frame in range(120):
		await process_frame
	check(simulation.state_hash() == idle_hash, "120 rendering frames advance no gameplay state")
	var before: Vector2i = simulation.player_cell
	screen.call("move", Vector2i.LEFT) # Known wall at seed 1337 spawn (3,11).
	check(simulation.action_index == 1 and simulation.player_cell == before, "rejected input costs no time")
	await process_frame
	screen.get_node("%Wait").pressed.emit()
	check(simulation.action_index == 2 and simulation.simulation_time == 200, "controls recover after rejected input")
	await process_frame
	var inspect_hash: String = simulation.state_hash()
	var rng_before: Array = simulation.rng_states()
	screen.call("inspect_at", simulation.player_cell)
	check(simulation.state_hash() == inspect_hash and simulation.rng_states() == rng_before, "UI Inspect has no world/time/RNG mutation")
	await process_frame
	screen.call("inspect_at", Vector2i(30, 38))
	var history: Array = screen.get("result_history")
	check(history.back()["code"] == "NOT_VISIBLE" and history.back()["inspection"].is_empty(), "hidden UI Inspect reveals no payload")
	check(simulation.state_hash() == inspect_hash, "hidden Inspect leaves world unchanged")
	await process_frame
	screen.call("move", Vector2i.RIGHT)
	check(simulation.player_cell == before + Vector2i.RIGHT and simulation.action_index == 3, "existing pad adapter routes movement through simulation")
	var read_view: RefCounted = screen.get("region")
	read_view.player_cell = Vector2i.ZERO
	read_view.cells.fill(0)
	check(simulation.player_cell == before + Vector2i.RIGHT, "UI view is detached")
	# Primary/secondary touch lifecycles and cancellation/reset do not cause actions.
	await process_frame
	var touch_hash: String = simulation.state_hash()
	touch(screen, 0, true)
	touch(screen, 0, true)
	touch(screen, 1, true)
	check(screen.get("_primary_touch") == 0 and screen.get("_ignored_touches").has(1), "secondary and duplicate presses cannot claim primary gesture")
	screen.get_node("%Wait").pressed.emit()
	check(simulation.state_hash() == touch_hash, "overlapping touch cannot submit an emulated button action")
	touch(screen, 1, false)
	touch(screen, 0, false)
	await process_frame
	check(screen.get("_primary_touch") == -1 and screen.get("_ignored_touches").is_empty(), "touch release unlocks without stale ownership")
	touch(screen, 2, true)
	screen.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(screen.get("_primary_touch") == -1, "focus loss clears input latch")
	check(simulation.state_hash() == touch_hash, "gesture bookkeeping consumes no turns")
	boot.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	for frame in range(30):
		await process_frame
	screen.call("wait_action")
	check(simulation.state_hash() == touch_hash, "menu navigation/hidden input/render frames consume no turns")
	boot.get_node("%ExploreRegion").pressed.emit()
	screen.get_node("%Regenerate").pressed.emit()
	simulation = screen.get("simulation")
	check(simulation.state_hash() == initial and simulation.action_index == 0, "regeneration resets all canonical state including RNG/scheduler/fog")
	screen.get_node("%NextSeed").pressed.emit()
	simulation = screen.get("simulation")
	check(screen.get("seed_value") == 1338 and simulation.state_hash() != initial, "next seed resets a distinct simulation")
	boot.queue_free()
	await process_frame
	print("SIMULATION_SCENE_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
