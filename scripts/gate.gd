extends StaticBody2D
@onready var animation_player = $AnimationPlayer
@onready var detection_box = $DetectionBox

@export var key_id: String

# Called when the node enters the scene tree for the first time.
func _ready():
	detection_box.connect("body_entered", _on_detection_box_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_detection_box_body_entered(body):
	if body is Player:
		var player = body as Player
		if player.inventory_item != null and player.inventory_item is KeyItem:
			var key_item = player.inventory_item as KeyItem
			if key_item.key_id == key_id:
				animation_player.play("open")
				player.remove_item_from_inventory(key_item)
	pass
