extends CharacterBody3D


@export var speed: float = 30.0
@export var mouse_sensitivity: float = 0.002
@export var joystick_sensitivity: float = 2.5

var pitch: float = 0.0
var yaw: float = 0.0
var min_pitch: float = deg_to_rad(-89)
var max_pitch: float = deg_to_rad(89)

@onready var camera: Camera3D = $Camera3D


func _unhandled_input(event):

	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)


func _physics_process(delta: float) -> void:

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var axis_x = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		var axis_y = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

		if abs(axis_x) > 0.1:
			yaw -= axis_x * joystick_sensitivity * delta
		if abs(axis_y) > 0.1:
			pitch -= axis_y * joystick_sensitivity * delta
			pitch = clamp(pitch, min_pitch, max_pitch)

		# Apply rotation
		rotation = Vector3(pitch, yaw, 0)
	
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed

	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if Input.is_action_pressed("Fly_Up"):
		velocity.y = speed
	elif Input.is_action_pressed("Fly_Down"):
		velocity.y = -speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()


func cast_ray(pos: Vector2 = Vector2(0.0, 0.0)) -> Dictionary:
	var space_state = get_world_3d().direct_space_state
	var center
	
	if pos == Vector2(0.0, 0.0):
		# Find center of screen
		var viewport_size = get_viewport().get_visible_rect().size
		center = viewport_size / 2
	else:
		center = pos

	# Update casting positions
	var from = camera.project_ray_origin(center)
	var to = from + camera.project_ray_normal(center) * 1000

	# Make query
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1

	# Cast ray
	var result = space_state.intersect_ray(query)

	if result:
		return {"position": result.position, "normal": result.normal}
	else:
		return {"position": null, "normal": null}


func brush_sphere(terrain: VoxelTerrain, mode: VoxelTool.Mode, radius: float) -> void:
	
	var mesher: VoxelMesherTransvoxel = terrain.mesher
	var voxel_tool: VoxelTool = terrain.get_voxel_tool()
	
	var ray_hit: Dictionary = cast_ray(get_viewport().get_mouse_position())
	
	if ray_hit.position == null:
		return
	
	voxel_tool.mode = mode
	voxel_tool.do_sphere(ray_hit.position, radius)
