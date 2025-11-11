extends CharacterBody3D
class_name Player


@onready var animation_player: AnimationPlayer = $AnimationPlayer

# === General ===
var speed: float = 5.0
var jump_height: float = 4.5

# === Jump ===
var jumps: int = 0
var max_jumps: int = 2

func _physics_process(_delta: float) -> void:
	move_and_slide()


func play_animation(animation: String) -> void:
	if $AnimationPlayer.get_animation_list().find(animation) != -1:
		$AnimationPlayer.play(animation)
