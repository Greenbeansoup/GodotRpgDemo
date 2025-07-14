extends Node2D

@onready var green_pear = $GreenPear
@onready var red_apple = $RedApple
@onready var player: Player = $Player



enum Fruit_Shapes { APPLE = 0, PEAR = 1, GRAPE = 2}
enum Fruit_Colors { GREEN = 0, RED = 3}

# Called when the node enters the scene tree for the first time.
func _ready():
	green_pear.set_fruit(Fruit_Shapes.PEAR, Fruit_Colors.GREEN)
	red_apple.set_fruit(Fruit_Shapes.APPLE, Fruit_Colors.RED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player.player_state_machine.current_state == "DEAD":
		get_tree().reload_current_scene()
