extends Node2D

@onready var area_2d: Area2D = $Area2D

signal PlayerFinished

func _on_area_2d_body_entered(body: Node2D) -> void:
	if GameManager.kills >= 5:
		PlayerFinished.emit()
