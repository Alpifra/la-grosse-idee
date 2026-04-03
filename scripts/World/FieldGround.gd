class_name FieldGround
extends Node2D

@export var field_width  : int = 640
@export var field_height : int = 480
@export var fence_size   : int = 16

# ── Fences.png — 64×64, grille 4×4 de 16×16 ─────────────────────────────────
# Ligne y=0 seulement : (0,0) poteau │ (16,0) planche H │ reste vide
const _FENCE_TEX = preload("res://assets/sprites/Fences.png")

const R_POST  := Rect2( 0, 0, 16, 16)   # poteau rond
const R_BOARD := Rect2(16, 0, 16, 16)   # planche horizontale

const POST_STEP : int = 32   # un poteau tous les 2 tiles (32 px)

func _draw() -> void:
	_draw_fence()

# ── Clôture ────────────────────────────────────────────────────────────────────

func _draw_fence() -> void:
	var fw   := field_width
	var fh   := field_height
	var fs   := fence_size
	var half := fs * 0.5

	# Bords haut et bas — planches horizontales normales
	for x in range(0, fw, fs):
		var r := R_POST if (x % POST_STEP == 0) else R_BOARD
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, 0,       fs, fs), r)
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, fh - fs, fs, fs), r)

	# Bords gauche et droit — poteaux normaux, planches tournées à 90°
	for y in range(fs, fh - fs, fs):
		var is_post := (y % POST_STEP == 0)
		for x_pos : int in [0, fw - fs]:
			if is_post:
				draw_texture_rect_region(_FENCE_TEX, Rect2(x_pos, y, fs, fs), R_POST)
			else:
				draw_set_transform(Vector2(x_pos + half, y + half), PI * 0.5, Vector2.ONE)
				draw_texture_rect_region(_FENCE_TEX, Rect2(-half, -half, fs, fs), R_BOARD)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
