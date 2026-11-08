
class_name WallClingComponent
extends Node


enum SurfaceType {
	NONE,
	SIDE_WALL,
	CEILING
}


@export_group("Hold Duration")

@export_range(0.1, 5.0, 0.1)
var side_wall_duration: float = 1.6

@export_range(0.1, 5.0, 0.05)
var ceiling_duration: float = 0.65


@export_group("Movement")

@export var cling_force: float = 80.0


@export_group("Jump")

@export var wall_jump_away_speed: float = 420.0
@export var wall_jump_up_speed: float = 600.0
@export var ceiling_detach_speed: float = 350.0
@export var jump_grace_time := 0.2

@export_group("Detection and Visuals")

@export_range(0.5, 1.0, 0.05)
var surface_normal_threshold: float = 0.8

@export_range(1.0, 40.0, 1.0)
var rotation_speed: float = 18.0

var active := false
var surface_type: SurfaceType = SurfaceType.NONE
var surface_normal := Vector2.ZERO
var time_left := 0.0

var target_rotation := 0.0
var visual_rotation := 0.0

var contact_locked := false
var timed_out := false
var jump_grace_left := 0.0

var jump_surface_type: SurfaceType = SurfaceType.NONE
var jump_surface_normal := Vector2.ZERO

func update(delta: float, cling_held: bool) -> void:
	var just_ended = false
	
	if active:
		if not cling_held:
			_end_cling(true)
			timed_out = false
			contact_locked = false
			just_ended = true

		else:
			time_left -= delta
			if time_left <= 0.0:
				_end_cling(false)
				timed_out = true
				just_ended = true

	elif timed_out and not cling_held:
		timed_out = false
		contact_locked = false
		jump_grace_left = jump_grace_time
		just_ended = true

	if not active and not just_ended:
		jump_grace_left = maxf(jump_grace_left - delta, 0.0)


	var desired_rotation := target_rotation if active else 0.0

	visual_rotation = lerp_angle(
		visual_rotation,
		desired_rotation,
		clampf(delta * rotation_speed, 0.0, 1.0)
	)

	if not active and absf(visual_rotation) < 0.005:
		visual_rotation = 0.0




func try_start(body: CharacterBody2D, cling_requested: bool) -> bool:

	if not cling_requested or active or timed_out:
		return false

	var found_surface := false

	for i in range(body.get_slide_collision_count()):

		var collision := body.get_slide_collision(i)
		var normal := collision.get_normal().normalized()
		var collider := collision.get_collider()

	
		if collider is Node and (collider as Node).is_in_group("Enemy"):
			continue


		var is_side_wall := absf(normal.x) >= surface_normal_threshold

	
		var is_ceiling := normal.y >= surface_normal_threshold

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
			
		target_rotation = (-surface_normal).angle() - Vector2.DOWN.angle()

		active = true
		contact_locked = true

		body.velocity = Vector2.ZERO

		return true


	if not found_surface:
		contact_locked = false

	return false


func get_cling_velocity(normal_speed: float) -> Vector2:

	var movement_axis := 0.0
	var movement_direction := Vector2.ZERO

	if surface_type == SurfaceType.SIDE_WALL:

		movement_axis = Input.get_axis("move_up", "move_down")

		movement_direction = Vector2.DOWN

	elif surface_type == SurfaceType.CEILING:

		movement_axis = Input.get_axis("move_left", "move_right")

		movement_direction = Vector2.RIGHT

	var adhesion_velocity := -surface_normal * cling_force

	var movement_velocity := movement_direction * movement_axis * normal_speed

	return movement_velocity + adhesion_velocity


func has_surface_contact(body: CharacterBody2D) -> bool:

	for i in range(body.get_slide_collision_count()):

		var collision := body.get_slide_collision(i)
		var collider := collision.get_collider()

		if collider is Node and (collider as Node).is_in_group("Enemy"):
			continue

		var normal := collision.get_normal().normalized()

	
		if normal.dot(surface_normal) >= 0.65:
			return true

	return false


func jump_off(body: CharacterBody2D) -> bool:

	if active:
		jump_surface_type = surface_type
		jump_surface_normal = surface_normal

	elif jump_grace_left <= 0.0 or jump_surface_type == SurfaceType.NONE:
		return false

	var jump_type = jump_surface_type
	var normal = jump_surface_normal

	release()

	jump_grace_left = 0.0
	timed_out = true
	jump_surface_type = SurfaceType.NONE
	jump_surface_normal = Vector2.ZERO

	if jump_type == SurfaceType.SIDE_WALL:
		body.velocity = Vector2(normal.x * wall_jump_away_speed, -wall_jump_up_speed)
	
	elif jump_type == SurfaceType.CEILING:
		body.velocity = normal * ceiling_detach_speed

	return true

func get_dash_direction(input_direction: Vector2) -> Vector2:


	if input_direction.length_squared() > 0.01:
		return input_direction.normalized()

	return surface_normal


func maintain_contact(body: CharacterBody2D) -> bool:

	if has_surface_contact(body):
		return true


	release()

	contact_locked = false

	return false

func release() -> void:

	active = false
	time_left = 0.0
	target_rotation = 0.0
	surface_type = SurfaceType.NONE
	contact_locked = false
	jump_grace_left = 0.0

func _end_cling(allow_jump: bool) -> void:
	jump_surface_type = surface_type
	jump_surface_normal = surface_normal
	active = false
	time_left = 0.0
	target_rotation = 0.0
	surface_type = SurfaceType.NONE

	if allow_jump:
		jump_grace_left = jump_grace_time
