extends CharacterBody2D


@onready var dash_c = $DashComponent
@onready var launch_c = $LaunchComponent
@onready var movement_c = $MovementComponent


var dash_left = 0.0
var dash_direction = Vector2.RIGHT
var dash_available = true
var is_dashing = false
var hit_targets: Array[Area2D] = []

func _ready() -> void:
	dash_c.enemy_hit.connect(_on_enemy_hit)

func _physics_process(delta: float) -> void:
	if is_on_floor():
		dash_c.refresh()
	
	if not dash_c.active and not launch_c.active:
		if Input.is_action_just_pressed("dash") and dash_c.can_start():
			dash_c.start(movement_c.facing)

	if dash_c.active:
		dash_c.tick(delta)
		velocity = dash_c.current_velocity()
	
	elif launch_c.active:
		launch_c.tick(delta)
		velocity = launch_c.current_velocity()
	
	else:
		movement_c.tick(self, delta)
	
	move_and_slide()

	if dash_c.active:
		dash_c.check_targets()

func _on_enemy_hit(launch_dir: Vector2) -> void:
	launch_c.start(launch_dir)
