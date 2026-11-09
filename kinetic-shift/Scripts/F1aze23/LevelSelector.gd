extends Control

@onready var gridC: GridContainer = $VBoxContainer/ScrollContainer/GridContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.startMenu()
	for i in gridC.get_children():
		i.createButton()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
