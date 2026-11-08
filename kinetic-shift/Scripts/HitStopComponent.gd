class_name HitStopComponent
extends Node

@export_range(0.1, 0.30, 0.005) var duration = 0.06

var _active = false
var _request_id = 0
var _prev_time_scale = 1.0

func play() -> void:
	if not _active:
		_prev_time_scale = Engine.time_scale
	
	_active = true
	_request_id += 1
	var request_id = _request_id

	Engine.time_scale = 0.0
	await get_tree().create_timer(duration, true, false, true).timeout

	if request_id == _request_id:
		Engine.time_scale = _prev_time_scale
		_active = false

func _exit_tree() -> void:
	if _active:
		Engine.time_scale = _prev_time_scale
