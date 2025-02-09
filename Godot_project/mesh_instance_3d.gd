extends MeshInstance3D

func _ready():
	# Ensure the MeshInstance has a valid mesh
	if mesh:
		var material_count = mesh.get_surface_count()
		for i in range(material_count):
			var material = mesh.surface_get_material(i)
			if material == null:
				material = StandardMaterial3D.new()
			material.albedo_texture = get_parent().texture
			mesh.surface_set_material(i, material)
