class_name FieldGround
extends Node2D

@export var field_width  : int = 640
@export var field_height : int = 480
@export var fence_size   : int = 16

# ── Fences.png — 64×64, grille 4×4 de 16×16 ─────────────────────────────────
# Colonnes = connexion horizontale : 0=poteau seul, 1=+droit, 2=+gauche+droit, 3=+gauche
# Lignes   = connexion verticale   : 0=haut, 1=milieu (y=0..15), 2=bas, 3=isolé
#
# R_H : Tile(2,0) — planche H + poteau, x=0..15 opaque → tuile haut/bas sans gap
# R_V : Tile(0,1) — poteau seul y=0..15 → tuile côté gauche/droit (vue de profil top-down :
#                   les planches partent en profondeur, invisibles — seul le poteau est visible)
const _FENCE_TEX = preload("res://assets/sprites/Fences.png")

const R_H := Rect2(32, 0,  16, 16)   ## poteau + planches gauche & droite — bords haut/bas
const R_V := Rect2( 0, 16, 16, 16)   ## poteau seul pleine hauteur (y=0..15) — bords gauche/droit

func _draw() -> void:
	_draw_fence()

# ── Clôture ────────────────────────────────────────────────────────────────────

func _draw_fence() -> void:
	var fw := field_width
	var fh := field_height
	var fs := fence_size

	# Bords haut et bas — planches horizontales continues
	for x in range(0, fw, fs):
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, 0,       fs, fs), R_H)
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, fh - fs, fs, fs), R_H)

	# Bords gauche et droit — poteaux vus de profil (planches perpendiculaires à la caméra)
	for y in range(fs, fh - fs, fs):
		draw_texture_rect_region(_FENCE_TEX, Rect2(0,       y, fs, fs), R_V)
		draw_texture_rect_region(_FENCE_TEX, Rect2(fw - fs, y, fs, fs), R_V)
