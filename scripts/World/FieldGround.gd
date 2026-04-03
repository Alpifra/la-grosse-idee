class_name FieldGround
extends Node2D

@export var field_width  : int = 640
@export var field_height : int = 480
@export var fence_size   : int = 16

# ── Fences.png — 64×64, grille 4×4 de 16×16 ─────────────────────────────────
# Colonnes = connexion horizontale : 0=aucune, 1=+droite, 2=+gauche+droite, 3=+gauche
# Lignes   = connexion verticale   : 0=bas seul (y=3..15), 1=haut+bas (y=0..15),
#                                    2=haut seul (y=0..12), 3=isolé
const _FENCE_TEX = preload("res://assets/sprites/Fences.png")

# Sections courantes
const R_H  := Rect2(32,  0, 16, 16)  ## Tile(2,0) — planche gauche+droite, pas de haut — bords H
const R_V  := Rect2( 0, 16, 16, 16)  ## Tile(0,1) — poteau plein haut+bas, pas de planches — bords V

# Coins — combinaison de la connexion H (col) et V (ligne)
const R_TL := Rect2(16,  0, 16, 16)  ## Tile(1,0) — planche droite + bas seul  — coin haut-gauche
const R_TR := Rect2(48,  0, 16, 16)  ## Tile(3,0) — planche gauche + bas seul  — coin haut-droit
const R_BL := Rect2(16, 32, 16, 16)  ## Tile(1,2) — planche droite + haut seul — coin bas-gauche
const R_BR := Rect2(48, 32, 16, 16)  ## Tile(3,2) — planche gauche + haut seul — coin bas-droit

func _draw() -> void:
	_draw_fence()

# ── Clôture ────────────────────────────────────────────────────────────────────

func _draw_fence() -> void:
	var fw := field_width
	var fh := field_height
	var fs := fence_size

	# Coins
	draw_texture_rect_region(_FENCE_TEX, Rect2(0,       0,       fs, fs), R_TL)
	draw_texture_rect_region(_FENCE_TEX, Rect2(fw - fs, 0,       fs, fs), R_TR)
	draw_texture_rect_region(_FENCE_TEX, Rect2(0,       fh - fs, fs, fs), R_BL)
	draw_texture_rect_region(_FENCE_TEX, Rect2(fw - fs, fh - fs, fs, fs), R_BR)

	# Bords haut et bas — planches horizontales continues (hors coins)
	for x in range(fs, fw - fs, fs):
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, 0,       fs, fs), R_H)
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, fh - fs, fs, fs), R_H)

	# Bords gauche et droit — poteaux vus de profil (hors coins)
	for y in range(fs, fh - fs, fs):
		draw_texture_rect_region(_FENCE_TEX, Rect2(0,       y, fs, fs), R_V)
		draw_texture_rect_region(_FENCE_TEX, Rect2(fw - fs, y, fs, fs), R_V)
