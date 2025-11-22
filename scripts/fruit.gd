class_name FruitItem extends DroppableItem
@onready var fruit: Sprite2D = $"Fruit"
@onready var touch_box = $TouchBox
@onready var collision_shape_2d = $TouchBox/CollisionShape2D

func set_fruit(fruit_shape: Globals.Fruit_Shapes, fruit_color: Globals.Fruit_Colors):
	fruit.frame_coords = Vector2(fruit_shape, fruit_color)
	touch_box.entity_type = str(fruit_color)
	
	match fruit_shape:
		Globals.Fruit_Shapes.APPLE:
			touch_box.value = 40
		Globals.Fruit_Shapes.PEAR:
			touch_box.value = 20
		Globals.Fruit_Shapes.GRAPE:
			touch_box.value = 10

func drop() -> void:
	scale = Vector2(1.0, 1.0)
	
func _get_random_direction() -> Vector2:
	return Vector2.DOWN.rotated(rng.randf() * 2 * PI)
	
func set_touch_box_enabled(enabled: bool) -> void:
	collision_shape_2d.set_deferred("disabled", !enabled)
