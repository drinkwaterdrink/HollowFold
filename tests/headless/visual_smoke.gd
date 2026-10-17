extends SceneTree
## Rendered desktop check: routes actual pointer input through the Godot GUI.
## Screenshots are generated under ignored .local/verification/.

var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _settle() -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw


func _click(button: Button) -> void:
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.position = button.get_global_rect().get_center()
	click.pressed = true
	root.push_input(click, true)
	click = click.duplicate()
	click.pressed = false
	root.push_input(click, true)
	await _settle()


func _capture(label: String) -> void:
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png("res://.local/verification/" + label + ".png")
	if error != OK:
		push_error("Screenshot failed: " + label)
		failures += 1


func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("visual_smoke requires a rendering display")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://.local/verification")
	var scene: PackedScene = load("res://scenes/boot.tscn")
	var boot: Control = scene.instantiate()
	root.add_child(boot)
	await _settle()
	_capture("title")
	await _click(boot.get_node("%NewRunButton"))
	if not boot.get_node("%NewRunPanel").visible:
		failures += 1
		push_error("Pointer input did not open New Run")
	_capture("new-run")
	await _click(boot.get_node("%NewRunBack"))
	await _click(boot.get_node("%SettingsButton"))
	if not boot.get_node("%SettingsPanel").visible:
		failures += 1
		push_error("Pointer input did not open Settings")
	_capture("settings")
	await _click(boot.get_node("%SettingsBack"))
	if not boot.get_node("%TitlePanel").visible:
		failures += 1
		push_error("Pointer input did not return to title")
	print("VISUAL_SMOKE: pointer navigation, 3 screenshots, %d failures" % failures)
	boot.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)
