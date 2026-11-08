class_name InputComponent
extends Node

var move_x := 0.0
var move_y := 0.0
var move_dir := Vector2.ZERO
var jump_pressed := false
var dash_pressed := false
var jump_held := false
var jump_released = false
var _jump_press_pending := false
var _jump_release_pending := false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if event is InputEventKey and (event as InputEventKey).echo:
			return
		_jump_press_pending = true
	if event.is_action_released("jump"):
		_jump_release_pending = true

func update_input() -> void:
	move_x = Input.get_axis("move_left", "move_right")
	move_y = Input.get_axis("move_up", "move_down")
	move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	jump_pressed = _jump_press_pending or Input.is_action_just_pressed("jump")
	jump_released = _jump_release_pending or Input.is_action_just_released("jump")
	_jump_press_pending = false
	_jump_release_pending = false
	dash_pressed = Input.is_action_just_pressed("dash")
	jump_held = Input.is_action_pressed("jump")
	if (dash_pressed and jump_held and not Input.is_action_pressed("move_up") and not Input.is_action_pressed("move_down")):
		move_dir.y = -1.0
		move_dir = move_dir.normalized()
