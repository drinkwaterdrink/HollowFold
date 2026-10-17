extends "res://tests/headless/visual_smoke.gd"
## Uses the existing real-viewport pointer helpers; never runs on a headless backend.


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("region_visual_smoke requires a rendering display")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://.local/verification")
	var packed: PackedScene = load("res://scenes/boot.tscn")
	var boot: Control = packed.instantiate()
	root.add_child(boot)
	await _settle()
	await _click(boot.get_node("%NewRunButton"))
	await _click(boot.get_node("%ExploreRegion"))
	var screen: Control = boot.get_node("%RegionScreen")
	_check(screen.visible, "pointer opens region")
	var model: RefCounted = screen.get("region")
	var hash_before: String = model.fingerprint()
	_capture("i002-region")
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var buttons: Array[String] = ["North", "East", "South", "West"]
	var moved: bool = false
	for index in range(4):
		var before: Vector2i = model.player_cell
		if model.is_walkable(before + directions[index]):
			await _click(screen.get_node("%" + buttons[index]))
			model = screen.get("region")
			_check(model.player_cell == before + directions[index], "pointer makes exactly one grid step")
			moved = true
			break
	_check(moved, "spawn has usable movement control")
	# Send an actual key event through the viewport while a pad button owns focus.
	for index in range(4):
		var before: Vector2i = model.player_cell
		if model.is_walkable(before + directions[index]):
			var key := InputEventKey.new()
			key.physical_keycode = [KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_LEFT][index]
			key.pressed = true
			root.push_input(key, true)
			await _settle()
			model = screen.get("region")
			_check(model.player_cell == before + directions[index], "viewport keyboard reaches movement before GUI focus handling")
			key = key.duplicate()
			key.pressed = false
			root.push_input(key, true)
			break
	var world: Node2D = screen.get_node("%RegionWorld")
	var actor: Node2D = world.get_node("Player")
	var viewport: SubViewport = screen.get_node("%MapViewport")
	var rendered_player: Vector2 = viewport.get_canvas_transform() * actor.position
	_check(Rect2(Vector2.ZERO, Vector2(viewport.size)).has_point(rendered_player), "camera keeps player inside clipped map")
	await _click(screen.get_node("%Regenerate"))
	model = screen.get("region")
	_check(model.fingerprint() == hash_before and model.player_cell == model.spawn_cell, "pointer regeneration repeats original seed")
	await _click(screen.get_node("%NextSeed"))
	_check(screen.get("seed_value") == 1338, "pointer selects next seed")
	_capture("i002-next-seed")
	for window_size in [Vector2i(450, 800), Vector2i(360, 640), Vector2i(450, 1000)]:
		root.size = window_size
		await _settle()
		for name in ["RegionBack", "North", "South", "West", "East", "Regenerate", "NextSeed"]:
			var button: Button = screen.get_node("%" + name)
			var rect: Rect2 = button.get_global_rect()
			_check(Rect2(Vector2.ZERO, boot.size).encloses(rect), "control inside portrait viewport: " + name + " at " + str(window_size))
		_capture("i002-" + str(window_size.x) + "x" + str(window_size.y))
	await _click(screen.get_node("%RegionBack"))
	_check(boot.get_node("%NewRunPanel").visible and not screen.visible, "pointer returns to New Run panel")
	await _click(boot.get_node("%NewRunBack"))
	_check(boot.get_node("%TitlePanel").visible, "pointer returns to original title")
	boot.queue_free()
	await process_frame
	print("REGION_VISUAL_SMOKE: pointer/key navigation, camera, regeneration, 3 portrait sizes; %d failures" % failures)
	quit(1 if failures > 0 else 0)
