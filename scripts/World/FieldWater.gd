## Dessine le lac, les deux rivières et le pont en pixel art.
## Placé dans Field.tscn avec z_index = -9 (entre sol −11 et clôture −10 = visible au-dessus).
##
## VÉRIFICATION :
##   - Au démarrage, la console Godot affiche une carte ASCII de toutes les tuiles d'eau.
##   - Appuyer sur F3 en jeu bascule un overlay coloré sur chaque tuile (désactiver pour la prod).
extends Node2D

const TILE := 16
const COLS := 40   # 640 ÷ 16
const ROWS := 30   # 480 ÷ 16

const _WAT_MID  := preload("res://assets/sprites/Water_Middle.png")
const _WAT_TILE := preload("res://assets/sprites/Water_Tile.png")
const _BRIDGE   := preload("res://assets/sprites/Bridge_Wood.png")

# ── Géométrie des plans d'eau ──────────────────────────────────────────────────
# Lac        : cols  3– 9, rows  3– 9  (7×7 tuiles, coin haut-gauche)
# Rivière H  : cols  9–39, rows  5– 7  (3 tuiles de haut, s'étend jusqu'au bord droit)
# Rivière V  : cols 22–24, rows  0– 7  (3 tuiles de large, descend depuis le bord haut)
# Pont       : cols 22–24, rows  2– 4  (sur la rivière V, passage E–O)
#
# Water_Tile.png — grille 3×6, tuiles 16 px :
#   row 0 : coins convexes  (TL, haut, TR)
#   row 1 : bords           (gauche, intérieur, droite)
#   row 2 : coins convexes  (BL, bas, BR)
#   row 3 : coins concaves  (TL, TR)
#   row 4 : coins concaves  (BL, BR)

var _debug_overlay := false

## Renvoie vrai si la tuile (c, r) appartient au plan d'eau
func _is_water(c: int, r: int) -> bool:
	if c >= 3  and c <= 9  and r >= 3 and r <= 9: return true  # lac
	if c >= 9  and c <= 39 and r >= 5 and r <= 7: return true  # rivière H
	if c >= 22 and c <= 24 and r >= 0 and r <= 7: return true  # rivière V
	return false

## Rectangle source dans Water_Tile.png
func _wt(col: int, row: int) -> Rect2:
	return Rect2(col * TILE, row * TILE, TILE, TILE)

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_print_water_map()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		_debug_overlay = not _debug_overlay
		queue_redraw()
		print("[FieldWater] Debug overlay: ", "ON" if _debug_overlay else "OFF")

func _draw() -> void:
	_draw_water_tiles()
	_draw_concave_corners()
	_draw_bridge()
	if _debug_overlay:
		_draw_debug_overlay()

# ── Eau ────────────────────────────────────────────────────────────────────────

## Dessine chaque tuile d'eau avec le bord correct calculé par voisinage cardinal
func _draw_water_tiles() -> void:
	for r in range(ROWS):
		for c in range(COLS):
			if not _is_water(c, r):
				continue
			var n := _is_water(c,     r - 1)
			var s := _is_water(c,     r + 1)
			var e := _is_water(c + 1, r    )
			var w := _is_water(c - 1, r    )
			var dest := Rect2(c * TILE, r * TILE, TILE, TILE)

			# Intérieur : tuile bleue unie
			if n and s and e and w:
				draw_texture_rect(_WAT_MID, dest, false)
				continue

			# Coins convexes (2 côtés adjacents manquants)
			var src: Rect2
			if   not n and not w and s and e: src = _wt(0, 0)  # coin haut-gauche
			elif not n and not e and s and w: src = _wt(2, 0)  # coin haut-droite
			elif not s and not w and n and e: src = _wt(0, 2)  # coin bas-gauche
			elif not s and not e and n and w: src = _wt(2, 2)  # coin bas-droite
			# Bords (1 seul côté manquant)
			elif not n: src = _wt(1, 0)  # bord haut
			elif not s: src = _wt(1, 2)  # bord bas
			elif not w: src = _wt(0, 1)  # bord gauche
			else:       src = _wt(2, 1)  # bord droite

			draw_texture_rect_region(_WAT_TILE, dest, src)

## Coins concaves aux jonctions lac–rivière H et rivière V–rivière H
## Ces tiles sont des tuiles TERRE avec eau en coin, dessinées sur la case adjacente au bord.
func _draw_concave_corners() -> void:
	# Jonction lac (col 9) ↔ rivière H (col 10+)
	_draw_wt_at(10, 4, 0, 4)  # eau en bas-gauche  → coin interne BL
	_draw_wt_at(10, 8, 0, 3)  # eau en haut-gauche → coin interne TL
	# Jonction rivière V (cols 22-24), côté ouest (col 21) ↔ rivière H
	_draw_wt_at(21, 4, 1, 4)  # eau en bas-droite  → coin interne BR
	# Jonction rivière V, côté est (col 25) ↔ rivière H
	_draw_wt_at(25, 4, 0, 4)  # eau en bas-gauche  → coin interne BL

## Dessine une tuile de Water_Tile.png à la position monde (c, r)
func _draw_wt_at(c: int, r: int, wt_col: int, wt_row: int) -> void:
	draw_texture_rect_region(_WAT_TILE,
		Rect2(c * TILE, r * TILE, TILE, TILE),
		_wt(wt_col, wt_row))

# ── Pont ───────────────────────────────────────────────────────────────────────

## Pont en bois sur la rivière V (cols 22–24, rows 2–4) — passage E–O, 48×48 px
func _draw_bridge() -> void:
	var dest := Rect2(22 * TILE, 2 * TILE, 3 * TILE, 3 * TILE)
	var src  := Rect2(0, 0, 3 * TILE, 3 * TILE)
	draw_texture_rect_region(_BRIDGE, dest, src)

# ── Vérification ───────────────────────────────────────────────────────────────

## Imprime dans la console une carte ASCII des tuiles d'eau (rows 0–12 × cols 0–39).
## Symboles :
##   ~ = intérieur   ╔╗╚╝ = coins convexes   T/B/G/D = bords   C = concave   . = terre
## Règle de cohérence : une tuile eau ne devrait jamais avoir 3+ voisins manquants.
func _print_water_map() -> void:
	print("\n=== WATER MAP (F3 = overlay visuel) ===")
	print("     0         1         2         3      ")
	print("     0123456789012345678901234567890123456789")
	for r in range(13):   # rows 0–12 suffisent pour voir lac + rivières
		var line := ""
		for c in range(COLS):
			line += _get_tile_char(c, r)
		print("%2d : %s" % [r, line])
	print("")

	# Vérifie qu'aucune tuile d'eau n'est presque-isolée (bug de géométrie)
	var problems := 0
	for r in range(ROWS):
		for c in range(COLS):
			if not _is_water(c, r):
				continue
			var neighbors := (1 if _is_water(c, r-1) else 0) \
				+ (1 if _is_water(c, r+1) else 0) \
				+ (1 if _is_water(c+1, r) else 0) \
				+ (1 if _is_water(c-1, r) else 0)
			if neighbors <= 1:
				push_warning("EAU ISOLEE en (%d,%d) — seulement %d voisin(s)" % [c, r, neighbors])
				problems += 1
	if problems == 0:
		print("[FieldWater] Carte OK — aucune tuile isolée.")
	else:
		print("[FieldWater] ATTENTION : %d tuile(s) isolée(s) — voir les warnings." % problems)

## Renvoie le caractère ASCII représentant la tuile (c, r) pour la vérification console.
func _get_tile_char(c: int, r: int) -> String:
	if not _is_water(c, r): return "."
	var n := _is_water(c, r-1)
	var s := _is_water(c, r+1)
	var e := _is_water(c+1, r)
	var w := _is_water(c-1, r)
	if n and s and e and w: return "~"
	if not n and not w and s and e: return "╔"
	if not n and not e and s and w: return "╗"
	if not s and not w and n and e: return "╚"
	if not s and not e and n and w: return "╝"
	if not n: return "T"   # top border
	if not s: return "B"   # bottom border
	if not w: return "G"   # gauche border
	return "D"             # droite border

# ── Overlay debug (F3) ────────────────────────────────────────────────────────

## Dessine un overlay semi-transparent sur chaque tuile eau pour identifier visuellement
## quel sprite est utilisé. Code couleur :
##   Bleu foncé  = intérieur   Cyan     = bord haut/bas
##   Vert        = bord G/D    Jaune    = coin convexe   Rouge = concave
func _draw_debug_overlay() -> void:
	var col_interior  := Color(0.0, 0.2, 0.8, 0.5)
	var col_top_bot   := Color(0.0, 0.8, 0.8, 0.6)
	var col_side      := Color(0.0, 0.6, 0.3, 0.6)
	var col_corner    := Color(1.0, 1.0, 0.0, 0.6)
	var col_concave   := Color(1.0, 0.0, 0.0, 0.6)
	var col_bridge    := Color(0.8, 0.4, 0.0, 0.5)

	for r in range(ROWS):
		for c in range(COLS):
			if not _is_water(c, r):
				continue
			var n := _is_water(c, r-1)
			var s := _is_water(c, r+1)
			var e := _is_water(c+1, r)
			var w := _is_water(c-1, r)
			var dest := Rect2(c * TILE + 1, r * TILE + 1, TILE - 2, TILE - 2)

			var color: Color
			var label: String
			if n and s and e and w:
				color = col_interior; label = "~"
			elif not n and not w and s and e:
				color = col_corner; label = "╔"
			elif not n and not e and s and w:
				color = col_corner; label = "╗"
			elif not s and not w and n and e:
				color = col_corner; label = "╚"
			elif not s and not e and n and w:
				color = col_corner; label = "╝"
			elif not n or not s:
				color = col_top_bot; label = "═"
			else:
				color = col_side; label = "║"

			draw_rect(dest, color)
			draw_string(ThemeDB.fallback_font, Vector2(c * TILE + 2, r * TILE + 11), label,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)

	# Concaves en rouge
	for pos in [[10, 4], [10, 8], [21, 4], [25, 4]]:
		var dest := Rect2(pos[0] * TILE + 1, pos[1] * TILE + 1, TILE - 2, TILE - 2)
		draw_rect(dest, col_concave)
		draw_string(ThemeDB.fallback_font, Vector2(pos[0] * TILE + 2, pos[1] * TILE + 11),
			"C", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)

	# Pont en orange
	draw_rect(Rect2(22 * TILE, 2 * TILE, 3 * TILE, 3 * TILE), col_bridge)
	draw_string(ThemeDB.fallback_font, Vector2(22 * TILE + 2, 2 * TILE + 11),
		"PONT", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color.WHITE)
