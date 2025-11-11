extends CharacterBody3D

# === CONFIG ===
@export var enabled: bool = false
@export var speed: float = 30.0
@export var mouse_sensitivity: float = 0.002
@export var joystick_sensitivity: float = 2.5

# === CAMERA ROTATION ===
var pitch: float = 0.0
var yaw: float = 0.0
const MIN_PITCH: float = deg_to_rad(-89)
const MAX_PITCH: float = deg_to_rad(89)

@onready var camera: Camera3D = $Camera3D

# === INPUT HANDLING ===
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and enabled:
		yaw -= event.relative.x * mouse_sensitivity
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, MIN_PITCH, MAX_PITCH)

# === MOVEMENT + ROTATION ===
func _physics_process(delta: float) -> void:
	camera.current = enabled
	if not enabled:
		$UI.visible = false
		return
	
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_handle_camera_rotation(delta)

	# Movement input
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Horizontal movement
	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Vertical / fly movement
	if Input.is_action_pressed("Fly_Up"):
		velocity.y = speed
	elif Input.is_action_pressed("Fly_Down"):
		velocity.y = -speed
	else:
		velocity.y = move_toward(velocity.y, 0, speed)

	move_and_slide()

# === CAMERA ROTATION HELPERS ===
func _handle_camera_rotation(delta: float) -> void:
	var axis_x := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var axis_y := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	if abs(axis_x) > 0.1:
		yaw -= axis_x * joystick_sensitivity * delta
	if abs(axis_y) > 0.1:
		pitch = clamp(pitch - axis_y * joystick_sensitivity * delta, MIN_PITCH, MAX_PITCH)

	# Apply rotation
	rotation = Vector3(pitch, yaw, 0.0)

# === RAYCAST FROM CAMERA ===
func cast_ray(pos: Vector2 = Vector2.ZERO) -> Dictionary:
	var space_state := get_world_3d().direct_space_state
	var screen_pos := pos if pos != Vector2.ZERO else get_viewport().get_visible_rect().size / 2

	var from := camera.project_ray_origin(screen_pos)
	var to := from + camera.project_ray_normal(screen_pos) * 1000.0

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collision_mask = 1

	var result := space_state.intersect_ray(query)
	return result if result else {"position": null, "normal": null}

# === TERRAIN BRUSH ===
func brush_sphere(terrain: VoxelTerrain, mode: VoxelTool.Mode, radius: float) -> void:
	var ray_hit := cast_ray(get_viewport().get_mouse_position())
	if ray_hit.position == null:
		return

	var voxel_tool := terrain.get_voxel_tool()
	voxel_tool.mode = mode
	voxel_tool.do_sphere(ray_hit.position, radius)
