
extends Control


@export var inGameTimeElapsed: float = 0.0
@export var timer: Label

@onready var killCounter: Label = $Label2
@onready var dashBar: ProgressBar = $DashMeter/DashBar
@onready var dashCount: Label = $DashMeter/DashCount


func _ready() -> void:
	pass


func _process(delta: float) -> void:

	# Update the game timer.
	if not GameManager.paused:

		inGameTimeElapsed += delta

		var minutes: int = int(inGameTimeElapsed) / 60
		var seconds: int = int(inGameTimeElapsed) % 60
		var milliseconds: int = int(fmod(inGameTimeElapsed, 1.0) * 1000)

		timer.text = "%02d:%02d:%03d" % [
			minutes,
			seconds,
			milliseconds
		]

	# Update kill counter.
	killCounter.text = "Kills: " + str(GameManager.kills)

	# Update dash energy meter.
	_update_dash_meter()


func _update_dash_meter() -> void:

	var player = GameManager.player

	if not is_instance_valid(player):

		dashBar.value = 0.0
		dashCount.text = "-- / --"

		return

	var dash_component: DashComponent = player.get_node_or_null(
		"DashComponent"
	) as DashComponent

	if dash_component == null:

		dashBar.value = 0.0
		dashCount.text = "-- / --"

		return

	dashBar.max_value = dash_component.max_charges

	var displayed_energy := float(dash_component.charges)

	# Include partial regeneration in the progress bar.
	if dash_component.charges < dash_component.max_charges:

		displayed_energy += (
			dash_component.recharge_progress
			/ maxf(dash_component.recharge_time, 0.001)
		)

	dashBar.value = minf(
		displayed_energy,
		float(dash_component.max_charges)
	)

	dashCount.text = "%d / %d" % [
		dash_component.charges,
		dash_component.max_charges
	]
