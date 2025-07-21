class_name InventoryManager extends Node

var item: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_item(item: Node2D):
	if item == null:
		item = item

func remove_item():
	if item != null and item is DroppableItem:
		item.drop()
	item = null

func get_item():
	return item
