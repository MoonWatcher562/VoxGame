extends State
class_name MoveState


func enter() -> void:
	player.play_animation("walk")


func update(_delta) -> void:
	move_horiz()
	
	if not player.is_on_floor():
		state_machine.change_state("FallState")
	
	elif Input.is_action_just_pressed("Jump"):
		state_machine.change_state("JumpState")
	
	elif dir() == Vector2.ZERO:
		state_machine.change_state("IdleState")


func exit() -> void:
	pass
