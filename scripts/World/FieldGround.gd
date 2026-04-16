class_name FieldGround
extends Node2D

@export var field_width  : int = 640
@export var field_height : int = 480
@export var fence_size   : int = 16

# ── Fences.png — 64×64, grille 4×4 de 16×16 ─────────────────────────────────
# Colonnes = connexion horizontale : 0=aucune, 1=+droite, 2=+gauche+droite, 3=+gauche
# Lignes   = plage Y opaque du poteau :
#   row 0 → y=3..13  (isolé haut — pas utilisé, post trop court)
#   row 1 → y=3..15  (connecte vers le bas — bord haut + coins haut)
#   row 2 → y=0..15  (connecte vers le haut — bord bas + coins bas)
#   row 3 → y=0..13  (isolé bas — non utilisé)
#
# Choix par bord :
#   Bord HAUT  : row 1 (y=3..15) → le post descend jusqu'au bord du tile,
#                s'enchaîne sans gap avec R_V (row 1 aussi, y=0..15 au tile suivant)
#   Bord BAS   : row 2 (y=0..15) → même plage que les coins bas → pas d'excès
#   Côtés V    : row 1 colonne 0 (y=0..15) → traverse sans coupure

const _FENCE_TEX = preload("res://assets/sprites/Fences.png")

const R_HT := Rect2(32, 16, 16, 16)  ## Tile(2,1) — planches G+D, post y=3..15 — bord haut
const R_HB := Rect2(32, 32, 16, 16)  ## Tile(2,2) — planches G+D, post y=0..15 — bord bas
const R_V  := Rect2( 0, 16, 16, 16)  ## Tile(0,1) — post y=0..15, pas de planches — côtés V

const R_TL := Rect2(16, 16, 16, 16)  ## Tile(1,1) — planche droite,  post y=3..15 — coin haut-gauche
const R_TR := Rect2(48, 16, 16, 16)  ## Tile(3,1) — planche gauche,  post y=3..15 — coin haut-droit
const R_BL := Rect2(16, 32, 16, 16)  ## Tile(1,2) — planche droite,  post y=0..15 — coin bas-gauche
const R_BR := Rect2(48, 32, 16, 16)  ## Tile(3,2) — planche gauche,  post y=0..15 — coin bas-droit

func _ready() -> void:
	_add_fence_collision()

func _draw() -> void:
	_draw_fence()

# ── Collisions physiques ──────────────────────────────────────────────────────

## Crée 4 murs invisibles (StaticBody2D) le long du périmètre de la clôture.
## Le joueur et les animaux ne peuvent pas traverser les barrières.
func _add_fence_collision() -> void:
	var body := StaticBody2D.new()
	add_child(body)
	var fw  := float(field_width)
	var fh  := float(field_height)
	var fs  := float(fence_size)
	# Bord haut
	_add_rect(body, Vector2(fw * 0.5, fs * 0.5),       Vector2(fw, fs))
	# Bord bas
	_add_rect(body, Vector2(fw * 0.5, fh - fs * 0.5),  Vector2(fw, fs))
	# Bord gauche
	_add_rect(body, Vector2(fs * 0.5, fh * 0.5),       Vector2(fs, fh))
	# Bord droit
	_add_rect(body, Vector2(fw - fs * 0.5, fh * 0.5),  Vector2(fs, fh))

func _add_rect(body: StaticBody2D, center: Vector2, size: Vector2) -> void:
	var cs    := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size  = size
	cs.shape    = shape
	cs.position = center
	body.add_child(cs)

# ── Clôture ────────────────────────────────────────────────────────────────────

func _draw_fence() -> void:
	var fw := field_width
	var fh := field_height
	var fs := fence_size

	# Coins
	draw_texture_rect_region(_FENCE_TEX, Rect2(0,       0,       fs, fs), R_TL)
	draw_texture_rect_region(_FENCE_TEX, Rect2(fw - fs, 0,       fs, fs), R_TR)
	draw_texture_rect_region(_FENCE_TEX, Rect2(0,       fh - fs, fs, fs), R_TL)
	draw_texture_rect_region(_FENCE_TEX, Rect2(fw - fs, fh - fs, fs, fs), R_TR)

	# Bords haut et bas — même tuile (row 1) pour une apparence cohérente
	for x in range(fs, fw - fs, fs):
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, 0,       fs, fs), R_HT)
		draw_texture_rect_region(_FENCE_TEX, Rect2(x, fh - fs, fs, fs), R_HT)

	# Bords gauche et droit — poteaux vus de profil (hors coins)
	for y in range(fs, fh - fs, fs):
		draw_texture_rect_region(_FENCE_TEX, Rect2(0,       y, fs, fs), R_V)
		draw_texture_rect_region(_FENCE_TEX, Rect2(fw - fs, y, fs, fs), R_V)
