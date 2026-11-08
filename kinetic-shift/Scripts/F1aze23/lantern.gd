extends Area2D

var gm:GameManager
func _ready() -> void:
	gm = get_tree().get_first_node_in_group("GameManager") as GameManager

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		gm.SaveNode(body)
