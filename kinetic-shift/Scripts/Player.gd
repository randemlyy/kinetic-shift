extends CharacterBody2D

@onready var input_c: InputComponent = $InputComponent
@onready var dash_c: DashComponent = $DashComponent
@onready var launch_c: LaunchComponent = $LaunchComponent
@onready var movement_c: MovementComponent = $MovementComponent
@onready var particle_c: ParticleComponent = $ParticleComponent
@onready var hitstop_c: HitStopComponent = $HitStopComponent

@onready var dash_effect: DashEffectComponent = $DashEffectComponent
@onready var launch_effect: LaunchEffectComponent = $LaunchEffectComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	dash_c.hitbox = $DashHitbox
	dash_c.hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	var was_on_floor = is_on_floor()
	input_c.update_input()

	if input_c.move_x != 0.0:
		player_sprite.flip_h = input_c.move_x < 0.0

	if is_on_floor():
		dash_c.refresh()
	
	# Dash input check and dash particle effect
	if not dash_c.active and not launch_c.active:
		if input_c.dash_pressed and dash_c.can_start():
			dash_c.start(movement_c.facing, input_c.move_dir)
			particle_c.play_dash(dash_c.direction)


	# Handling dash and launch velocity
	if dash_c.active:
		velocity = dash_c.velocity_for_frame(delta)
	
	elif launch_c.active:
		launch_c.tick(delta)
		velocity = launch_c.current_velocity()
	
	else:
		movement_c.tick(self, delta, input_c)

	var landing_speed = maxf(velocity.y, 0.0)
	move_and_slide()

	if not was_on_floor and is_on_floor():
		particle_c.play_landing(Vector2(0.0, 20.0), landing_speed)

	_update_animation()

	dash_effect.update_effect(delta, dash_c.active)
	launch_effect.update_effect(delta, launch_c.active)
	

	# Launch check
	if dash_c.active:

		var enemy := dash_c.find_enemy()

		if enemy != null:
			if enemy.has_method("die"):
				enemy.call("die")
			
			else:
				_disable_enemy_hitbox(enemy)
			
			dash_c.finish()
			await hitstop_c.play()
			launch_c.start(dash_c.launch_direction(input_c.move_dir))
			dash_c.refresh()
		elif dash_c.active:
			dash_c.advance(delta)

func _disable_enemy_hitbox(enemy: PhysicsBody2D) -> void:
	for shape in enemy.find_children("*", "CollisionShape2D", true, false):
		(shape as CollisionShape2D).set_deferred("disabled", true)

func _update_animation() -> void:
	if not is_on_floor():
		animation_player.pause()
		return

	var anim = "Idle"
	
	if is_on_floor() and not dash_c.active and not launch_c.active and absf(velocity.x) > 5.0:
		anim = "Walk"
	
	if animation_player.current_animation != anim or not animation_player.is_playing():
		animation_player.play(anim)