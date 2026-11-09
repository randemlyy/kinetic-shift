
class_name DashComponent
extends Node


@export_group("Dash")

@export var dash_distance: float = 105.0
@export var dash_duration: float = 0.12
@export var post_dash_hit_window: float = 0.10


var hit_window_left: float = 0.0

var hitbox: Area2D

var active: bool = false
var dash_ready: bool = true

var direction: Vector2 = Vector2.RIGHT

var time_left: float = 0.0
var distance_left: float = 0.0

var dashMultiplier: float = 1.0


func refresh() -> void:
	dash_ready = true


func can_start() -> bool:
	return dash_ready


func start(facing: float, input_dir: Vector2) -> void:

	direction = input_dir.normalized()

	if direction == Vector2.ZERO:
		direction = Vector2(signf(facing), 0.0)

	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	dash_ready = false
	active = true

	time_left = dash_duration
	distance_left = dash_distance

	hit_window_left = 0.0

	if hitbox != null:
		hitbox.set_deferred("monitoring", true)


func velocity_for_frame(delta: float) -> Vector2:

	if delta <= 0.0 or time_left <= 0.0:
		return Vector2.ZERO

	var dash_speed := (
		dash_distance / maxf(dash_duration, 0.001)
	)

	var frame_time := minf(delta, time_left)

	var frame_distance := minf(
		distance_left,
		dash_speed * frame_time
	)

	frame_distance *= maxf(dashMultiplier, 0.0)

	return direction * (frame_distance / delta)


func advance(delta: float) -> void:

	if not active:
		return


	var frame_time := minf(delta, time_left)

	time_left = maxf(
		time_left - frame_time,
		0.0
	)

	var dash_speed := (
		dash_distance / maxf(dash_duration, 0.001)
	)

	distance_left = maxf(
		distance_left - dash_speed * frame_time,
		0.0
	)


	if time_left <= 0.0 or distance_left <= 0.0:
		finish(true)


func tick_hit_window(delta: float) -> void:

	if active or hit_window_left <= 0.0:
		return


	hit_window_left = maxf(
		hit_window_left - delta,
		0.0
	)


	if hit_window_left <= 0.0 and hitbox != null:
		hitbox.set_deferred("monitoring", false)


func find_enemy() -> PhysicsBody2D:

	if (
		not active
		and hit_window_left <= 0.0
	):
		return null


	if hitbox == null:
		return null


	for body in hitbox.get_overlapping_bodies():

		if (
			body.is_in_group("Enemy")
			and body is PhysicsBody2D
		):
			return body as PhysicsBody2D

	return null

func finish(keep_hit_window: bool = false) -> void:

	active = false

	time_left = 0.0
	distance_left = 0.0

	if keep_hit_window:

		hit_window_left = post_dash_hit_window

	else:

		hit_window_left = 0.0

		if hitbox != null:
			hitbox.set_deferred("monitoring", false)


func launch_direction(input_dir: Vector2) -> Vector2:

	if input_dir.length_squared() > 0.01:
		return input_dir.normalized()

	return direction
