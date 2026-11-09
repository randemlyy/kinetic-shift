class_name WallClingComponent
extends Node


enum SurfaceType {
	NONE,
	SIDE_WALL,
	CEILING
}

@export_group("Hold Duration")

@export var side_wall_duration: float = 2.0
@export var ceiling_duration: float = 1.2


@export_group("Movement")

@export var surface_acceleration: float = 3000.0
@export var surface_deceleration: float = 3600.0
@export var cling_force: float = 80.0

@export_group("Jump")

@export var wall_jump_away_speed: float = 520.0
@export var wall_jump_up_speed: float = 720.0
@export var ceiling_detach_speed: float = 450.0


@export_group("Detection and Visuals")

@export_range(0.5, 1.0, 0.05)
var surface_normal_threshold: float = 0.8

@export_range(1.0, 40.0, 1.0)
var rotation_speed: float = 18.0

var active: bool = false

var surface_type: SurfaceType = SurfaceType.NONE
var surface_normal: Vector2 = Vector2.ZERO

var time_left: float = 0.0

var target_rotation: float = 0.0
var visual_rotation: float = 0.0

var surface_velocity: float = 0.0

var contact_locked: bool = false
var last_surface_type: SurfaceType = SurfaceType.NONE
var last_surface_normal: Vector2 = Vector2.ZERO
var jump_grace_left: float = 0.0

@export var jump_grace_duration: float = 0.12

func update(delta: float, _cling_held: bool) -> void:


	if active:
		time_left = maxf(
			time_left - delta,
			0.0
		)

		if time_left <= 0.0:
			_end_cling(true)

	if not active and jump_grace_left > 0.0:

		jump_grace_left = maxf(
			jump_grace_left - delta,
			0.0
		)

		if jump_grace_left <= 0.0:
			last_surface_type = SurfaceType.NONE
			last_surface_normal = Vector2.ZERO

	var desired_rotation := (
		target_rotation if active else 0.0
	)

	visual_rotation = lerp_angle(
		visual_rotation,
		desired_rotation,
		clampf(
			delta * rotation_speed,
			0.0,
			1.0
		)
	)

	if not active and absf(visual_rotation) < 0.005:
		visual_rotation = 0.0

func try_start(
	body: CharacterBody2D,
	cling_held: bool = true
) -> bool:

	if active:
		return false

	if not cling_held:
		return false

	var found_surface := false

	for i in body.get_slide_collision_count():

		var collision := body.get_slide_collision(i)

		var normal := collision.get_normal().normalized()

		var collider := collision.get_collider()

		# Never cling to enemies.
		if collider is Node and (
			collider as Node
		).is_in_group("Enemy"):
			continue

		var is_side_wall := (
			absf(normal.x)
			>= surface_normal_threshold
		)

		var is_ceiling := (
			normal.y
			>= surface_normal_threshold
		)

		if not is_side_wall and not is_ceiling:
			continue

		found_surface = true

		if contact_locked:
			continue

		surface_normal = normal

		if is_side_wall:

			surface_type = SurfaceType.SIDE_WALL
			time_left = side_wall_duration

		else:

			surface_type = SurfaceType.CEILING
			time_left = ceiling_duration

		target_rotation = (
			-surface_normal
		).angle() - Vector2.DOWN.angle()

		active = true
		contact_locked = true
		body.velocity = Vector2.ZERO

		return true

	if not found_surface:
		contact_locked = false

	return false


func get_cling_velocity(
	normal_speed: float,
	move_x: float,
	move_y: float,
	delta: float
) -> Vector2:

	var input_axis: float = 0.0

	var movement_direction := Vector2.ZERO

	if surface_type == SurfaceType.SIDE_WALL:
		input_axis = move_y

		movement_direction = Vector2.DOWN

	elif surface_type == SurfaceType.CEILING:

		
		input_axis = move_x

		movement_direction = Vector2.RIGHT

	var target_speed := input_axis * normal_speed

	var acceleration_amount := (
		surface_acceleration
		if input_axis != 0.0
		else surface_deceleration
	)

	surface_velocity = move_toward(
		surface_velocity,
		target_speed,
		acceleration_amount * delta
	)

	var adhesion_velocity := (
		-surface_normal * cling_force
	)

	return (
		movement_direction * surface_velocity
		+ adhesion_velocity
	)

func has_surface_contact(
	body: CharacterBody2D
) -> bool:

	for i in body.get_slide_collision_count():

		var collision := body.get_slide_collision(i)

		var collider := collision.get_collider()

		if collider is Node and (
			collider as Node
		).is_in_group("Enemy"):
			continue

		var normal := collision.get_normal().normalized()

	
		if normal.dot(surface_normal) >= 0.65:
			return true

	return false

func maintain_contact(
	body: CharacterBody2D
) -> bool:

	if not active:
		return false

	if has_surface_contact(body):
		return true

	_end_cling(true)

	contact_locked = false

	return false

func jump_off(
	body: CharacterBody2D,
	movement_c: MovementComponent
) -> bool:

	var jump_type := surface_type
	var normal := surface_normal

	if not active:

		if jump_grace_left <= 0.0:
			return false

		jump_type = last_surface_type
		normal = last_surface_normal
		
		jump_grace_left = 0.0
		last_surface_type = SurfaceType.NONE
		last_surface_normal = Vector2.ZERO

	else:

		_end_cling(false)

	if jump_type == SurfaceType.SIDE_WALL:

		body.velocity = Vector2(
			normal.x * wall_jump_away_speed,
			-wall_jump_up_speed
		)

		movement_c.start_wall_jump_lock(
			normal.x
		)

		return true

	elif jump_type == SurfaceType.CEILING:
		
		body.velocity = (
			normal * ceiling_detach_speed
		)

		return true

	return false

func get_dash_direction(
	input_direction: Vector2
) -> Vector2:

	if input_direction.length_squared() > 0.01:
		return input_direction.normalized()

	return surface_normal

func release() -> void:

	if not active:
		return

	_end_cling(true)


func _end_cling(
	allow_jump_grace: bool
) -> void:

	if active and allow_jump_grace:

		last_surface_type = surface_type
		last_surface_normal = surface_normal

		jump_grace_left = jump_grace_duration

	active = false

	time_left = 0.0

	target_rotation = 0.0

	surface_type = SurfaceType.NONE

	surface_normal = Vector2.ZERO

	surface_velocity = 0.0
