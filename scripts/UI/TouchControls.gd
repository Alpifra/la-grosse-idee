class_name TouchControls
extends CanvasLayer

## Contrôles tactiles persistants — D-pad (bas-droite) + bouton menu (haut-gauche)
## Autoload, layer 100 — overlay par-dessus toutes les scènes
##
## Espace de coordonnées : viewport 320×180 (rendu 4× → 1280×720 écran)
## Un bouton 16×16 px viewport = 64×64 px écran ≈ cible tactile confortable

const BTN  : int = 16  ## taille d'un bouton en px viewport
const GAP  : int = 1   ## écart entre boutons du D-pad
const MARG : int = 8   ## marge par rapport aux bords de l'écran

var _backdrop    : Button
var _menu_panel  : Panel

func _ready() -> void:
	layer = 100
	_build_dpad()
	_build_menu_button()
	_build_menu_panel()

# ── D-pad ──────────────────────────────────────────────────────────────────────

## Construit le D-pad en croix (4 boutons dans un container bas-droite)
func _build_dpad() -> void:
	var root := Control.new()
	root.name     = "Dpad"
	root.modulate = Color(1.0, 1.0, 1.0, 0.55)
	var sz : int = 3 * BTN + 2 * GAP
	root.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	root.offset_right  = -MARG
	root.offset_bottom = -MARG
	root.offset_left   = -(MARG + sz)
	root.offset_top    = -(MARG + sz)
	add_child(root)

	# position dans la grille 3×3, action input, icône unicode
	var layout : Array[Dictionary] = [
		{ "pos": Vector2(BTN + GAP, 0),           "action": "move_up",    "icon": "▲" },
		{ "pos": Vector2(BTN + GAP, 2*(BTN+GAP)), "action": "move_down",  "icon": "▼" },
		{ "pos": Vector2(0,          BTN + GAP),  "action": "move_left",  "icon": "◀" },
		{ "pos": Vector2(2*(BTN+GAP), BTN + GAP), "action": "move_right", "icon": "▶" },
	]

	for cfg in layout:
		var btn     := _make_dpad_btn(cfg["icon"])
		btn.position = cfg["pos"]
		var action  : String = cfg["action"]
		# Simule l'action input tant que le bouton est maintenu
		btn.button_down.connect(func(): Input.action_press(action))
		btn.button_up.connect(func():   Input.action_release(action))
		root.add_child(btn)

## Fabrique un bouton stylisé pour le D-pad (16×16, icône centrée)
func _make_dpad_btn(icon: String) -> Button:
	var btn := Button.new()
	btn.text = icon
	btn.size = Vector2(BTN, BTN)
	btn.add_theme_font_size_override("font_size", 8)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_stylebox_override("normal",  _make_style(Color(0.15, 0.20, 0.35, 0.85)))
	btn.add_theme_stylebox_override("hover",   _make_style(Color(0.15, 0.20, 0.35, 0.85)))
	btn.add_theme_stylebox_override("pressed", _make_style(Color(0.40, 0.50, 0.80, 0.95)))
	return btn

# ── Bouton menu ────────────────────────────────────────────────────────────────

## Bouton ≡ en haut à gauche — ouvre/ferme le menu
func _build_menu_button() -> void:
	var btn      := Button.new()
	btn.name     = "MenuBtn"
	btn.text     = "≡"
	btn.size     = Vector2(BTN, BTN)
	btn.position = Vector2(MARG, MARG)
	btn.modulate = Color(1.0, 1.0, 1.0, 0.75)
	btn.add_theme_font_size_override("font_size", 11)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_stylebox_override("normal", _make_style(Color(0.10, 0.12, 0.22, 0.80)))
	btn.add_theme_stylebox_override("hover",  _make_style(Color(0.10, 0.12, 0.22, 0.80)))
	btn.pressed.connect(_toggle_menu)
	add_child(btn)

# ── Menu panel ─────────────────────────────────────────────────────────────────

## Construit le fond + panneau menu (invisible par défaut)
func _build_menu_panel() -> void:
	# Fond semi-transparent plein écran — bloque les inputs au jeu et ferme le menu au tap
	_backdrop                = Button.new()
	_backdrop.name           = "Backdrop"
	_backdrop.visible        = false
	_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	var back_style           := StyleBoxFlat.new()
	back_style.bg_color      = Color(0.0, 0.0, 0.0, 0.45)
	_backdrop.add_theme_stylebox_override("normal",  back_style)
	_backdrop.add_theme_stylebox_override("hover",   back_style)
	_backdrop.add_theme_stylebox_override("pressed", back_style)
	_backdrop.pressed.connect(_toggle_menu)
	add_child(_backdrop)

	# Panneau centré 140×96 px
	_menu_panel         = Panel.new()
	_menu_panel.name    = "MenuPanel"
	_menu_panel.visible = false
	var ps              := _make_style(Color(0.05, 0.05, 0.15, 0.96))
	ps.border_color     = Color(0.75, 0.80, 1.00, 0.90)
	ps.border_width_left   = 2
	ps.border_width_top    = 2
	ps.border_width_right  = 2
	ps.border_width_bottom = 2
	ps.corner_radius_top_left     = 4
	ps.corner_radius_top_right    = 4
	ps.corner_radius_bottom_right = 4
	ps.corner_radius_bottom_left  = 4
	_menu_panel.add_theme_stylebox_override("panel", ps)
	_menu_panel.set_anchors_preset(Control.PRESET_CENTER)
	_menu_panel.offset_left   = -70.0
	_menu_panel.offset_top    = -48.0
	_menu_panel.offset_right  =  70.0
	_menu_panel.offset_bottom =  48.0
	add_child(_menu_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   =  8.0
	vbox.offset_top    =  8.0
	vbox.offset_right  = -8.0
	vbox.offset_bottom = -8.0
	vbox.add_theme_constant_override("separation", 5)
	_menu_panel.add_child(vbox)

	_add_option(vbox, "Stats",        _on_stats_pressed)
	_add_option(vbox, "Items",        _on_items_pressed)
	_add_option(vbox, "Sauvegarder",  _on_save_pressed)

## Ajoute un bouton d'option dans le menu
func _add_option(parent: VBoxContainer, label: String, cb: Callable) -> void:
	var btn := Button.new()
	btn.text = label
	btn.add_theme_font_size_override("font_size", 9)
	btn.pressed.connect(cb)
	parent.add_child(btn)

func _toggle_menu() -> void:
	var open        := not _menu_panel.visible
	_menu_panel.visible = open
	_backdrop.visible   = open

# ── Handlers menu (placeholders) ───────────────────────────────────────────────

func _on_stats_pressed() -> void:
	_toggle_menu()   # TODO : afficher la fiche de stats du joueur

func _on_items_pressed() -> void:
	_toggle_menu()   # TODO : ouvrir l'inventaire

func _on_save_pressed() -> void:
	_toggle_menu()   # TODO : appeler SaveSystem.save()

# ── Helpers ────────────────────────────────────────────────────────────────────

## StyleBoxFlat de base — coins arrondis 2px, bordure 1px bleu-gris
func _make_style(bg: Color) -> StyleBoxFlat:
	var s                      := StyleBoxFlat.new()
	s.bg_color                 = bg
	s.border_width_left        = 1
	s.border_width_top         = 1
	s.border_width_right       = 1
	s.border_width_bottom      = 1
	s.border_color             = Color(0.65, 0.75, 1.00, 0.90)
	s.corner_radius_top_left     = 2
	s.corner_radius_top_right    = 2
	s.corner_radius_bottom_right = 2
	s.corner_radius_bottom_left  = 2
	return s
