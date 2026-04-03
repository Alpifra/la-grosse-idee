class_name ExplosionEffect
extends Node2D

## Explosion pixel art — 100% draw_rect entiers, zéro Polygon2D / AnimatedSprite2D
## 6 frames : 3 feu (expansion) + 3 fumée (contraction)
## API : play("explode") — signal animation_finished

signal animation_finished

const FRAME_DURATION : float = 0.10   # 10 fps — rythme NES authentique

# ── Palette ────────────────────────────────────────────────────────────────────
const C_CORE   := Color(1.00, 0.98, 0.60)   # cœur blanc-jaune
const C_FIRE1  := Color(1.00, 0.78, 0.08)   # jaune-or
const C_FIRE2  := Color(0.92, 0.42, 0.04)   # orange vif
const C_FIRE3  := Color(0.72, 0.18, 0.02)   # rouge-orange bord
const C_SMK1   := Color(0.58, 0.22, 0.06)   # fumée chaude
const C_SMK2   := Color(0.30, 0.14, 0.04)   # fumée froide

var _frame   : int   = 0
var _elapsed : float = 0.0
var _playing : bool  = false

func _ready() -> void:
	visible = false

## Lance l'animation depuis le frame 0 — nom ignoré (une seule animation)
func play(_anim_name: String = "explode") -> void:
	_frame   = 0
	_elapsed = 0.0
	_playing = true
	visible  = true
	queue_redraw()

func _process(delta: float) -> void:
	if not _playing:
		return
	_elapsed += delta
	if _elapsed >= FRAME_DURATION:
		_elapsed -= FRAME_DURATION
		_frame   += 1
		if _frame >= 6:
			_playing = false
			visible  = false
			animation_finished.emit()
		else:
			queue_redraw()

func _draw() -> void:
	match _frame:
		0: _fire(6)
		1: _fire(10)
		2: _fire(14)
		3: _smoke(12)
		4: _smoke(8)
		5: _smoke(4)

# ── Dessin ─────────────────────────────────────────────────────────────────────

## Frame feu — 3 couches de rectangles en croix (expansion)
func _fire(r: int) -> void:
	var h : int = r / 2
	# Bord rouge
	draw_rect(Rect2(-r,   -h,   r*2, r),   C_FIRE3)
	draw_rect(Rect2(-h,   -r,   r,   r*2), C_FIRE3)
	# Anneau orange
	draw_rect(Rect2(-r+2, -h+1, r*2-4, r-2), C_FIRE2)
	draw_rect(Rect2(-h+1, -r+2, r-2,   r*2-4), C_FIRE2)
	# Anneau or
	draw_rect(Rect2(-h,   -h,   r,     r),   C_FIRE1)
	# Cœur blanc-jaune
	draw_rect(Rect2(-h/2, -h/2, h,     h),   C_CORE)

## Frame fumée — carré + bosses grises (contraction)
func _smoke(r: int) -> void:
	var h : int = r / 2
	# Corps fumée
	draw_rect(Rect2(-r,   -h,   r*2, r),   C_SMK1)
	draw_rect(Rect2(-h,   -r,   r,   r*2), C_SMK1)
	# Centre plus sombre
	draw_rect(Rect2(-h,   -h,   r,   r),   C_SMK2)
