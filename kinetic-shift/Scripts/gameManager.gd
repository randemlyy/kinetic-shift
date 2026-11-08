class_name GameManager
extends Node

@export var spawnpoint:Node2D
@export var dedscreen:Control
@export var pausescreen:Control
@export var finishpoint:Node2D
@onready var timer: Control = $CanvasLayer/Timer

var paused:bool = false
const PLAYER = preload("uid://c4x33uyjhsfud")
var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	player.global_position = spawnpoint.global_position
	print(player.global_position)
	player.get_node("HealthComponent").connect("Death", _on_player_death)
	
	finishpoint.connect("PlayerFinished", _on_player_finished)
	dedscreen.visible = false

func _process(delta: float) -> void:
	if get_tree().paused && not paused:
		if Input.is_key_pressed(KEY_R):
			get_tree().reload_current_scene()
			if is_inside_tree():
				get_tree().paused = false
	else:
		if Input.is_action_just_pressed("ui_cancel"):
			if paused:
				paused = false
			elif not paused:
				paused = true
	
	if paused:
		if is_inside_tree():
			get_tree().paused = true
		pausescreen.visible = true
	elif not paused:
		if is_inside_tree():
			get_tree().paused = false
		pausescreen.visible = false

func _on_player_finished() -> void:
	print("player finished")
	SaveManager.verify_and_save_time("level 0", timer.inGameTimeElapsed)
	pass

func _on_player_death():
	print ("player is ded")
	dedscreen.visible = true
	#Engine.time_scale = lerp(1.0, 0.0, 0.5)
	if is_inside_tree():
		get_tree().paused = true
	#get_tree().reload_current_scene()
	pass
	
