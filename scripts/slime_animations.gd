extends Sprite2D
@onready var animation_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func anim_asleepen():
	animation_tree.set("parameters/conditions/asleepen", true)
	animation_tree.set("parameters/conditions/awaken", false)
	
func anim_awaken():
	animation_tree.set("parameters/conditions/asleepen", false)
	animation_tree.set("parameters/conditions/awaken", true)
	
func anim_take_damage():
	animation_tree.set("parameters/conditions/take_damage", true)

func anim_take_damage_stop():
	animation_tree.set("parameters/conditions/take_damage", false)

func set_slime_texture(color: Slime.SLIME_TYPE):
	if color == Slime.SLIME_TYPE.GREEN:
		texture = load("res://assets/slime_green.png")
	elif color == Slime.SLIME_TYPE.PURPLE:
		texture = load("res://assets/slime_purple.png")
