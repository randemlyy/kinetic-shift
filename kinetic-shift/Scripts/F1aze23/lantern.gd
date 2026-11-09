extends Area2D

@onready var label: Label = $Label

func _ready() -> void:
	label.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameManager.SaveNode(body)
		label.visible = true
		await get_tree().create_timer(2).timeout
		label.visible = false
