extends Node2D
## The ship: a small arrow that leans into turns, with a flickering flame.

const Tune := preload("res://tune.gd")

var tilt := 0.0
var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var c := Color(Tune.SHIP_COLOR)
	var lean := tilt * 4.0
	var flame := 6.0 + 3.0 * sin(_t * 30.0)
	draw_colored_polygon(PackedVector2Array([Vector2(-4, 9), Vector2(4, 9), Vector2(0, 9 + flame)]), Color("ff9a3a"))
	var hull := PackedVector2Array([Vector2(lean, -13), Vector2(11, 10), Vector2(0, 5), Vector2(-11, 10)])
	draw_colored_polygon(hull, c)
	hull.append(hull[0])
	draw_polyline(hull, c.darkened(0.5), 2.0, true)
	draw_circle(Vector2(lean * 0.5, -2), 3.0, Color("e8f6ff"))
