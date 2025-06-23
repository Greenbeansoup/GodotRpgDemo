extends Entity

@onready var sprite_2d = $Sprite2D
@onready var animation_tree = $Sprite2D/AnimationTree

@export var health_controller: StatusController
@export var target: Node2D
@export_enum("ASLEEP:0", "AWAKEN:1", "IDLE:2", "ASLEEPEN:3", "CHASE:4", "TAKE_DAMAGE:5") var slime_initial_state: int

enum SLIME_STATES {ASLEEP, AWAKEN, IDLE, ASLEEPEN, CHASE, TAKE_DAMAGE}
const AGGRO_RANGE = 100
const DE_AGGRO_RANGE = 200
const SPEED = 80

var slime_state_machine: FiniteStateMachine

# Called when the node enters the scene tree for the first time.
func _ready():
	slime_state_machine = FiniteStateMachine.new()
	slime_state_machine.add_state(_state_name(SLIME_STATES.ASLEEP))
	slime_state_machine.add_state(_state_name(SLIME_STATES.AWAKEN), sprite_2d.anim_awaken)
	slime_state_machine.add_state(_state_name(SLIME_STATES.IDLE))
	slime_state_machine.add_state(_state_name(SLIME_STATES.ASLEEPEN), sprite_2d.anim_asleepen)
	slime_state_machine.add_state(_state_name(SLIME_STATES.CHASE))
	slime_state_machine.add_state(_state_name(SLIME_STATES.TAKE_DAMAGE), sprite_2d.anim_take_damage, sprite_2d.anim_take_damage_stop)
	_set_state(slime_initial_state)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_speed = 0
	var direction: Vector2
	
	if _is_slime_state(SLIME_STATES.ASLEEP):
			_set_state(SLIME_STATES.AWAKEN)
	elif _is_slime_state(SLIME_STATES.AWAKEN):
		_set_state(SLIME_STATES.IDLE)
	elif _is_slime_state(SLIME_STATES.IDLE):
		if target != null and target.global_position.distance_to(global_position) <= AGGRO_RANGE:
			_set_state(SLIME_STATES.CHASE)
	elif _is_slime_state(SLIME_STATES.CHASE):
		if target == null or target.global_position.distance_to(global_position) >= DE_AGGRO_RANGE:
			move_speed = 0
			_set_state(SLIME_STATES.IDLE)
		elif target != null:
			direction = target.global_position - global_position
			move_speed = SPEED
	
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
