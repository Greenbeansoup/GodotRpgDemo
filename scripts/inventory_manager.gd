class_name InventoryManager extends Node

var item: Node2D
var item_container: ItemContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(item_container: ItemContainer = ItemContainer.new(), item: Node2D = null):
	self.item_container = item_container
	item_container.reparent(self)
	item_container.top_level = true # tells item container to ignore parent position data
	add_item(item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_item(item: Node2D):
	if self.item == null and item != null:
		item.reparent(item_container)
		self.item = item
		self.item.global_position = item_container.global_position

func remove_item():
	var returnItem = item
	item = null
	return returnItem

func get_item():
	return item
