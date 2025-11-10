@tool
extends EditorPlugin



## Make sure to define vars / nodes in function
## Add Input actions to the _ready function


var action_pressed: bool = false


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_KP_0) and not action_pressed:
		action_pressed = true
		var fireball = $"../Fireball"
		match fireball.transparency:
			1.0: fireball.transparency = 0.0
			0.0: fireball.transparency = 1.0
	elif not Input.is_key_pressed(KEY_KP_0):
		action_pressed = false
	
	
	## Terrain
	var voxel_terrain: VoxelTerrain = $"../VoxelTerrain"
	var vt: VoxelTool = voxel_terrain.get_voxel_tool()
	if Input.is_key_pressed(KEY_KP_1) and not action_pressed:
		action_pressed = true
		
		var ray_hit: Dictionary = cast_ray(get_viewport().get_mouse_position())
		#vt.do_point()
	
	elif not Input.is_key_pressed(KEY_KP_0):
		action_pressed = true


func cast_ray(pos: Vector2 = Vector2.ZERO) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var center = pos

	# Determine screen center if no pos is provided
	if pos == Vector2.ZERO:
		var viewport_size = get_viewport().get_visible_rect().size
		center = viewport_size / 2

	# Determine which camera to use
	var cam: Camera3D = null
	if Engine.is_editor_hint():
		# Editor mode: get the editor's current 3D viewport camera
		var editor = get_editor_interface()  # Only works in EditorPlugin scripts
		if editor:
			cam = editor.get_editor_viewport().get_camera_3d()
		else:
			push_warning("Editor camera not found; using default camera fallback.")
	else:
		# Runtime: use a Camera3D in the scene (assumes this node has one assigned)
		pass
		#cam = camera  # replace with your Camera3D reference

	if not cam:
		push_error("No camera found for raycast.")
		return {"position": null, "normal": null}

	# Compute ray
	var from = cam.project_ray_origin(center)
	var to = from + cam.project_ray_normal(center) * 1000

	# Physics query
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)
	if result:
		return {"position": result.position, "normal": result.normal}
	return {"position": null, "normal": null}
