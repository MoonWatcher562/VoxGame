extends Node
class_name State


@onready var state_machine: StateMachine = $".."
@onready var player: Player = $"../.."
var state_name: String

func enter() -> void:
	pass


func update(_delta) -> void:
	pass


func exit() -> void:
	pass


func gravity(delta: float) -> void:
	player.velocity += player.get_gravity() * delta
	player.move_and_slide()

func dir() -> Vector2:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	return input_dir

func move_horiz() -> void:
	var input_dir = dir()
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * player.speed
		player.velocity.z = direction.z * player.speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.speed)
	player.move_and_slide()
