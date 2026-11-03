extends CharacterBody2D

@onready var input_c: InputComponent = $InputComponent
@onready var dash_c: DashComponent = $DashComponent
@onready var launch_c: LaunchComponent = $LaunchComponent
@onready var movement_c: MovementComponent = $MovementComponent

func _ready() -> void:
	dash_c.hitbox = $DashHitbox
	dash_c.hitbox.monitoring = false

func _physics_process(delta: float) -> void:
	input_c.update_input()

	if is_on_floor():
		dash_c.refresh()
	
	if not dash_c.active and not launch_c.active:
		if input_c.dash_pressed and dash_c.can_start():
			dash_c.start(movement_c.facing, input_c.move_dir)

	if dash_c.active:
		velocity = dash_c.velocity_for_frame(delta)
	
	elif launch_c.active:
		launch_c.tick(delta)
		velocity = launch_c.current_velocity()
	
	else:
		movement_c.tick(self, delta, input_c)

	move_and_slide()

	if dash_c.active:

		var enemy := dash_c.find_enemy()

		if enemy != null:
			if enemy.has_method("die"):
				enemy.call("die")
			
			else:
				_disable_enemy_hitbox(enemy)
			
			dash_c.finish()
			launch_c.start(dash_c.launch_direction(input_c.move_dir))
			dash_c.refresh()
			print("Dash hit: ", enemy.name)
			
		elif dash_c.active:
			dash_c.advance(delta)

func _disable_enemy_hitbox(enemy: PhysicsBody2D) -> void:
	for shape in enemy.find_children("*", "CollisionShape2D", true, false):
		(shape as CollisionShape2D).set_deferred("disabled", true)
