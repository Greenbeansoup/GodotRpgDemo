class_name DroppableItem extends StaticBody2D

var rng: RandomNumberGenerator

# Called when the node enters the scene tree for the first time.
func _ready():
	self.rng = RandomNumberGenerator.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_touch_box_enabled(enabled: bool) -> void:
	print("Parent called, you probably didn't mean that")
	pass

func drop(call_back: Callable = func(): pass) -> void:
	pass
	
func _get_random_direction() -> Vector2:
	return Vector2.DOWN.rotated(self.rng.randf() * 2 * PI)
	
func activate():
	pass
	
func deactivate():
	pass
