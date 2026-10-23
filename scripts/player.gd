extends CharacterBody3D
class_name BharatPlayer

@export var walk_speed := 6.2
@export var sprint_speed := 10.0
@export var jump_velocity := 5.2
var gravity := 19.6
var camera_pivot: Node3D
var camera: Camera3D
var active_vehicle: BharatVehicle
var mouse_sensitivity := 0.0022
var look_pitch := -0.16

func _ready() -> void:
	_make_character()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _make_character() -> void:
	var capsule_mesh := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.75
	capsule_mesh.mesh = capsule
	capsule_mesh.position.y = 0.92
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.67, 0.39, 0.23)
	capsule_mesh.material_override = skin
	add_child(capsule_mesh)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.8
	collision.shape = shape
	collision.position.y = 0.9
	add_child(collision)

	camera_pivot = Node3D.new()
	camera_pivot.position.y = 1.5
	add_child(camera_pivot)
	camera = Camera3D.new()
	camera.position = Vector3(0, 1.0, 5.8)
	camera.rotation.x = -0.12
	camera.current = true
	camera_pivot.add_child(camera)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		look_pitch = clampf(look_pitch - event.relative.y * mouse_sensitivity, -0.75, 0.45)
		camera_pivot.rotation.x = look_pitch
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var move_dir := (camera_pivot.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	move_dir.y = 0
	var speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
	if move_dir.length() > 0.01:
		velocity.x = move_toward(velocity.x, move_dir.x * speed, 25.0 * delta)
		velocity.z = move_toward(velocity.z, move_dir.z * speed, 25.0 * delta)
		rotation.y = lerp_angle(rotation.y, atan2(-move_dir.x, -move_dir.z), 8.0 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 25.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 25.0 * delta)
	move_and_slide()
