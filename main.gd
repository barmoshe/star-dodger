extends Node2D
## Star Dodger: steer the ship (WASD or arrows), collect stars, dodge meteors.
## R restarts after a game over. --autoplay lets a simple pilot fly (for recordings).
## Press Ctrl+Shift+M while playing to leave Claude a mark.

const Tune := preload("res://tune.gd")
const W := 640.0
const H := 360.0

var ship: Node2D
var vel := Vector2.ZERO
var meteors: Array[Node2D] = []
var stars: Array[Node2D] = []
var sparks: Array = []
var score := 0
var lives := Tune.LIVES
var over := false
var shake := 0.0
var hurt := 0.0
var _t := 0.0
var _meteor_t := 0.0
var _star_t := 0.0
var _bg := []
var _autoplay := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 11
	_autoplay = "--autoplay" in OS.get_cmdline_user_args()
	for i in 90:
		_bg.append([Vector2(_rng.randf() * W, _rng.randf() * H), _rng.randf_range(0.2, 1.0)])
	var cam := Camera2D.new()
	cam.name = "Camera"
	cam.position = Vector2(W, H) / 2
	add_child(cam)
	ship = Node2D.new()
	ship.name = "Ship"
	ship.set_script(preload("res://ship.gd"))
	ship.add_to_group("ship")
	add_child(ship)
	_reset()
	if has_node("/root/Playmark"):
		Playmark.set_player(ship)
		Playmark.add_context("run", func(): return {"score": score, "lives": lives, "meteors": meteors.size(),
			"meteor_speed": _meteor_speed(), "ship": ship.position, "ship_velocity": vel})


func _reset() -> void:
	for m in meteors + stars:
		m.queue_free()
	meteors.clear()
	stars.clear()
	score = 0
	lives = Tune.LIVES
	over = false
	vel = Vector2.ZERO
	ship.position = Vector2(W / 2, H - 50)


func _meteor_speed() -> float:
	return Tune.METEOR_SPEED + Tune.METEOR_SPEED_PER_POINT * score


func _process(delta: float) -> void:
	_t += delta
	shake = maxf(shake - delta * 3.0, 0.0)
	hurt = maxf(hurt - delta * 2.0, 0.0)
	if over:
		if Input.is_physical_key_pressed(KEY_R) or (_autoplay and _t > 1.0):
			_reset()
		queue_redraw()
		return
	_steer(delta)
	_spawn(delta)
	_move_things(delta)
	_update_sparks(delta)
	var cam: Camera2D = $Camera
	cam.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * Tune.HIT_SHAKE * shake * shake
	queue_redraw()


func _steer(delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	for k in [[KEY_A, Vector2.LEFT], [KEY_D, Vector2.RIGHT], [KEY_W, Vector2.UP], [KEY_S, Vector2.DOWN]]:
		if Input.is_physical_key_pressed(k[0]):
			dir += k[1]
	if _autoplay:
		dir = _pilot()
	var want := dir.limit_length(1.0) * Tune.SHIP_SPEED
	vel = want if Tune.SHIP_ACCEL <= 0.0 else vel.move_toward(want, Tune.SHIP_ACCEL * delta)
	ship.position = (ship.position + vel * delta).clamp(Vector2(16, 40), Vector2(W - 16, H - 16))
	ship.tilt = clampf(vel.x / Tune.SHIP_SPEED, -1.0, 1.0)


## The recording pilot: heads for the nearest star, swerves from meteors close above.
func _pilot() -> Vector2:
	var goal := Vector2(W / 2 + sin(_t * 0.7) * 180, H - 60)
	var best := INF
	for s in stars:
		var d := ship.position.distance_to(s.position)
		if s.position.y < ship.position.y and d < best:
			best = d
			goal = s.position + Vector2(0, 40)
	var dir := (goal - ship.position) / 60.0
	for m in meteors:
		var off := ship.position - m.position
		if off.y > -10 and off.y < 90 and absf(off.x) < 34:
			dir.x += signf(off.x if off.x != 0 else 1.0) * 2.5
	return dir.limit_length(1.0)


func _spawn(delta: float) -> void:
	_meteor_t -= delta
	_star_t -= delta
	if _meteor_t <= 0.0:
		_meteor_t = Tune.METEOR_EVERY
		var m := Node2D.new()
		m.set_script(preload("res://meteor.gd"))
		m.position = Vector2(_rng.randf_range(20, W - 20), -20)
		m.radius = _rng.randf_range(9, 16)
		m.add_to_group("meteor")
		add_child(m)
		meteors.append(m)
	if _star_t <= 0.0:
		_star_t = Tune.STAR_EVERY
		var s := Node2D.new()
		s.set_script(preload("res://star.gd"))
		s.position = Vector2(_rng.randf_range(30, W - 30), -20)
		s.add_to_group("star")
		add_child(s)
		stars.append(s)


func _move_things(delta: float) -> void:
	for m in meteors.duplicate():
		m.position.y += _meteor_speed() * delta
		m.rotation += delta * 1.5
		if m.position.distance_to(ship.position) < m.radius + 9:
			_hit(m)
		elif m.position.y > H + 30:
			meteors.erase(m)
			m.queue_free()
	for s in stars.duplicate():
		s.position.y += Tune.STAR_SPEED * delta
		if s.position.distance_to(ship.position) < 18:
			score += 1
			_burst(s.position, Color(Tune.STAR_COLOR), 8)
			stars.erase(s)
			s.queue_free()
		elif s.position.y > H + 30:
			stars.erase(s)
			s.queue_free()


func _hit(m: Node2D) -> void:
	meteors.erase(m)
	m.queue_free()
	lives -= 1
	hurt = 1.0
	shake = 1.0
	_burst(ship.position, Color(Tune.METEOR_COLOR), Tune.HIT_SPARKS)
	if lives <= 0:
		over = true
		_t = 0.0


func _burst(at: Vector2, c: Color, n: int) -> void:
	for i in n:
		var a := _rng.randf() * TAU
		sparks.append({"p": at, "v": Vector2.from_angle(a) * _rng.randf_range(60, 180), "life": 0.5, "c": c})


func _update_sparks(delta: float) -> void:
	for s in sparks:
		s.p += s.v * delta
		s.v *= 0.92
		s.life -= delta
	sparks = sparks.filter(func(s): return s.life > 0.0)


func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("0b0b1a"))
	for b in _bg:
		var y := fmod(b[0].y + _t * 30.0 * b[1], H)
		draw_rect(Rect2(b[0].x, y, 1.5, 1.5), Color(1, 1, 1, 0.25 + 0.5 * b[1]))
	for s in sparks:
		draw_circle(s.p, 2.0, Color(s.c, clampf(s.life * 2.0, 0.0, 1.0)))
	if hurt > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(1, 0.2, 0.2, 0.25 * hurt))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(16, 26), "SCORE %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, Vector2(W - 110, 26), "LIVES " + "♥".repeat(maxi(lives, 0)), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("ff6b8a"))
	if over:
		draw_string(font, Vector2(W / 2 - 70, H / 2), "GAME OVER", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color.WHITE)
		draw_string(font, Vector2(W / 2 - 58, H / 2 + 28), "R to fly again", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1, 0.7))
