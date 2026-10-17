extends "res://tests/headless/visual_smoke.gd"
## Real GUI routing, without claiming physical Android input observation.


func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func pointer(position: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = position
	event.pressed = pressed
	root.push_input(event, true)


func routed_touch(position: Vector2, index: int, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.position = position
	event.index = index
	event.pressed = pressed
	root.push_input(event, true)


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("simulation_visual_smoke requires real rendering")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://.local/verification")
	var scene: PackedScene = load("res://scenes/boot.tscn")
	var boot: Control = scene.instantiate()
	root.add_child(boot)
	await _settle()
	await _click(boot.get_node("%NewRunButton"))
	await _click(boot.get_node("%ExploreRegion"))
	var screen: Control = boot.get_node("%RegionScreen")
	var simulation: RefCounted = screen.get("simulation")
	_capture("i003-initial-fog")
	await _click(screen.get_node("%Wait"))
	check(simulation.action_index == 1 and simulation.simulation_time == 100, "actual centre Wait button costs 100")
	var before: String = simulation.state_hash()
	var viewport: SubViewport = screen.get_node("%MapViewport")
	var container: SubViewportContainer = screen.get_node("%MapContainer")
	var view: RefCounted = screen.get("region")
	var local: Vector2 = viewport.get_canvas_transform() * view.cell_to_world(simulation.player_cell)
	var position: Vector2 = container.get_global_transform() * local
	pointer(position, true)
	pointer(position, false)
	await _settle()
	var history: Array = screen.get("result_history")
	check(history.back()["code"] == "OK" and not history.back()["inspection"].is_empty(), "map pointer Inspect returns visible tile details")
	check(simulation.state_hash() == before, "map pointer Inspect costs no time or RNG")
	_capture("i003-visible-inspect")
	# Find an undiscovered pixel within the real clipped map and inspect it.
	var hidden_pixel := Vector2(-1, -1)
	for y in range(4, viewport.size.y, 12):
		for x in range(4, viewport.size.x, 12):
			var cell: Vector2i = view.world_to_cell(viewport.get_canvas_transform().affine_inverse() * Vector2(x, y))
			if view.contains(cell) and view.terrain_at(cell) == 4:
				hidden_pixel = Vector2(x, y)
				break
		if hidden_pixel.x >= 0:
			break
	check(hidden_pixel.x >= 0, "unknown area present in initial map viewport")
	position = container.get_global_transform() * hidden_pixel
	pointer(position, true)
	pointer(position, false)
	await _settle()
	history = screen.get("result_history")
	check(history.back()["code"] == "NOT_VISIBLE" and history.back()["inspection"].is_empty(), "unknown pointer Inspect never discloses terrain")
	check(simulation.state_hash() == before, "hidden Inspect costs no time")
	# Several complete pointer clicks in one input frame yield a single Wait.
	position = screen.get_node("%Wait").get_global_rect().get_center()
	for click in range(5):
		pointer(position, true)
		pointer(position, false)
	await _settle()
	check(simulation.action_index == 2 and simulation.simulation_time == 200, "rapid GUI clicks cannot double execute within one input frame")
	# Route synthetic touch events through the real viewport, including a possible
	# emulated-mouse button path. This does not claim observation of Android's OS adapter.
	routed_touch(position, 0, true)
	routed_touch(position, 1, true)
	check(screen.get("_primary_touch") == 0 and screen.get("_ignored_touches").has(1), "viewport routes primary/secondary touches to input guard")
	routed_touch(position, 0, false)
	routed_touch(position, 1, false)
	pointer(position, true)
	pointer(position, false)
	await _settle()
	check(simulation.action_index == 2, "secondary touch/emulated pointer cannot add a command")
	routed_touch(position, 0, true)
	routed_touch(position, 0, false)
	pointer(position, true)
	pointer(position, false)
	await _settle()
	check(simulation.action_index == 3, "single primary gesture recovers and converges to one action")
	var idle: String = simulation.state_hash()
	for frame in range(30):
		await process_frame
	check(simulation.state_hash() == idle, "real rendered idle frames do not advance gameplay")
	for size in [Vector2i(450, 800), Vector2i(360, 640), Vector2i(450, 1000)]:
		root.size = size
		await _settle()
		for name in ["RegionBack", "North", "South", "Wait", "Regenerate", "NextSeed"]:
			check(Rect2(Vector2.ZERO, boot.size).encloses(screen.get_node("%" + name).get_global_rect()), "I003 control stays in portrait viewport: " + name)
		_capture("i003-" + str(size.x) + "x" + str(size.y))
	await _click(screen.get_node("%Regenerate"))
	simulation = screen.get("simulation")
	check(simulation.action_index == 0 and simulation.simulation_time == 0, "GUI regeneration resets turns/time")
	await _click(screen.get_node("%RegionBack"))
	check(boot.get_node("%NewRunPanel").visible, "existing Back route preserved")
	boot.queue_free()
	await process_frame
	print("SIMULATION_VISUAL_SMOKE: Wait, visible/hidden Inspect, rapid clicks, routed touches, idle frames, three portrait sizes; %d failures" % failures)
	quit(1 if failures > 0 else 0)
