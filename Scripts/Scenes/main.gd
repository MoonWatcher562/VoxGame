extends Node3D

#@onready var voxel_lod_terrain: VoxelLodTerrain = $VoxelLodTerrain
@onready var voxel_terrain: VoxelTerrain = $VoxelTerrain
@onready var builder: CharacterBody3D = $Builder

var key_pressed: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE) and not key_pressed:
		key_pressed = true
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.MOUSE_MODE_VISIBLE: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif not Input.is_key_pressed(KEY_ESCAPE):
		key_pressed = false
	
	if Input.is_key_pressed(KEY_KP_7):
		get_tree().quit()
	
	if Input.is_action_just_pressed("Erase"):
		builder.brush_sphere(voxel_terrain, VoxelTool.MODE_REMOVE, 10.0)
