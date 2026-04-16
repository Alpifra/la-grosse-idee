class_name FarmerController
extends CharacterBody2D

## Personnage joueur — Fermier
## ZQSD + flèches directionnelles, 8 animations directionnelles
## Actions d'input : move_up / move_down / move_left / move_right

const WALK_SPEED : float = 100.0

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D

## Dernière direction mémorisée pour l'animation idle (bas par défaut)
var _last_dir  := Vector2.DOWN
var _cur_anim  := &""  # Animation courante — évite les appels play() redondants

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
	var anim: StringName
	if   dir == Vector2.LEFT:  anim = &"walk_left"
	elif dir == Vector2.RIGHT: anim = &"walk_right"
	elif dir == Vector2.UP:    anim = &"walk_up"
	else:                      anim = &"walk_down"
	_play(anim)

## Animation idle selon la dernière direction regardée
func _play_idle_anim() -> void:
	var anim: StringName
	if   _last_dir == Vector2.LEFT:  anim = &"idle_left"
	elif _last_dir == Vector2.RIGHT: anim = &"idle_right"
	elif _last_dir == Vector2.UP:    anim = &"idle_up"
	else:                            anim = &"idle_down"
	_play(anim)

## Appelle play() uniquement si l'animation change — évite un appel inutile à 60 fps
func _play(anim: StringName) -> void:
	if anim != _cur_anim:
		_cur_anim = anim
		_sprite.play(anim)
