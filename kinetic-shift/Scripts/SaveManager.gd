#class_name SaveManager
extends Node

const SAVE_PATH:String = "user://save_data.tres"
var current_save:SaveData

func _ready() -> void:
	load_game()


func verify_and_save_time(level_id:String, new_time:float) -> void:
	if current_save.best_times.has(level_id):
		var old_time = current_save.best_times[level_id]
		if new_time < old_time:
			current_save.best_times[level_id] = new_time
			save_game()
	else:
		current_save.best_times[level_id] = new_time
		save_game()

func save_game() -> void:
	var error = ResourceSaver.save(current_save, SAVE_PATH)
	if error != OK:
		print ("Failed to save data")


func load_game() -> void:
	if ResourceLoader.exists(SAVE_PATH):
		current_save = ResourceLoader.load(SAVE_PATH) as SaveData
	else:
		current_save = SaveData.new()

func clear_all_saves() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var error = DirAccess.remove_absolute(SAVE_PATH)
		if error == OK:
			print("save files deleted")
		else:
			print("deletion failed")
	current_save = SaveData.new()
