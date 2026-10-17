extends RefCounted
## No omniscient memory: only current own range + LOS permits pursue/retreat.

const Sight = preload("res://scripts/game_session/visibility.gd")
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT,
	Vector2i(-1, -1), Vector2i(1, -1), Vector2i(1, 1), Vector2i(-1, 1)]

static func occupied(actors: Dictionary, cell: Vector2i, excluding: String = "") -> bool:
	for id: String in actors:
		var actor: RefCounted = actors[id]
		if id != excluding and actor.alive and actor.cell == cell:
			return true
	return false

static func legal_step(grid: RefCounted, actors: Dictionary, id: String, from: Vector2i, direction: Vector2i) -> bool:
	if not grid.can_step(from, direction) or occupied(actors, from + direction, id):
		return false
	if direction.x != 0 and direction.y != 0:
		if occupied(actors, from + Vector2i(direction.x, 0), id) or occupied(actors, from + Vector2i(0, direction.y), id):
			return false
	return true

static func senses(grid: RefCounted, actor: RefCounted, player: RefCounted) -> bool:
	return player.alive and (player.cell - actor.cell).length_squared() <= actor.detection * actor.detection and Sight.has_line(grid, actor.cell, player.cell)

static func decide(grid: RefCounted, actors: Dictionary, actor: RefCounted, player: RefCounted) -> Dictionary:
	if not actor.alive or not senses(grid, actor, player):
		return {"kind": "wait", "behavior": "idle"}
	var retreat: bool = actor.hp * 3 <= actor.max_hp
	if retreat:
		var best: Vector2i = Vector2i.ZERO
		var distance: int = (actor.cell - player.cell).length_squared()
		for direction in DIRECTIONS:
			var next_distance: int = (actor.cell + direction - player.cell).length_squared()
			if next_distance > distance and legal_step(grid, actors, actor.id, actor.cell, direction):
				best = direction
				distance = next_distance
		if best != Vector2i.ZERO:
			return {"kind": "move", "direction": best, "behavior": "retreat"}
	var delta: Vector2i = player.cell - actor.cell
	if maxi(absi(delta.x), absi(delta.y)) <= actor.attack_range:
		return {"kind": "attack", "behavior": "retreat" if retreat else "pursue"}
	# BFS towards a legal attack cell, max one visit per tile (small current region).
	var queue: Array[Vector2i] = [actor.cell]
	var first: Dictionary = {actor.cell: Vector2i.ZERO}
	var cursor: int = 0
	while cursor < queue.size() and cursor < grid.width * grid.height:
		var cell: Vector2i = queue[cursor]
		cursor += 1
		var distance: Vector2i = player.cell - cell
		if cell != actor.cell and maxi(absi(distance.x), absi(distance.y)) <= actor.attack_range and Sight.has_line(grid, cell, player.cell):
			return {"kind": "move", "direction": first[cell], "behavior": "pursue"}
		for direction in DIRECTIONS:
			var next: Vector2i = cell + direction
			if not first.has(next) and legal_step(grid, actors, actor.id, cell, direction):
				first[next] = direction if cell == actor.cell else first[cell]
				queue.append(next)
	return {"kind": "wait", "behavior": "retreat" if retreat else "pursue"}

static func encounter_cell(grid: RefCounted) -> Vector2i:
	var queue: Array[Vector2i] = [grid.spawn_cell]
	var distances: Dictionary = {grid.spawn_cell: 0}
	var cursor: int = 0
	var fallback := Vector2i(-1, -1)
	while cursor < queue.size() and cursor < grid.width * grid.height:
		var cell: Vector2i = queue[cursor]
		cursor += 1
		var distance: int = distances[cell]
		if distance >= 8:
			return cell
		if distance >= 6 and fallback.x == -1:
			fallback = cell
		for direction in DIRECTIONS:
			var next: Vector2i = cell + direction
			if not distances.has(next) and grid.can_step(cell, direction):
				distances[next] = distance + 1
				queue.append(next)
	return fallback
