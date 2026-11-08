extends StaticBody2D

var player
@export var joeBall:PackedScene
@onready var ballSpawn: Marker2D = $BallSpawn
var canAttack := true
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if global_position.distance_to(player.global_position) < 300:
		attack(Vector2(randf(), randf()))
	
func attack(offset : Vector2):
	if !canAttack:
		return
	canAttack = false
	var attackPos = player.global_position + offset
	look_at(attackPos)
	var ball = joeBall.instantiate()
	get_tree().root.add_child(ball)
	ball.global_position = ballSpawn.global_position
	ball.start(attackPos)
	await get_tree().create_timer(1).timeout
	canAttack = true
