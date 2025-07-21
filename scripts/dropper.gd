class_name Dropper extends Node2D
@onready var drop_container: DropContainer = $DropContainer


var drop_item: DroppableItem
var drop_timer: Timer
var drop_flag: bool
var impulse_velocity = Vector2(20, 20)

# Called when the node enters the scene tree for the first time.
func _ready():
	drop_timer = Timer.new()
	drop_timer.one_shot = true
	drop_timer.connect("timeout", _on_drop_timer_timeout)
	add_child(drop_timer)
	
	drop_container = DropContainer.new()
	add_child(drop_container)
	
	drop()

func _physics_process(delta):
	pass

func drop():
	drop_container.set_floor(30)
	drop_container.apply_impulse(Vector2(100.0, -100.0))

func set_drop(item: DroppableItem):
	drop_container.global_position = item.global_position
	drop_item = item
	item.reparent(drop_container)
	
func _on_drop_timer_timeout():
	drop_item.reparent(get_tree().current_scene)
	drop_item = null
