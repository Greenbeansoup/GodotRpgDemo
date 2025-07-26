class_name Dropper extends Node2D
@onready var drop_container: DropContainer = $DropContainer

@export var drop_item: DroppableItem

var drop_timer: Timer
var drop_flag: bool
var impulse_velocity = Vector2(20, 20)
var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	drop_timer = Timer.new()
	drop_timer.one_shot = true
	drop_timer.connect("timeout", _on_drop_timer_timeout)
	add_child(drop_timer)
	
	rng = RandomNumberGenerator.new()
	
	if drop_item != null:
		set_drop(drop_item)

func _physics_process(delta):
	pass

func drop(direction: int = 0):
	if drop_item:
		drop_item.deactivate()
	drop_container.reparent(get_tree().current_scene)
	drop_container.call_deferred("apply_impulse", _get_random_direction(direction).normalized() * rng.randf_range(100, 250))
	drop_timer.start(0.5)

func set_drop(item: DroppableItem):
	drop_container.global_position = item.global_position
	drop_item = item
	drop_item.call_deferred("reparent", drop_container)
	
func _on_drop_timer_timeout():
	if drop_item:
		drop_item.reparent(get_tree().current_scene)
		drop_item.set_touch_box_enabled(true)
		drop_item = null

func _get_random_direction(direction) -> Vector2:
	rng.randomize()
	var angle: float
	if direction == 0:
		angle = rng.randf_range(-PI, 0.0) # Top half of unit circle
	# Bottom right 0,PI/2
	# Bottom left PI/2,PI
	# Top left -PI,-PI/2
	# Top Right -PI/2,0
	if direction == 1:
		angle = rng.randf_range(-PI/2.0, 0.0)
	elif direction == -1:
		angle = rng.randf_range(-PI, -PI/2.0)
	return Vector2.RIGHT.rotated(angle)

	
