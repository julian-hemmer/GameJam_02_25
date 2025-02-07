extends CharacterBody3D

@export var speed = 5.0
@export var jump_force = 4.0
@export var gravity = 9.8
@export var camera_sensitivity = 0.005
@onready var camera = $Camera3D

var camera_rotation_x = 0.0
var camera_rotation_y = 0.0
var is_mouse_captured = true

func _ready():
	# Capturer la souris au départ
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# S'assurer que la caméra est attachée au joueur
	camera = $Camera3D

func _physics_process(delta):
	# Vérifier si la touche ESCAPE est pressée pour basculer le mode de la souris
	if Input.is_action_just_pressed("ui_cancel"):  # Par défaut, ESCAPE est lié à "ui_cancel"
		if is_mouse_captured:
			# Libérer la souris
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			# Capturer la souris à nouveau
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		is_mouse_captured = !is_mouse_captured
	
	# Appliquer la gravité
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Récupérer les inputs de déplacement
	var direction = Vector3.ZERO
	
	# Récupérer les mouvements de la caméra
	var forward = -camera.global_transform.basis.z # direction avant de la caméra
	var right = camera.global_transform.basis.x # direction droite de la caméra

	# Appliquer les entrées utilisateur selon la direction de la caméra
	if Input.is_action_pressed("ui_up"):  # W ou Z
		direction += forward
	if Input.is_action_pressed("ui_down"):  # S ou S
		direction -= forward
	if Input.is_action_pressed("ui_left"):  # A ou Q
		direction -= right
	if Input.is_action_pressed("ui_right"):  # D
		direction += right

	# Normaliser la direction et appliquer le mouvement
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

	# Gérer le mouvement de la caméra
	_handle_camera_rotation(delta)

# Fonction pour gérer la rotation de la caméra
func _handle_camera_rotation(delta):
	# Récupérer les mouvements de la souris ou des entrées pour la rotation
	var mouse_movement = Input.get_last_mouse_velocity() * camera_sensitivity
	camera_rotation_x -= mouse_movement.y
	camera_rotation_y -= mouse_movement.x

	# Limiter l'angle de la caméra pour ne pas la faire tourner de manière trop extrême
	camera_rotation_x = clamp(camera_rotation_x, -90, 90)

	# Appliquer la rotation à la caméra
	camera.rotation_degrees.x = camera_rotation_x
	camera.rotation_degrees.y = camera_rotation_y
