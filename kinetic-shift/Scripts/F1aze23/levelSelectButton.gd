extends VBoxContainer

@onready var PB: Label = $HBoxContainer/Label
@export var sceneName:String
@export var scenePath:String
@onready var button: Button = $Button
@onready var killCount: Label = $HBoxContainer/Label2

func createButton():
	if GameManager.currentSave.bestTimes.has(sceneName):
		PB.text = "PB: " + str(GameManager.currentSave.bestTimes[sceneName])
	else:
		PB.text = ''
	if GameManager.currentSave.killCounts.has(sceneName):
		killCount.text = "Most Kills: " + str(GameManager.currentSave.killCounts[sceneName])
	else:
		killCount.text = ''
	button.text = sceneName
func _on_button_pressed() -> void:
	GameManager.StartGame(scenePath)
