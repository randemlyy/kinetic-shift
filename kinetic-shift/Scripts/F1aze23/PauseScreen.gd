extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/F1aze23/MainMenu.tscn")
	get_parent().queue_free()
	get_tree().get_first_node_in_group("Player").queue_free()
	get_tree().paused = false
