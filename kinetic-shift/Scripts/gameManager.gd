extends Node

var spawnpoint:Node2D
var dedscreen:Control
var pausescreen:Control
var finishpoint:Node2D
var timer: Control

var paused:bool = false
const PLAYER = preload("uid://c4x33uyjhsfud")
const HUD = preload("res://Scenes/F1aze23/hud.tscn")
var player
var hud

var currentSave:SaveData


var playerSave:String
var timeSave:String = "user://save_data.tres"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().set_auto_accept_quit(false)

func StartGame() -> void:
	hud = HUD.instantiate()
	add_child(hud)
	dedscreen = hud.get_node("DedScreen")
	spawnpoint = get_tree().get_first_node_in_group("SpawnPoint")
	pausescreen = hud.get_node("PauseScreen")
	timer = hud.get_node("Timer")
	finishpoint = get_tree().get_first_node_in_group("FinishLine")
	
	player = PLAYER.instantiate()
	get_tree().root.add_child.call_deferred(player)
	player.global_position = spawnpoint.global_position
	print(player.global_position)
	player.get_node("HealthComponent").connect("Death", _on_player_death)
	
	finishpoint.connect("PlayerFinished", _on_player_finished)
	dedscreen.visible = false
	
	if ResourceLoader.exists(timeSave):
		currentSave = ResourceLoader.load(timeSave) as SaveData
	else:
		currentSave = SaveData.new()
		
	playerSave = "user://" + "player_" + get_tree().current_scene.scene_file_path.get_file()
	print(playerSave)
	
func startMenu():
	if ResourceLoader.exists(timeSave):
		currentSave = ResourceLoader.load(timeSave) as SaveData
	else:
		currentSave = SaveData.new()

func _process(delta: float) -> void:
	if pausescreen == null:
		return
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
	SaveTimer()
	pass

func _on_player_death():
	print ("player is ded")
	player.death()
	LoadNode()
	
	
func SaveNode(node:Node):
	var packed = PackedScene.new()
	packed.pack(node)
	ResourceSaver.save(packed, playerSave)
	print("saved")
	
func LoadNode():
	if !FileAccess.file_exists(playerSave):
		dedscreen.visible = true
		return
	var packed = load(playerSave) as PackedScene
	if packed:
		var loaded = packed.instantiate()
		player = loaded
		player.get_node("HealthComponent").connect("Death", _on_player_death)
		add_child(loaded)
		
func SaveTimer():
	var sceneFile = get_tree().current_scene.scene_file_path.get_file()
	var saveData = SaveData.new()
	if currentSave.bestTimes.has(sceneFile):
		if currentSave.bestTimes[sceneFile] > timer.inGameTimeElapsed:
			currentSave.bestTimes[sceneFile] = timer.inGameTimeElapsed
	else:
		currentSave.bestTimes[sceneFile] = timer.inGameTimeElapsed
	ResourceSaver.save(currentSave, timeSave)
	
	
func DeletePSave():
	var dir = DirAccess.open("user://")
	
	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		
		while file != "":
			if file.begins_with("player"):
				dir.remove(file)
			file = dir.get_next()
			
		dir.list_dir_end()
	else:
		print("Error Occured")
		
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		DeletePSave()
		get_tree().quit()
		
		
