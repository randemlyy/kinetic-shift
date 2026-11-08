class_name GameManager
extends Node

@export var spawnpoint:Node2D
@export var dedscreen:Control
@export var pausescreen:Control
var paused:bool = false
const PLAYER = preload("uid://c4x33uyjhsfud")
var player

const savePath = "user://saved_node.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = PLAYER.instantiate()
	add_child(player)
	player.global_position = spawnpoint.global_position
	print(player.global_position)
	player.get_node("HealthComponent").connect("Death", _on_player_death)
	
	dedscreen.visible = false

func _process(delta: float) -> void:
	if get_tree().paused && not paused:
		if Input.is_key_pressed(KEY_R):
			await get_tree().reload_current_scene()
			get_tree().paused = false
	else:
		if Input.is_action_just_pressed("ui_cancel"):
			if paused:
				paused = false
			elif not paused:
				paused = true
	
	if paused:
		get_tree().paused = true
		pausescreen.visible = true
	elif not paused:
		get_tree().paused = false
		pausescreen.visible = false

func _on_player_death():
	print ("player is ded")
	player.queue_free()
	LoadNode()
	#dedscreen.visible = true
	#Engine.time_scale = lerp(1.0, 0.0, 0.5)
	#get_tree().paused = true
	#get_tree().reload_current_scene()
	pass
	
	
func SaveNode(node:Node):
	var packed = PackedScene.new()
	packed.pack(node)
	ResourceSaver.save(packed, savePath)
	
func LoadNode():
	var packed = load(savePath) as PackedScene
	if packed:
		var loaded = packed.instantiate()
		player = loaded
		player.get_node("HealthComponent").connect("Death", _on_player_death)
		add_child(loaded)

func SetOwnerRecursive(root: Node, current_node: Node) -> void:
	for child in current_node.get_children():
		child.owner = root
		SetOwnerRecursive(root, child)
