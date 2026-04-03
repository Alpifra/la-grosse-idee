class_name PlayerAnimated
extends CharacterBody2D

## Joueur 4-directions avec AnimatedSprite2D — frames générées à l'exécution
## 2 frames de marche par direction + 1 frame idle (8 animations au total)

const SPEED : float = 80.0   # px/s — adapté à 320×180

@onready var _anim : AnimatedSprite2D = $AnimatedSprite2D

var _facing : String = "down"

func _ready() -> void:
	_build_frames()
	_anim.play("idle_down")

func _physics_process(_delta: float) -> void:
	var input := Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up",   "ui_down")
	)
	if input != Vector2.ZERO:
		input    = input.normalized()
		velocity = input * SPEED
		_set_facing(input)
		_anim.play("walk_" + _facing)
	else:
		velocity = Vector2.ZERO
		_anim.play("idle_" + _facing)
	move_and_slide()

## Choisit la direction dominante (4-dir style DQ2)
func _set_facing(v: Vector2) -> void:
	if abs(v.x) >= abs(v.y):
		_facing = "right" if v.x > 0 else "left"
	else:
		_facing = "down" if v.y > 0 else "up"

# ── Génération des SpriteFrames ───────────────────────────────────────────────

## Construit toutes les animations au démarrage — aucun fichier image requis
func _build_frames() -> void:
	var sf := SpriteFrames.new()
	const DIRS    : Array[String] = ["down", "up", "left", "right"]
	const PREFIXES: Array[String] = ["idle_", "walk_"]

	for prefix in PREFIXES:
		for dir in DIRS:
			var anim : String = prefix + dir
			sf.add_animation(anim)
			sf.set_animation_loop(anim, true)
			sf.set_animation_speed(anim, 6.0 if prefix == "walk_" else 1.0)
			var n : int = 2 if prefix == "walk_" else 1
			for f in range(n):
				sf.add_frame(anim, _make_frame(dir, f))

	_anim.sprite_frames = sf
	_anim.centered      = true

## Génère un frame 16×32 px (proportions NES) en ImageTexture
func _make_frame(dir: String, frame: int) -> ImageTexture:
	var img := Image.create(16, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color.TRANSPARENT)

	# ── Palette personnage ─────────────────────────────────────────────────────
	var skin  := Color(0.95, 0.78, 0.58)
	var hair  := Color(0.55, 0.28, 0.08)
	var shirt := Color(0.90, 0.88, 0.82)
	var pants := Color(0.22, 0.62, 0.80)
	var boots := Color(0.42, 0.22, 0.06)
	var dark  := Color(0.10, 0.07, 0.04)  # yeux / ombres

	# ── Jambes (alternance gauche/droite selon frame) ──────────────────────────
	var left_y  : int = 21 if (frame == 0) else 23
	var right_y : int = 23 if (frame == 0) else 21
	_rect(img, 2,  left_y,  6, 27, pants)
	_rect(img, 10, right_y, 14, 27, pants)
	_rect(img, 2,  27, 6,  31, boots)
	_rect(img, 10, 27, 14, 31, boots)

	# ── Corps ──────────────────────────────────────────────────────────────────
	_rect(img, 2, 14, 14, 22, shirt)
	# Bras (dépassent légèrement du corps)
	_rect(img, 0, 14, 3,  20, shirt)
	_rect(img, 13, 14, 16, 20, shirt)

	# ── Tête ───────────────────────────────────────────────────────────────────
	match dir:
		"up":
			# Vue dos — cheveux couvrent tout
			_rect(img, 4, 4, 12, 13, hair)
		"left":
			# Vue profil gauche
			_rect(img, 4, 5, 11, 13, skin)
			_rect(img, 4, 4, 12, 7,  hair)
			img.set_pixel(5, 10, dark)                     # oeil unique
		"right":
			# Vue profil droit
			_rect(img, 5, 5, 12, 13, skin)
			_rect(img, 4, 4, 12, 7,  hair)
			img.set_pixel(10, 10, dark)                    # oeil unique
		_:  # down — vue face
			_rect(img, 4, 5, 12, 13, skin)
			_rect(img, 3, 3, 13, 6,  hair)
			img.set_pixel(6,  10, dark)                    # oeil gauche
			img.set_pixel(9,  10, dark)                    # oeil droit

	return ImageTexture.create_from_image(img)

## Remplit un rectangle dans l'image (helper inline)
func _rect(img: Image, x0: int, y0: int, x1: int, y1: int, c: Color) -> void:
	for py in range(y0, y1):
		for px in range(x0, x1):
			if px >= 0 and px < img.get_width() and py >= 0 and py < img.get_height():
				img.set_pixel(px, py, c)
