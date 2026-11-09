extends VBoxContainer

@onready var PB: Label = $Label
@export var sceneName:String
@export var scenePath:String

func createButton():
	if GameManager.currentSave.bestTimes.has(sceneName):
		PB.text = str(GameManager.currentSave[sceneName])
	else:
		PB.text = ''

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(scenePath)
