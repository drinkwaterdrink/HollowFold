extends Node2D
## Read-only terrain presentation. No terrain generation or collision decisions here.

const Grid = preload("res://scripts/world/region_grid.gd")
const EnemyMarker = preload("res://scripts/visual/enemy_marker.gd")
var enemies: Dictionary = {}
var selected_target: String = ""

@onready var terrain: TileMapLayer = $Terrain
@onready var actor: Node2D = $Player
@onready var camera: Camera2D = $Camera


func display_region(region: Grid) -> void:
	if terrain.tile_set == null:
		terrain.tile_set = _make_tileset()
	terrain.clear()
	for y in range(region.height):
		for x in range(region.width):
			var cell := Vector2i(x, y)
			var tile: int = region.terrain_at(cell)
			if tile != Grid.Terrain.UNKNOWN and not region.visible.is_empty() and region.visible[y * region.width + x] == 0:
				tile += 5 # Remembered terrain is dim; unknown terrain is absent from the view.
			terrain.set_cell(cell, 0, Vector2i(tile, 0))
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = region.width * Grid.TILE_SIZE
	camera.limit_bottom = region.height * Grid.TILE_SIZE
	display_player(region)
	_display_enemies(region)
	camera.reset_smoothing()


func _display_enemies(region: Grid) -> void:
	var visible_ids: Array[String] = []
	for record: Dictionary in region.actors:
		if record["id"] == "player":
			actor.modulate = Color.WHITE if record["alive"] else Color("76586b")
			continue
		var id: String = record["id"]
		visible_ids.append(id)
		if not enemies.has(id):
			var marker := Node2D.new()
			marker.set_script(EnemyMarker)
			marker.z_index = 2
			add_child(marker)
			enemies[id] = marker
		var enemy: Node2D = enemies[id]
		enemy.position = region.cell_to_world(Vector2i(record["cell"][0],record["cell"][1]))
		enemy.set("selected", id == selected_target)
		enemy.queue_redraw()
	for id: String in enemies.keys():
		if id not in visible_ids:
			enemies[id].queue_free()
			enemies.erase(id)


func hit_feedback(id: String) -> void:
	var marker: Node2D = actor if id == "player" else enemies.get(id)
	if marker == null:
		return
	# Pure presentation tween; no callbacks into gameplay.
	marker.scale = Vector2(1.2,1.2)
	marker.create_tween().tween_property(marker,"scale",Vector2.ONE,0.12)


func display_player(region: Grid) -> void:
	actor.position = region.cell_to_world(region.player_cell)
	camera.position = actor.position
	camera.force_update_scroll()


func _make_tileset() -> TileSet:
	# Four original code-drawn prototype tiles: ground, rock, water, entrance.
	var image := Image.create(Grid.TILE_SIZE * 9, Grid.TILE_SIZE, false, Image.FORMAT_RGBA8)
	var colors: Array[Color] = [Color("293b35"), Color("484c50"), Color("24546a"), Color("293b35")]
	for tile in range(4):
		var origin: int = tile * Grid.TILE_SIZE
		image.fill_rect(Rect2i(origin, 0, 24, 24), colors[tile])
		image.fill_rect(Rect2i(origin, 23, 24, 1), colors[tile].darkened(0.2))
		if tile == Grid.Terrain.ROCK:
			image.fill_rect(Rect2i(origin + 2, 2, 20, 2), Color("6b7072"))
			image.fill_rect(Rect2i(origin + 4, 12, 11, 1), Color("353b40"))
		elif tile == Grid.Terrain.WATER:
			image.fill_rect(Rect2i(origin + 3, 7, 10, 2), Color("5395a5"))
			image.fill_rect(Rect2i(origin + 11, 16, 10, 2), Color("397990"))
		elif tile == Grid.Terrain.ENTRANCE:
			image.fill_rect(Rect2i(origin + 3, 3, 18, 18), Color("bda16c"))
			image.fill_rect(Rect2i(origin + 5, 5, 14, 14), Color("1b2724"))
		else:
			image.fill_rect(Rect2i(origin + 5, 6, 2, 2), Color("405448"))
			image.fill_rect(Rect2i(origin + 17, 17, 2, 2), Color("1d302c"))
	image.fill_rect(Rect2i(4 * Grid.TILE_SIZE, 0, Grid.TILE_SIZE, Grid.TILE_SIZE), Color("0c1012"))
	for tile in range(4):
		for y in range(Grid.TILE_SIZE):
			for x in range(Grid.TILE_SIZE):
				image.set_pixel((tile + 5) * Grid.TILE_SIZE + x, y, image.get_pixel(tile * Grid.TILE_SIZE + x, y).darkened(0.65))
	var atlas := TileSetAtlasSource.new()
	atlas.texture = ImageTexture.create_from_image(image)
	atlas.texture_region_size = Vector2i(Grid.TILE_SIZE, Grid.TILE_SIZE)
	for tile in range(9):
		atlas.create_tile(Vector2i(tile, 0))
	var result := TileSet.new()
	result.tile_size = Vector2i(Grid.TILE_SIZE, Grid.TILE_SIZE)
	result.add_source(atlas, 0)
	return result
