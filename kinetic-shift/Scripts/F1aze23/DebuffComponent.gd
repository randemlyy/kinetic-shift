class_name DebuffComponent
extends Node

var player
enum  debuffType {SLOWNESS, DASH, STUN}
var dType = debuffType.SLOWNESS
var debuffI

func debuff(player:CharacterBody2D, num:int):
	debuffI = get_parent().get_node("DebuffIndicator")
	dType = num as debuffType
	if player.has_node("debuff"):
		return
	name = "debuff"
	if dType == debuffType.SLOWNESS:
		var move = player.get_node("MovementComponent")
		var temp = move.speed
		move.speed *= 0.7
		debuffI.text = "Slowed"
		await get_tree().create_timer(5).timeout
		move.speed = temp
	elif dType == debuffType.DASH:
		var dash = player.get_node("DashComponent")
		dash.dashMultiplier = 0.6
		debuffI.text = "Reduced Dash"
		await get_tree().create_timer(5).timeout
		dash.dashMultiplier = 1
	elif dType == debuffType.STUN:
		var move = player.get_node("MovementComponent")
		var temp = move.speed
		move.speed = 0
		debuffI.text = "Stunned"
		await get_tree().create_timer(2).timeout
		move.speed = temp
	debuffI.text = ""
	queue_free()
