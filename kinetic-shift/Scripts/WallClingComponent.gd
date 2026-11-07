
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

func update(delta: float) -> void:

	
	if active:

		var moving_on_surface := false

		if surface_type == SurfaceType.SIDE_WALL:

			moving_on_surface = (
				Input.is_action_pressed("move_up")
				or Input.is_action_pressed("move_down")
			)

		elif surface_type == SurfaceType.CEILING:

			moving_on_surface = (
				Input.is_action_pressed("move_left")
				or Input.is_action_pressed("move_right")
			)

	
		if not moving_on_surface:

			time_left = maxf(time_left - delta, 0.0)

			if time_left <= 0.0:
				release()


	var desired_rotation := target_rotation if active else 0.0

	visual_rotation = lerp_angle(
		visual_rotation,
		desired_rotation,
		clampf(delta * rotation_speed, 0.0, 1.0)
	)

	if not active and absf(visual_rotation) < 0.005:
		visual_rotation = 0.0




func try_start(body: CharacterBody2D) -> bool:

	if active:
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


func jump_off(body: CharacterBody2D) -> void:

	if not active:
		return

	var previous_surface := surface_type
	var previous_normal := surface_normal

	release()

	if previous_surface == SurfaceType.SIDE_WALL:

	
		body.velocity = Vector2(
			previous_normal.x * wall_jump_away_speed,
			-wall_jump_up_speed
		)

	elif previous_surface == SurfaceType.CEILING:

		
		body.velocity = previous_normal * ceiling_detach_speed



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
