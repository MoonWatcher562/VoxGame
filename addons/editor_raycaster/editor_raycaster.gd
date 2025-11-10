@tool
extends EditorPlugin

var button: Button

func _enter_tree():
	button = Button.new()
	button.text = "Raycast"
	button.pressed.connect(_on_raycast_pressed)
	add_control_to_container(CONTAINER_TOOLBAR, button)
	print("Editor Raycaster loaded")

func _exit_tree():
	remove_control_from_container(CONTAINER_TOOLBAR, button)
	button.queue_free()
	print("Editor Raycaster unloaded")

func _on_raycast_pressed():
	var editor_if = get_editor_interface()
	var viewport = editor_if.get_editor_viewport_3d()
	if not viewport:
		printerr("No 3D editor viewport found!")
		return

	var camera = viewport.get_camera_3d()
	if not camera:
		printerr("No editor camera found!")
		return

	var mouse_pos = viewport.get_mouse_position()

	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000.0

	# ✅ Godot 4.5 way to get the root of the edited scene
	var edited_scene = editor_if.get_edited_scene_root()
	if not edited_scene:
		printerr("No edited scene root found!")
		return

	var space_state = edited_scene.get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		print("✅ Hit at:", result.position, " | Collider:", result.collider)
	else:
		print("❌ No hit detected.")
