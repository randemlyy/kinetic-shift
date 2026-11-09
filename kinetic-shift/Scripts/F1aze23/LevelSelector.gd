extends Control

@onready var gridC: GridContainer = $VBoxContainer/GridContainer

func _ready() -> void:
	GameManager.startMenu()
	for i in gridC.get_children():
		i.createButton()


func _process(delta: float) -> void:
	pass
