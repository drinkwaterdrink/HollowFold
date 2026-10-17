extends SceneTree

const Session = preload("res://scripts/game_session/simulation_session.gd")
const Grid = preload("res://scripts/world/region_grid.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)

func install_encounter(screen: Control, lethal: bool = false) -> RefCounted:
	var grid := Grid.new(11,9)
	grid.cells.fill(0)
	grid.spawn_cell = Vector2i(2,4)
	grid.entrance_cell = grid.spawn_cell
	var specs: Array[Dictionary] = [{"id":"player","cell":[2,4],"accuracy":200},
		{"id":"mite-001","name":"Hollow mite","cell":[3,4],"max_hp":18,"ai":"hostile","attack_cost":120}]
	if lethal:
		specs[0]["max_hp"] = 1
		specs[1]["offense"] = 1000
		specs[1]["accuracy"] = 200
	var old: RefCounted = screen.get("simulation")
	old.result_published.disconnect(screen._on_result)
	var session := Session.new(1337,grid,"i004-v1",specs)
	screen.set("simulation",session)
	session.result_published.connect(screen._on_result)
	screen.set("_request_id",0)
	screen.call("_clear_gestures")
	screen.set("region",session.view())
	screen.get_node("%RegionWorld").display_region(session.view())
	screen.call("_update_labels","Combat fixture")
	return session

func _run() -> void:
	var boot: Control = load("res://scenes/boot.tscn").instantiate()
	root.add_child(boot)
	await process_frame
	boot.get_node("%NewRunButton").pressed.emit()
	boot.get_node("%ExploreRegion").pressed.emit()
	await process_frame
	var screen: Control = boot.get_node("%RegionScreen")
	check(screen.has_node("%Attack"), "explicit combat button exists")
	if failures:
		boot.queue_free()
		await process_frame
		print("COMBAT_SCENE_SMOKE: %d checks, %d failures" % [checks,failures])
		quit(1)
		return
	var session: RefCounted = install_encounter(screen)
	screen.call("inspect_at",Vector2i(3,4))
	check(screen.get("selected_target") == "mite-001" and session.simulation_time == 0, "map Inspect selects visible identity without turn")
	await process_frame
	screen.get_node("%Attack").pressed.emit()
	for index in range(8):
		screen.get_node("%Attack").pressed.emit()
	check(session.action_index == 1 and session.actor_view("player")["stamina"] == 9, "rapid attack signals spend once")
	check(screen.get_node("%CombatLog").text.contains("damage"), "readable damage feedback displayed")
	check(screen.get_node("%PlayerVitals").text.contains("30/30"), "player HP visible")
	await process_frame
	var before: String = session.state_hash()
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.index = 0
	screen._input(touch)
	touch = touch.duplicate()
	touch.index = 1
	screen._input(touch)
	screen.get_node("%Attack").pressed.emit()
	check(session.state_hash() == before, "overlap guard also protects Attack")
	screen.notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	await process_frame
	screen.get_node("%Attack").pressed.emit()
	check(session.action_index == 2, "Attack recovers from focus/overlap")
	before = session.state_hash()
	for frame in range(60):
		await process_frame
	check(session.state_hash() == before, "combat actors do not advance from 60 idle frames")
	screen.set("selected_target","missing")
	screen.get_node("%Attack").pressed.emit()
	check(session.state_hash() == before and screen.get_node("%RegionStatus").text.contains("no time"), "unavailable target reports free rejection")
	await process_frame
	screen.call("wait_action")
	check(session.action_index == 3, "controls recover after invalid attack")
	boot.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	before = session.state_hash()
	await process_frame
	screen.call("attack_action")
	check(session.state_hash() == before, "hidden combat controls/menu do not advance turns")
	boot.get_node("%ExploreRegion").pressed.emit()
	await process_frame
	session = install_encounter(screen,true)
	screen.call("wait_action")
	await process_frame
	screen.call("wait_action")
	check(session.is_defeated() and screen.get_node("%RegionStatus").text.contains("Defeated"), "temporary player defeat clearly presented")
	check(screen.get_node("%Attack").disabled and screen.get_node("%Wait").disabled and screen.get_node("%East").disabled, "dead player action controls disabled")
	before = session.state_hash()
	await process_frame
	screen.call("attack_action")
	check(session.state_hash() == before, "direct adapter cannot bypass defeat")
	screen.get_node("%Regenerate").pressed.emit()
	session = screen.get("simulation")
	check(not session.is_defeated() and session.action_index == 0 and session.actor_view("player")["hp"] == 30, "regenerate clears temporary defeat and restores actors")
	check(not screen.get_node("%Attack").disabled and screen.get("selected_target").is_empty(), "regeneration unlocks combat input and clears stale target")
	var fresh: RefCounted = Session.new(1337,null,"i004-v1")
	check(session.state_hash() == fresh.state_hash(), "regenerate restores full combat canonical state and RNG")
	screen.get_node("%NextSeed").pressed.emit()
	session = screen.get("simulation")
	check(session.state_hash() == Session.new(1338,null,"i004-v1").state_hash(), "next seed has fresh deterministic encounter")
	boot.queue_free()
	await process_frame
	print("COMBAT_SCENE_SMOKE: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
