class_name FarmerController
extends CharacterBody2D

## Personnage joueur — Fermier
## ZQSD + flèches directionnelles, 8 animations directionnelles
## Actions d'input : move_up / move_down / move_left / move_right

const WALK_SPEED : float = 100.0

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D

## Dernière direction mémorisée pour l'animation idle (bas par défaut)
var _last_dir := Vector2.DOWN

func _ready() -> void:
	add_to_group("player")
	_sprite.play("idle_down")

func _physics_process(_delta: float) -> void:
	var dir := _read_input()
	if dir != Vector2.ZERO:
		velocity = dir * WALK_SPEED
		_last_dir = dir
		_play_walk_anim(dir)
	else:
		velocity = Vector2.ZERO
		_play_idle_anim()
	move_and_slide()

# ── Input ──────────────────────────────────────────────────────────────────────

## Lecture des actions — 4 directions strictes (vecteurs unitaires, pas besoin de normalize)
## Priorité : gauche > droite > haut > bas
func _read_input() -> Vector2:
	if Input.is_action_pressed("move_left"):  return Vector2.LEFT
	if Input.is_action_pressed("move_right"): return Vector2.RIGHT
	if Input.is_action_pressed("move_up"):    return Vector2.UP
	if Input.is_action_pressed("move_down"):  return Vector2.DOWN
	return Vector2.ZERO

# ── Animations ─────────────────────────────────────────────────────────────────

## Animation de marche selon la direction
func _play_walk_anim(dir: Vector2) -> void:
	if   dir == Vector2.LEFT:  _sprite.play("walk_left")
	elif dir == Vector2.RIGHT: _sprite.play("walk_right")
	elif dir == Vector2.UP:    _sprite.play("walk_up")
	elif dir == Vector2.DOWN:  _sprite.play("walk_down")

## Animation idle selon la dernière direction regardée
func _play_idle_anim() -> void:
	if   _last_dir == Vector2.LEFT:  _sprite.play("idle_left")
	elif _last_dir == Vector2.RIGHT: _sprite.play("idle_right")
	elif _last_dir == Vector2.UP:    _sprite.play("idle_up")
	else:                             _sprite.play("idle_down")
