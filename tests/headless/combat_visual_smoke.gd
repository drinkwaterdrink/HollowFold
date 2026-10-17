extends "res://tests/headless/simulation_visual_smoke.gd"
## Real desktop GUI, generated encounter plus controlled defeat fixture.

const Grid = preload("res://scripts/world/region_grid.gd")
const Generator = preload("res://scripts/world/local_region_generator.gd")
const Session = preload("res://scripts/game_session/simulation_session.gd")
const AI = preload("res://scripts/combat/enemy_ai.gd")

func next_step(grid: RefCounted, start: Vector2i, target: Vector2i) -> Vector2i:
	var queue: Array[Vector2i] = [start]
	var first: Dictionary = {start: Vector2i.ZERO}
	var index: int = 0
	while index < queue.size():
		var cell: Vector2i = queue[index]
		index += 1
		if maxi(absi(cell.x-target.x),absi(cell.y-target.y)) == 1 and load("res://scripts/game_session/visibility.gd").has_line(grid,cell,target):
			return first[cell]
		for direction: Vector2i in AI.DIRECTIONS:
			var next: Vector2i = cell+direction
			if next != target and not first.has(next) and grid.can_step(cell,direction):
				first[next] = direction if cell == start else first[cell]
				queue.append(next)
	return Vector2i.ZERO

func tap_cell(screen: Control, cell: Vector2i) -> void:
	var viewport: SubViewport = screen.get_node("%MapViewport")
	var container: SubViewportContainer = screen.get_node("%MapContainer")
	var region: RefCounted = screen.get("region")
	var point: Vector2 = container.get_global_transform() * (viewport.get_canvas_transform() * region.cell_to_world(cell))
	check(container.get_global_rect().has_point(point), "target lies inside clipped map")
	pointer(point,true)
	pointer(point,false)
	await _settle()

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("combat_visual_smoke needs rendering")
		quit(1)
		return
	var boot: Control = load("res://scenes/boot.tscn").instantiate()
	root.add_child(boot)
	await _settle()
	await _click(boot.get_node("%NewRunButton"))
	await _click(boot.get_node("%ExploreRegion"))
	var screen: Control = boot.get_node("%RegionScreen")
	var session: RefCounted = screen.get("simulation")
	var terrain: RefCounted = Generator.generate(1337)
	_capture("i004-initial")
	for step in range(40):
		var enemy: Dictionary = session.actor_record("mite-001")
		var target := Vector2i(enemy["cell"][0],enemy["cell"][1])
		var direction: Vector2i = next_step(terrain,session.player_cell,target)
		if direction == Vector2i.ZERO:
			break
		screen.call("move",direction)
		await _settle()
	var visible: Dictionary = session.actor_view("mite-001")
	check(not visible.is_empty(), "generated reachable encounter visible after exploration")
	var cell := Vector2i(visible["cell"][0],visible["cell"][1])
	var before: String = session.state_hash()
	await tap_cell(screen,cell)
	check(screen.get("selected_target") == "mite-001" and session.state_hash() == before, "real map pointer selects without time")
	_capture("i004-target")
	var index: int = session.action_index
	await _click(screen.get_node("%Attack"))
	check(session.action_index == index+1, "real Attack button commits one combat action")
	check(screen.get_node("%CombatLog").text.contains("damage") or screen.get_node("%CombatLog").text.contains("miss"), "combat outcome readable")
	_capture("i004-combat")
	for size in [Vector2i(450,800),Vector2i(360,640),Vector2i(450,1000)]:
		root.size = size
		await _settle()
		for name in ["Attack","PlayerVitals","CombatLog","North","South","Regenerate","NextSeed"]:
			check(Rect2(Vector2.ZERO,boot.size).encloses(screen.get_node("%"+name).get_global_rect()), "combat UI fits portrait: " + name + " " + str(size))
		_capture("i004-" + str(size.x) + "x" + str(size.y))
	# Duplicate and touch overlap through actual viewport routing, then recovery.
	index = session.action_index
	var point: Vector2 = screen.get_node("%Attack").get_global_rect().get_center()
	for click in range(5):
		pointer(point,true)
		pointer(point,false)
	await _settle()
	check(session.action_index == index+1, "five same-frame GUI attack clicks execute once")
	before = session.state_hash()
	routed_touch(point,0,true)
	routed_touch(point,1,true)
	routed_touch(point,0,false)
	routed_touch(point,1,false)
	pointer(point,true)
	pointer(point,false)
	await _settle()
	check(session.state_hash() == before, "routed overlapping touch/emulated mouse cannot add attacks")
	# Controlled lethal encounter uses the same production scene and combat pipeline.
	var fixture := Grid.new(11,9)
	fixture.cells.fill(0)
	fixture.spawn_cell = Vector2i(2,4)
	var actors: Array[Dictionary] = [{"id":"player","cell":[2,4],"max_hp":1},
		{"id":"mite-001","name":"Hollow mite","cell":[3,4],"offense":1000,"accuracy":200,"ai":"hostile","attack_cost":120}]
	session.result_published.disconnect(screen._on_result)
	session = Session.new(1337,fixture,"i004-v1",actors)
	screen.set("simulation",session)
	session.result_published.connect(screen._on_result)
	screen.set("_request_id",0)
	screen.call("_clear_gestures")
	screen.set("selected_target", "")
	screen.set("region",session.view())
	screen.get_node("%RegionWorld").display_region(session.view())
	screen.call("_update_labels","Controlled defeat fixture")
	await _click(screen.get_node("%Wait"))
	await _click(screen.get_node("%Wait"))
	check(session.is_defeated() and screen.get_node("%Attack").disabled, "rendered temporary defeat locks combat controls")
	_capture("i004-defeat")
	await _click(screen.get_node("%Regenerate"))
	session = screen.get("simulation")
	check(not session.is_defeated() and session.action_index == 0, "pointer regenerate recovers from defeat")
	await _click(screen.get_node("%RegionBack"))
	check(boot.get_node("%NewRunPanel").visible, "Back remains operational after combat")
	boot.queue_free()
	await process_frame
	print("COMBAT_VISUAL_SMOKE: generated encounter, map selection, Attack, routed overlap, portrait, defeat; %d failures" % failures)
	quit(1 if failures else 0)
