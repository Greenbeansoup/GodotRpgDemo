extends Node2D

@onready var animation_tree = $AnimationTree
@onready var player = $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func anim_idle():
	animation_tree.set("parameters/conditions/idle", true)
	animation_tree.set("parameters/conditions/run", false)
	animation_tree.set("parameters/conditions/taking_hit", false)
	animation_tree.set("parameters/conditions/dashing", false)
	
func anim_run():
	animation_tree.set("parameters/conditions/run", true)
	animation_tree.set("parameters/conditions/idle", false)
	animation_tree.set("parameters/conditions/taking_hit", false)
	animation_tree.set("parameters/conditions/dashing", false)

func anim_taking_hit():
	animation_tree.set("parameters/conditions/taking_hit", true)
	animation_tree.set("parameters/conditions/run", false)
	animation_tree.set("parameters/conditions/idle", false)

func anim_dashing():
	animation_tree.set("parameters/conditions/dashing", true)
	animation_tree.set("parameters/conditions/run", false)
	animation_tree.set("parameters/conditions/idle", false)

func anim_death():
	animation_tree.set("parameters/conditions/dead", true)
	
