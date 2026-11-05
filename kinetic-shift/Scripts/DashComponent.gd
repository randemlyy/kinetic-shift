class_name DashComponent
extends Node

@export_group("Dash")
@export var dash_distance = 50.0
@export var dash_duration = 0.09
@export var post_dash_hit_window = 0.09

var hit_window_left = 0.0
var hitbox: Area2D
var active = false
var dash_ready = true
var direction = Vector2.RIGHT
var time_left = 0.0
var distance_left = 0.0

func refresh() -> void:
	dash_ready = true

func can_start() -> bool:
	return dash_ready

func start(facing: float, input_dir: Vector2) -> void:
	direction = input_dir.normalized()
	
	if direction == Vector2.ZERO:
		direction = Vector2(facing, 0.0)
	
	dash_ready = false
	active = true
	time_left = dash_duration
	distance_left = dash_distance
	hit_window_left = 0.0
	if hitbox != null:
		hitbox.set_deferred("monitoring", true)

func velocity_for_frame(delta: float) -> Vector2:
	var frame_time = minf(delta, time_left)
	if frame_time <= 0.0:
		return Vector2.ZERO

	return direction * (distance_left/frame_time)


func advance(delta: float) -> void:
	var frame_time := minf(delta, time_left)

	time_left -= frame_time
	distance_left = maxf(0.0, distance_left - (dash_distance * frame_time / dash_duration))

	if time_left <= 0.0 or distance_left <= 0.0:
		finish(true)

func tick_hit_window(delta: float) -> void:
	if active or hit_window_left <= 0.0:
		return

	hit_window_left -= delta
	if hit_window_left <= 0.0 and hitbox != null:
		hitbox.set_deferred("monitoring", false)

func find_enemy() -> PhysicsBody2D:
	if (not active and hit_window_left <= 0.0) or hitbox == null:
		return null

	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("Enemy") and body is PhysicsBody2D:
			return body as PhysicsBody2D
	return null

func finish(keep_hit_window: bool = false) -> void:
	active = false

	if keep_hit_window:
		hit_window_left = post_dash_hit_window
	else:
		hit_window_left = 0.0
		if hitbox != null:
			hitbox.set_deferred("monitoring", false)

func launch_direction(input_dir: Vector2) -> Vector2:
	return input_dir.normalized() if input_dir != Vector2.ZERO else direction
