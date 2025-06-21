extends Node2D

@onready var animation_tree = $"../AnimationTree"
@onready var player = $"../.."


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	var idle = !player.velocity
	
	animation_tree.set("parameters/conditions/idle", idle)
	animation_tree.set("parameters/conditions/run", !idle)
	
	pass
