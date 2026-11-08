class_name DebuffComponent
extends Node

var player
enum  debuffType {WEAKNESS, SLOWNESS, DASH, STUN}
var dType = debuffType.WEAKNESS

func debuff(player:CharacterBody2D, num:int):
	dType = num as debuffType
	if player.has_node("debuff"):
		return
	name = "debuff"
	if dType == debuffType.WEAKNESS:
		var health = player.get_node("HealthComponent")
		health.damageMultiplier = 1.5
		print("weakened")
		await get_tree().create_timer(5).timeout
		health.damageMultiplier = 1
		print("done")
	elif dType == debuffType.SLOWNESS:
		var move = player.get_node("MovementComponent")
		var temp = move.speed
		move.speed *= 0.7
		print("slowed")
		await get_tree().create_timer(5).timeout
		move.speed = temp
	elif dType == debuffType.DASH:
		var dash = player.get_node("DashComponent")
		dash.dashMultiplier = 0.6
		print("dash reduced")
		await get_tree().create_timer(5).timeout
		dash.dashMultiplier = 1
	elif dType == debuffType.STUN:
		var move = player.get_node("MovementComponent")
		var temp = move.speed
		move.speed = 0
		print("stunned")
		await get_tree().create_timer(2).timeout
		move.speed = temp
	print("done")
	queue_free()
