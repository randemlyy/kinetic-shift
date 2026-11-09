extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var game_manager: GameManager = $"../GameManager"

signal PlayerFinished

func _on_area_2d_body_entered(body: Node2D) -> void:
	PlayerFinished.emit()
	pass # Replace with function body.
