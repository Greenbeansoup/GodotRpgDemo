class_name Player extends Entity

@onready var animation_tree = $Sprite2D/AnimationTree
@onready var player_sprite = $Sprite2D
@onready var roll_timer = $RollTimer
@onready var cool_down_timer = $CoolDownTimer
@onready var death_timer = $DeathTimer
@onready var item_container: ItemContainer = $ItemContainer
@onready var active_weapon_container = $ActiveWeaponContainer
@onready var active_weapon_animation_player = $ActiveWeaponContainer/AnimationPlayer

@export var health_controller: StatusController
@export var stamina_controller: StatusController
@export var inventory_item: Node2D
@export var active_weapon: Weapon

@export_enum("IDLE:0", "RUNNING:1", "DASHING:2", "TAKING_DAMAGE:3", "DEAD:4") var initial_player_state: int
enum PLAYER_STATES { IDLE, RUNNING, DASHING, TAKING_DAMAGE, DEAD }

const DROPPER_SCENE = preload("res://scenes/dropper.tscn")
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
var recoil_vector: Vector2 = Vector2.ZERO
var recoil_timer: Timer
var attack_timer: Timer
var dropper: Dropper

var current_loot_focus: Lootable

var player_state_machine: FiniteStateMachine

func _on_ready():
	roll_timer.connect("timeout", _on_roll_timer_timeout)
	cool_down_timer.connect("timeout", _on_dash_delay_cooldown_timeout)
	death_timer.connect("timeout", _on_death_timeout)
	active_weapon_animation_player.connect("animation_finished", _on_attack_finish)
	
	attack_timer = Timer.new()
	_init_timer(attack_timer, _on_attack_timer_timeout)
	
	recoil_timer = Timer.new()
	_init_timer(recoil_timer, _on_recoil_timer_timeout)
	
	if health_controller != null:
		health_controller.connect("status_changed", _on_health_changed)
		
	if inventory_item != null:
		remove_child(inventory_item)
		item_container.add_child(inventory_item)
		inventory_item.global_position = item_container.global_position
	item_container.top_level = true # tells item container to ignore parent position data

	player_state_machine = FiniteStateMachine.new()
	player_state_machine.add_state(_state_name(PLAYER_STATES.IDLE), player_sprite.anim_idle)
	player_state_machine.add_state(_state_name(PLAYER_STATES.RUNNING), player_sprite.anim_run)
	player_state_machine.add_state(_state_name(PLAYER_STATES.DASHING), _on_dash_entered, _on_dash_exited)
	player_state_machine.add_state(_state_name(PLAYER_STATES.TAKING_DAMAGE), _on_take_damage)
	player_state_machine.add_state(_state_name(PLAYER_STATES.DEAD), _on_death)
	player_state_machine.change_state(_state_name(initial_player_state))
	
	dropper = DROPPER_SCENE.instantiate()
	dropper.global_position = self.global_position
	add_child(dropper)

func _init_timer(timer: Timer, call_back: Callable):
	timer.one_shot = true
	timer.connect("timeout", call_back)
	add_child(timer)

func _physics_process(delta):
	if item_container != null:
		var x_add = 15
		if !player_sprite.flip_h: 
			x_add = -15
		item_container.set_item_position(item_container.global_position.lerp(Vector2(global_position.x + x_add, global_position.y - 8.0), 3 * delta))
	
	if _is_state(PLAYER_STATES.DEAD):
		return
		
	if stamina_controller.get_value() < stamina_controller.max_value and stamina_can_refill:
		stamina_controller.increment_value(delta * STAMINA_REFILL_SPEED)
		
	if Input.is_action_just_pressed("attack"):
		_attack()
		
	if Input.is_action_just_pressed('interact'):
		_interact()
   
	if Input.is_action_just_pressed('drop'):
		_drop()
	
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
	else:
		print("Taking damage")
		pre_velocity = recoil_vector
		move_force = 200.0
	if Input.is_action_just_pressed("roll"):
		_set_state(PLAYER_STATES.DASHING)
	if _is_state(PLAYER_STATES.DASHING):
		move_force = DASH_STRENGTH
		pre_velocity = roll_velocity

	if pre_velocity.x > 0:
		_flip(false)
	elif pre_velocity.x < 0:
		_flip(true)
	
	if !can_move:
		return
	
	velocity = pre_velocity.normalized() * move_force
	
	move_and_slide()
	
func _drop():
	if active_weapon != null:
		# active_weapon.drop()
		active_weapon.deactivate()
		dropper.set_drop(active_weapon)
		dropper.drop()
		active_weapon = null

func _interact():
	if current_loot_focus != null:
		current_loot_focus.open()

func _attack():
	if active_weapon != null:
		if player_sprite.flip_h:
			active_weapon_animation_player.play("attack_left")
		else:
			active_weapon_animation_player.play("attack")
		active_weapon.activate()
		attack_timer.start(active_weapon.get_attack_time())

func _on_attack_finish(anim_name: String):
	active_weapon.deactivate()

func _flip(flip_val: bool) -> void:
	if player_sprite.flip_h != flip_val:
		player_sprite.flip_h = flip_val
		active_weapon_container.position.x = (active_weapon_container.position.x) * -1
		if active_weapon != null:
			active_weapon.flip(flip_val)

func _on_dash_entered():
	if stamina_controller.get_value() >= DASH_STAMINA_COST:
		is_invulnerable = true
		player_sprite.anim_dashing()
		stamina_can_refill = false
		stamina_controller.decrement_value(DASH_STAMINA_COST)
		cool_down_timer.start(DASH_DELAY)
		roll_velocity = velocity
		roll_timer.start(ROLL_LENGTH)
	else:
		_set_state(PLAYER_STATES.IDLE)
		
func _on_dash_exited():
	is_invulnerable = false

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
		
func remove_item_from_inventory(item: Node2D):
	if inventory_item == item:
		inventory_item.queue_free()
		inventory_item = null

func _on_take_damage():
	player_sprite.anim_taking_hit()
	

func _on_health_changed(oldValue, newValue):
	if newValue == 0:
		_set_state(PLAYER_STATES.DEAD)
		
func _on_animation_tree_animation_finished(anim_name):
	pass
	#if (anim_name == "take_damage"):
	#	_set_state(PLAYER_STATES.IDLE)
		
func _on_death():
	player_sprite.anim_death()
	death_timer.start(DEATH_TIMEOUT)

func _on_death_timeout():
	get_tree().reload_current_scene()
	
func _recoil_from_point(source: Vector2):
	recoil_vector = (global_position - source).normalized()
	recoil_timer.start(0.1)

func _on_recoil_timer_timeout():
	print("Recoil timeout")
	_set_state(PLAYER_STATES.IDLE)

func _on_hurt_box_entered(body):
	if body is HitBox and !is_invulnerable:
		damage_entity(body.damage)
		_recoil_from_point(body.global_position)
	elif body is TouchBox:
		var body_parent = body.get_parent()
		if body.entity_type == str(Globals.Fruit_Colors.RED):
			health_controller.increment_value(body.value)
			body_parent.queue_free()
		elif body.entity_type == str(Globals.Fruit_Colors.GREEN):
			# TODO figure out a purpose for green stuff
			print("Green thing found")
			body_parent.queue_free()
		elif body_parent is KeyItem and inventory_item == null:
			body_parent.reparent(item_container)
			inventory_item = body_parent
			inventory_item.global_position = item_container.global_position
		elif body_parent is Weapon and active_weapon == null:
			body_parent.reparent(active_weapon_container)
			active_weapon = body_parent
			active_weapon.global_position = active_weapon_container.global_position
			active_weapon.flip(player_sprite.flip_h)
			active_weapon.set_touch_box_enabled(false) # TODO: Why do I need this. Find where it's being activated, shouldn't need touchbox while it's being held
		elif body_parent is Lootable:
			current_loot_focus = body_parent as Lootable

func _on_hurt_box_exited(body):
	if current_loot_focus == body.get_parent():
		current_loot_focus = null

func _on_attack_timer_timeout():
	if active_weapon != null:
		active_weapon.deactivate()
