class_name DroppableItem extends StaticBody2D

var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_touch_box_enabled(enabled: bool) -> void:
	pass

func drop() -> void:
	pass
