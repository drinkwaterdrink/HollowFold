extends RefCounted
## Terrain and detached presentation/fixture data. Runtime position is owned by SimulationSession.

enum Terrain { GROUND, ROCK, WATER, ENTRANCE, UNKNOWN }
const TILE_SIZE: int = 24
const GENERATION_REVISION: int = 1

var width: int
var height: int
var seed_value: int = 0
var cells: PackedByteArray = PackedByteArray()
var spawn_cell: Vector2i = Vector2i.ZERO
var entrance_cell: Vector2i = Vector2i.ZERO
var player_cell: Vector2i = Vector2i.ZERO
var visible: PackedByteArray = PackedByteArray()
var discovered: PackedByteArray = PackedByteArray()


func _init(grid_width: int, grid_height: int) -> void:
	width = grid_width
	height = grid_height
	cells.resize(width * height)
	cells.fill(Terrain.ROCK)


func contains(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func terrain_at(cell: Vector2i) -> int:
	return cells[cell.y * width + cell.x] if contains(cell) else Terrain.ROCK


func set_terrain(cell: Vector2i, terrain: int) -> void:
	assert(contains(cell), "Terrain edits must stay inside the region")
	cells[cell.y * width + cell.x] = terrain


func is_walkable(cell: Vector2i) -> bool:
	return contains(cell) and terrain_at(cell) in [Terrain.GROUND, Terrain.ENTRANCE]


func try_move(direction: Vector2i) -> bool:
	# Compatibility fixture helper; runtime gameplay commits only through SimulationSession.
	if not can_step(player_cell, direction):
		return false
	player_cell += direction
	return true


func can_step(from_cell: Vector2i, direction: Vector2i) -> bool:
	if direction == Vector2i.ZERO or absi(direction.x) > 1 or absi(direction.y) > 1:
		return false
	var target: Vector2i = from_cell + direction
	if not is_walkable(target):
		return false
	if direction.x != 0 and direction.y != 0:
		if not is_walkable(from_cell + Vector2i(direction.x, 0)) or not is_walkable(from_cell + Vector2i(0, direction.y)):
			return false
	return true


func cell_to_world(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5)) * TILE_SIZE


func world_to_cell(point: Vector2) -> Vector2i:
	return Vector2i(floori(point.x / TILE_SIZE), floori(point.y / TILE_SIZE))


func fingerprint() -> String:
	# Locale-independent integer/text encoding; excludes the mutable current player cell.
	return ("%d|%d,%d|%d|%d,%d|%d,%d|%s" % [GENERATION_REVISION, width, height, seed_value, spawn_cell.x, spawn_cell.y, entrance_cell.x, entrance_cell.y, cells.hex_encode()]).sha256_text()
