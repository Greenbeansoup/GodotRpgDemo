extends Sprite2D
@onready var fruit: Sprite2D = $"."
@onready var touch_box = $TouchBox

func set_fruit(fruit_shape: Globals.Fruit_Shapes, fruit_color: Globals.Fruit_Colors):
	fruit.frame_coords = Vector2(fruit_shape, fruit_color)
	touch_box.entity_name = fruit_color
	
	match fruit_shape:
		Globals.Fruit_Shapes.APPLE:
			touch_box.value = 40
		Globals.Fruit_Shapes.PEAR:
			touch_box.value = 20
		Globals.Fruit_Shapes.GRAPE:
			touch_box.value = 10

func _on_touch_box_entered(body):
	if body.is_in_group("Player"):
		fruit.queue_free()
