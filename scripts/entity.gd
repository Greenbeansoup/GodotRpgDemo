class_name Entity extends CharacterBody2D

var can_move: bool
var is_invulnerable: bool

func set_entity_position(position: Vector2):
	self.position = position
	
func set_entity_velocity(velocity: Vector2):
	self.velocity = velocity

func set_entity_can_move(can_move: bool):
	self.can_move = can_move

func damage_entity(value: float):
	pass

func check_is_invulnerable() -> bool:
	return is_invulnerable
