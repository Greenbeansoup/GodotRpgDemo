class_name DropContainer extends CharacterBody2D

const DRAG_FACTOR = .95

# Gravity is automatically applied to CharacterBody2D nodes.
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var floor: float
var impulse: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():# Apply the initial impulse by directly adding to the velocity
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	velocity += self.impulse
	self.impulse = Vector2.ZERO
	
	if velocity.x > .1:
		velocity.x *= DRAG_FACTOR
	else:
		velocity.x = 0

	if !_is_on_floor():
		velocity.y += gravity * delta
	elif velocity.y > 0:
		velocity.y = 0
	move_and_slide()

func apply_impulse(impulse: Vector2):
	self.impulse = impulse

func set_floor(floor: float):
	self.floor = floor

func _is_on_floor():
	if global_position.y >= floor:
		return true
