class_name BossSlime extends Entity

@onready var sprite_2d = $ScaleNode/Sprite2D
@onready var animation_player = $ScaleNode/Sprite2D/AnimationPlayer
@onready var scale_node = $ScaleNode
@onready var collision_shape_2d = $CollisionShape2D
@onready var health_scale = $HealthScale

@export var health_controller: StatusController
@export var target: Node2D
@export var aggro_range: int = 150
@export var de_aggro_range: int = 250
@export var speed: int = 60
@export var initial_scale: float = 1.0
@export var minimum_scale: float = 1.0
@export var max_health: float = 10.0
@export var min_health: float = 0.0
@export_enum("ASLEEP:0", "IDLE:1", "CHASE:2", "TAKE_DAMAGE:3") var slime_initial_state: int
@export_enum("PURPLE:0", "GREEN:1") var slime_type: int = 0
enum SLIME_TYPE {
	PURPLE = 0,
	GREEN = 1
}
enum SLIME_STATES {ASLEEP, IDLE, CHASE, TAKE_DAMAGE}

const SLEEP_TIMEOUT = 10.0
const IDLE_MOVE_TIMEOUT = 1.0

var slime_state_machine: FiniteStateMachine
var rng: RandomNumberGenerator
var sleep_timer: Timer
var idle_move_timer: Timer
var idle_direction: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	if health_controller == null:
		health_controller = StatusController.new()
	if health_controller != null:
		health_controller.connect("status_changed", _on_health_changed)
		health_controller.reparent(scale_node)
		health_controller.position.y = -5
	
	slime_state_machine = FiniteStateMachine.new()
	slime_state_machine.add_state(_state_name(SLIME_STATES.ASLEEP), sprite_2d.anim_asleepen, sprite_2d.anim_awaken)
	slime_state_machine.add_state(_state_name(SLIME_STATES.IDLE), _on_idle_entered, _on_idle_exited)
	slime_state_machine.add_state(_state_name(SLIME_STATES.CHASE))
	slime_state_machine.add_state(_state_name(SLIME_STATES.TAKE_DAMAGE), sprite_2d.anim_take_damage, sprite_2d.anim_take_damage_stop)
	
	rng = RandomNumberGenerator.new()
	
	sleep_timer = Timer.new()
	sleep_timer.one_shot = true
	self.add_child(sleep_timer)
	sleep_timer.connect("timeout", _on_sleep_timer_timeout)
	idle_move_timer = Timer.new()
	idle_move_timer.one_shot = true
	self.add_child(idle_move_timer)
	idle_move_timer.connect("timeout", _on_idle_move_timer_timeout)
	
	_initialize(slime_type, slime_initial_state, max_health, min_health, initial_scale)

func _initialize(type: SLIME_TYPE, state: SLIME_STATES, max_health: float = 10.0, min_health: float = 0.0, scale: float = 1.0):
	print("initial health ", max_health)
	_set_state(state)
	_set_scale(scale)
	sprite_2d.set_slime_texture(type)
	slime_type = type
	if health_controller != null:
		health_controller.set_max_value(max_health)
		health_controller.set_min_value(min_health)
		health_controller.set_value(max_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !is_visible_in_tree():
		return
	var move_speed = 0
	var direction: Vector2
	if  target != null and target.global_position.distance_to(global_position) <= aggro_range:
		_set_state(SLIME_STATES.CHASE)
	if _is_slime_state(SLIME_STATES.IDLE):
		direction = idle_direction
		move_speed = speed
	if _is_slime_state(SLIME_STATES.CHASE):
		if target == null or target.global_position.distance_to(global_position) >= de_aggro_range:
			move_speed = 0
			_set_state(SLIME_STATES.IDLE)
		elif target != null:
			direction = target.global_position - global_position
			move_speed = speed
	
	if direction.x > 0:
		sprite_2d.flip_h = false
	elif direction.x < 0:
		sprite_2d.flip_h = true

	velocity = direction.normalized() * move_speed
	move_and_slide()

func _on_hurt_box_entered(body):
	if body is HitBox and body.is_in_group("Player_Weapon"):
		health_controller.decrement_value(body.damage)

func _state_name(state: SLIME_STATES) -> String:
	return SLIME_STATES.keys()[state]
	
func _is_slime_state(state: SLIME_STATES) -> bool:
	return slime_state_machine.get_current_state() == _state_name(state)
	
func _set_state(state: SLIME_STATES) -> void:
	slime_state_machine.change_state(_state_name(state))
	
func damage_entity(value: float):
	if health_controller != null:
		health_controller.decrement_value(value)
		
func _on_health_changed(oldValue: float, newValue: float):
	if health_controller != null and newValue <= health_controller.min_value and slime_type == SLIME_TYPE.PURPLE:
		_initialize(SLIME_TYPE.GREEN, SLIME_STATES.ASLEEP)
		return
	var diff: float = newValue - oldValue
	var percentage_change = (diff / health_controller.max_value) + 1
	_set_scale(percentage_change)

func _set_scale(scale: float):
	if scale_node.scale.x * scale <= minimum_scale:
		scale = minimum_scale / scale_node.scale.x
	
	var scale_vector = Vector2(scale, scale)	
	scale_node.apply_scale(scale_vector)
	collision_shape_2d.apply_scale(scale_vector)

func _get_random_direction() -> Vector2:
	if rng.randf() < 0.75:
		return Vector2.ZERO
	return Vector2.DOWN.rotated(rng.randf() * 2 * PI)
	
func _start_sleep_timer():
	sleep_timer.start(SLEEP_TIMEOUT)

func _on_sleep_timer_timeout():
	if _is_slime_state(SLIME_STATES.IDLE):
		_set_state(SLIME_STATES.ASLEEP)
		
func _on_idle_move_timer_timeout():
	idle_direction = _get_random_direction()
	idle_move_timer.start(IDLE_MOVE_TIMEOUT)
	
func _on_idle_entered():
	idle_move_timer.start(IDLE_MOVE_TIMEOUT)
	sleep_timer.start(SLEEP_TIMEOUT)

func _on_idle_exited():
	idle_move_timer.stop()
