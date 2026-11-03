class_name LaunchComponent
extends Node

@export_group("Launch")
@export var launch_speed := 650.0
@export var launch_duration := 0.14

var active := false
var direction := Vector2.ZERO
var time_left := 0.0

func start(new_dir: Vector2) -> void:
	direction = new_dir.normalized()
	time_left = launch_duration	
	active = true

func tick(delta: float) -> void:
	time_left -= delta

	if time_left <= 0.0:
		active = false
	
func current_velocity() -> Vector2:
	return direction * launch_speed
