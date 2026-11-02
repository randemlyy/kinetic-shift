extends Node

signal enemy_hit(launch_dir: Vector2)

@export_group("Dash")
@export var dash_speed = 1200.0
@export var dash_duration = 0.05
@export var hitbox: Area2D

var active = false
var facing := 1.0
var dash_ready = true
var direction = Vector2.RIGHT
var time_left = 0.0
var hit_targets: Array[Area2D] = []

func refresh() -> void:
	dash_ready = true

func can_start() -> bool:
	return dash_ready

func start(player_facing: float) -> void:
	facing = player_facing
	direction = _held_direction()
	
	if direction == Vector2.ZERO:
		direction = Vector2(facing, 0.0)
	
	dash_ready = false
	active = true

	time_left = dash_duration
	hit_targets.clear()

func tick(delta: float) -> void:
	time_left -= delta
	if time_left <= 0.0:
		active = false
	
func current_velocity() -> Vector2:
	return direction * dash_speed

func check_targets() -> void:
	pass

func _held_direction() -> Vector2:
	return Input.get_vector("left", "right", "up", "down").normalized()

func _launch_direction() -> Vector2:
	var held_direction = _held_direction()
	if held_direction != Vector2.ZERO:
		return held_direction
	
	return Vector2(facing, 0.0)
