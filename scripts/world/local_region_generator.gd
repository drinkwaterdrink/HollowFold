extends RefCounted
## Revision 1: a small connected local region, not the later macro-world generator.

const Grid = preload("res://scripts/world/region_grid.gd")
const WIDTH: int = 31
const HEIGHT: int = 39
const CARDINALS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]


static func generate(seed_value: int) -> Grid:
	var region := Grid.new(WIDTH, HEIGHT)
	region.seed_value = seed_value
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var start := Vector2i(2 * rng.randi_range(0, 14) + 1, 2 * rng.randi_range(0, 18) + 1)
	region.set_terrain(start, Grid.Terrain.GROUND)
	var stack: Array[Vector2i] = [start]
	# Every odd interior cell is visited once. Carving links yields one connected floor.
	while not stack.is_empty():
		var current: Vector2i = stack.back()
		var options: Array[Vector2i] = []
		for direction in CARDINALS:
			var next: Vector2i = current + direction * 2
			if next.x > 0 and next.y > 0 and next.x < WIDTH - 1 and next.y < HEIGHT - 1 and region.terrain_at(next) == Grid.Terrain.ROCK:
				options.append(direction)
		if options.is_empty():
			stack.pop_back()
			continue
		var chosen: Vector2i = options[rng.randi_range(0, options.size() - 1)]
		region.set_terrain(current + chosen, Grid.Terrain.GROUND)
		region.set_terrain(current + chosen * 2, Grid.Terrain.GROUND)
		stack.append(current + chosen * 2)
	# Small clearings introduce loops; each overlaps an already connected odd cell.
	for clearing in range(8):
		var origin := Vector2i(2 * rng.randi_range(0, 13) + 1, 2 * rng.randi_range(0, 17) + 1)
		for y in range(origin.y, origin.y + 3):
			for x in range(origin.x, origin.x + 3):
				region.set_terrain(Vector2i(x, y), Grid.Terrain.GROUND)
	# Water replaces rock only, so it cannot sever the walkable network.
	for pool in range(30):
		var origin := Vector2i(rng.randi_range(1, WIDTH - 4), rng.randi_range(1, HEIGHT - 4))
		for y in range(origin.y, origin.y + 3):
			for x in range(origin.x, origin.x + 3):
				var cell := Vector2i(x, y)
				if region.terrain_at(cell) == Grid.Terrain.ROCK:
					region.set_terrain(cell, Grid.Terrain.WATER)
	# (2, 2) is rock in the original maze. Removing any optional clearing here
	# cannot disconnect the original floor network; keep one guaranteed water tile.
	region.set_terrain(Vector2i(2, 2), Grid.Terrain.WATER)
	region.spawn_cell = start
	region.entrance_cell = start
	region.player_cell = start
	region.set_terrain(start, Grid.Terrain.ENTRANCE)
	return region
