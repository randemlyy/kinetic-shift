extends Node

var spawnpoint:Node2D
var pausescreen:Control
var finishpoint:Node2D
var timer: Control

var paused:bool = false
const PLAYER = preload("uid://c4x33uyjhsfud")
const HUD = preload("res://Scenes/F1aze23/hud.tscn")
var player
var hud
var time

var currentSave:SaveData

var kills := 0

var playerSave:String
var statSave:String = "user://save_data.tres"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().set_auto_accept_quit(false)

func StartGame(path:String) -> void:
	await get_tree().change_scene_to_file(path)
	await get_tree().create_timer(0.2).timeout
	kills = 0
	hud = HUD.instantiate()
	add_child(hud)
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
	
	pausescreen.visible = false
	get_tree().paused = false
	paused = false
	
	if ResourceLoader.exists(statSave):
		currentSave = ResourceLoader.load(statSave) as SaveData
	else:
		currentSave = SaveData.new()
		
	playerSave = "user://" + "player_" + get_tree().current_scene.scene_file_path.get_file()
	print(playerSave)
	
func startMenu():
	if ResourceLoader.exists(statSave):
		currentSave = ResourceLoader.load(statSave) as SaveData
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
	SaveStats()
	player.death()
	get_tree().change_scene_to_file("res://Scenes/F1aze23/GameOver.tscn")
	DeletePSave()
	hud.visible =false
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
	var packed = load(playerSave) as PackedScene
	if packed:
		var loaded = packed.instantiate()
		player = loaded
		player.get_node("HealthComponent").connect("Death", _on_player_death)
		add_child(loaded)
		
func SaveStats():
	var sceneFile = get_tree().current_scene.scene_file_path.get_file()
	var saveData = SaveData.new()
	time = snapped(timer.inGameTimeElapsed, 0.001)
	if currentSave.bestTimes.has(sceneFile):
		if currentSave.bestTimes[sceneFile] > time:
			currentSave.bestTimes[sceneFile] = time
	else:
		currentSave.bestTimes[sceneFile] = time
	if currentSave.killCounts.has(sceneFile):
		if currentSave.killCounts[sceneFile] < kills:
			currentSave.killCounts[sceneFile] = kills
	else:
		currentSave.killCounts[sceneFile] = kills
	ResourceSaver.save(currentSave, statSave)
	
	
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
		
		
