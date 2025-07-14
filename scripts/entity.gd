class_name Entity extends CharacterBody2D

@export var can_move: bool
var is_invulnerable: bool

func set_entity_position(entity_position: Vector2):
	position = entity_position
	
func set_entity_velocity(entity_velocity: Vector2):
	velocity = entity_velocity

func set_entity_can_move(entity_can_move: bool):
	can_move = entity_can_move

func damage_entity(_value: float):
	pass

func check_is_invulnerable() -> bool:
	return is_invulnerable
