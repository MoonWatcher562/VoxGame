extends State
class_name FallState


func enter() -> void:
	player.play_animation("FallState")


func update(_delta) -> void:
	gravity(_delta)
	move_horiz()
	
	if Input.is_action_just_pressed("Jump") and player.jumps != player.max_jumps:
		state_machine.change_state("JumpState")
	
	elif player.is_on_floor():
		state_machine.change_state("IdleState")


func exit() -> void:
	pass
