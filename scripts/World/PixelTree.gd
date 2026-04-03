class_name PixelTree
extends Node2D

## Arbre pixel art — 100% draw_rect entiers, zéro Sprite2D / Polygon2D
## Canopée pyramidale 4 niveaux + tronc — style DQ2 16-bit
## Ancre : bas-centre (0,0) — hauteur totale ≈ 37 px

# ── Palette ────────────────────────────────────────────────────────────────────
const C_TRUNK  := Color(0.38, 0.22, 0.08)   # tronc marron
const C_BARK   := Color(0.24, 0.13, 0.04)   # ombre tronc (bord gauche)
const C_DARK   := Color(0.08, 0.32, 0.10)   # feuillage bas / ombre
const C_MID    := Color(0.16, 0.52, 0.18)   # feuillage moyen
const C_LIGHT  := Color(0.34, 0.72, 0.24)   # reflet haut

func _draw() -> void:
	# ── Tronc ──────────────────────────────────────────────────────────────────
	draw_rect(Rect2(-2,  -8,  4, 8), C_TRUNK)
	draw_rect(Rect2(-2,  -8,  1, 8), C_BARK)    # ombre 1 px côté gauche

	# ── Canopée — 5 rectangles empilés (base large → pointe) ──────────────────
	draw_rect(Rect2(-12, -16, 24, 8), C_DARK)   # base (ombre portée)
	draw_rect(Rect2(-10, -24, 20, 8), C_MID)    # niveau 2
	draw_rect(Rect2( -7, -30, 14, 6), C_MID)    # niveau 3
	draw_rect(Rect2( -4, -34,  8, 4), C_LIGHT)  # niveau 4
	draw_rect(Rect2( -2, -37,  4, 3), C_LIGHT)  # pointe

	# ── Reflet (1 px au sommet de la pointe) ───────────────────────────────────
	draw_rect(Rect2( -1, -37,  2, 2), Color(0.50, 0.86, 0.32))
