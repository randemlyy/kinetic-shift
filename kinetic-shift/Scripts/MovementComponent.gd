class_name MovementComponent
extends Node


@export_group("Movement")

@export var speed: float = 460.0
@export var acceleration: float = 3800.0
@export var deceleration: float = 4200.0


@export_group("Gravity")

@export var gravity: float = 2600.0
@export var max_fall_speed: float = 1150.0


@export_group("Jump")

@export var jump_speed: float = 920.0

@export_range(0.05, 0.25, 0.01)
var coyote_time: float = 0.12

@export_range(0.05, 0.25, 0.01)
var jump_buffer_time: float = 0.12

@export_range(0.1, 1.0, 0.05)
var jump_cut_multiplier: float = 0.45


@export_group("Air Control")

@export var air_acceleration: float = 2600.0
@export var air_deceleration: float = 1800.0


@export_group("Wall Slide")

@export var wall_slide_speed: float = 200.0


@export_group("Wall Jump")

@export var wall_jump_lock_duration: float = 0.12


var facing: float = 1.0

var coyote_left: float = 0.0
var jump_buffer_left: float = 0.0

var jumped_this_frame: bool = false

var wall_jump_lock_left: float = 0.0
var wall_jump_away_direction: float = 0.0


func update_jump_buffer(delta: float, jump_pressed: bool) -> void:
	if jump_pressed:
		jump_buffer_left = jump_buffer_time
	else:
		jump_buffer_left = maxf(
			jump_buffer_left - delta,
			0.0
		)


func start_wall_jump_lock(away_direction: float) -> void:
	wall_jump_away_direction = signf(away_direction)
	wall_jump_lock_left = wall_jump_lock_duration

	if wall_jump_away_direction != 0.0:
		facing = wall_jump_away_direction


func tick(
	body: CharacterBody2D,
	delta: float,
	input_c: InputComponent
) -> void:

	jumped_this_frame = false

	var on_floor := body.is_on_floor()

	if on_floor:
		coyote_left = coyote_time
	else:
		coyote_left = maxf(
			coyote_left - delta,
			0.0
		)

		body.velocity.y += gravity * delta

	body.velocity.y = minf(
		body.velocity.y,
		max_fall_speed
	)

	if input_c.jump_released and body.velocity.y < 0.0:
		body.velocity.y = maxf(
			body.velocity.y,
			-jump_speed * jump_cut_multiplier
		)


	if jump_buffer_left > 0.0 and coyote_left > 0.0:

		body.velocity.y = -jump_speed

		jump_buffer_left = 0.0
		coyote_left = 0.0

		jumped_this_frame = true

	var horizontal_input := input_c.move_x


	if wall_jump_lock_left > 0.0:

		wall_jump_lock_left = maxf(
			wall_jump_lock_left - delta,
			0.0
		)

		if horizontal_input * wall_jump_away_direction < 0.0:
			horizontal_input = 0.0



	var current_acceleration := (
		acceleration if on_floor else air_acceleration
	)

	var current_deceleration := (
		deceleration if on_floor else air_deceleration
	)


	if horizontal_input != 0.0:

		facing = horizontal_input

		var target_speed := horizontal_input * speed

		body.velocity.x = move_toward(
			body.velocity.x,
			target_speed,
			current_acceleration * delta
		)

	else:

		body.velocity.x = move_toward(
			body.velocity.x,
			0.0,
			current_deceleration * delta
		)


	if (
		not on_floor
		and body.is_on_wall()
		and body.velocity.y > 0.0
	):

		var wall_normal := body.get_wall_normal()

		var pushing_toward_wall := (
			input_c.move_x * wall_normal.x < -0.1
		)

		if pushing_toward_wall:

			body.velocity.y = minf(
				body.velocity.y,
				wall_slide_speed
			)
