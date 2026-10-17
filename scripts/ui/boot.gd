extends Control
## Title and temporary exploration navigation. No persistent run exists yet.

@onready var title_panel: VBoxContainer = %TitlePanel
@onready var new_run_panel: VBoxContainer = %NewRunPanel
@onready var settings_panel: VBoxContainer = %SettingsPanel
@onready var region_screen: Control = %RegionScreen


func _ready() -> void:
	%NewRunButton.pressed.connect(_show_panel.bind(new_run_panel, %NewRunBack))
	%SettingsButton.pressed.connect(_show_panel.bind(settings_panel, %SettingsBack))
	%NewRunBack.pressed.connect(_return_to_title)
	%SettingsBack.pressed.connect(_return_to_title)
	%ExploreRegion.pressed.connect(_explore_region)
	region_screen.back_requested.connect(_go_back)
	_return_to_title()


func _show_panel(panel: VBoxContainer, focus: Button) -> void:
	region_screen.set_active(false)
	region_screen.hide()
	$SafeArea.show()
	title_panel.visible = panel == title_panel
	new_run_panel.visible = panel == new_run_panel
	settings_panel.visible = panel == settings_panel
	%Scroll.scroll_vertical = 0
	focus.grab_focus.call_deferred()


func _return_to_title() -> void:
	_show_panel(title_panel, %NewRunButton)


func _explore_region() -> void:
	$SafeArea.hide()
	region_screen.show()
	region_screen.set_active(true)
	region_screen.get_node("%RegionBack").grab_focus.call_deferred()


func _go_back() -> void:
	if region_screen.visible:
		_show_panel(new_run_panel, %ExploreRegion)
	else:
		_return_to_title()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		_go_back()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_node_ready():
		_go_back()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		get_tree().quit()
