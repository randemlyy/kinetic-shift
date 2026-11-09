class_name DashEffectComponent
extends Node

@export_range(0.01, 0.1, 0.005) var interval = 0.025
@export_range(0.03, 0.3, 0.01) var lifetime = 0.12
@export var ghost_color = Color(0.35, 0.35, 1.0, 0.4)

@onready var source: Sprite2D = $"../Sprite2D"

var time_left = 0.0

func update_effect(delta: float, is_dashing: bool) -> void:
	if not is_dashing:
		time_left = 0.0
		return
	
	time_left -= delta
	if time_left > 0.0:
		return
	
	_spawn()
	time_left = interval

func _spawn() -> void:
	var ghost = source.duplicate() as Sprite2D
	var world = get_tree().current_scene
	if ghost == null or world == null:
		return
	
	ghost.modulate = ghost_color
	ghost.z_index = source.z_index - 1
	world.add_child(ghost)
	ghost.global_transform = source.global_transform

	var fade_color = ghost_color
	fade_color.a = 0.0
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate", fade_color, lifetime)
	tween.tween_callback(ghost.queue_free)
