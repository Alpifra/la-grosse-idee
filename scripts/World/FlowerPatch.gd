class_name FlowerPatch
extends Node2D

## Fleur sprite réel — Outdoor_Decor_Free.png, tuile 16x16
## Balancement vent : décalage entier ±2 px sur la position.x du sprite
## flower_index sélectionne la couleur (0=rose, 1=jaune, 2=rouge, 3=violet, 4=blanc)

@export var flower_index : int   = 0
@export var wind_speed   : float = 1.6

@onready var _sprite : Sprite2D = $Sprite2D

const _TEXTURE  = preload("res://assets/sprites/Outdoor_Decor_Free.png")
const _RECTS : Array = [
	Rect2( 0, 128, 16, 16),   # 0 — rose
	Rect2(16, 128, 16, 16),   # 1 — jaune
	Rect2(32, 128, 16, 16),   # 2 — rouge
	Rect2(48, 128, 16, 16),   # 3 — violet
	Rect2(64, 128, 16, 16),   # 4 — blanc
]

var _time  := 0.0
var _phase := 0.0
var _sway  := 0

func _ready() -> void:
	_phase = position.x * 0.07 + position.y * 0.04
	var at       := AtlasTexture.new()
	at.atlas      = _TEXTURE
	at.region     = _RECTS[flower_index % _RECTS.size()]
	_sprite.texture        = at
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

## Balancement quantifié à l'entier — jamais de sous-pixel
func _process(delta: float) -> void:
	_time += delta
	var new_s : int = roundi(sin(_time * wind_speed + _phase) * 2.0)
	if new_s != _sway:
		_sway = new_s
		_sprite.position.x = float(_sway)
