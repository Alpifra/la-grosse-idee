class_name BlueWomanController
extends CharacterBody2D

## Personnage féminin — AnimatedSprite2D avec blue_haired_woman_shadow.png
## ZQSD + flèches directionnelles, Shift = course
## 8 animations : idle_down/up, walk/run left/right, walk up/down

const WALK_SPEED : float = 80.0
const RUN_SPEED  : float = 150.0

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D

## Direction mémorisée pour l'animation idle (bas par défaut)
var _last_dir := Vector2.DOWN

func _ready() -> void:
	add_to_group("player")
	_sprite.play("idle_down")

func _physics_process(_delta: float) -> void:
	var dir := _read_input()
	var run  := Input.is_key_pressed(KEY_SHIFT)

	if dir != Vector2.ZERO:
		velocity  = dir.normalized() * (RUN_SPEED if run else WALK_SPEED)
		_last_dir = dir
		_play_move_anim(dir, run)
	else:
		velocity = Vector2.ZERO
		_play_idle_anim()

	move_and_slide()

# ── Input ─────────────────────────────────────────────────────────────────────

## Lecture ZQSD + flèches — 4 directions strictes, pas de diagonale
## Priorité : horizontal > vertical
func _read_input() -> Vector2:
	if Input.is_key_pressed(KEY_LEFT)  or Input.is_key_pressed(KEY_Q): return Vector2.LEFT
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D): return Vector2.RIGHT
	if Input.is_key_pressed(KEY_UP)    or Input.is_key_pressed(KEY_Z): return Vector2.UP
	if Input.is_key_pressed(KEY_DOWN)  or Input.is_key_pressed(KEY_S): return Vector2.DOWN
	return Vector2.ZERO

# ── Animations ────────────────────────────────────────────────────────────────

## Animation de déplacement — direction toujours pure (pas de diagonale)
func _play_move_anim(dir: Vector2, run: bool) -> void:
	if dir == Vector2.LEFT:
		_sprite.play("run_left"  if run else "walk_left")
	elif dir == Vector2.RIGHT:
		_sprite.play("run_right" if run else "walk_right")
	elif dir == Vector2.UP:
		_sprite.play("walk_up")
	elif dir == Vector2.DOWN:
		_sprite.play("walk_down")

## Animation idle selon la dernière direction regardée
func _play_idle_anim() -> void:
	if _last_dir == Vector2.UP:
		_sprite.play("idle_up")
	else:
		_sprite.play("idle_down")
