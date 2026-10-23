extends Node
class_name WantedSystem

signal wanted_changed(level: int)

var level: int = 0
var cooldown: float = 0.0
var quiet_time: float = 0.0

func add_crime(severity: int = 1) -> void:
	level = clampi(level + severity, 0, 5)
	quiet_time = 0.0
	cooldown = 18.0 + float(level) * 7.0
	wanted_changed.emit(level)

func _process(delta: float) -> void:
	if level <= 0:
		return
	quiet_time += delta
	if quiet_time >= cooldown:
		level -= 1
		quiet_time = 0.0
		cooldown = 18.0 + float(level) * 7.0
		wanted_changed.emit(level)

func clear_wanted() -> void:
	level = 0
	quiet_time = 0.0
	wanted_changed.emit(level)
