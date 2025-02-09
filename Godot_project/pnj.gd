extends RigidBody3D

@export var texture: Texture  # Texture unique pour ce NPC

# Define the two positions between which the NPC should move
@export var target_position_1 : Vector3
@export var target_position_2 : Vector3

# The time to move between the two positions (in seconds)
@export var time_to_move : float = 3.0

# Current target position
var target_position : Vector3

@export var camera: Camera3D
@export var interaction_distance: float = 5.0

@export var death_sound: AudioStream
@export var death_message: String = "JE MEURT"
var death_audio_player: AudioStreamPlayer

@export var interaction_sound: Array[AudioStream]
@export var interaction_message: Array[String]
var interaction_audio_player: AudioStreamPlayer

@export var message_label: Label
var message_timer: Timer
var is_near_npc = false

func _ready():
	interaction_audio_player = AudioStreamPlayer.new()
	add_child(interaction_audio_player)
	
	death_audio_player = AudioStreamPlayer.new()
	add_child(death_audio_player)
	death_audio_player.stream = death_sound
	
	# Initialize the positions
	global_transform.origin = target_position_1
	target_position = target_position_2

	# Initialize the message timer
	message_timer = Timer.new()
	add_child(message_timer)
	message_timer.connect("timeout", _on_message_timeout)
	message_timer.start(5.0)
	message_label.visible = false
	
	# Appliquer la texture unique au MeshInstance3D enfant
	var mesh_instance = $MeshInstance3D
	if mesh_instance:
		mesh_instance.apply_texture(texture)

func is_after(start_position, end_position, direction):
	var normalized_direction = direction.normalized()
	var delta = start_position - end_position
	delta.y = 0
	normalized_direction.y = 0
	return delta.dot(normalized_direction) > 0

func get_other():
	# If current target position is 1, return 2, otherwise return 1
	if target_position == target_position_1:
		return target_position_2
	else:
		return target_position_1

func _process(delta):
	# Calculate direction towards the target position
	var direction = target_position - global_transform.origin
	direction = direction.normalized()  # Normalize to get a unit vector

	# Check if the NPC has reached the current target
	if global_transform.origin.distance_to(target_position) <= 1:  # Small tolerance to switch
		# Switch to the other target position
		target_position = get_other()

	# Move the NPC toward the target position based on time_to_move
	move_toward_target(delta)
	if camera:
		look_at(camera.global_transform.origin, Vector3.UP)

	# Check if the player is near enough to interact with the NPC
	check_for_interaction()

func move_toward_target(delta):
	# Calculate the distance to the target
	var collision_shape = $CollisionShape3D
	if (collision_shape.disabled):
		global_transform.origin.y += -2 * delta
		return
	var distance = get_other().distance_to(target_position)

	# Calculate how much time it will take to reach the target
	var velocity = distance / time_to_move  # Units per second

	# Calculate the direction to the target
	var direction = target_position - global_transform.origin
	direction = direction.normalized()  # Normalize to get a unit vector

	# Calculate the velocity vector to move towards the target
	var velocity_vector = direction * velocity * delta

	# Move the NPC towards the target position
	move_and_collide(velocity_vector)

func check_for_interaction():
	# Get the player's position (assuming the player is a Camera3D for this example)
	var player_position = camera.global_transform.origin

	# Check if the player is within the interaction distance
	if global_transform.origin.distance_to(player_position) <= interaction_distance:
		is_near_npc = true

		# If the player presses Enter while near the NPC, show the message
		if Input.is_key_pressed(KEY_K):  # Default "ui_accept" is Enter or E
			show_message(death_message)
			var collision_shape = $CollisionShape3D
			collision_shape.disabled = true
			death_audio_player.play()
		if Input.is_action_just_pressed("ui_f"):  # Default "ui_accept" is Enter or E
			var random_index = randi() % interaction_message.size()
			show_message(interaction_message[random_index])
			var audio_player = AudioStreamPlayer.new()
			add_child(audio_player)  # Add the player to the scene tree
			audio_player.stream = interaction_sound[random_index]
			audio_player.play()
			audio_player.connect("finished", _on_audio_finished.bind(audio_player))
	else:
		is_near_npc = false

func show_message(message: String):
	# Display the message on the screen
	message_label.text = message
	message_label.visible = true
	message_timer.start(5.0)  # Start timer to hide the message after 5 seconds

func _on_message_timeout():
	# Hide the message after 5 seconds
	message_label.visible = false
	
# Signal handler that frees the AudioStreamPlayer after the sound finishes
func _on_audio_finished(audio_player: AudioStreamPlayer):
	# Free the AudioStreamPlayer when the sound finishes
	audio_player.queue_free()
