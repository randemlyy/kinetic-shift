extends Control

const levelSelect = "res://Scenes/F1aze23/LevelSelector.tscn"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(levelSelect)


func _on_quit_pressed() -> void:
	get_tree().quit()
