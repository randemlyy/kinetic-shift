class_name HealthComponent
extends Node

var health:int
var maxHealth = 100
@export var healthBar:ProgressBar
var hurt = []
var isDashing
var damageMultiplier = 1.0

func start():
	health = maxHealth
	if healthBar != null:
		healthBar.max_value = maxHealth

func update(delta:float):
	if healthBar != null:
		healthBar.value = health
	if health <= 0:
		health = 0
	elif health >= 100:
		health = 100
	
func damage(amt:float, node:Node):
	if hurt.has(node):
		return
	hurt+=[node]
	var temp = health
	health -= amt* damageMultiplier
	await get_tree().create_timer(0.2).timeout
	if hurt.has(node):
		hurt.erase(node)
	print(health, node, amt)

	
