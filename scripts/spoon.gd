class_name SpoonItem extends Weapon
@onready var hit_box = $HitBox
@onready var collision_shape_2d = $HitBox/CollisionShape2D
@onready var sprite_2d = $Sprite2D
@onready var touch_collision = $TouchBox/TouchCollision

@export var damage: float

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_box.damage = self.damage
	deactivate()
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func activate():
	collision_shape_2d.set_deferred("disabled", false)
	
func deactivate():
	collision_shape_2d.set_deferred("disabled", true)

func flip(flip_val: bool) -> void:
	sprite_2d.flip_h = flip_val
	if flip_val && self.position.x >= 0 || !flip_val && self.position.x < 0:
			self.set_deferred("position", Vector2((self.position.x + 14) * -1,  self.position.y))

func set_touch_box_enabled(enabled: bool) -> void:
	touch_collision.set_deferred("disabled", !enabled)

func drop(call_back: Callable = set_touch_box_enabled.bind(true)) -> void:
	set_touch_box_enabled(false)
	super.drop(call_back)
