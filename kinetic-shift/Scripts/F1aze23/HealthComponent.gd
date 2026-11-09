class_name HealthComponent
extends Node

var hurt = []
var isDashing

signal Death


func damage():
	Death.emit()
