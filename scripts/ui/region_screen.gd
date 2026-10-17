extends Control
## Input/presentation only; SimulationSession is the single gameplay writer.

signal back_requested

const Session = preload("res://scripts/game_session/simulation_session.gd")
const Command = preload("res://scripts/game_session/action_command.gd")
const Result = preload("res://scripts/game_session/action_result.gd")
const Grid = preload("res://scripts/world/region_grid.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i(-1, -1), Vector2i.UP, Vector2i(1, -1), Vector2i.LEFT, Vector2i.RIGHT, Vector2i(-1, 1), Vector2i.DOWN, Vector2i(1, 1)]
const BUTTONS: Array[String] = ["NorthWest", "North", "NorthEast", "West", "East", "SouthWest", "South", "SouthEast"]
const FAILURE_MESSAGES: Dictionary = {"BLOCKED": "Blocked terrain", "CORNER_BLOCKED": "Blocked corner", "OUT_OF_BOUNDS": "Region boundary", "NOT_VISIBLE": "Not currently visible"}
const KEY_DIRECTIONS: Dictionary = {
	KEY_UP: Vector2i.UP, KEY_W: Vector2i.UP, KEY_KP_8: Vector2i.UP,
	KEY_DOWN: Vector2i.DOWN, KEY_S: Vector2i.DOWN, KEY_KP_2: Vector2i.DOWN,
	KEY_LEFT: Vector2i.LEFT, KEY_A: Vector2i.LEFT, KEY_KP_4: Vector2i.LEFT,
	KEY_RIGHT: Vector2i.RIGHT, KEY_D: Vector2i.RIGHT, KEY_KP_6: Vector2i.RIGHT,
	KEY_Q: Vector2i(-1, -1), KEY_KP_7: Vector2i(-1, -1),
	KEY_E: Vector2i(1, -1), KEY_KP_9: Vector2i(1, -1),
	KEY_Z: Vector2i(-1, 1), KEY_KP_1: Vector2i(-1, 1),
	KEY_C: Vector2i(1, 1), KEY_KP_3: Vector2i(1, 1),
}

var region: Grid # Detached masked view, never authoritative.
var simulation: Session
var seed_value: int = 1337
var active: bool = false
var result_history: Array[Dictionary] = []
var _request_id: int = 0
var _last_input_frame: int = -1
var _primary_touch: int = -1
var _ignored_touches: Dictionary = {}
var _suppressed_touch_frame: int = -1
@onready var world: Node2D = %RegionWorld


func _ready() -> void:
	%RegionBack.pressed.connect(func() -> void: back_requested.emit())
	%Regenerate.pressed.connect(regenerate)
	%NextSeed.pressed.connect(_next_seed)
	%Wait.pressed.connect(wait_action)
	%MapContainer.gui_input.connect(_map_input)
	for index in range(BUTTONS.size()):
		get_node("%" + BUTTONS[index]).pressed.connect(move.bind(DIRECTIONS[index]))


func set_active(value: bool) -> void:
	active = value
	_clear_gestures()
	if active and simulation == null:
		regenerate()


func regenerate() -> void:
	if simulation != null:
		simulation.result_published.disconnect(_on_result)
	simulation = Session.new(seed_value)
	simulation.result_published.connect(_on_result)
	_request_id = 0
	result_history.clear()
	_clear_gestures()
	region = simulation.view()
	world.display_region(region)
	_update_labels("Tap map: Inspect. Centre: Wait. Rock blocks sight.")


func _next_seed() -> void:
	seed_value += 1
	regenerate()


func _admit() -> bool:
	# This gates presentation input only; frames never advance simulation time.
	if not active or simulation == null or _last_input_frame == Engine.get_process_frames():
		return false
	if not _ignored_touches.is_empty() or _suppressed_touch_frame == Engine.get_process_frames():
		return false
	_last_input_frame = Engine.get_process_frames()
	_request_id += 1
	return true


func move(direction: Vector2i) -> void:
	if _admit():
		simulation.submit(Command.move(_request_id, direction))


func wait_action() -> void:
	if _admit():
		simulation.submit(Command.wait(_request_id))


func inspect_at(cell: Vector2i) -> void:
	if _admit():
		simulation.submit(Command.inspect(_request_id, cell))


func _on_result(result: Result) -> void:
	result_history.append(result.record())
	if result_history.size() > 32:
		result_history.pop_front()
	region = simulation.view()
	world.display_region(region)
	var message: String = "Action +%d time. Tap map to inspect." % result.cost
	if not result.success:
		message = "%s — no time used." % FAILURE_MESSAGES.get(result.code, "Action unavailable")
	elif not result.inspection.is_empty():
		var cell: Array = result.inspection["cell"]
		message = "%s at %d,%d — no time used." % [["Ground", "Rock", "Water", "Entrance"][result.inspection["terrain"]], cell[0], cell[1]]
	_update_labels(message)


func _update_labels(message: String) -> void:
	%SeedPosition.text = "Seed %d · %d,%d · #%d t%d" % [seed_value, region.player_cell.x, region.player_cell.y, simulation.action_index, simulation.simulation_time]
	%RegionStatus.text = message


func _map_input(event: InputEvent) -> void:
	if active and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		var viewport: SubViewport = %MapViewport
		var point: Vector2 = event.position * Vector2(viewport.size) / %MapContainer.size
		inspect_at(region.world_to_cell(viewport.get_canvas_transform().affine_inverse() * point))
		accept_event()


func _clear_gestures() -> void:
	_primary_touch = -1
	_ignored_touches.clear()
	_last_input_frame = -1
	_suppressed_touch_frame = -1


func _release_touch(index: int) -> void:
	if _primary_touch == index:
		_primary_touch = -1


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		_clear_gestures()


func _input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			if _primary_touch == -1:
				_primary_touch = event.index
			else:
				_suppressed_touch_frame = Engine.get_process_frames()
				if event.index != _primary_touch:
					_ignored_touches[event.index] = true
				get_viewport().set_input_as_handled()
		elif _ignored_touches.has(event.index):
			_suppressed_touch_frame = Engine.get_process_frames()
			_ignored_touches.erase(event.index)
			get_viewport().set_input_as_handled()
		elif event.index == _primary_touch:
			_release_touch.call_deferred(event.index)
		return
	if event is InputEventScreenDrag and event.index != _primary_touch:
		get_viewport().set_input_as_handled()
		return
	if not event is InputEventKey or not event.pressed:
		return
	if KEY_DIRECTIONS.has(event.physical_keycode):
		if not event.echo:
			move(KEY_DIRECTIONS[event.physical_keycode])
		get_viewport().set_input_as_handled()
	elif event.physical_keycode in [KEY_SPACE, KEY_PERIOD, KEY_KP_5, KEY_I]:
		if not event.echo:
			if event.physical_keycode == KEY_I:
				inspect_at(simulation.player_cell)
			else:
				wait_action()
		get_viewport().set_input_as_handled()
