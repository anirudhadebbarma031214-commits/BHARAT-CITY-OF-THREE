extends Node3D

const PlayerScript = preload("res://scripts/player.gd")
const VehicleScript = preload("res://scripts/vehicle.gd")
const WantedScript = preload("res://scripts/wanted_system.gd")
const MinimapScript = preload("res://scripts/minimap.gd")

var player: BharatPlayer
var vehicles: Array[BharatVehicle] = []
var wanted: WantedSystem
var wanted_label: Label
var objective_label: Label
var speed_label: Label
var minimap: Control
var mission_index := 1
var mission_started := false
var mission_finished := false
var finish_timer := 0.0
var intro_layer: Control
var end_layer: Control
var objective_position := Vector3(0, 0, -62)

func _ready() -> void:
	_setup_input()
	_build_environment()
	_build_city()
	_build_player()
	_build_vehicles()
	_build_hud()
	_build_intro()

func _setup_input() -> void:
	_add_key("move_forward", KEY_W)
	_add_key("move_back", KEY_S)
	_add_key("move_left", KEY_A)
	_add_key("move_right", KEY_D)
	_add_key("interact", KEY_F)
	_add_key("handbrake", KEY_SPACE)
	_add_key("horn", KEY_E)
	_add_key("camera_toggle", KEY_V)
	_add_key("jump", KEY_SPACE)
	_add_key("pause", KEY_ESCAPE)

func _add_key(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.12, 0.27, 0.42)
	sky_mat.sky_horizon_color = Color(0.78, 0.68, 0.51)
	sky_mat.ground_bottom_color = Color(0.08, 0.1, 0.08)
	sky_mat.ground_horizon_color = Color(0.3, 0.32, 0.27)
	env.sky.sky_material = sky_mat
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.49, 0.56, 0.66)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.25
	env.fog_enabled = true
	env.fog_light_color = Color(0.64, 0.7, 0.68)
	env.fog_density = 0.0018
	world.environment = env
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-43, -28, 0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 100.0
	add_child(sun)

func _build_city() -> void:
	_box("Ground", Vector3(0, -0.5, -42), Vector3(180, 1, 230), Color(0.19, 0.28, 0.19), true)
	_box("Agartala asphalt road", Vector3(0, 0.02, -42), Vector3(17, 0.16, 210), Color(0.105, 0.12, 0.13), true)
	_box("Left footpath", Vector3(-9.5, 0.18, -42), Vector3(2.1, 0.35, 210), Color(0.47, 0.43, 0.35), true)
	_box("Right footpath", Vector3(9.5, 0.18, -42), Vector3(2.1, 0.35, 210), Color(0.47, 0.43, 0.35), true)
	for z in range(-135, 65, 10):
		_box("Road lane marking", Vector3(0, 0.12, z), Vector3(0.16, 0.025, 4.0), Color(0.92, 0.84, 0.56), false)
	for side in [-1, 1]:
		for i in range(10):
			var z := -8.0 - float(i) * 15.0
			var x := float(side) * (13.0 + float(i % 2) * 3.0)
			var height := 5.0 + float((i * 7) % 4)
			var color := [Color(0.73,0.54,0.36), Color(0.65,0.68,0.53), Color(0.69,0.47,0.39), Color(0.72,0.67,0.5)][i % 4]
			_box("Indian shopfront", Vector3(x, height * 0.5, z), Vector3(7.0, height, 9.0), color, true)
			_box("Shop awning", Vector3(x, 2.5, z + 4.65), Vector3(6.8, 0.25, 1.2), Color(0.12, 0.38, 0.42), false)
			_box("Signboard", Vector3(x, height - 1.0, z + 4.58), Vector3(5.8, 0.8, 0.16), Color(0.92, 0.72, 0.22), false)
			_add_tree(Vector3(float(side) * (21.0 + float(i % 3) * 2.0), 0, z - 3.0))
	# A distant landmark-like silhouette and pond to give the starter map local character.
	_box("Palace district silhouette", Vector3(-3, 3.2, -115), Vector3(20, 6.4, 4), Color(0.78, 0.73, 0.59), true)
	_box("Pond", Vector3(30, -0.08, -67), Vector3(24, 0.18, 31), Color(0.09, 0.32, 0.36), false)
	for z in [-8.0, -22.0, -38.0, -55.0, -74.0, -91.0]:
		_box("Cross street", Vector3(0, 0.015, z), Vector3(90, 0.12, 6), Color(0.12, 0.14, 0.14), true)
	# Mission destination marker.
	var marker := MeshInstance3D.new()
	var marker_mesh := CylinderMesh.new()
	marker_mesh.top_radius = 2.2
	marker_mesh.bottom_radius = 2.2
	marker_mesh.height = 0.08
	marker.mesh = marker_mesh
	marker.position = objective_position + Vector3.UP * 0.16
	var marker_mat := StandardMaterial3D.new()
	marker_mat.albedo_color = Color(0.95, 0.58, 0.08, 0.72)
	marker_mat.emission_enabled = true
	marker_mat.emission = Color(0.95, 0.3, 0.02)
	marker.material_override = marker_mat
	add_child(marker)

func _add_tree(pos: Vector3) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 3.0
	trunk.mesh = trunk_mesh
	trunk.position = pos + Vector3.UP * 1.5
	trunk.material_override = _material(Color(0.28, 0.17, 0.09), 0.95)
	add_child(trunk)
	var crown := MeshInstance3D.new()
	var crown_mesh := SphereMesh.new()
	crown_mesh.radius = 1.65
	crown_mesh.height = 3.2
	crown.mesh = crown_mesh
	crown.position = pos + Vector3.UP * 3.8
	crown.material_override = _material(Color(0.12, 0.32, 0.17), 0.92)
	add_child(crown)

func _box(label: String, pos: Vector3, dimensions: Vector3, color: Color, solid: bool) -> void:
	var body: StaticBody3D = StaticBody3D.new() if solid else StaticBody3D.new()
	body.name = label
	body.position = pos
	var mesh_node := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	mesh_node.mesh = mesh
	mesh_node.material_override = _material(color, 0.76)
	body.add_child(mesh_node)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = dimensions
		collision.shape = shape
		body.add_child(collision)
	add_child(body)

func _material(color: Color, roughness: float = 0.7) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat

func _build_player() -> void:
	player = PlayerScript.new()
	player.name = "Player"
	player.position = Vector3(-2.5, 0.15, 7)
	add_child(player)

func _build_vehicles() -> void:
	for i in range(4):
		var vehicle: BharatVehicle = VehicleScript.new()
		vehicle.name = "Parked Car %d" % (i + 1)
		vehicle.position = Vector3(3.0 if i % 2 == 0 else -3.0, 0.0, -float(i) * 25.0 - 1.0)
		vehicle.rotation.y = PI if i % 2 == 0 else 0.0
		vehicle.max_speed = 26.0 + float(i) * 1.5
		add_child(vehicle)
		vehicles.append(vehicle)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "GameHUD"
	add_child(layer)
	var top := Label.new()
	top.text = "BHARAT  /  AGARTALA, TRIPURA"
	top.position = Vector2(28, 22)
	top.add_theme_font_size_override("font_size", 20)
	top.add_theme_color_override("font_color", Color(0.95, 0.9, 0.72))
	layer.add_child(top)

	wanted_label = Label.new()
	wanted_label.text = "WANTED  ☆ ☆ ☆ ☆ ☆"
	wanted_label.position = Vector2(1160, 26)
	wanted_label.size = Vector2(400, 54)
	wanted_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	wanted_label.add_theme_font_size_override("font_size", 26)
	wanted_label.add_theme_color_override("font_color", Color(0.98, 0.83, 0.45))
	layer.add_child(wanted_label)

	objective_label = Label.new()
	objective_label.text = "MISSION 01  |  FIRST DAY IN AGARTALA\nReach the golden marker"
	objective_label.position = Vector2(28, 75)
	objective_label.size = Vector2(510, 65)
	objective_label.add_theme_font_size_override("font_size", 18)
	objective_label.add_theme_color_override("font_color", Color(1, 1, 1))
	layer.add_child(objective_label)

	speed_label = Label.new()
	speed_label.position = Vector2(1160, 82)
	speed_label.size = Vector2(400, 35)
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	speed_label.add_theme_font_size_override("font_size", 18)
	speed_label.add_theme_color_override("font_color", Color(0.65, 0.91, 0.98))
	layer.add_child(speed_label)

	minimap = MinimapScript.new()
	minimap.position = Vector2(28, 670)
	minimap.size = Vector2(190, 190)
	layer.add_child(minimap)

	var controls := Label.new()
	controls.text = "WASD Move / Drive   F Enter-Car / Exit   SPACE Handbrake / Jump   E Horn   V Camera"
	controls.position = Vector2(245, 850)
	controls.size = Vector2(1120, 28)
	controls.add_theme_font_size_override("font_size", 14)
	controls.add_theme_color_override("font_color", Color(0.87, 0.9, 0.89))
	layer.add_child(controls)

	wanted = WantedScript.new()
	wanted.name = "WantedSystem"
	add_child(wanted)
	wanted.wanted_changed.connect(_on_wanted_changed)
	_on_wanted_changed(0)

func _build_intro() -> void:
	intro_layer = Control.new()
	intro_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	var bg := ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.015, 0.025, 0.035, 0.96)
	intro_layer.add_child(bg)
	var title := Label.new()
	title.text = "BHARAT\nCITY OF THREE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	title.position = Vector2(-360, -170)
	title.size = Vector2(720, 250)
	title.add_theme_font_size_override("font_size", 52)
	title.add_theme_color_override("font_color", Color(0.95, 0.76, 0.35))
	intro_layer.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "AGARTALA, TRIPURA  •  A GAME BY ANI STUDIO"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	subtitle.position = Vector2(-360, 55)
	subtitle.size = Vector2(720, 45)
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.84, 0.88, 0.9))
	intro_layer.add_child(subtitle)
	var button := Button.new()
	button.text = "START STORY"
	button.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	button.position = Vector2(-130, 125)
	button.size = Vector2(260, 58)
	button.add_theme_font_size_override("font_size", 22)
	button.pressed.connect(_start_story)
	intro_layer.add_child(button)
	add_child(intro_layer)

func _start_story() -> void:
	mission_started = true
	intro_layer.queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_wanted_changed(level: int) -> void:
	if not is_instance_valid(wanted_label):
		return
	var stars := ""
	for i in range(5):
		stars += "★ " if i < level else "☆ "
	wanted_label.text = "WANTED  " + stars
	wanted_label.add_theme_color_override("font_color", Color(1.0, 0.28, 0.18) if level >= 4 else Color(0.98, 0.83, 0.45))

func _process(delta: float) -> void:
	if not mission_started:
		return
	if mission_finished:
		finish_timer -= delta
		if finish_timer <= 0:
			_show_next_mission()
		return
	if Input.is_action_just_pressed("interact"):
		if player.active_vehicle:
			player.active_vehicle.exit_vehicle()
			player.active_vehicle = null
		else:
			var nearest := _nearest_vehicle()
			if nearest and player.global_position.distance_to(nearest.global_position) < 4.5:
				nearest.enter_vehicle(player, wanted)
				player.active_vehicle = nearest
	if Input.is_action_just_pressed("camera_toggle"):
		if player.active_vehicle:
			player.camera.position.z = -6.8 if player.camera.position.z > 0 else 6.8
			player.camera.rotation.y = PI if player.camera.position.z < 0 else 0.0
		else:
			player.camera.position.z = 5.8 if player.camera.position.z < 0 else -5.8
			player.camera.rotation.y = PI if player.camera.position.z < 0 else 0.0
	if player.active_vehicle:
		player.global_position = player.active_vehicle.global_position + Vector3.UP * 0.3
		player.camera_pivot.global_position = player.active_vehicle.global_position + Vector3.UP * 1.5
		speed_label.text = "SPEED  %d KM/H" % player.active_vehicle.get_speed_kmh()
	else:
		speed_label.text = "ON FOOT"
		player.camera_pivot.position = Vector3(0, 1.5, 0)
	if minimap:
		minimap.player_position = player.global_position
		minimap.player_yaw = player.global_rotation.y
		minimap.wanted_level = wanted.level
	if player.global_position.distance_to(objective_position) < 4.0:
		_finish_mission()

func _nearest_vehicle() -> BharatVehicle:
	var best: BharatVehicle
	var best_dist := INF
	for vehicle in vehicles:
		var dist := player.global_position.distance_to(vehicle.global_position)
		if dist < best_dist:
			best_dist = dist
			best = vehicle
	return best

func _finish_mission() -> void:
	mission_finished = true
	finish_timer = 3.2
	end_layer = Control.new()
	end_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var black := ColorRect.new()
	black.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	black.color = Color.BLACK
	end_layer.add_child(black)
	var text := Label.new()
	text.text = "BHARAT: CITY OF THREE\n\nA GAME BY ANI STUDIO"
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	text.add_theme_font_size_override("font_size", 34)
	text.add_theme_color_override("font_color", Color(0.95, 0.78, 0.42))
	end_layer.add_child(text)
	get_tree().current_scene.add_child(end_layer)

func _show_next_mission() -> void:
	mission_index += 1
	mission_finished = false
	if is_instance_valid(end_layer):
		end_layer.queue_free()
	objective_position = Vector3(0, 0, -62.0 - float(mission_index - 1) * 10.0)
	objective_label.text = "MISSION %02d  |  AGARTALA STORIES\nReach the golden marker" % mission_index
