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
	var randomDirection = _get_random_direction()
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", global_position + randomDirection * 30, .5).set_trans(Tween.TRANS_EXPO)
	tween.tween_callback(call_back)
	
func _get_random_direction() -> Vector2:
	return Vector2.DOWN.rotated(self.rng.randf() * 2 * PI)
