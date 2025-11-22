class_name KeyItem extends DroppableItem
@onready var collision_shape_2d = $TouchBox/CollisionShape2D
@onready var touch_box = $TouchBox
@onready var key = $"."

@export var key_id: String

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_id() -> String:
	return key_id

func set_touch_box_enabled(enabled: bool) -> void:
	collision_shape_2d.set_deferred("disabled", !enabled)

func drop() -> void:
	scale = Vector2(.5, .5)
