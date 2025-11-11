extends State
class_name IdleState


func enter() -> void:
	player.play_animation("idle")
	player.jumps = 0


func update(_delta) -> void:
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	
	if not player.is_on_floor():
		state_machine.change_state("FallState")
	
	elif Input.is_action_just_pressed("Jump"):
		state_machine.change_state("JumpState")
	
	elif input_dir != Vector2.ZERO:
		state_machine.change_state("MoveState")


func exit() -> void:
	pass
