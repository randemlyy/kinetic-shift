extends StaticBody2D

@onready var ballSpawn: Marker2D = $BallSpawn
@onready var eye_sprite: Sprite2D = $EyeSprite

@export var joeBall:PackedScene
@export var detection_range = 300.0
@export var direction_frames: Array[int] = [8, 9, 10, 11, 12, 13, 14, 15]

var canAttack := true
var player: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		eye_sprite.frame = 0
		return
	
	var to_player = player.global_position - global_position
	if to_player.length() > detection_range:
		eye_sprite.frame = 0
		return
	
	var sector := int(round(fposmod(to_player.angle(), TAU) / (PI / 4.0))) % 8
	eye_sprite.frame = direction_frames[sector]

	attack(Vector2(randf(), randf()))
	
func attack(offset : Vector2):
	if !canAttack:
		return

	canAttack = false

	var attackPos = player.global_position + offset
	var aimDir = global_position.direction_to(attackPos)

	if aimDir == Vector2.ZERO:
		aimDir = Vector2.RIGHT
	
	ballSpawn.position = aimDir * 20.0
	
	var ball = joeBall.instantiate()
	get_tree().root.add_child(ball)
	ball.global_position = ballSpawn.global_position
	ball.start(attackPos)
	
	await get_tree().create_timer(1).timeout
	canAttack = true
