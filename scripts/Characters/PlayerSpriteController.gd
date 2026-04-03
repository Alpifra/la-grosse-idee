class_name PlayerSpriteController
extends CharacterBody2D

## Fermier pixel art — 100% draw_rect entiers, zéro AnimatedSprite2D
## Mouvement 4 directions, 2 frames d'animation marche (alternance jambes)
## Ancre : bas-centre (0,0) — hauteur totale ≈ 27 px

const SPEED : float = 80.0

# ── Palette fermier DQ2 ────────────────────────────────────────────────────────
const C_SKIN  := Color(0.94, 0.82, 0.68)   # peau
const C_HAIR  := Color(0.32, 0.18, 0.08)   # cheveux bruns
const C_SHIRT := Color(0.22, 0.50, 0.82)   # chemise bleue
const C_PANTS := Color(0.25, 0.20, 0.14)   # pantalon marron
const C_SHOE  := Color(0.16, 0.10, 0.06)   # chaussures noires
const C_BELT  := Color(0.50, 0.36, 0.10)   # ceinture dorée
const C_EYE   := Color(0.10, 0.06, 0.02)   # yeux

var _walk_frame  := 0      # 0 = pied droit, 1 = pied gauche
var _step_timer  := 0.0    # accumulateur pas
var _moving      := false

func _physics_process(delta: float) -> void:
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up",   "ui_down")
	)

	if input != Vector2.ZERO:
		velocity = input.normalized() * SPEED
		_step_timer += delta
		if _step_timer >= 0.2:
			_step_timer  = 0.0
			_walk_frame  = 1 - _walk_frame
			queue_redraw()
		if not _moving:
			_moving = true
			queue_redraw()
	else:
		velocity = Vector2.ZERO
		if _moving:
			_moving     = false
			_walk_frame = 0
			queue_redraw()

	move_and_slide()

func _draw() -> void:
	_draw_farmer(_walk_frame)

## Fermier en draw_rect entiers — ancre bas-centre (0,0)
func _draw_farmer(frame: int) -> void:
	# ── Jambes (alternance frame 0/1) ─────────────────────────────────────────
	var la := -1 if frame == 1 else 0   # pied gauche levé sur frame 1
	var lb :=  0 if frame == 1 else -1  # pied droit levé sur frame 0
	draw_rect(Rect2(-4, -5 + la, 3, 5), C_SHOE)   # jambe gauche
	draw_rect(Rect2( 1, -5 + lb, 3, 5), C_SHOE)   # jambe droite

	# ── Pantalon ───────────────────────────────────────────────────────────────
	draw_rect(Rect2(-4, -11, 8, 6), C_PANTS)

	# ── Ceinture ───────────────────────────────────────────────────────────────
	draw_rect(Rect2(-4, -12, 8, 1), C_BELT)

	# ── Chemise + bras ─────────────────────────────────────────────────────────
	draw_rect(Rect2(-4, -19, 8, 7), C_SHIRT)
	draw_rect(Rect2(-6, -18, 2, 5), C_SHIRT)   # bras gauche
	draw_rect(Rect2( 4, -18, 2, 5), C_SHIRT)   # bras droit

	# ── Mains ──────────────────────────────────────────────────────────────────
	draw_rect(Rect2(-6, -14, 2, 2), C_SKIN)
	draw_rect(Rect2( 4, -14, 2, 2), C_SKIN)

	# ── Tête ───────────────────────────────────────────────────────────────────
	draw_rect(Rect2(-3, -25, 6, 6), C_SKIN)    # visage
	draw_rect(Rect2(-3, -27, 6, 2), C_HAIR)    # cheveux

	# ── Yeux ───────────────────────────────────────────────────────────────────
	draw_rect(Rect2(-1, -23, 1, 1), C_EYE)     # œil gauche
	draw_rect(Rect2( 1, -23, 1, 1), C_EYE)     # œil droit
