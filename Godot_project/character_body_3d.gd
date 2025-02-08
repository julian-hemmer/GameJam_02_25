extends CharacterBody3D

@export var speed = 5.0
@export var jump_force = 5.0
@export var gravity = 9.8
@export var camera_sensitivity = 0.005

@onready var camera = $Camera3D
@onready var mesh = $MeshInstance3D  # Assure-toi que le MeshInstance3D est bien un enfant

var camera_rotation_x = 0.0
var camera_rotation_y = 0.0
var is_mouse_captured = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
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
