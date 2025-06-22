extends Entity

@onready var animation_tree = $Sprite2D/AnimationTree
@onready var player_sprite = $Sprite2D
@onready var player = $"."
@onready var cooldown_timer: Timer = $CoolDownTimer
@onready var death_timer = $DeathTimer
@onready var roll_timer = $RollTimer

@export var health_controller: StatusController
@export var stamina_controller: StatusController
@export var dead = false

const SPEED = 100.0
const DASH_STRENGTH = 250.0
const DASH_DELAY = 1.5
const MAX_HEALTH = 100.0
const DASH_STAMINA_COST = 20.0
const STAMINA_REFILL_SPEED = 80.0
const ROLL_LENGTH = .15

var stamina_can_refill = true
var is_rolling = false
var is_taking_hit = false
var is_dead = false
var roll_velocity = Vector2.ZERO
var death_activated = false

func _on_ready():
	is_invulnerable = false # Inhereted from Entity
	death_timer.connect("timeout", _on_death_timer_timeout)
	health_controller.connect("status_changed", _on_health_changed)
	roll_timer.connect("timeout", _on_rolltimer_timeout)

func _process(delta):
	if stamina_can_refill:
		stamina_controller.increment_value(delta * STAMINA_REFILL_SPEED)
	pass

func _physics_process(delta):
	if dead or death_activated or !can_move:
		return
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionX = Input.get_axis("move_left", "move_right")
	var directionY = Input.get_axis("move_up", "move_down")
	if Input.is_action_just_pressed("roll"):
		_roll(directionX, directionY)
	
	if directionX > 0:
		player_sprite.flip_h = false
	elif directionX < 0:
		player_sprite.flip_h = true

	var pre_velocity: Vector2
	var force = 0
	if !is_rolling:
		force = SPEED
		if directionX:
			pre_velocity.x = directionX * SPEED
		else:
			pre_velocity.x = move_toward(velocity.x, 0, SPEED)
		if directionY:
			pre_velocity.y = directionY * SPEED
		else:
			pre_velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		force = DASH_STRENGTH
		is_invulnerable = true
		var dashX = 0
		var dashY = 0
		if roll_velocity.x > 0:
			dashX = 1
		elif roll_velocity.x < 0:
			dashX = -1
		if roll_velocity.y > 0:
			dashY = 1
		elif roll_velocity.y < 0:
			dashY = -1
			
		pre_velocity.x = DASH_STRENGTH * dashX
		pre_velocity.y = DASH_STRENGTH * dashY
	
	velocity = pre_velocity.normalized() * force

	move_and_slide()

func _roll(directionX, directionY):
	if stamina_controller.get_value() >= 20 and !is_rolling:
		is_taking_hit = false
		is_rolling = true
		stamina_can_refill = false
		stamina_controller.decrement_value(DASH_STAMINA_COST)
		roll_velocity = Vector2(directionX, directionY)
		roll_timer.start(ROLL_LENGTH)
		cooldown_timer.start(DASH_DELAY)
		
func damage_entity(value: float):
	health_controller.decrement_value(value)

func _on_hurt_box_entered(body):
	if body is HitBox and !is_invulnerable:
		health_controller.decrement_value(body.damage)
	elif body is TouchBox:
		if body.entity_name == Globals.Fruit_Colors.RED:
			health_controller.increment_value(body.value)
			print("Red thing found")
		elif body.entity_name == Globals.Fruit_Colors.GREEN:
			# TODO figure out a purpose for green stuff
			print("Green thing found")

func _on_animation_tree_animation_finished(anim_name):
	if (anim_name == "take_damage"):
		is_taking_hit = false

func _on_cooldown_timeout():
	stamina_can_refill = true
	
func _on_rolltimer_timeout():
	is_rolling = false
	is_invulnerable = false

func _on_death_timer_timeout():
	dead = true

func _on_health_changed(oldValue, newValue):
	if oldValue > newValue:
		is_taking_hit = true
	if newValue == 0 and !death_activated:
		death_activated = true
		death_timer.start(2)
