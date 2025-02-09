extends MeshInstance3D

@export var video_stream: VideoStream          # Vidéo assignable dans l'inspecteur
@export var screen_size: Vector2 = Vector2(2.0, 1.0)  # Taille de l'écran pour cette instance
@export var video_size: Vector2 = Vector2(1920.0, 1080.0)  # Taille de la vidéo (résolution)
@export var activation_distance: float = 5.0      # Distance d’activation

@onready var subviewport: SubViewport = $SubViewport
@onready var subviewport_container: SubViewportContainer = $SubViewport/SubViewportContainer
@onready var video_player: VideoStreamPlayer = $SubViewport/SubViewportContainer/VideoStreamPlayer
@onready var player: Node3D = get_node("/root/main/player")  # Change ce chemin si nécessaire

var tv_on: bool = false

func _ready():
	# Appliquer la vidéo au VideoStreamPlayer
	if video_stream:
		video_player.stream = video_stream
	
	# Pour éviter que le mesh soit partagé entre les instances,
	# dupliquer le Mesh s'il n'est pas déjà unique.
	update_mesh_size()
	
	# Ajuster la résolution du SubViewport en fonction de la taille désirée
	update_screen_size()
	update_texture()

	# Assurer que la TV démarre éteinte
	video_player.stop()

func _process(delta):
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Activation/désactivation de la TV avec "F"
	if distance_to_player < activation_distance and Input.is_action_just_pressed("ui_f"):
		toggle_tv()
	
	# Ajuster le volume audio en fonction de la distance
	adjust_audio_volume(distance_to_player)

func toggle_tv():
	if tv_on:
		video_player.stop()
	else:
		video_player.play()
	tv_on = !tv_on

func adjust_audio_volume(distance: float):
	var max_distance = activation_distance
	var volume = clamp(1.0 - (distance / max_distance), 0.0, 1.0)
	video_player.volume_db = linear_to_db(volume)

func update_mesh_size():
	# Vérifier que le mesh est un PlaneMesh
	if mesh is PlaneMesh:
		# Dupliquer le mesh pour que cette instance soit indépendante
		# (Cela évite que la modification de la taille affecte toutes les instances partageant la même ressource.)
		mesh = mesh.duplicate()  
		mesh.size = screen_size

func update_screen_size():
	# Calculer le ratio en fonction de screen_size et video_size
	var aspect_ratio = screen_size.x / screen_size.y
	var size_x = video_size.x * aspect_ratio
	var size_y = video_size.y
	subviewport.size = Vector2i(size_x, size_y)
	# Adapter le scale du SubViewportContainer pour correspondre exactement à la taille du PlaneMesh
	subviewport_container.set_scale(Vector2(screen_size.x, screen_size.y))

func update_texture():
	# Assigner la texture générée par le SubViewport à notre PlaneMesh
	var texture = subviewport.get_texture()
	if mesh is PlaneMesh and texture:
		var material = StandardMaterial3D.new()
		material.albedo_texture = texture                # Appliquer la texture générée par le SubViewport
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # Désactiver les ombres
		material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.no_depth_test = false                   # Important pour l'affichage correct
		material.albedo_color = Color(1, 1, 1)            # Éviter que l'image soit foncée
		material.roughness = 1.0                         # Éviter les reflets bizarres
		material.metallic = 0.0                          # Pas de réflexion métal
		material.flags_unshaded = true                   # Désactiver l'éclairage
		material.flags_transparent = false               # Pas besoin de transparence
		material.flags_no_depth_test = false             # Gérer correctement la profondeur
		material.flags_disable_receive_shadows = true    # Pas d'ombres projetées

		# Appliquer ce matériel à cette instance uniquement
		self.material_override = material
