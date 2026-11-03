extends CharacterBody2D

@onready var input_c = $InputComponent
@onready var dash_c = $DashComponent
@onready var launch_c = $LaunchComponent
@onready var movement_c = $MovementComponent

func _ready() -> void:
	dash_c.hitbox = $DashHitbox
	dash_c.enemy_hit.connect(_on_enemy_hit)

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
		dash_c.check_targets(input_c)
		if dash_c.active:
			dash_c.advance(delta)

func _on_enemy_hit(launch_dir: Vector2) -> void:
	launch_c.start(launch_dir)
