extends Node2D

@onready var area_2d: Area2D = $Area2D
@onready var label: Label = $Label

signal PlayerFinished

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return
	if GameManager.kills >= 3:
		PlayerFinished.emit()
	else:
		label.text = "YOU NEED ATLEAST 3 KILLS"
		await get_tree().create_timer(2).timeout
		label.text = "FINISH LINE"
