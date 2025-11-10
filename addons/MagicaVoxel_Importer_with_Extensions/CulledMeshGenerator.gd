const Faces = preload("./Faces.gd")
const vox_to_godot = Basis(Vector3.RIGHT, Vector3.FORWARD, Vector3.UP)

func generate(vox, voxel_data, scale, snaptoground):
	var generator = VoxelMeshGenerator.new(vox, voxel_data, scale, snaptoground)
	return generator.generate_mesh()

# ================= Mesh Generator =================
class MeshGenerator:
	var surfaces = {}

	func ensure_surface_exists(surface_index: int, color: Color, material: Material):
		if surfaces.has(surface_index):
			return
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		st.set_color(color)
		st.set_material(material)
		surfaces[surface_index] = st

	func add_vertex(surface_index: int, vertex: Vector3, normal: Vector3):
		var st = surfaces[surface_index] as SurfaceTool
		st.set_normal(normal)
		st.add_vertex(vertex)

	func combine_surfaces():
		var mesh = ArrayMesh.new()
		for surface_index in surfaces:
			var surface = surfaces[surface_index] as SurfaceTool
			surface.index()
			# No generate_normals needed because normals are per-face
			mesh = surface.commit(mesh)
			var new_surface_index = mesh.get_surface_count() - 1
			mesh.surface_set_name(new_surface_index, str(surface_index))
		return mesh

# ================= Voxel Mesh Generator =================
class VoxelMeshGenerator:
	var vox
	var voxel_data = {}
	var scale: float
	var snaptoground: bool

	func _init(vox, voxel_data, scale, snaptoground):
		self.vox = vox
		self.voxel_data = voxel_data
		self.scale = scale
		self.snaptoground = snaptoground

	func get_material(voxel):
		var surface_index = voxel_data[voxel]
		return vox.materials[surface_index]

	func face_is_visible(voxel, face):
		if not voxel_data.has(voxel + face):
			return true
		var local_material = get_material(voxel)
		var adj_material = get_material(voxel + face)
		return adj_material.is_glass() and not local_material.is_glass()

	func generate_mesh():
		# Determine bounds
		var mins = Vector3(1e6, 1e6, 1e6)
		var maxs = Vector3(-1e6, -1e6, -1e6)
		for v in voxel_data:
			mins = mins.min(v)
			maxs = maxs.max(v)

		var yoffset = Vector3.ZERO
		if snaptoground:
			yoffset = Vector3(0, -mins.z * scale, 0)

		var gen = MeshGenerator.new()

		for voxel in voxel_data:
			var surface_index = voxel_data[voxel]
			var color = vox.colors[surface_index]
			var material = vox.materials[surface_index].get_material(color)
			gen.ensure_surface_exists(surface_index, color, material)

			# Define faces with normals
			var face_defs = []
			if face_is_visible(voxel, Vector3.UP): face_defs.append([Faces.Top, Vector3.UP])
			if face_is_visible(voxel, Vector3.DOWN): face_defs.append([Faces.Bottom, Vector3.DOWN])
			if face_is_visible(voxel, Vector3.LEFT): face_defs.append([Faces.Left, Vector3.LEFT])
			if face_is_visible(voxel, Vector3.RIGHT): face_defs.append([Faces.Right, Vector3.RIGHT])
			if face_is_visible(voxel, Vector3.BACK): face_defs.append([Faces.Front, Vector3.BACK])
			if face_is_visible(voxel, Vector3.FORWARD): face_defs.append([Faces.Back, Vector3.FORWARD])

			for face_data in face_defs:
				var verts = face_data[0]
				var normal = face_data[1]
				for vtx in verts:
					var vertex = yoffset + vox_to_godot * (vtx + voxel) * scale
					gen.add_vertex(surface_index, vertex, vox_to_godot * normal)

		return gen.combine_surfaces()
