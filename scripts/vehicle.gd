extends CharacterBody3D
class_name BharatVehicle

@export var vehicle_label: String = "Agartala City Car"
@export var max_speed: float = 27.0
@export var acceleration: float = 16.0
@export var braking: float = 28.0
@export var steering_rate: float = 1.45
var driver_active := false
var current_speed := 0.0
var player_ref: Node3D
var wanted_system: Node
var horn_time := 0.0
var last_collision_speed := 0.0

func _ready() -> void:
	add_to_group("vehicles")
	_make_vehicle()

func _make_vehicle() -> void:
	var body_mesh := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.0, 0.85, 4.0)
	body_mesh.mesh = mesh
	body_mesh.position.y = 0.8
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.08, 0.31, 0.48)
	mat.metallic = 0.42
	mat.roughness = 0.27
	body_mesh.material_override = mat
	add_child(body_mesh)

	var roof := MeshInstance3D.new()
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(1.7, 0.58, 1.8)
	roof.mesh = roof_mesh
	roof.position = Vector3(0, 1.48, -0.1)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.12, 0.2, 0.23, 0.82)
	glass.metallic = 0.15
	glass.roughness = 0.16
	roof.material_override = glass
	add_child(roof)

	for x in [-0.88, 0.88]:
		for z in [-1.25, 1.25]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.36
			wheel_mesh.bottom_radius = 0.36
			wheel_mesh.height = 0.22
			wheel.mesh = wheel_mesh
			wheel.rotation.z = PI / 2.0
			wheel.position = Vector3(x, 0.42, z)
			var rubber := StandardMaterial3D.new()
			rubber.albedo_color = Color(0.035, 0.04, 0.045)
			wheel.material_override = rubber
			add_child(wheel)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 1.4, 4.0)
	collision.shape = shape
	collision.position.y = 0.8
	add_child(collision)

func _physics_process(delta: float) -> void:
	if horn_time > 0.0:
		horn_time -= delta
	if not driver_active:
		velocity = Vector3.ZERO
		return

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steer := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if throttle > 0.0:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	elif throttle < 0.0:
		if current_speed > 1.0:
			current_speed = move_toward(current_speed, 0.0, braking * delta)
		else:
			current_speed = move_toward(current_speed, -max_speed * 0.32, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, acceleration * 0.3 * delta)

	if Input.is_action_pressed("handbrake"):
		current_speed = move_toward(current_speed, 0.0, braking * 1.4 * delta)

	var steering_factor := clampf(absf(current_speed) / 7.0, 0.0, 1.0)
	rotation.y -= steer * steering_rate * steering_factor * delta * signf(current_speed if absf(current_speed) > 0.1 else 1.0)
	var forward := -global_transform.basis.z
	velocity.x = forward.x * current_speed
	velocity.z = forward.z * current_speed
	velocity.y -= 22.0 * delta
	last_collision_speed = absf(current_speed)
	move_and_slide()

	if Input.is_action_just_pressed("horn") and horn_time <= 0.0:
		horn_time = 1.0
		print("HONK! Indian city traffic horn")

func enter_vehicle(player: Node3D, wanted: Node) -> void:
	driver_active = true
	player_ref = player
	wanted_system = wanted
	player.visible = false
	player.set_physics_process(false)
	if wanted_system:
		wanted_system.add_crime(1)

func exit_vehicle() -> void:
	if not driver_active:
		return
	driver_active = false
	current_speed = 0.0
	if is_instance_valid(player_ref):
		player_ref.global_position = global_position + global_transform.basis.x * 2.1 + Vector3.UP * 0.2
		player_ref.visible = true
		player_ref.set_physics_process(true)
	player_ref = null

func get_speed_kmh() -> int:
	return int(absf(current_speed) * 3.6)
