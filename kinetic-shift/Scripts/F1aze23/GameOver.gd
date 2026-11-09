extends Control

@onready var time: Label = $VBoxContainer2/Label
@onready var kills: Label = $VBoxContainer2/Label2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time.text = "Time: " + str(GameManager.time)
	kills.text = "Kills: " + str(GameManager.kills)



func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/F1aze23/MainMenu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
