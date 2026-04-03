class_name FieldGround
extends Node2D

@export var field_width  : int = 640
@export var field_height : int = 480
@export var fence_size   : int = 16

# ── Fences.png — 64×64, grille 4×4 de 16×16 ─────────────────────────────────
# Tile (2,0) = Rect2(32,0,16,16) : bras gauche + poteau + bras droit (x=0..15 opaque)
# C'est le seul tile qui produit une clôture continue — les bras se touchent
# au bord de chaque tile voisin, sans gap.
const _FENCE_TEX = preload("res://assets/sprites/Fences.png")

## Tile "section intérieure" — poteau centré avec bras horizontal des deux côtés
const R_FULL := Rect2(32, 0, 16, 16)

func _draw() -> void:
	_draw_fence()

# ── Clôture ────────────────────────────────────────────────────────────────────

func _draw_fence() -> void:
	var fw   := field_width
	var fh   := field_height
	var fs   := fence_size
	var half := fs * 0.5

	# Bords haut et bas — R_FULL tuilé tous les 16 px → continuité garantie
	for x in range(0, fw, fs):
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, 0,       fs, fs), R_FULL)
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, fh - fs, fs, fs), R_FULL)

	# Bords gauche et droit — R_FULL pivoté 90° → bras deviennent verticaux
	for y in range(fs, fh - fs, fs):
		for x_pos : int in [0, fw - fs]:
			draw_set_transform(Vector2(x_pos + half, y + half), PI * 0.5, Vector2.ONE)
			draw_texture_rect_region(_FENCE_TEX, Rect2(-half, -half, fs, fs), R_FULL)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
