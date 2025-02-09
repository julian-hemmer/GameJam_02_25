extends CharacterBody3D

@export var speed = 5.0
@export var jump_force = 5.0
@export var gravity = 9.8
@export var camera_sensitivity = 0.005

@onready var camera = $Camera3D
@onready var mesh = $MeshInstance3D  # Assure-toi que le MeshInstance3D est bien un enfant

@export var no_anomaly_zone: MeshInstance3D
@export var has_anomaly_zone: MeshInstance3D

@export var anomaly_has_anomaly_zone_position: Vector3
@export var anomaly_no_anomaly_zone_position: Vector3
@export var anomaly_spawn_position: Vector3

@export var no_anomaly_has_anomaly_zone_position: Vector3
@export var no_anomaly_no_anomaly_zone_position: Vector3
@export var no_anomaly_spawn_position: Vector3

@export var message_label: Label

var is_in_anomaly: bool = false
var score = 0

var camera_rotation_x = 0.0
var camera_rotation_y = 0.0
var is_mouse_captured = true

func update_state():
	is_in_anomaly = randi() % 2 == 0
	if is_in_anomaly:
		print("Is in anomaly")
		global_transform.origin = anomaly_spawn_position
		no_anomaly_zone.global_transform.origin = anomaly_no_anomaly_zone_position
		has_anomaly_zone.global_transform.origin = anomaly_has_anomaly_zone_position
	else:
		print("Is not in anomaly")
		global_transform.origin = no_anomaly_spawn_position
		no_anomaly_zone.global_transform.origin = no_anomaly_no_anomaly_zone_position
		has_anomaly_zone.global_transform.origin = no_anomaly_has_anomaly_zone_position

func _ready():
	update_state()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	message_label.text = String("Score: {0}").format([score])
	message_label.visible = true
	# Gestion de la souris (ESC pour la libérer/capturer)
	if Input.is_action_just_pressed("ui_cancel"):
		is_mouse_captured = !is_mouse_captured
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if is_mouse_captured else Input.MOUSE_MODE_VISIBLE)
	
	# Appliquer la gravité
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Déplacement du joueur
	var direction = Vector3.ZERO
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x

	if Input.is_action_pressed("ui_up"):
		direction += forward
	if Input.is_action_pressed("ui_down"):
		direction -= forward
	if Input.is_action_pressed("ui_left"):
		direction -= right
	if Input.is_action_pressed("ui_right"):
		direction += right

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta)
		velocity.z = move_toward(velocity.z, 0, speed * delta)

	# Saut
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()

	# Appliquer la rotation caméra + Mesh
	_handle_camera_rotation(delta)
	
	if is_player_in_cylinder(no_anomaly_zone):
		if is_in_anomaly:
			score = 0
		else:
			score += 1
		update_state()
	if is_player_in_cylinder(has_anomaly_zone):
		if is_in_anomaly:
			score += 1
		else:
			score = 0
		update_state()
		return

func _handle_camera_rotation(delta):
	var mouse_movement = Input.get_last_mouse_velocity() * camera_sensitivity
	camera_rotation_x -= mouse_movement.y
	camera_rotation_y -= mouse_movement.x

	# Limiter la rotation en X (haut/bas)
	camera_rotation_x = clamp(camera_rotation_x, -90, 90)

	# Appliquer la rotation de la caméra
	camera.rotation_degrees.x = camera_rotation_x

	# Tourner le joueur (et donc le MeshInstance3D)
	rotation_degrees.y = camera_rotation_y
	
# Function to check if the player is inside the cylinder
func is_player_in_cylinder(cylinder_mesh: MeshInstance3D) -> bool:
	var player_pos = camera.global_transform.origin
	var cylinder_pos = cylinder_mesh.global_transform.origin
	var meshs: CylinderMesh = cylinder_mesh.mesh  # Use x scale to represent the radius (assuming uniform scaling)
	var radius = meshs.top_radius  # Use x scale to represent the radius (assuming uniform scaling)
	var distance = (player_pos.x - cylinder_pos.x) ** 2 + (player_pos.z - cylinder_pos.z) ** 2
	if distance <= radius * radius:
		return true
	return false
