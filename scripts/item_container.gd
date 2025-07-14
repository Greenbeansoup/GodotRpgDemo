class_name ItemContainer extends Node2D

var amplitude = .2  # Adjust as needed
var speed = 2.0    # Adjust as needed
var time = 0.0
var start_position: Vector2

func _process(delta):
	time += delta
	position.y = start_position.y + sin(time * speed) * amplitude

func _ready():
	start_position = position

func set_item_position(new_position: Vector2):
	start_position.y = new_position.y
	position.x = new_position.x
