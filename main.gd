extends Node2D
## The starting point: an empty room and a square you move with WASD or the arrow keys.
## Build the game from here. Press Ctrl+Shift+M while playing to leave Claude a mark.

const SPEED := 180.0
const ROOM := Rect2(40, 40, 560, 280)

var player: Node2D


func _ready() -> void:
	var cam := Camera2D.new()
	cam.position = Vector2(320, 180)
	add_child(cam)
	player = Node2D.new()
	player.name = "Player"
	player.position = ROOM.get_center()
	player.set_script(preload("res://player.gd"))
	add_child(player)
	if has_node("/root/Playmark"):
		Playmark.set_player(player)
		Playmark.add_context("player", func(): return {"position": player.position})


func _process(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	for k in [[KEY_A, Vector2.LEFT], [KEY_D, Vector2.RIGHT], [KEY_W, Vector2.UP], [KEY_S, Vector2.DOWN]]:
		if Input.is_physical_key_pressed(k[0]):
			dir += k[1]
	player.position = (player.position + dir.limit_length(1.0) * SPEED * delta).clamp(ROOM.position + Vector2(12, 12), ROOM.end - Vector2(12, 12))
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(0, 0, 640, 360), Color("1c1a2a"))
	draw_rect(ROOM, Color("2a2740"))
	draw_rect(ROOM, Color("4b4670"), false, 2.0)
