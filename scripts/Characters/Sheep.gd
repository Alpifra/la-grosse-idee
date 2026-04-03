class_name Sheep
extends CharacterBody2D

## Brebis pixel art — 100% draw_rect entiers, zéro Polygon2D
## Taille en jeu : ~18×14 px, ancré bas-centre
## 2 frames NES (idle / pas) — snap instantané, pas d'interpolation

const MOVE_SPEED : float = 1.2
const TILE_SIZE  : int   = 16
const IDLE_MIN   : float = 1.5
const IDLE_MAX   : float = 5.0

@export var field_bounds := Rect2(16, 16, 608, 448)

# ── Palette DQ2 brebis ────────────────────────────────────────────────────────
const C_WOOL  := Color(0.93, 0.93, 0.95)   # laine principale (blanc froid)
const C_SHAD  := Color(0.72, 0.72, 0.78)   # ombre sous la laine
const C_HEAD  := Color(0.88, 0.83, 0.76)   # tête beige
const C_SNOUT := Color(0.78, 0.70, 0.64)   # museau plus sombre
const C_EYE   := Color(0.10, 0.07, 0.06)   # œil
const C_LEG   := Color(0.60, 0.58, 0.54)   # pattes grises
const C_HOOF  := Color(0.22, 0.18, 0.16)   # sabots noirs

var _target_position : Vector2
var _moving          := false
var _idle_timer      := 0.0
var _step_alt        := false
var _walk_frame      := 0   # 0 = idle / 1 = pas

func _ready() -> void:
	position         = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	_target_position = position
	_idle_timer      = randf_range(IDLE_MIN, IDLE_MAX)

func _process(delta: float) -> void:
	if _moving:
		_step_towards_target(delta)
	else:
		_idle_timer -= delta
		if _idle_timer <= 0.0:
			_pick_next_tile()

func _draw() -> void:
	_draw_sheep(_walk_frame)

# ── Dessin pixel art ──────────────────────────────────────────────────────────

## Brebis complète en draw_rect entiers — ancre = bas-centre (0,0)
func _draw_sheep(frame: int) -> void:
	# ── Laine (corps) ─────────────────────────────────────────────────────────
	draw_rect(Rect2(-4, -13, 7,  1), C_WOOL)   # sommet (étroit)
	draw_rect(Rect2(-5, -12, 9,  2), C_WOOL)   # milieu haut
	draw_rect(Rect2(-6,  -10, 10, 3), C_WOOL)  # milieu large
	draw_rect(Rect2(-5,  -7,  8,  2), C_WOOL)  # bas laine
	draw_rect(Rect2(-4,  -5,  6,  1), C_SHAD)  # ombre inférieure

	# ── Tête (côté droit) ─────────────────────────────────────────────────────
	draw_rect(Rect2(4, -12, 4, 5), C_HEAD)     # crâne
	draw_rect(Rect2(5,  -7, 3, 2), C_SNOUT)    # museau
	draw_rect(Rect2(5, -10, 1, 2), C_EYE)      # œil

	# ── Pattes 4x — alternance frame 0/1 ─────────────────────────────────────
	# frame 0 (idle) : toutes au sol — frame 1 (pas) : A levées, B abaissées
	var oa := -1 if frame == 1 else 0   # offset patte A (avant-gauche, arrière-droite)
	var ob :=  0 if frame == 1 else -1  # offset patte B (avant-droite, arrière-gauche)
	_leg(-5, oa)   # avant gauche
	_leg(-2, ob)   # avant droite
	_leg( 2, ob)   # arrière gauche
	_leg( 5, oa)   # arrière droite

## Dessine une patte + sabot à la colonne x avec un offset vertical
func _leg(x: int, offset: int) -> void:
	draw_rect(Rect2(x, -4 + offset, 2, 3), C_LEG)
	draw_rect(Rect2(x, -1 + offset, 2, 1), C_HOOF)

# ── Mouvement (identique à avant) ────────────────────────────────────────────

func _set_frame(f: int) -> void:
	_walk_frame = f
	queue_redraw()

func _step_towards_target(delta: float) -> void:
	position = position.move_toward(_target_position, MOVE_SPEED * TILE_SIZE * delta)
	if position.is_equal_approx(_target_position):
		position    = _target_position
		_moving     = false
		_idle_timer = randf_range(IDLE_MIN, IDLE_MAX)
		_set_frame(0)

func _pick_next_tile() -> void:
	if randf() < 0.3:
		_idle_timer = randf_range(IDLE_MIN, IDLE_MAX)
		return
	var dirs := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	dirs.shuffle()
	for dir: Vector2 in dirs:
		var candidate := _target_position + dir * TILE_SIZE
		if field_bounds.has_point(candidate):
			_target_position = candidate
			_moving          = true
			_step_alt        = !_step_alt
			_set_frame(1 if _step_alt else 0)
			return
	_idle_timer = randf_range(IDLE_MIN, IDLE_MAX)
