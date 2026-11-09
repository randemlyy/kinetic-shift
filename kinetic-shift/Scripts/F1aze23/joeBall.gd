extends CharacterBody2D

var vel = 300
var moveDir := Vector2.ZERO
func start(pos : Vector2):
	moveDir = (pos - global_position).normalized()
	await get_tree().create_timer(8).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	velocity = moveDir * vel
	move_and_slide()


func attackAreaEntered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var debuff = DebuffComponent.new()
		body.add_child(debuff)
		debuff.debuff(body, randi_range(1,3))
	if !body.is_in_group("Enemy"):
		print(body.name)
		queue_free()
