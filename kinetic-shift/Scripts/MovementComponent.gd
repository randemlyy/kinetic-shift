class_name MovementComponent
extends Node

@export_group("Movement")
@export var speed = 350.0
@export var acceleration = 1800.0
@export var deceleration = 2200.0
@export var gravity = 3200.0
@export var jump_speed = 1050.0
@export var coyote_time = 0.10
@export var jump_buffer_time = 0.10

var facing = 1.0
var coyote_left = 0.0
var jump_buffer_left = 0.0
var jumped_this_frame = false

func update_jump_buffer(delta: float, jump_pressed: bool) -> void:
	if jump_pressed:
		jump_buffer_left = jump_buffer_time
	else:
		jump_buffer_left = maxf(0.0, jump_buffer_left - delta)

func tick(body: CharacterBody2D, delta: float, input_c: InputComponent) -> void:
	jumped_this_frame = false

	if body.is_on_floor():
		coyote_left = coyote_time
	else:
		coyote_left = maxf(0.0, coyote_left - delta)
		body.velocity.y += gravity * delta

	if jump_buffer_left > 0.0 and coyote_left > 0.0:
		body.velocity.y = -jump_speed
		jump_buffer_left = 0.0
		coyote_left = 0.0
		jumped_this_frame = true
	
	if input_c.move_x != 0.0:
		facing = input_c.move_x

		body.velocity.x = move_toward(body.velocity.x, facing * speed, acceleration * delta)
	
	else:
		body.velocity.x = move_toward(body.velocity.x, 0.0, deceleration * delta)
