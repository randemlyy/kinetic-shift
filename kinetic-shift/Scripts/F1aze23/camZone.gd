extends Area2D


func _process(delta: float) -> void:
	for i in get_overlapping_bodies():
		if i.is_in_group("Player"):
			var camC = i.get_node("CameraComponent")
			if camC.cZone != self:
				camC.SwitchZone(self)
'''
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var camC = body.get_node("CameraComponent")
		if camC.cZone != self:
			camC.SwitchZone(self)
'''
