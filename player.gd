extends Node2D
## The player: a square for now.


func _draw() -> void:
	draw_rect(Rect2(-10, -10, 20, 20), Color("f2621b"))
	draw_rect(Rect2(-10, -10, 20, 20), Color("111111"), false, 2.0)


func _process(_delta: float) -> void:
	queue_redraw()
