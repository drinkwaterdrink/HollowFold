extends SceneTree

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func _key(screen: Control, code: int, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	event.echo = echo
	screen.call("_input", event)


func _run() -> void:
	var packed: PackedScene = load("res://scenes/boot.tscn")
	var boot: Control = packed.instantiate()
	root.add_child(boot)
	await process_frame
	boot.get_node("%NewRunButton").pressed.emit()
	boot.get_node("%ExploreRegion").pressed.emit()
	await process_frame
	await process_frame
	var screen: Control = boot.get_node("%RegionScreen")
	var world: Node2D = screen.get_node("%RegionWorld")
	var map: TileMapLayer = world.get_node("Terrain")
	var player: Node2D = world.get_node("Player")
	var camera: Camera2D = world.get_node("Camera")
	var model: RefCounted = screen.get("region")
	_check(screen.visible and screen.get("active") and not boot.get_node("SafeArea").visible, "explore hides menu and activates region")
	_check(map.get_used_cells().size() == model.width * model.height, "every terrain tile rendered")
	_check(map.map_to_local(model.player_cell) == model.cell_to_world(model.player_cell), "TileMap agrees with logical coordinates")
	_check(player.position == model.cell_to_world(model.player_cell) and camera.position == player.position, "actor/camera match spawn")
	var original_hash: String = model.fingerprint()
	var start: Vector2i = model.spawn_cell
	# Reach a legal cell using the actual directional button signal.
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]
	var buttons: Array[String] = ["North", "East", "South", "West"]
	for index in range(directions.size()):
		var direction: Vector2i = directions[index]
		if model.is_walkable(start + direction):
			screen.get_node("%" + buttons[index]).pressed.emit()
			_check(model.player_cell == start + direction, "directional button moves exactly one logical cell")
			_check(player.position == model.cell_to_world(model.player_cell) and camera.position == player.position, "movement synchronizes actor/camera")
			break
	screen.get_node("%Regenerate").pressed.emit()
	model = screen.get("region")
	_check(model.fingerprint() == original_hash and model.player_cell == start, "same-seed debug regeneration resets identical map/spawn")
	_check(player.position == model.cell_to_world(start), "regeneration resets rendered player")
	screen.get_node("%NextSeed").pressed.emit()
	model = screen.get("region")
	_check(screen.get("seed_value") == 1338 and model.fingerprint() != original_hash, "Next seed varies generated terrain")
	# Explicit fixture verifies blocked input through the UI adapter, including echo rejection.
	model.player_cell = Vector2i(0, 0)
	world.display_player(model)
	var before: Vector2 = player.position
	screen.get_node("%West").pressed.emit()
	_check(model.player_cell == Vector2i.ZERO and player.position == before, "blocked button cannot move actor/model")
	screen.get_node("%Regenerate").pressed.emit()
	model = screen.get("region")
	var legal_key: int = KEY_UP
	var legal_direction := Vector2i.ZERO
	for direction in directions:
		if model.is_walkable(model.player_cell + direction):
			legal_direction = direction
			legal_key = [KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_LEFT][directions.find(direction)]
			break
	before = Vector2(model.player_cell)
	_key(screen, legal_key, true)
	_check(model.player_cell == Vector2i(before), "held keyboard echo does not repeat movement")
	_key(screen, legal_key)
	_check(model.player_cell == Vector2i(before) + legal_direction, "keyboard movement works while button has focus")
	boot.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await process_frame
	_check(not screen.visible and not screen.get("active") and boot.get_node("%NewRunPanel").visible, "Android Back returns to launch panel")
	var hidden_cell: Vector2i = model.player_cell
	_key(screen, legal_key)
	screen.get_node("%North").pressed.emit()
	_check(model.player_cell == hidden_cell, "hidden region ignores keyboard and movement buttons")
	boot.get_node("%ExploreRegion").pressed.emit()
	var cancel := InputEventAction.new()
	cancel.action = &"ui_cancel"
	cancel.pressed = true
	boot.call("_unhandled_input", cancel)
	_check(not screen.visible and boot.get_node("%NewRunPanel").visible, "Escape returns to launch panel")
	boot.get_node("%ExploreRegion").pressed.emit()
	screen.get_node("%RegionBack").pressed.emit()
	_check(not screen.visible and boot.get_node("%NewRunPanel").visible, "visible region Back returns")
	boot.get_node("%NewRunBack").pressed.emit()
	_check(boot.get_node("%TitlePanel").visible, "original Back still returns to title")
	boot.queue_free()
	await process_frame
	print("REGION_SCENE_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
