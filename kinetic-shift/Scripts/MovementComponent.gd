extends Node

@export_group("Movement")
@export var speed = 240.0
@export var acceleration = 1800.0
@export var deceleration = 2200.0
@export var gravity = 1500.0
@export var jump_speed = 500.0
@export var coyote_time = 0.10
@export var jump_buffer_time = 0.10

var facing = 1.0
var coyote_left = 0.0
var jump_buffer_left = 0.0

func tick(body: CharacterBody2D, delta: float) -> void:
	if body.is_on_floor():
		coyote_left = coyote_time
	else:
		coyote_left = maxf(0.0, coyote_left - delta)
		body.velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump"):
		jump_buffer_left = jump_buffer_time
	else:
		jump_buffer_left = maxf(0.0, jump_buffer_left - delta)

	if jump_buffer_left > 0.0 and coyote_left > 0.0:
		body.velocity.y = -jump_speed
		jump_buffer_left = 0.0
		coyote_left = 0.0
	
	jump_buffer_left = maxf(0.0, jump_buffer_left - delta)

	var dir = Input.get_axis("left", "right")

	if dir != 0.0:
		facing = dir
		body.velocity.x = move_toward(body.velocity.x, dir * speed, acceleration * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, 0.0, deceleration * delta)
	
	if jump_buffer_left > 0.0 and coyote_left > 0.0:
		body.velocity.y = -jump_speed
		jump_buffer_time = 0.0
		coyote_left = 0.0