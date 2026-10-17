extends Control
## I-001 navigation only. No run is created by this placeholder.

@onready var title_panel: VBoxContainer = %TitlePanel
@onready var new_run_panel: VBoxContainer = %NewRunPanel
@onready var settings_panel: VBoxContainer = %SettingsPanel


func _ready() -> void:
	%NewRunButton.pressed.connect(_show_panel.bind(new_run_panel, %NewRunBack))
	%SettingsButton.pressed.connect(_show_panel.bind(settings_panel, %SettingsBack))
	%NewRunBack.pressed.connect(_return_to_title)
	%SettingsBack.pressed.connect(_return_to_title)
	_return_to_title()


func _show_panel(panel: VBoxContainer, focus: Button) -> void:
	title_panel.visible = panel == title_panel
	new_run_panel.visible = panel == new_run_panel
	settings_panel.visible = panel == settings_panel
	%Scroll.scroll_vertical = 0
	focus.grab_focus.call_deferred()


func _return_to_title() -> void:
	_show_panel(title_panel, %NewRunButton)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		_return_to_title()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready():
		_return_to_title()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
