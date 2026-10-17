extends RefCounted
## Integer supercover LOS: rock occludes, water transmits, corners cannot be peeked through.

const Grid = preload("res://scripts/world/region_grid.gd")
const RADIUS: int = 8


static func opaque(grid: Grid, cell: Vector2i) -> bool:
	return not grid.contains(cell) or grid.terrain_at(cell) == Grid.Terrain.ROCK


static func has_line(grid: Grid, origin: Vector2i, target: Vector2i) -> bool:
	if not grid.contains(origin) or not grid.contains(target):
		return false
	var delta: Vector2i = target - origin
	var nx: int = absi(delta.x)
	var ny: int = absi(delta.y)
	var step := Vector2i(signi(delta.x), signi(delta.y))
	var cursor: Vector2i = origin
	var ix: int = 0
	var iy: int = 0
	while cursor != target:
		var decision: int = (1 + 2 * ix) * ny - (1 + 2 * iy) * nx
		if decision == 0:
			if opaque(grid, cursor + Vector2i(step.x, 0)) or opaque(grid, cursor + Vector2i(0, step.y)):
				return false
			cursor += step
			ix += 1
			iy += 1
		elif decision < 0:
			cursor.x += step.x
			ix += 1
		else:
			cursor.y += step.y
			iy += 1
		if cursor != target and opaque(grid, cursor):
			return false
	return true


static func calculate(grid: Grid, origin: Vector2i) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(grid.width * grid.height)
	for y in range(maxi(0, origin.y - RADIUS), mini(grid.height, origin.y + RADIUS + 1)):
		for x in range(maxi(0, origin.x - RADIUS), mini(grid.width, origin.x + RADIUS + 1)):
			var cell := Vector2i(x, y)
			if (cell - origin).length_squared() <= RADIUS * RADIUS and has_line(grid, origin, cell):
				result[y * grid.width + x] = 1
	return result
