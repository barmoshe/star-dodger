extends Node2D
## A star to collect: five points, a soft pulse.

const Tune := preload("res://tune.gd")

var _t := 0.0


func _process(delta: float) -> void:
	_t += delta
	rotation += delta
	queue_redraw()


func _draw() -> void:
	var c := Color(Tune.STAR_COLOR)
	var s := 1.0 + 0.12 * sin(_t * 6.0)
	draw_circle(Vector2.ZERO, 12.0 * s, Color(c, 0.15))
	var pts := PackedVector2Array()
	for i in 10:
		var r := (8.0 if i % 2 == 0 else 3.5) * s
		pts.append(Vector2.from_angle(TAU * i / 10.0 - PI / 2) * r)
	draw_colored_polygon(pts, c)
