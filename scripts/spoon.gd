class_name SpoonItem extends Weapon
@onready var hit_box = $HitBox
@onready var collision_shape_2d = $HitBox/CollisionShape2D
@onready var sprite_2d = $Sprite2D

@export var damage: float

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_box.damage = self.damage
	deactivate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func activate():
	collision_shape_2d.set_deferred("disabled", false)
	
func deactivate():
	collision_shape_2d.set_deferred("disabled", true)

func flip(flip_val: bool) -> void:
	sprite_2d.flip_h = flip_val
