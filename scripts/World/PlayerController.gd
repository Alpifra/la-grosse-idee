class_name PlayerController
extends CharacterBody2D

enum Direction { DOWN, UP, RIGHT, LEFT }

const MOVE_SPEED : float = 5.0
const TILE_SIZE  : int   = 16

@export var movement_bounds := Rect2(16, 16, 608, 448)

# ── Références visuelles ──────────────────────────────────────────────────────
@onready var _visual : Node2D    = $Visual
@onready var _hair   : Polygon2D = $Visual/Hair
@onready var _head   : Polygon2D = $Visual/Head
@onready var _ear_l  : Polygon2D = $Visual/EarL
@onready var _ear_r  : Polygon2D = $Visual/EarR
@onready var _eye_l  : Polygon2D = $Visual/EyeL
@onready var _eye_r  : Polygon2D = $Visual/EyeR
@onready var _leg_l  : Polygon2D = $Visual/LegL
@onready var _leg_r  : Polygon2D = $Visual/LegR
@onready var _boot_l : Polygon2D = $Visual/BootL
@onready var _boot_r : Polygon2D = $Visual/BootR

# ── 3 frames NES — snap instantané ───────────────────────────────────────────
# Frame 0 = neutre | Frame 1 = pas gauche | Frame 2 = pas droit
const F_LEG_L : Array[int] = [ 0, -2,  0]
const F_LEG_R : Array[int] = [ 0,  0, -2]
const F_BODY  : Array[int] = [ 0, -1, -1]

# ── Polygones par direction (static var — PackedVector2Array non-const) ────────

# Cheveux — face avant : couronne arrondie au-dessus de la tête
static var POLY_HAIR_FRONT := PackedVector2Array([
	Vector2(-5,-20), Vector2(5,-20), Vector2(6,-16), Vector2(4,-14), Vector2(-4,-14), Vector2(-6,-16)])
# Cheveux — dos : couvre tout le crâne, yeux et oreilles masqués
static var POLY_HAIR_BACK := PackedVector2Array([
	Vector2(-5,-20), Vector2(5,-20), Vector2(5,-10), Vector2(-5,-10)])
# Cheveux — profil droit : asymétriques, s'étirent vers l'arrière
static var POLY_HAIR_SIDE := PackedVector2Array([
	Vector2(-2,-20), Vector2(5,-20), Vector2(6,-15), Vector2(3,-13), Vector2(-2,-13)])

# Tête — face avant : 8 px large, plein visage
static var POLY_HEAD_FRONT := PackedVector2Array([
	Vector2(-4,-16), Vector2(4,-16), Vector2(4,-10), Vector2(-4,-10)])
# Tête — dos : couverte par les cheveux (même forme, couleur différente)
static var POLY_HEAD_BACK  := PackedVector2Array([
	Vector2(-4,-16), Vector2(4,-16), Vector2(4,-10), Vector2(-4,-10)])
# Tête — profil : 5 px large (côté droit visible)
static var POLY_HEAD_SIDE  := PackedVector2Array([
	Vector2(-1,-16), Vector2(4,-16), Vector2(4,-10), Vector2(-1,-10)])

const COLOR_SKIN       := Color(0.95, 0.78, 0.58, 1)
const COLOR_SKIN_BACK  := Color(0.75, 0.58, 0.42, 1)   # dos légèrement plus sombre

var _target_position : Vector2
var _moving          := false
var _step_alt        := false
var _direction       := Direction.DOWN

func _ready() -> void:
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	_target_position = position
	_apply_direction(Direction.DOWN)
	_apply_frame(0)

func _process(delta: float) -> void:
	if _moving:
		_step_towards_target(delta)
	else:
		_read_input()

## Lit les entrées, tourne immédiatement (DQ2 style), puis démarre le pas
func _read_input() -> void:
	var dir_vec := Vector2.ZERO
	var new_dir := _direction

	if Input.is_action_pressed("ui_right"):   dir_vec = Vector2.RIGHT ; new_dir = Direction.RIGHT
	elif Input.is_action_pressed("ui_left"):  dir_vec = Vector2.LEFT  ; new_dir = Direction.LEFT
	elif Input.is_action_pressed("ui_down"):  dir_vec = Vector2.DOWN  ; new_dir = Direction.DOWN
	elif Input.is_action_pressed("ui_up"):    dir_vec = Vector2.UP    ; new_dir = Direction.UP

	if dir_vec != Vector2.ZERO:
		_apply_direction(new_dir)

	if dir_vec == Vector2.ZERO:
		return
	var next := position + dir_vec * TILE_SIZE
	if movement_bounds.has_point(next):
		_target_position = next
		_moving   = true
		_step_alt = !_step_alt
		_apply_frame(1 if _step_alt else 2)

## Glisse vers la tuile cible à vitesse constante
func _step_towards_target(delta: float) -> void:
	position = position.move_toward(_target_position, MOVE_SPEED * TILE_SIZE * delta)
	if position.is_equal_approx(_target_position):
		position = _target_position
		_moving  = false
		_apply_frame(0)

## Applique une frame NES : snap entier, zéro interpolation
## Les bottes suivent les jambes pour conserver le contact avec le sol
func _apply_frame(f: int) -> void:
	_leg_l.position.y  = float(F_LEG_L[f])
	_boot_l.position.y = float(F_LEG_L[f])
	_leg_r.position.y  = float(F_LEG_R[f])
	_boot_r.position.y = float(F_LEG_R[f])
	_visual.position.y = float(F_BODY[f])

## Change l'orientation complète du sprite — polygones et visibilité swappés
func _apply_direction(dir: Direction) -> void:
	if _direction == dir:
		return
	_direction = dir
	match dir:

		Direction.DOWN:
			_visual.scale.x  = 1
			_hair.polygon    = POLY_HAIR_FRONT
			_head.polygon    = POLY_HEAD_FRONT
			_head.color      = COLOR_SKIN
			_ear_l.visible   = true
			_ear_r.visible   = true
			_eye_l.visible   = true
			_eye_r.visible   = true

		Direction.UP:
			_visual.scale.x  = 1
			_hair.polygon    = POLY_HAIR_BACK    # couvre tout le crâne
			_head.polygon    = POLY_HEAD_BACK
			_head.color      = COLOR_SKIN_BACK   # dos légèrement plus sombre
			_ear_l.visible   = false             # masqués par les cheveux
			_ear_r.visible   = false
			_eye_l.visible   = false
			_eye_r.visible   = false

		Direction.RIGHT:
			_visual.scale.x  = 1
			_hair.polygon    = POLY_HAIR_SIDE
			_head.polygon    = POLY_HEAD_SIDE
			_head.color      = COLOR_SKIN
			_ear_l.visible   = false             # oreille lointaine masquée
			_ear_r.visible   = true
			_ear_r.position  = Vector2(3.0, -13.0)
			_eye_l.visible   = false
			_eye_r.visible   = true
			_eye_r.position  = Vector2(1.0, -14.0)

		Direction.LEFT:
			_visual.scale.x  = -1               # miroir du profil droit
			_hair.polygon    = POLY_HAIR_SIDE
			_head.polygon    = POLY_HEAD_SIDE
			_head.color      = COLOR_SKIN
			_ear_l.visible   = false
			_ear_r.visible   = true
			_ear_r.position  = Vector2(3.0, -13.0)
			_eye_l.visible   = false
			_eye_r.visible   = true
			_eye_r.position  = Vector2(1.0, -14.0)
