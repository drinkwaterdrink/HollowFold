extends MarginContainer
## Converts platform pixels to logical canvas coordinates; desktop uses full window.

const EDGE_PADDING: int = 24


func _ready() -> void:
	get_viewport().size_changed.connect(_refresh)
	_refresh.call_deferred()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_RESUMED, NOTIFICATION_APPLICATION_FOCUS_IN] and is_node_ready():
		_refresh.call_deferred()


func content_rect(safe_pixels: Rect2, window_pixels: Rect2, canvas_size: Vector2) -> Rect2:
	# Empty values are common on desktop/headless backends.
	if not safe_pixels.has_area() or not window_pixels.has_area():
		return Rect2(Vector2.ZERO, canvas_size)
	var intersection: Rect2 = safe_pixels.intersection(window_pixels)
	if not intersection.has_area():
		return Rect2(Vector2.ZERO, canvas_size)
	var ratio: Vector2 = canvas_size / window_pixels.size
	return Rect2((intersection.position - window_pixels.position) * ratio, intersection.size * ratio)


func _refresh() -> void:
	var canvas_size: Vector2 = get_viewport_rect().size
	var usable := Rect2(Vector2.ZERO, canvas_size)
	if OS.get_name() == "Android":
		var window_pixels := Rect2(Vector2(DisplayServer.window_get_position()), Vector2(DisplayServer.window_get_size()))
		usable = content_rect(Rect2(DisplayServer.get_display_safe_area()), window_pixels, canvas_size)
	add_theme_constant_override("margin_left", EDGE_PADDING + ceili(usable.position.x))
	add_theme_constant_override("margin_top", EDGE_PADDING + ceili(usable.position.y))
	add_theme_constant_override("margin_right", EDGE_PADDING + ceili(canvas_size.x - usable.end.x))
	add_theme_constant_override("margin_bottom", EDGE_PADDING + ceili(canvas_size.y - usable.end.y))
