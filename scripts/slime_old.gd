class_name SlimeOld extends Entity
@onready var trap_timer = $TrapTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
@export var health_controller: StatusController
@export var target: Node2D
@export var can_sleep: bool = true
@export_enum("PURPLE:0", "GREEN:1") var slime_type: int
enum Slime_Type {
	PURPLE = 0,
	GREEN = 1
}

enum Slime_State {
	ASLEEP,
	IDLE,
	AWAKING,
	CHASE,
}

@export var slime_state: Slime_State

var move_timer: Timer
var sleep_timer: Timer
var rng: RandomNumberGenerator
var current_direction: Vector2

var health
var dead = false
const SPEED = 40
const IDLE_SPEED = 10
const AGGRO_RANGE = 100
const DE_AGGRO_RANGE = 150
const IDLE_MOVE_TIMEOUT = 1.0
const SLEEP_TIMEOUT = 5.0
# Called when the node enters the scene tree for the first time.
func _ready():
	_initialize(slime_type, slime_state, can_move)
	move_timer = Timer.new()
	move_timer.connect("timeout", _change_direction)
	move_timer.one_shot = true
	sleep_timer = Timer.new()
	sleep_timer.one_shot = true
	sleep_timer.connect("timeout", _sleep_timer_timeout)
	add_child(move_timer)
	add_child(sleep_timer)
	rng = RandomNumberGenerator.new()
	health_controller = StatusController.new()
	health_controller.max_value = 1
	health_controller.min_value = 0
	health_controller.connect("status_changed", _on_health_changed)
	animated_sprite_2d.connect("animation_finished", _on_animation_finished)
	
func _initialize(type: Slime_Type, state: Slime_State, can_move: bool):
	slime_state = state
	slime_type = type
	if type == Slime_Type.PURPLE:
		animated_sprite_2d.play("asleep_purple")
	else:
		animated_sprite_2d.play("asleep_green")
	self.can_move = can_move
	dead = false
	_animate(type, state)

func damage_entity(value: float):
	health_controller.decrement_value(value)

func _on_health_changed(oldValue, newValue):
	if newValue <= 0:
		dead = true

func _physics_process(delta):
	if !is_visible_in_tree():
		return
	if dead and slime_type == Slime_Type.PURPLE:
		_initialize(Slime_Type.GREEN, Slime_State.ASLEEP, true)
	elif !dead and !can_move:
		return
	#elif dead:
		# queue_free()
	
	var direction: Vector2
	var move_speed = IDLE_SPEED
	if slime_state != Slime_State.CHASE and target != null and target.global_position.distance_to(global_position) <= AGGRO_RANGE:
		if slime_state == Slime_State.ASLEEP:
			_awaken()
		elif slime_state == Slime_State.IDLE:
			slime_state = Slime_State.CHASE
	elif slime_state == Slime_State.IDLE:
		if move_timer.time_left == 0:
			move_timer.start(IDLE_MOVE_TIMEOUT + rng.randf())
		direction = current_direction
		if can_sleep and sleep_timer.time_left == 0:
			sleep_timer.start(SLEEP_TIMEOUT)
	elif slime_state == Slime_State.CHASE:
		if target != null and target.global_position.distance_to(global_position) <= DE_AGGRO_RANGE:
			direction = target.global_position - global_position
			move_speed = SPEED
		else:
			slime_state = Slime_State.IDLE
	
	if direction.x > 0:
		animated_sprite_2d.flip_h = false
	elif direction.x < 0:
		animated_sprite_2d.flip_h = true
	
	velocity = direction.normalized() * move_speed
	move_and_slide()

func _awaken():
	slime_state = Slime_State.AWAKING
	if slime_type == Slime_Type.PURPLE:
		animated_sprite_2d.play("awaken_purple")
	else:
		animated_sprite_2d.play("awaken_green")

func _on_animation_finished():
	var anim_name: String = animated_sprite_2d.animation
	if slime_state == Slime_State.ASLEEP:
		return
	if anim_name == "awaken_purple":
		animated_sprite_2d.play("idle_purple")
		slime_state = Slime_State.IDLE
	if anim_name == "awaken_green":
		animated_sprite_2d.play("idle_green")
		slime_state = Slime_State.IDLE

func get_random_direction() -> Vector2:
	if rng.randf() < 0.75:
		return Vector2.ZERO
	return Vector2.DOWN.rotated(rng.randf() * 2 * PI)
	
func _change_direction():
	current_direction = get_random_direction()
	move_timer.start(IDLE_MOVE_TIMEOUT + rng.randf())

func _sleep_timer_timeout():
	print("sleep timeout")
	if slime_state == Slime_State.IDLE:
		slime_state = Slime_State.ASLEEP
		if slime_type == Slime_Type.PURPLE:
			
			animated_sprite_2d.play_backwards("awaken_purple")
		else:
			animated_sprite_2d.play_backwards("awaken_green")
			
func _animate(type: Slime_Type, state: Slime_State):
	if type == Slime_Type.PURPLE:
		if state == Slime_State.IDLE:
			animated_sprite_2d.play("idle_purple")
		elif state == Slime_State.ASLEEP:
			animated_sprite_2d.play("asleep_purple")
	if type == Slime_Type.GREEN:
		if state == Slime_State.IDLE:
			animated_sprite_2d.play("idle_green")
		elif state == Slime_State.ASLEEP:
			animated_sprite_2d.play("asleep_green")
