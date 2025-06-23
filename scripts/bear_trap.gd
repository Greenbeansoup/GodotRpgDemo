class_name BearTrap extends Trap
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var sprung_timer = $SprungTimer
@onready var detection_timer = $DetectionTimer
@onready var view_box = $ViewBox
@onready var grab_box = $GrabBox

const DETECTION_TIMEOUT = 0.5
const DAMAGE = 40.0

var is_sprung = false
var detection_activated = false
var prevent_body_exited = false

var grab_box_bodies_entered = []
var detection_box_bodies_entered = []

var trapped_entity: Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	does_hold = true # Inhereted from Trap
	hold_length = 3 # Inhereted from Trap
	self.z_index = -1
	
	# Set up signal handlers
	grab_box.connect("body_entered", _on_hit_box_body_entered)
	grab_box.connect("body_exited", _on_hit_box_body_exited)
	sprung_timer.connect("timeout", _on_sprung_timer_timeout)
	view_box.connect("body_entered", _on_detection_box_body_entered)
	view_box.connect("body_exited", _on_detection_box_body_exited)
	detection_timer.connect("timeout", _on_detection_timer_timeout)
	animated_sprite_2d.connect("animation_finished", _on_animation_finished)
	
	does_hold = true
	hold_length = 3.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_hit_box_body_entered(body):
	if body is Entity and !grab_box_bodies_entered.has(body):
		grab_box_bodies_entered.append(body)
		if !is_sprung:
			trigger_trap(body)

func trigger_trap(body: Entity = null):
	is_sprung = true
	self.z_index = 0
	if body != null and !body.check_is_invulnerable() and does_hold:
		body.damage_entity(DAMAGE)
		if body.is_in_group("Trappable"):
			trapped_entity = body
			body.set_entity_position(position)
			body.set_entity_velocity(Vector2.ZERO)
			body.set_entity_can_move(false)
	if body != null and body is Slime:
		if (body as Slime).slime_type == Slime.Slime_Type.PURPLE:
			animated_sprite_2d.play("slime_trapped_purple")
			body.hide()
		else:
			animated_sprite_2d.play("slime_trapped_green")
	else:
		animated_sprite_2d.play("trigger")
		sprung_timer.start(hold_length)

func _on_sprung_timer_timeout():
	self.z_index = -1
	animated_sprite_2d.play("idle")
	is_sprung = false
	if trapped_entity != null:
		trapped_entity.set_entity_can_move(true)
		trapped_entity = null

func _on_detection_box_body_entered(body):
	if body.is_in_group("Trappable") and !is_sprung and !detection_activated and !detection_box_bodies_entered.has(body):
		detection_box_bodies_entered.append(body)
		detection_activated = true
		detection_timer.start(DETECTION_TIMEOUT)

func _on_detection_timer_timeout():
	detection_activated = false
	if !is_sprung:
		trigger_trap()

func _on_hit_box_body_exited(body):
	# This whole process is sketch af - maybe try state machines
	if !prevent_body_exited or body != trapped_entity:
		grab_box_bodies_entered.erase(body)

func _on_detection_box_body_exited(body):
	detection_box_bodies_entered.erase(body)
	
func _on_animation_finished():
	var anim_name: String = animated_sprite_2d.animation
	if anim_name == "slime_trapped_purple":
		is_sprung = false
		self.z_index = -1
		animated_sprite_2d.play("idle")
		trapped_entity.set_entity_can_move(true)
		trapped_entity.show()
		trapped_entity = null
