extends State
class_name JumpState


func enter() -> void:
	player.velocity.y = player.jump_height
	player.play_animation("jump")
	player.jumps += 1


func update(_delta) -> void:
	move_horiz()
	gravity(_delta)
	
	if player.velocity.y < 0:
		state_machine.change_state("FallState")
	
	elif player.is_on_floor():
		state_machine.change_state("IdleState")
	
	elif Input.is_action_just_pressed("Jump"):
		state_machine.change_state("JumpState")


func exit() -> void:
	pass
