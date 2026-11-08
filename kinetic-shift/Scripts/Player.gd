
extends CharacterBody2D

@onready var input_c: InputComponent = $InputComponent
@onready var dash_c: DashComponent = $DashComponent
@onready var launch_c: LaunchComponent = $LaunchComponent
@onready var movement_c: MovementComponent = $MovementComponent
@onready var wall_cling_c: WallClingComponent = $WallClingComponent
@onready var particle_c: ParticleComponent = $ParticleComponent
@onready var hitstop_c: HitStopComponent = $HitStopComponent
@onready var health_c: HealthComponent = $HealthComponent

@onready var dash_effect: DashEffectComponent = $DashEffectComponent
@onready var launch_effect: LaunchEffectComponent = $LaunchEffectComponent
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player_sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox

var normal_sprite_scale := Vector2.ONE
var dash_visual_weight := 0.0
var normal_sprite_flip_h := false
var dead = false
var cling_input_queued = true

func _ready() -> void:
	dash_c.hitbox = $DashHitbox
	dash_c.hitbox.monitoring = false
	normal_sprite_scale = player_sprite.scale

	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	
	health_c.start()
	
func _process(delta: float) -> void:
	health_c.update(delta)
	health_c.isDashing = dash_c.active


func _physics_process(delta: float) -> void:

	input_c.update_input()
	movement_c.update_jump_buffer(delta, input_c.jump_pressed)

	if input_c.jump_released:
		cling_input_queued = true

	wall_cling_c.update(delta, input_c.jump_held)

	var was_on_floor = is_on_floor()

	var wall_jump_started := false

	if wall_cling_c.active:

		if input_c.dash_pressed and dash_c.can_start():

			var dash_direction := wall_cling_c.get_dash_direction(input_c.move_dir)

			wall_cling_c.release()
			cling_input_queued = false

			normal_sprite_flip_h = player_sprite.flip_h

			dash_c.start(movement_c.facing, dash_direction)

			particle_c.play_dash(dash_c.direction)

		elif input_c.jump_pressed:

			wall_jump_started = wall_cling_c.jump_off(self)
			cling_input_queued = false
			movement_c.jump_buffer_left = 0.0

	
		else:

			velocity = wall_cling_c.get_cling_velocity(movement_c.speed)

			move_and_slide()

			wall_cling_c.maintain_contact(self)

			_update_dash_visual(delta)
			_update_animation()

			dash_effect.update_effect(delta, dash_c.active)
			launch_effect.update_effect(delta, launch_c.active)

			return

	if not wall_cling_c.active and input_c.move_x != 0.0:
		player_sprite.flip_h = input_c.move_x < 0.0


	if is_on_floor() and not wall_cling_c.active:
		dash_c.refresh()



	if not wall_cling_c.active and not dash_c.active and not launch_c.active:

		if input_c.dash_pressed and dash_c.can_start():

			normal_sprite_flip_h = player_sprite.flip_h

			dash_c.start(movement_c.facing, input_c.move_dir)

			particle_c.play_dash(dash_c.direction)

	# A fresh Jump press after letting go can jump away from the saved surface.
	if (
		not wall_jump_started
		and not wall_cling_c.active
		and not dash_c.active
		and not launch_c.active
		and input_c.jump_pressed
	):
		wall_jump_started = wall_cling_c.jump_off(self)
		if wall_jump_started:
			cling_input_queued = false
			movement_c.jump_buffer_left = 0.0

	# Check existing wall contact before movement, so a cling press wins over a coyote jump.
	if (
		not is_on_floor()
		and not wall_cling_c.active
		and not dash_c.active
		and not launch_c.active
	):
		if wall_cling_c.try_start(
			self,
			input_c.jump_held and cling_input_queued
		):
			movement_c.jump_buffer_left = 0.0



	if wall_cling_c.active:
		velocity = wall_cling_c.get_cling_velocity(movement_c.speed)

	elif dash_c.active:

		velocity = dash_c.velocity_for_frame(delta)

	elif launch_c.active:

		launch_c.tick(delta)

		velocity = launch_c.current_velocity()

	elif wall_jump_started:

		
		pass

	else:

		movement_c.tick(self, delta, input_c)
		if movement_c.jumped_this_frame:
			cling_input_queued = false


	var landing_speed = maxf(velocity.y, 0.0)

	move_and_slide()

	if wall_cling_c.active:
		wall_cling_c.maintain_contact(self)

	# Landing particles.
	if not was_on_floor and is_on_floor():

		particle_c.play_landing(Vector2(0.0, 20.0), landing_speed)




	if dash_c.active or dash_c.hit_window_left > 0.0:

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

		else:

			dash_c.tick_hit_window(delta)



	elif not launch_c.active:

		if wall_cling_c.try_start(
			self,
			input_c.jump_held and cling_input_queued
		):
			movement_c.jump_buffer_left = 0.0




	_update_dash_visual(delta)

	_update_animation()

	dash_effect.update_effect(delta, dash_c.active)

	launch_effect.update_effect(delta, launch_c.active)


func _update_dash_visual(delta: float) -> void:

	var prev_weight = dash_visual_weight

	var target = 1.0 if dash_c.active else 0.0

	var blend_time = 0.025 if target > dash_visual_weight else 0.08

	dash_visual_weight = move_toward(
		dash_visual_weight,
		target,
		delta / blend_time
	)

	if dash_visual_weight > 0.01:

		player_sprite.flip_h = false

	elif prev_weight > 0.01:

		player_sprite.flip_h = input_c.move_x < 0.0 if input_c.move_x != 0.0 else normal_sprite_flip_h

	
	player_sprite.rotation = (
		wall_cling_c.visual_rotation
		+ dash_c.direction.angle() * dash_visual_weight
	)

	player_sprite.scale = normal_sprite_scale.lerp(
		normal_sprite_scale * Vector2(1.5, 0.8),
		dash_visual_weight
	)

	player_sprite.modulate = Color.WHITE.lerp(
		Color(0.05, 0.05, 0.08, 0.85),
		dash_visual_weight
	)


func _disable_enemy_hitbox(enemy: PhysicsBody2D) -> void:

	for shape in enemy.find_children("*", "CollisionShape2D", true, false):

		(shape as CollisionShape2D).set_deferred("disabled", true)


func _on_hurtbox_body_entered(body: Node2D) -> void:

	if dead or not body.is_in_group("Enemy"):
		return

	
	if dash_c.active and dash_c.find_enemy() == body:
		return

	die()


func die() -> void:


	pass


func _update_animation() -> void:

	# Maintain idle animation while clinging.
	if wall_cling_c.active:

		if animation_player.current_animation != "Idle":

			animation_player.play("Idle")

		return


	if dash_c.active or dash_visual_weight > 0.01:

		if animation_player.current_animation != "Dash":

			animation_player.play("Dash")

		return


	if not is_on_floor():

		if animation_player.current_animation == "Dash":

			animation_player.play("Idle")

			animation_player.seek(0.0, true)

		animation_player.pause()

		return


	var anim = "Idle"

	if is_on_floor() and not dash_c.active and not launch_c.active and absf(velocity.x) > 5.0:

		anim = "Walk"


	if animation_player.current_animation != anim or not animation_player.is_playing():

		animation_player.play(anim)
