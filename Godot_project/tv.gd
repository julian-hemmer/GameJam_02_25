extends Node3D

@onready var video_player = $SubViewport/SubViewportContainer/VideoStreamPlayer
@onready var player = get_node("/root/main/player")  # Change ce chemin si nécessaire
@export var activation_distance = 5.0  # Distance à laquelle le joueur peut activer la TV

var tv_on = false  # Suivi de l'état de la TV

func _ready():
	video_player.stop()  # Assurez-toi que la vidéo est arrêtée au début

func _process(delta):
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Si le joueur est proche de la TV et appuie sur "F"
	if distance_to_player < activation_distance and Input.is_action_just_pressed("ui_f"):
		toggle_tv()
	
	# Modifie le volume du son en fonction de la distance du joueur
	adjust_audio_volume(distance_to_player)

# Fonction pour allumer/éteindre la TV
func toggle_tv():
	if tv_on:
		video_player.stop()  # Arrête la vidéo
	else:
		video_player.play()  # Lance la vidéo
	tv_on = !tv_on

# Fonction pour ajuster le volume du son en fonction de la distance
func adjust_audio_volume(distance: float):
	var max_distance = activation_distance
	var volume = clamp(1.0 - (distance / max_distance), 0.0, 1.0)
	video_player.volume_db = linear_to_db(volume)
