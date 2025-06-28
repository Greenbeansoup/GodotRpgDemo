extends Entity

@onready var animation_tree = $Sprite2D/AnimationTree
@onready var player_sprite = $Sprite2D
@onready var roll_timer = $RollTimer
@onready var cool_down_timer = $CoolDownTimer
@onready var death_timer = $DeathTimer

@export var health_controller: StatusController
@export var stamina_controller: StatusController

@export_enum("IDLE:0", "RUNNING:1", "DASHING:2", "TAKING_DAMAGE:3", "DEAD:4") var initial_player_state: int
enum PLAYER_STATES { IDLE, RUNNING, DASHING, TAKING_DAMAGE, DEAD }

const SPEED = 120.0
const DASH_STRENGTH = 500.0
const DASH_DELAY = 1
const MAX_HEALTH = 100.0
const DASH_STAMINA_COST = 20.0
const STAMINA_REFILL_SPEED = 80.0
const ROLL_LENGTH = .15
const DEATH_TIMEOUT = 2

var stamina_can_refill = true
var roll_velocity = Vector2.ZERO

var player_state_machine: FiniteStateMachine

func _on_ready():
	roll_timer.connect("timeout", _on_roll_timer_timeout)
	cool_down_timer.connect("timeout", _on_dash_delay_cooldown_timeout)
	death_timer.connect("timeout", _on_death_timeout)
	if health_controller != null:
		health_controller.connect("status_changed", _on_health_changed)

	player_state_machine = FiniteStateMachine.new()
	player_state_machine.add_state(_state_name(PLAYER_STATES.IDLE), player_sprite.anim_idle)
	player_state_machine.add_state(_state_name(PLAYER_STATES.RUNNING), player_sprite.anim_run)
	player_state_machine.add_state(_state_name(PLAYER_STATES.DASHING), _on_dash_entered)
	player_state_machine.add_state(_state_name(PLAYER_STATES.TAKING_DAMAGE), _on_take_damage)
	player_state_machine.add_state(_state_name(PLAYER_STATES.DEAD), _on_death)
	player_state_machine.change_state(_state_name(initial_player_state))

func _physics_process(delta):
	if _is_state(PLAYER_STATES.DEAD):
		return
		
	if stamina_controller.get_value() < stamina_controller.max_value and stamina_can_refill:
		stamina_controller.increment_value(delta * STAMINA_REFILL_SPEED)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var pre_velocity = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	var move_force = SPEED
	
	if !_is_state(PLAYER_STATES.TAKING_DAMAGE):
		if _is_state(PLAYER_STATES.IDLE):
			if abs(pre_velocity.x) > 0 or abs(pre_velocity.y) > 0:
				_set_state(PLAYER_STATES.RUNNING)
		if _is_state(PLAYER_STATES.RUNNING):
			if pre_velocity.x == 0 and pre_velocity.y == 0:
				_set_state(PLAYER_STATES.IDLE)
	if Input.is_action_just_pressed("roll"):
		_set_state(PLAYER_STATES.DASHING)
	if _is_state(PLAYER_STATES.DASHING):
		move_force = DASH_STRENGTH
		pre_velocity = roll_velocity

	if pre_velocity.x > 0:
		player_sprite.flip_h = false
	elif pre_velocity.x < 0:
		player_sprite.flip_h = true
	
	if !can_move:
		return
	
	velocity = pre_velocity.normalized() * move_force
	
	move_and_slide()
		
func _on_dash_entered():
	if stamina_controller.get_value() >= DASH_STAMINA_COST:
		player_sprite.anim_dashing()
		stamina_can_refill = false
		stamina_controller.decrement_value(DASH_STAMINA_COST)
		cool_down_timer.start(DASH_DELAY)
		roll_velocity = velocity
		roll_timer.start(ROLL_LENGTH)
	else:
		_set_state(PLAYER_STATES.IDLE)

func _state_name(state: PLAYER_STATES) -> String:
	return PLAYER_STATES.keys()[state]
	
func _is_state(state: PLAYER_STATES) -> bool:
	return player_state_machine.get_current_state() == _state_name(state)
	
func _set_state(state: PLAYER_STATES) -> void:
	player_state_machine.change_state(_state_name(state))

func _on_roll_timer_timeout():
	_set_state(PLAYER_STATES.IDLE)
	
func _on_dash_delay_cooldown_timeout():
	stamina_can_refill = true

func set_entity_can_move(can_move: bool):
	self.can_move = can_move
		
func damage_entity(value: float):
	_set_state(PLAYER_STATES.TAKING_DAMAGE)
	if health_controller != null:
		health_controller.decrement_value(value)

func _on_take_damage():
	player_sprite.anim_taking_hit()

func _on_health_changed(oldValue, newValue):
	if newValue == 0:
		_set_state(PLAYER_STATES.DEAD)
		
func _on_animation_tree_animation_finished(anim_name):
	if (anim_name == "take_damage"):
		_set_state(PLAYER_STATES.IDLE)
		
func _on_death():
	player_sprite.anim_death()
	death_timer.start(DEATH_TIMEOUT)

func _on_death_timeout():
	get_tree().reload_current_scene()

func _on_hurt_box_entered(body):
	if body is HitBox and !is_invulnerable:
		damage_entity(body.damage)
	elif body is TouchBox:
		if body.entity_name == Globals.Fruit_Colors.RED:
			health_controller.increment_value(body.value)
		elif body.entity_name == Globals.Fruit_Colors.GREEN:
			# TODO figure out a purpose for green stuff
			print("Green thing found")
