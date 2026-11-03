extends Node

signal enemy_hit(launch_dir: Vector2)

@export_group("Dash")
@export var dash_distance = 50.0
@export var dash_duration = 0.09
@export var hitbox: Area2D

var active = false
var facing := 1.0
var dash_ready = true
var direction = Vector2.RIGHT
var time_left = 0.0
var distance_left = 0.0
var hit_targets: Array[Node2D] = []

func refresh() -> void:
	dash_ready = true

func can_start() -> bool:
	return dash_ready

func start(player_facing: float, input_dir: Vector2) -> void:
	facing = player_facing
	direction = input_dir.normalized()
	
	if direction == Vector2.ZERO:
		direction = Vector2(facing, 0.0)
	
	dash_ready = false
	active = true
	time_left = dash_duration
	distance_left = dash_distance
	hit_targets.clear()

func velocity_for_frame(delta: float) -> Vector2:
	var step_time = minf(delta, time_left)
	if step_time <= 0.0:
		return Vector2.ZERO

	return direction * (distance_left/step_time)

func advance(delta: float) -> void:
	var step_time := minf(delta, time_left)

	time_left -= step_time
	distance_left = maxf(0.0, distance_left - (dash_distance * step_time / dash_duration))

	if time_left <= 0.0 or distance_left <= 0.0:
		active = false

func check_targets(input_c: InputComponent) -> void:
	if not active or hitbox == null:
		return

	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("Enemy") and not hit_targets.has(body):
			hit_targets.append(body)
			active = false
			refresh()
			enemy_hit.emit(_launch_direction(input_c.move_dir))
			print("Enemy hit!")
			return

func _launch_direction(input_dir: Vector2) -> Vector2:
	var held_direction = input_dir
	if held_direction != Vector2.ZERO:
		return held_direction
	
	return direction
