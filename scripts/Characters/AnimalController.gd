class_name AnimalController
extends CharacterBody2D

## Contrôleur partagé pour tous les animaux (brebis, vache, cochon, poule)
## CharacterBody2D → collisions avec le joueur et les autres animaux
## Déplacement aléatoire sur grille, AnimatedSprite2D pour le visuel

const TILE_SIZE : int   = 16
const IDLE_MIN  : float = 2.0
const IDLE_MAX  : float = 5.0

@export var move_speed   : float = 1.2
@export var field_bounds : Rect2 = Rect2(16, 16, 608, 448)

@onready var _sprite : AnimatedSprite2D = $AnimatedSprite2D

var _target   : Vector2
var _moving   := false
var _timer    := 0.0
var _cur_anim := &""  # Evite les appels play() redondants

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	position    = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	_target     = position
	_timer      = randf_range(IDLE_MIN, IDLE_MAX)
	_play(&"idle")

func _physics_process(delta: float) -> void:
	if _moving:
		_walk(delta)
	else:
		_timer -= delta
		if _timer <= 0.0:
			_pick_target()

## Avance vers la cible via move_and_slide (gère les collisions)
func _walk(delta: float) -> void:
	var to_target := _target - position
	var dist      := to_target.length()
	var step      := move_speed * TILE_SIZE * delta

	if dist <= step:
		position = _target
		velocity = Vector2.ZERO
		_moving  = false
		_timer   = randf_range(IDLE_MIN, IDLE_MAX)
		_play(&"idle")
		return

	velocity = to_target.normalized() * move_speed * TILE_SIZE
	# Flip sprite selon la direction horizontale
	if velocity.x < -0.5:
		_sprite.scale.x = -absf(_sprite.scale.x)
	elif velocity.x > 0.5:
		_sprite.scale.x =  absf(_sprite.scale.x)
	move_and_slide()
	# Si bloqué par une collision, renoncer à cette cible
	if (_target - position).length() >= dist - 0.1:
		_moving = false
		_timer  = randf_range(IDLE_MIN, IDLE_MAX)
		_play(&"idle")

## Appelle play() uniquement si l'animation change
func _play(anim: StringName) -> void:
	if anim != _cur_anim:
		_cur_anim = anim
		_sprite.play(anim)

## Choisit une tuile adjacente dans les bounds
func _pick_target() -> void:
	if randf() < 0.3:
		_timer = randf_range(IDLE_MIN, IDLE_MAX)
		return
	var dirs := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	dirs.shuffle()
	for d: Vector2 in dirs:
		var c := _target + d * TILE_SIZE
		if field_bounds.has_point(c):
			_target = c
			_moving = true
			_play(&"walk")
			return
	_timer = randf_range(IDLE_MIN, IDLE_MAX)
