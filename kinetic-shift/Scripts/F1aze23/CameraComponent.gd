class_name CameraComponent
extends Node

var cZone: Area2D
var cam: Camera2D

func start() -> void:
	cam = Camera2D.new()
	get_parent().add_child(cam)
	cZone = get_tree().get_first_node_in_group("startzone") as Area2D
	if cZone:
		SwitchZone(cZone)
	else:
		print("WHERE IS THE STARTZONE")

func SwitchZone(zone: Area2D) -> void:
	cZone = zone

func update() -> void:
	if cam == null or cZone == null:
		return

	cam.global_position = lerp(cam.global_position, cZone.global_position, 0.1)
