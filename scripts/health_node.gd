class_name HealthNode extends Node2D

signal health_depleted
signal health_changed(old_value, new_value)

@export var health: float
@export var max_health: float
@export var health_bar: HealthBar

func _ready():
	if health_bar != null:
		health_bar.value = health
		health_bar.max_value = max_health

func take_damage(damage: float):
	var oldHealth = health
	if health < damage:
		health = 0
	else:
		health -= damage
	
	if health <= 0:
		health_depleted.emit()
	_update_health_bar()
	health_changed.emit(oldHealth, health)
	
func heal(points: float):
	var oldHealth = health
	if health > max_health + points:
		health = max_health
	else:
		health += points
	_update_health_bar()
	health_changed.emit(oldHealth, health)
	
func _update_health_bar():
	if health_bar != null:
		health_bar.value = health
