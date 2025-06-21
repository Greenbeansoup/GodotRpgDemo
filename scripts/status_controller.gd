class_name StatusController extends Node2D

signal status_changed(old_value, new_value)

@export var value: float
@export var max_value: float
@export var min_value: float
@export var status_bar: ProgressBar

func _ready():
	if status_bar != null:
		status_bar.value = value
		status_bar.max_value = max_value

func decrement_value(decrement_value: float):
	change_value(-decrement_value)
	
func increment_value(increment_value: float):
	change_value(increment_value)
	
func change_value(input: float):
	var oldValue = value
	if value + input > max_value:
		value = max_value
	elif value + input < min_value:
		value = min_value
	else:
		value += input
	_update_status_bar()
	status_changed.emit(oldValue, value)

func get_value():
	return value
	
func _update_status_bar():
	if status_bar != null:
		status_bar.value = value
