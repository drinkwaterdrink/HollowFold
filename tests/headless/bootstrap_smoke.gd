extends SceneTree
## Real scene and UI behavior checks. No test framework dependency.

var failures: int = 0
var checks: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)


func _run() -> void:
	_check(ResourceLoader.exists("res://scenes/boot.tscn"), "boot scene exists")
	if failures > 0:
		_finish()
		return
	var packed: PackedScene = load("res://scenes/boot.tscn")
	var boot: Control = packed.instantiate()
	root.add_child(boot)
	await process_frame
	await process_frame
	_check(ProjectSettings.get_setting("application/config/name") == "Hollowfold", "project title")
	_check(ProjectSettings.get_setting("rendering/renderer/rendering_method") == "gl_compatibility", "Compatibility renderer")
	_check(ProjectSettings.get_setting("display/window/handheld/orientation") == 1, "portrait lock")
	var title: Control = boot.get_node("%TitlePanel")
	var launch: Control = boot.get_node("%NewRunPanel")
	var settings: Control = boot.get_node("%SettingsPanel")
	var new_button: Button = boot.get_node("%NewRunButton")
	var settings_button: Button = boot.get_node("%SettingsButton")
	_check(title.visible and not launch.visible and not settings.visible, "first install has title only")
	_check(boot.find_children("*Continue*", "Button", true, false).is_empty(), "Continue absent without save")
	new_button.pressed.emit()
	await process_frame
	_check(launch.visible and not title.visible and not settings.visible, "New Run opens placeholder only")
	boot.get_node("%NewRunBack").pressed.emit()
	await process_frame
	_check(title.visible and not launch.visible, "visible Back returns to title")
	settings_button.pressed.emit()
	await process_frame
	_check(settings.visible and not title.visible, "Settings opens")
	boot.get_node("%SettingsBack").pressed.emit()
	await process_frame
	_check(title.visible and not settings.visible, "Settings Back returns")
	for i in range(10):
		new_button.pressed.emit()
		boot.notification(Node.NOTIFICATION_WM_GO_BACK_REQUEST)
	await process_frame
	_check(title.visible and not launch.visible, "repeated navigation and Android Back return cleanly")
	settings_button.pressed.emit()
	var cancel := InputEventAction.new()
	cancel.action = &"ui_cancel"
	cancel.pressed = true
	boot.call("_unhandled_input", cancel)
	await process_frame
	_check(title.visible and not settings.visible, "Escape/ui_cancel returns")
	_check(new_button.has_focus(), "focus restored to primary title action")
	var safe: MarginContainer = boot.get_node("%SafeArea")
	var full := Rect2(0, 0, 1080, 2400)
	var result: Rect2 = safe.call("content_rect", Rect2(0, 90, 1080, 2190), full, Vector2(360, 800))
	_check(result.is_equal_approx(Rect2(0, 30, 360, 730)), "physical notch and gesture insets convert to logical coordinates")
	result = safe.call("content_rect", Rect2(1100, 240, 1000, 1900), Rect2(1000, 200, 1200, 2000), Vector2(360, 600))
	_check(result.is_equal_approx(Rect2(30, 12, 300, 570)), "translated screen/window origins and side cutouts")
	result = safe.call("content_rect", Rect2(), full, Vector2(360, 800))
	_check(result.is_equal_approx(Rect2(0, 0, 360, 800)), "empty platform safe area falls back to viewport")
	for viewport_size in [Vector2i(360, 640), Vector2i(360, 800), Vector2i(320, 568)]:
		root.size = viewport_size
		await process_frame
		await process_frame
		for button: Button in [new_button, settings_button]:
			_check(button.size.y >= 56, "large button height at " + str(viewport_size))
			_check(button.get_global_rect().position.x >= 0 and button.get_global_rect().end.x <= boot.size.x + 1, "button fits viewport width")
	boot.queue_free()
	await process_frame
	_finish()


func _finish() -> void:
	print("BOOTSTRAP_SMOKE: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
