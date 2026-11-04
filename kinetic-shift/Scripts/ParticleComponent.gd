class_name ParticleComponent
extends Node2D

@export var dash_effect: PackedScene
@export var landing_effect: PackedScene
@export var death_effect: PackedScene

func play_dash(dash_direction: Vector2) -> void:
	_spawn(dash_effect, global_position, -1.0, -dash_direction.normalized())

func play_landing(offset: Vector2, impact_speed: float) -> void:
	var intensity = clampf(impact_speed / 600.0, 0.15, 1.0)
	_spawn(landing_effect, global_position + offset, intensity)

func play_death() -> void:
	_spawn(death_effect, global_position)

func _spawn(effect_scene: PackedScene, at_position: Vector2, impact_intensity: float = -1.0, particle_direction: Vector2 = Vector2.ZERO) -> void:
	if effect_scene == null:
		return
	
	var effect = effect_scene.instantiate() as GPUParticles2D
	if effect == null:
		return
	
	var scene_root = get_tree().current_scene
	if scene_root == null:
		effect.free()
		return

	if impact_intensity >= 0.0:
		effect.amount_ratio = impact_intensity
		effect.speed_scale = lerpf(0.75, 1.5, impact_intensity)

	if particle_direction != Vector2.ZERO:
		var curr_material = effect.process_material as ParticleProcessMaterial
		if curr_material != null:
			var instance_material = curr_material.duplicate() as ParticleProcessMaterial
			instance_material.direction = Vector3(particle_direction.x, particle_direction.y, 0.0)
			effect.process_material = instance_material

	effect.emitting = false
	effect.one_shot = true
	scene_root.add_child(effect)
	effect.global_position = at_position
	effect.finished.connect(effect.queue_free, CONNECT_ONE_SHOT)
	effect.emitting = true
