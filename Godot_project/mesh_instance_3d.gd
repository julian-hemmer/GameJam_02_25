extends MeshInstance3D

# Fonction pour appliquer une texture à un matériau unique
func apply_texture(new_texture: Texture):
	# Créer un matériau StandardMaterial3D pour appliquer la texture
	var material = StandardMaterial3D.new()
	material.albedo_texture = new_texture
	
	# Dupliquer le matériau pour qu'il soit unique à cet objet
	var unique_material = material.duplicate() as Material
	
	# Appliquer le matériau unique à la sphère (ou autre MeshInstance3D)
	material_override = unique_material

	# Afficher le chemin de la texture pour débogage
	print("Texture path: ", new_texture.resource_path)
