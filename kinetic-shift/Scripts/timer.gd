extends Control

@export var inGameTimeElapsed:float = 0
@export var timer: Label
@onready var killCounter: Label = $Label2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not GameManager.paused:
		inGameTimeElapsed += delta
		var minutes:int = int(inGameTimeElapsed)/60
		var seconds:int = int(inGameTimeElapsed)%60

		var milliseconds:int = int (fmod(inGameTimeElapsed, 1.0) * 1000)

		timer.text = "%02d:%02d:%03d" % [minutes, seconds, milliseconds]
		
	killCounter.text = "Kills: " + str(GameManager.kills)
	pass
