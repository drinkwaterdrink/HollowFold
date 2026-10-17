extends SceneTree
## Pure terrain/determinism tests, independent of rendering and frame timing.

var checks: int = 0
var failures: int = 0


func _initialize() -> void:
	_run.call_deferred()


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)


func _run() -> void:
	_check(ResourceLoader.exists("res://scripts/world/local_region_generator.gd"), "region generator exists")
	if failures > 0:
		_finish()
		return
	var generator: Script = load("res://scripts/world/local_region_generator.gd")
	var example: RefCounted = generator.generate(1337)
	var fixture: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/i002_region_v1.json"))
	_check(example.fingerprint() == fixture["sha256"], "seed 1337 matches committed v1 hash")
	_check(example.spawn_cell == Vector2i(int(fixture["spawn"][0]), int(fixture["spawn"][1])), "fixture spawn")
	var hashes: Dictionary = {}
	for seed_value in range(100):
		var region: RefCounted = generator.generate(seed_value)
		var repeated: RefCounted = generator.generate(seed_value)
		_check(region.fingerprint() == repeated.fingerprint(), "same seed reproduces terrain/spawn: " + str(seed_value))
		hashes[region.cells.hex_encode()] = true
		_check(region.is_walkable(region.spawn_cell), "legal spawn")
		_check(region.terrain_at(region.entrance_cell) == 3, "entrance exists at spawn")
		_check(region.player_cell == region.spawn_cell, "initial player at spawn")
		_check(region.cells.has(0) and region.cells.has(1) and region.cells.has(2) and region.cells.has(3), "all four terrain kinds")
		var reachable: Dictionary = {region.spawn_cell: true}
		var queue: Array[Vector2i] = [region.spawn_cell]
		var index: int = 0
		while index < queue.size():
			var cell: Vector2i = queue[index]
			index += 1
			for step in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var next: Vector2i = cell + step
				if region.is_walkable(next) and not reachable.has(next):
					reachable[next] = true
					queue.append(next)
		var walkable: int = 0
		for y in range(region.height):
			for x in range(region.width):
				var cell := Vector2i(x, y)
				if region.is_walkable(cell):
					walkable += 1
				if x == 0 or y == 0 or x == region.width - 1 or y == region.height - 1:
					_check(not region.is_walkable(cell), "solid region boundary")
		_check(reachable.size() == walkable, "every walkable tile reachable")
	_check(hashes.size() == 100, "different seeds vary maps")
	# Explicit tiny fixture makes collision failure independent of generated geometry.
	var grid_script: Script = load("res://scripts/world/region_grid.gd")
	var grid: RefCounted = grid_script.new(5, 5)
	grid.cells.fill(0)
	grid.player_cell = Vector2i(2, 2)
	grid.set_terrain(Vector2i(3, 2), 1)
	_check(not grid.try_move(Vector2i.RIGHT) and grid.player_cell == Vector2i(2, 2), "wall cannot move logical player")
	grid.set_terrain(Vector2i(3, 2), 2)
	_check(not grid.try_move(Vector2i.RIGHT) and grid.player_cell == Vector2i(2, 2), "water blocked")
	_check(not grid.try_move(Vector2i(1, -1)), "diagonal cannot cut blocked corner")
	_check(not grid.try_move(Vector2i(2, 0)), "multi-cell delta rejected")
	_check(not grid.try_move(Vector2i.ZERO), "zero delta rejected")
	_check(grid.try_move(Vector2i.LEFT) and grid.player_cell == Vector2i(1, 2), "legal ground step")
	grid.player_cell = Vector2i(2, 2)
	_check(grid.try_move(Vector2i(-1, -1)) and grid.player_cell == Vector2i(1, 1), "open diagonal moves one cell")
	grid.player_cell = Vector2i.ZERO
	_check(not grid.try_move(Vector2i.LEFT) and grid.player_cell == Vector2i.ZERO, "out-of-bounds blocked")
	for cell in [Vector2i.ZERO, Vector2i(4, 3), Vector2i(-1, -1)]:
		_check(grid.world_to_cell(grid.cell_to_world(cell)) == cell, "coordinate center roundtrip")
	_check(grid.world_to_cell(Vector2(-0.1, -0.1)) == Vector2i(-1, -1), "negative coordinate floors")
	_finish()


func _finish() -> void:
	print("REGION_TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)
