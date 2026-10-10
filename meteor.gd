extends Node2D
## A meteor: a lumpy rock.

const Tune := preload("res://tune.gd")

var radius := 12.0
var _shape := PackedVector2Array()


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = get_instance_id()
	for i in 9:
		var a := TAU * i / 9.0
		_shape.append(Vector2.from_angle(a) * radius * rng.randf_range(0.78, 1.1))


func _draw() -> void:
	var c := Color(Tune.METEOR_COLOR)
	if Tune.METEOR_GLOW:
		for k in 3:
			draw_circle(Vector2.ZERO, radius * (1.9 - k * 0.3), Color(c, 0.08 + k * 0.05))
	draw_colored_polygon(_shape, c)
	var edge := _shape.duplicate()
	edge.append(_shape[0])
	draw_polyline(edge, c.darkened(0.45), 2.0, true)
	draw_circle(Vector2(-radius * 0.3, -radius * 0.2), radius * 0.22, c.darkened(0.3))
