
class_name WallClingComponent
extends Node

@export_group("Wall Cling")

@export_range(0.1, 3.0, 0.05)
var cling_duration: float = 1.0

@export_range(0.5, 1.0, 0.05)
var surface_normal_threshold: float = 0.8

@export_range(1.0, 40.0, 1.0)
var rotation_speed: float = 18.0



var active := false
var time_left := 0.0


var target_rotation := 0.0
var visual_rotation := 0.0


var contact_locked := false


func update(delta: float) -> void:
	
	if active:
		time_left = maxf(time_left - delta, 0.0)

		if time_left <= 0.0:
			active = false

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

	var found_cling_surface := false

	for i in range(body.get_slide_collision_count()):
		var collision := body.get_slide_collision(i)
		var normal := collision.get_normal()
		var collider := collision.get_collider()

	 
		if collider is Node and (collider as Node).is_in_group("Enemy"):
			continue

	  
		var is_side_wall := absf(normal.x) >= surface_normal_threshold

		var is_ceiling := normal.y >= surface_normal_threshold

	 
		if not is_side_wall and not is_ceiling:
			continue

		found_cling_surface = true

	   
		if contact_locked:
			continue

   
		var direction_to_surface := -normal

	   
		target_rotation = direction_to_surface.angle() - Vector2.DOWN.angle()

  
		active = true
		time_left = cling_duration
		contact_locked = true

	  
		body.velocity = Vector2.ZERO

		return true

  
	if not found_cling_surface:
		contact_locked = false

	return false
