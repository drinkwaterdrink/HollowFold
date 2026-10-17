extends Node2D
## Original temporary mite glyph. Reads only detached actor views.

var selected: bool = false

func _draw() -> void:
	if selected:
		draw_arc(Vector2.ZERO,11,0,TAU,24,Color("f4d479"),2)
	for y in [-5,0,5]:
		draw_line(Vector2(-10,y-2),Vector2(10,y+2),Color("da956b"),2)
	draw_circle(Vector2.ZERO,7,Color("b04d47"))
	draw_circle(Vector2(-3,-2),1.5,Color("ffdb9d"))
	draw_circle(Vector2(3,-2),1.5,Color("ffdb9d"))
