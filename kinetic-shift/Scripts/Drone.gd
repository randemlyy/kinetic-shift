class_name Drone
extends CharacterBody2D

@export var detection_range = 10.0
@export var chase_speed = 40.0
@export var idle_radius = Vector2(8.0, 4.0)
@export var idle_frequency = 2.0
@export var idle_drift = 3.0

@onready var detection_area: Area2D = $DetectionArea

var home_position = Vector2.ZERO
var player: Node2D = null
var elapsed = 0.0
var dead = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Enemy")
	home_position = global_position

	var col_shape = $DetectionArea/CollisionShape2D as CollisionShape2D
	var circle = CircleShape2D.new()
	circle.radius = detection_range
	col_shape.shape = circle

	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	if dead: 
		return
	
	elapsed += delta

	if is_instance_valid(player):
		velocity = global_position.direction_to(player.global_position) * chase_speed

	else:
		player = null
		var phase = elapsed * idle_frequency
		var offset = Vector2(sin(phase) * idle_radius.x, sin(phase * 0.8) * idle_radius.y)
		velocity = (home_position + offset - global_position) * idle_drift
	
	move_and_slide()

func die() -> void:
	if dead:
		return
	
	dead = true
	collision_layer = 0
	detection_area.set_deferred("monitoring", false)
	for shape in find_children("*", "CollisionShape2D", true, false):
		(shape as CollisionShape2D).set_deferred("disabled", true)
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
