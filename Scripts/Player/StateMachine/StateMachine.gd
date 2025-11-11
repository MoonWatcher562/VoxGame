extends Node
class_name StateMachine


var current_state_i: int = 0
var current_state: State

func _ready() -> void:
	current_state = $IdleState
	current_state.enter()


func _process(_delta: float) -> void:
	current_state.update(_delta)


func change_state(state: NodePath) -> void:
	current_state.exit()
	current_state = get_node(state)
	current_state.enter()
	print(current_state)
