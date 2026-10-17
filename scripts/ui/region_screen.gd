extends Control
## Temporary I-002 movement adapter, deliberately without the I-003 command engine.

signal back_requested

const Generator = preload("res://scripts/world/local_region_generator.gd")
const Grid = preload("res://scripts/world/region_grid.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i(-1, -1), Vector2i.UP, Vector2i(1, -1), Vector2i.LEFT, Vector2i.RIGHT, Vector2i(-1, 1), Vector2i.DOWN, Vector2i(1, 1)]
const BUTTONS: Array[String] = ["NorthWest", "North", "NorthEast", "West", "East", "SouthWest", "South", "SouthEast"]
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

var region: Grid
var seed_value: int = 1337
var active: bool = false
@onready var world: Node2D = %RegionWorld


func _ready() -> void:
	%RegionBack.pressed.connect(func() -> void: back_requested.emit())
	%Regenerate.pressed.connect(regenerate)
	%NextSeed.pressed.connect(_next_seed)
	for index in range(BUTTONS.size()):
		get_node("%" + BUTTONS[index]).pressed.connect(move.bind(DIRECTIONS[index]))


func set_active(value: bool) -> void:
	active = value
	if active and region == null:
		regenerate()


func regenerate() -> void:
	region = Generator.generate(seed_value)
	world.display_region(region)
	_update_labels("Parchment diamond: you. Gold square: entrance.")


func _next_seed() -> void:
	seed_value += 1
	regenerate()


func move(direction: Vector2i) -> void:
	if not active or region == null:
		return
	if region.try_move(direction):
		world.display_player(region)
		_update_labels("Rock and blue water block movement.")
	else:
		_update_labels("Blocked — choose another direction.")


func _update_labels(message: String) -> void:
	%SeedPosition.text = "Seed %d  ·  Cell %d, %d" % [seed_value, region.player_cell.x, region.player_cell.y]
	%RegionStatus.text = message


func _input(event: InputEvent) -> void:
	# Handle movement before GUI arrow-focus navigation; Tab/Enter still operate buttons.
	if not active or not event is InputEventKey or not event.pressed or event.echo:
		return
	if KEY_DIRECTIONS.has(event.physical_keycode):
		move(KEY_DIRECTIONS[event.physical_keycode])
		get_viewport().set_input_as_handled()
