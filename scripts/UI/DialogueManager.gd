class_name DialogueManager
extends CanvasLayer

## Système de dialogue NES-style avec effet typewriter
## Usage : DialogueManager.show_dialogue(lines, "Nom", speaker_node)
## lines : Array de String OU de Dictionary {text, speed, auto_next, auto_delay}
## Si speaker_node est fourni, bulle flottante au-dessus du personnage.
## Signal dialogue_finished émis quand la séquence est terminée.

signal dialogue_finished

@onready var _panel    : Panel         = $DialoguePanel
@onready var _label    : RichTextLabel = $DialoguePanel/Margin/VBox/Text
@onready var _name_tag : Panel         = $DialoguePanel/NameTag
@onready var _name_lbl : Label         = $DialoguePanel/NameTag/NameLabel
@onready var _cursor   : Label         = $DialoguePanel/Margin/VBox/Cursor
@onready var _timer    : Timer         = $TypewriterTimer

const CHARS_PER_SEC : float = 35.0

const BUBBLE_W : float = 130.0
const BUBBLE_H : float = 46.0
const ABOVE_PX : float = 40.0

var _queue      : Array   = []
var _full       : String  = ""
var _pos        : int     = 0
var _typing     : bool    = false
var _speaker    : Node2D  = null
var _auto_next  : bool    = false
var _auto_delay : float   = 0.5
var _auto_timer : Timer   = null
var _in_bubble  : bool    = false   # évite de re-créer le style à chaque ligne

var _bubble_style : StyleBoxFlat   # créé une seule fois dans _ready

func _ready() -> void:
	_panel.visible = false
	_timer.wait_time = 1.0 / CHARS_PER_SEC
	_timer.one_shot  = false
	_timer.timeout.connect(_on_typewriter_tick)
	layer = 10
	add_to_group("dialogue_manager")

	_auto_timer          = Timer.new()
	_auto_timer.one_shot = true
	_auto_timer.timeout.connect(_next_line)
	add_child(_auto_timer)

	# StyleBox bulle — créé une fois, réutilisé à chaque dialogue
	_bubble_style                          = StyleBoxFlat.new()
	_bubble_style.bg_color                 = Color(0.04, 0.04, 0.14, 0.72)
	_bubble_style.border_width_left        = 2
	_bubble_style.border_width_top         = 2
	_bubble_style.border_width_right       = 2
	_bubble_style.border_width_bottom      = 2
	_bubble_style.border_color             = Color(0.92, 0.92, 1.00, 0.85)
	_bubble_style.corner_radius_top_left   = 4
	_bubble_style.corner_radius_top_right  = 4
	_bubble_style.corner_radius_bottom_right = 4
	_bubble_style.corner_radius_bottom_left  = 4
	_bubble_style.content_margin_left      = 7
	_bubble_style.content_margin_top       = 5
	_bubble_style.content_margin_right     = 7
	_bubble_style.content_margin_bottom    = 5

## Retourne true si une boîte de dialogue est actuellement affichée
func is_open() -> bool:
	return _panel.visible

## Lance une séquence de dialogues.
## lines       : Array de String OU de Dictionary par ligne :
##               { "text": "...", "speed": 2.0, "auto_next": true, "auto_delay": 0.5 }
## speaker     : nom affiché dans le tag (vide = masqué)
## speaker_node: nœud 2D source — bulle flottante au-dessus si fourni
func show_dialogue(lines: Array, speaker: String = "", speaker_node: Node2D = null) -> void:
	_queue   = lines.duplicate()
	_speaker = speaker_node
	_name_lbl.text    = speaker
	_name_tag.visible = speaker != ""
	_panel.visible    = true
	if speaker_node != null:
		_enter_bubble_mode()
	else:
		_enter_fixed_mode()
	_next_line()

## Ferme la boîte immédiatement sans signal
func close() -> void:
	_timer.stop()
	_auto_timer.stop()
	_panel.visible = false
	_queue.clear()
	_speaker = null

# ── Position flottante ──────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	if _panel.visible and _speaker != null:
		_update_bubble_position()

func _update_bubble_position() -> void:
	var canvas_pos : Vector2 = get_viewport().get_canvas_transform() * _speaker.global_position
	var vp         : Vector2 = get_viewport().get_visible_rect().size
	var x : float = clamp(canvas_pos.x - BUBBLE_W * 0.5, 4.0, vp.x - BUBBLE_W - 4.0)
	var y : float = clamp(canvas_pos.y - ABOVE_PX - BUBBLE_H, 4.0, vp.y - BUBBLE_H - 4.0)
	_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_panel.position = Vector2(x, y)
	_panel.size     = Vector2(BUBBLE_W, BUBBLE_H)

# ── Style bulle vs barre fixe ───────────────────────────────────────────────────

func _enter_bubble_mode() -> void:
	if _in_bubble:
		return   # style déjà en place, juste mettre à jour la position
	_in_bubble = true
	_panel.add_theme_stylebox_override("panel", _bubble_style)
	_update_bubble_position()

func _enter_fixed_mode() -> void:
	if not _in_bubble:
		return   # déjà en mode barre, rien à faire
	_in_bubble = false
	_panel.remove_theme_stylebox_override("panel")
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left   = 6.0
	_panel.offset_top    = -56.0
	_panel.offset_right  = -6.0
	_panel.offset_bottom = -4.0

# ── Logique interne ─────────────────────────────────────────────────────────────

func _next_line() -> void:
	_auto_timer.stop()
	if _queue.is_empty():
		_panel.visible = false
		_speaker = null
		emit_signal("dialogue_finished")
		return
	var item = _queue.pop_front()
	if item is Dictionary:
		_full            = item.get("text",       "")
		_timer.wait_time = 1.0 / maxf(item.get("speed", CHARS_PER_SEC), 0.1)
		_auto_next       = item.get("auto_next",  false)
		_auto_delay      = item.get("auto_delay", 0.5)
	else:
		_full            = str(item)
		_timer.wait_time = 1.0 / CHARS_PER_SEC
		_auto_next       = false
		_auto_delay      = 0.5
	_pos    = 0
	_typing = true
	_label.text     = ""
	_cursor.visible = false
	_timer.start()

func _on_typewriter_tick() -> void:
	if _pos >= _full.length():
		_finish_typing()
		return
	_label.text += _full[_pos]
	_pos += 1

func _finish_typing() -> void:
	_timer.stop()
	_label.text     = _full
	_typing         = false
	if _auto_next:
		_cursor.visible = false
		_auto_timer.start(_auto_delay)
	else:
		_cursor.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if not (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_select")):
		return
	if _typing:
		_finish_typing()
	elif _auto_next:
		_auto_timer.stop()
		_next_line()
	else:
		_next_line()
	get_viewport().set_input_as_handled()
