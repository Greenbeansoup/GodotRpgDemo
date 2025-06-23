class_name StateMachineState extends Node

var state: String

# Please godot give me union types
var on_state_enter #: Callable | null
var on_state_exit

func construct_new_state(state: String, on_state_enter = null, on_state_exit = null):
	self.state = state
	self.on_state_enter = on_state_enter
	self.on_state_exit = on_state_exit

func exit():
	if on_state_exit != null:
		on_state_exit.call()
	
func enter():
	if on_state_enter != null:
		on_state_enter.call()
