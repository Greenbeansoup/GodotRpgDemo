class_name FiniteStateMachine extends Node

var state_dictionary: Dictionary
@export var current_state: String

# Called when the node enters the scene tree for the first time.
func _ready():
	state_dictionary = {}

func add_state(state: String, on_state_enter = null, on_state_exit = null):
	var state_machine_state := StateMachineState.new()
	state_machine_state.construct_new_state(state, on_state_enter, on_state_exit)
	state_dictionary.set(state, state_machine_state)
	
func change_state(new_state_key: String):
	var new_state: StateMachineState = state_dictionary.get(new_state_key)
	if new_state != null:
		var old_state: StateMachineState = state_dictionary.get(current_state)
		if old_state != null:
			old_state.exit()
		new_state.enter()
		current_state = new_state_key
		
func get_current_state() -> String:
	return current_state
