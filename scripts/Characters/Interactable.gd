class_name Interactable
extends Area2D

## Zone d'interaction NPC — déclenche un dialogue en deux phases :
##   1. player_lines : répliques du joueur (barre basse fixe)
##   2. dialogue_lines : réponses du NPC (bulle flottante au-dessus du NPC)
## Ajouter comme enfant Area2D d'un NPC avec un CollisionShape2D enfant.

## Lignes du joueur (phase 1 — bulle au-dessus du joueur)
@export var player_lines : Array = []
@export var player_name  : String = "Fermier"

## Lignes du NPC (phase 2 — bulle au-dessus du NPC)
## Chaque élément : String OU Dictionary {text, speed, auto_next, auto_delay}
@export var dialogue_lines : Array = ["..."]
@export var speaker_name   : String = ""

var _player_in_range : bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if not event.is_action_pressed("ui_accept"):
		return
	var dm := get_tree().get_first_node_in_group("dialogue_manager") as DialogueManager
	if dm == null or dm.is_open():
		return
	if not player_lines.is_empty():
		# Phase 1 : joueur parle (bulle au-dessus du joueur)
		var player := get_tree().get_first_node_in_group("player") as Node2D
		dm.show_dialogue(player_lines, player_name, player)
		dm.dialogue_finished.connect(_on_player_done.bind(dm), CONNECT_ONE_SHOT)
	else:
		# Pas de phase joueur : NPC parle directement
		dm.show_dialogue(dialogue_lines, speaker_name, get_parent() as Node2D)
	get_viewport().set_input_as_handled()

## Enchaîne sur les répliques du NPC après la fin des lignes joueur
func _on_player_done(dm: DialogueManager) -> void:
	dm.show_dialogue(dialogue_lines, speaker_name, get_parent() as Node2D)
