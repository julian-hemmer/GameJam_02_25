extends Node3D

@onready var video_player = $SubViewport/VideoStreamPlayer
@onready var plane_mesh_instance = $MeshInstance3D
@onready var plane_mesh: PlaneMesh = null
@onready var sub_viewport = $SubViewport

# Taille de la TV modifiable dans l'éditeur
@export var tv_size: Vector2 = Vector2(2.0, 1.0) :
	set(value):
		tv_size = value
		update_tv_size()

# Chemin de la vidéo modifiable dans l'éditeur
@export var video_path: String = "" :  
	set(value):
		video_path = value
		update_video()

# Option pour tester la vidéo directement depuis l'éditeur
@export var preview_video: bool = false :  
	set(value):
		preview_video = value
		if value:
			video_player.play()
		else:
			video_player.stop()

func _ready():
	update_tv_size()
	update_video()

func update_tv_size():
	if plane_mesh_instance and plane_mesh_instance.mesh is PlaneMesh:
		plane_mesh = plane_mesh_instance.mesh as PlaneMesh
		plane_mesh.size = tv_size  # Change la taille de l'écran

		# Ajuste la taille du SubViewport pour correspondre
		sub_viewport.size = Vector2i(tv_size.x * 100, tv_size.y * 100)

		# Met à jour la texture sur le MeshInstance3D
		var viewport_texture = sub_viewport.get_texture()
		var material = StandardMaterial3D.new()
		material.albedo_texture = viewport_texture
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  # Désactive les ombres
		plane_mesh_instance.set_surface_override_material(0, material)
	else:
		print("Erreur : Le MeshInstance3D ne contient pas un PlaneMesh valide !")


func update_video():
	if not video_player:
		print("Erreur : VideoStreamPlayer est introuvable !")
		return

	if video_path.is_empty():
		print("Aucune vidéo spécifiée.")
		return

	var stream = VideoStreamTheora.new()
	var error = stream.load(video_path)
	
	if error != OK:
		print("Erreur lors du chargement de la vidéo :", video_path)
		return

	video_player.stream = stream
	video_player.play()
