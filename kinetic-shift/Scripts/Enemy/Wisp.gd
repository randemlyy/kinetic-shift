class_name Wisp
extends CharacterBody2D

enum State {
	IDLE,
	CHASE,
	DEAD
}

@export var detection_range = 160.0
@export var chase_speed = 80.0
@export var idle_radius = Vector2(8.0, 4.0)
@export var idle_frequency = 2.0
@export var idle_drift = 3.0

@onready var detection_area: Area2D = $DetectionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var state = State.IDLE
var home_position = Vector2.ZERO
var player: Node2D = null
var elapsed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Enemy")
	home_position = global_position

	var col_shape = $DetectionArea/CollisionShape2D as CollisionShape2D
	var circle = CircleShape2D.new()
	circle.radius = detection_range
	col_shape.shape = circle

	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.play("idle")

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	elapsed += delta

	match state:
		State.IDLE:
			_update_idle()
		
		State.CHASE:
			_update_chase()
		State.DEAD:
			return
	
	move_and_slide()

func _update_idle() -> void:
	var phase = elapsed * idle_frequency
	var offset = Vector2(sin(phase) * idle_radius.x, sin(phase * 0.8) * idle_radius.y)
	velocity = (home_position + offset - global_position) * idle_drift

func _update_chase() -> void:
	if not is_instance_valid(player):
		player = null
		_change_state(State.IDLE)
		velocity = Vector2.ZERO
		return	
	animated_sprite.flip_h = not (player.global_position.x < global_position.x)
	velocity = global_position.direction_to(player.global_position) * chase_speed

func _change_state(next_state: State) -> void:
	if state == next_state:
		return
	
	state = next_state

	match state:
		State.IDLE:
			animated_sprite.play("Idle")
		State.CHASE:
			animated_sprite.play("Chase")
		State.DEAD:
			pass


func die() -> void:
	if state == State.DEAD:
		return

	_change_state(State.DEAD)
	collision_layer = 0
	detection_area.set_deferred("monitoring", false)

	for shape in find_children("*", "CollisionShape2D", true, false):
		(shape as CollisionShape2D).set_deferred("disabled", true)

	queue_free()

func _on_animation_finished() -> void:
	if state == State.DEAD:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		add_collision_exception_with(body)
		player = body
		_change_state(State.CHASE)

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		add_collision_exception_with(body)
		player = null
		_change_state(State.IDLE)
