extends Node2D

@onready var player = $Player
@onready var red_apple = $Fruit
@onready var green_grapes = $Fruit2
@onready var red_pear = $Fruit3

enum Fruit_Shapes { APPLE = 0, PEAR = 1, GRAPE = 2}
enum Fruit_Colors { GREEN = 0, RED = 3}
# Called when the node enters the scene tree for the first time.
func _ready():
	green_grapes.set_fruit(Fruit_Shapes.GRAPE, Fruit_Colors.GREEN)
	red_apple.set_fruit(Fruit_Shapes.APPLE, Fruit_Colors.RED)
	red_pear.set_fruit(Fruit_Shapes.PEAR, Fruit_Colors.RED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
