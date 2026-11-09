extends Node

var music_tracks: Dictionary = {
	"MainMenu.tscn" : preload("res://Assets/Music/ionevenknow.mp3"),
	"LevelSelector.tscn" : preload("res://Assets/Music/idontlikenamingthings.mp3"),
	"GameOver.tscn" : preload("res://Assets/Music/burntoutvro.mp3"),
	"TutorialLevel.tscn" :preload("res://Assets/Music/ionevenknow-v2.mp3"),
	"Level2.tscn" :preload("res://Assets/Music/Kinetic Shift 3f.mp3"),
	"Level3.tscn" :preload("res://Assets/Music/idontlikenamingthings.mp3"),
	"Level4.tscn" :preload("res://Assets/Music/whatconcotionisthis.mp3")
}

var audioP: AudioStreamPlayer
var cTrackPath: String = ""

func _ready() -> void:
	audioP = AudioStreamPlayer.new()
	add_child(audioP)
	
	get_tree().scene_changed.connect(_on_scene_changed)
	
	PlayMusic(get_tree().current_scene)

func _on_scene_changed() -> void:
	PlayMusic(get_tree().current_scene)

func PlayMusic(scene: Node) -> void:
	if not scene:
		return
		
	var sceneFile = scene.scene_file_path.get_file()
	
	if music_tracks.has(sceneFile):
		var targetStream = music_tracks[sceneFile]
		if audioP.stream != targetStream:
			audioP.stream = targetStream
			audioP.play()
