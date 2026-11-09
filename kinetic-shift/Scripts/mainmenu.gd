extends Node2D

@onready var play: Button = $Control/play
@onready var quit: Button = $Control/quit

const level1: PackedScene = preload("uid://cosvgii34ptxm")

func _on_play_button_down() -> void:
	get_tree().change_scene_to_packed(level1)
	pass # Replace with function body.

func _on_quit_button_down() -> void:
	get_tree().quit()
	pass # Replace with function body.
