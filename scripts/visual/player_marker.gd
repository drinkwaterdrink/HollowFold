extends Node2D
## Original temporary actor glyph. Logical position is supplied by the UI controller.


func _draw() -> void:
	draw_circle(Vector2.ZERO, 9, Color("0c1012"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, -8), Vector2(6, 0), Vector2(0, 8), Vector2(-6, 0)]), Color("f2e8cf"))
	draw_line(Vector2(-3, 0), Vector2(3, 0), Color("498b84"), 2)
