class_name Weapon extends DroppableItem

@export var attack_time: float

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func flip(flip_val: bool) -> void:
	pass

func get_attack_time():
	return attack_time
