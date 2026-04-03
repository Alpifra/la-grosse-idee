class_name PixelCloud
extends Node2D

## Nuage pixel art défilant — 100% draw_rect entiers, zéro Polygon2D
## 3 bosses cumuliformes : gauche / centre (plus haute) / droite
## 3 tons générés depuis cloud_color exporté

@export var cloud_color  : Color  = Color(0.24, 0.50, 0.82, 1)   # bleu SNES jour
@export var drift_speed  : float  = -14.0                          # px/s (négatif = vers gauche)
@export var wrap_x_min   : float  = -60.0                          # réapparition à gauche
@export var wrap_x_max   : float  = 380.0                          # départ à droite

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	position.x += drift_speed * delta
	if drift_speed < 0 and position.x < wrap_x_min:
		position.x = wrap_x_max
	elif drift_speed > 0 and position.x > wrap_x_max:
		position.x = wrap_x_min

func _draw() -> void:
	var c_shad := cloud_color.darkened(0.40)
	var c_body := cloud_color
	var c_glow := cloud_color.lightened(0.45)

	# ── Ombre base (dessous plat) ──────────────────────────────────────────────
	draw_rect(Rect2(-18,  -7, 36, 7), c_shad)

	# ── Corps : bosse gauche ───────────────────────────────────────────────────
	draw_rect(Rect2(-16, -11,  8, 4), c_body)

	# ── Corps : bosse droite ───────────────────────────────────────────────────
	draw_rect(Rect2(  8, -11,  8, 4), c_body)

	# ── Corps : bosse centrale (la plus haute) ─────────────────────────────────
	draw_rect(Rect2( -6, -15, 12, 8), c_body)

	# ── Reflets (1 ligne claire au sommet de chaque bosse) ────────────────────
	draw_rect(Rect2( -3, -15,  6, 2), c_glow)   # sommet central
	draw_rect(Rect2(-14, -11,  4, 2), c_glow)   # sommet gauche
	draw_rect(Rect2( 10, -11,  4, 2), c_glow)   # sommet droit
