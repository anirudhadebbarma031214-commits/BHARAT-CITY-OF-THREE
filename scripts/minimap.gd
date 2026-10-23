extends Control

var player_position := Vector3.ZERO
var player_yaw := 0.0
var wanted_level := 0

func _ready() -> void:
	custom_minimum_size = Vector2(190, 190)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var map_size := minf(size.x, size.y)
	var center := Vector2(map_size * 0.5, map_size * 0.5)
	var radius := map_size * 0.46
	draw_circle(center, radius + 5.0, Color(0.02, 0.04, 0.05, 0.85))
	draw_circle(center, radius, Color(0.12, 0.2, 0.18, 0.98))
	# Schematic local street grid, not a live GPS map.
	for offset in [-52.0, -18.0, 20.0, 55.0]:
		draw_line(center + Vector2(offset, -radius) , center + Vector2(offset, radius), Color(0.65, 0.65, 0.58, 0.7), 7.0)
		draw_line(center + Vector2(-radius, offset), center + Vector2(radius, offset), Color(0.65, 0.65, 0.58, 0.7), 7.0)
	draw_line(center + Vector2(-radius, 35), center + Vector2(radius, 35), Color(0.87, 0.76, 0.45, 0.8), 4.0)
	draw_circle(center + Vector2(30, -38), 5.0, Color(0.98, 0.75, 0.25))
	var arrow := PackedVector2Array([
		center + Vector2(0, -11).rotated(-player_yaw),
		center + Vector2(-7, 8).rotated(-player_yaw),
		center + Vector2(7, 8).rotated(-player_yaw)
	])
	draw_colored_polygon(arrow, Color(0.2, 0.9, 1.0))
	draw_arc(center, radius, 0, TAU, 48, Color(0.5, 0.85, 0.83, 0.9), 2.0)
