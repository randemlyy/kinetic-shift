class_name InputComponent
extends Node

var move_x := 0.0
var move_dir := Vector2.ZERO
var jump_pressed := false
var dash_pressed := false

func update_input() -> void:
	move_x = Input.get_axis("move_left", "move_right")
	move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jump_pressed = Input.is_action_just_pressed("jump")
	dash_pressed = Input.is_action_just_pressed("dash")