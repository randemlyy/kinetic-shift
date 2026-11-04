class_name ParticleComponent
extends Node2D

@export var dash_effect: PackedScene
@export var landing_effect: PackedScene
@export var death_effect: PackedScene

func play_dash() -> void:
	_spawn(dash_effect, global_position)

func play_landing(offset: Vector2 = Vector2.ZERO) -> void:
	_spawn(landing_effect, global_position + offset)

func play_death() -> void:
	_spawn(death_effect, global_position)

func _spawn(effect_scene: PackedScene, position: Vector2) -> void:
	if effect_scene == null:
		return
	
	var effect = effect_scene.instantiate() as GPUParticles2D
	if effect == null:
		return
	
	var scene_root = get_tree().current_scene
	if scene_root == null:
		effect.free()
		return
	
	effect.emitting = false
	effect.one_shot = true
	scene_root.add_child(effect)
	effect.global_position = position
	effect.finished.connect(effect.queue_free, CONNECT_ONE_SHOT)
	effect.emitting = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
