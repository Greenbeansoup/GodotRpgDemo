class_name Slime extends Entity
@onready var trap_timer = $TrapTimer
@onready var animated_sprite_2d = $AnimatedSprite2D

@export var target: Node2D

var move_timer: Timer
var rng: RandomNumberGenerator
var current_direction: Vector2

var dead = false
const SPEED = 40
const IDLE_SPEED = 10
const AGGRO_RANGE = 100
const IDLE_MOVE_TIMEOUT = 1.0
# Called when the node enters the scene tree for the first time.
func _ready():
	can_move = true
	move_timer = Timer.new()
	move_timer.connect("timeout", _change_direction)
	move_timer.one_shot = true
	add_child(move_timer)
	rng = RandomNumberGenerator.new()
	move_timer.start(IDLE_MOVE_TIMEOUT + rng.randf())

func damage_entity(value: float):
	pass

func _physics_process(delta):
	if dead or !can_move:
		return
	
	var direction: Vector2
	var move_speed = IDLE_SPEED
	if target != null and target.global_position.distance_to(global_position) <= AGGRO_RANGE:
		direction = target.global_position - global_position
		move_speed = SPEED
	else:
		direction = current_direction
	
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.flip_h = true
	
	velocity = direction.normalized() * move_speed
	move_and_slide()

func get_random_direction() -> Vector2:
	if rng.randf() < 0.75:
		return Vector2.ZERO
	return Vector2.DOWN.rotated(rng.randf() * 2 * PI)
	
func _change_direction():
	current_direction = get_random_direction()
	move_timer.start(IDLE_MOVE_TIMEOUT + rng.randf())
