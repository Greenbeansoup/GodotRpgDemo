class_name LootChest extends Lootable

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var detection_box = $DetectionBox

var chest_state_machine: FiniteStateMachine

# Called when the node enters the scene tree for the first time.
func _ready():
	chest_state_machine = FiniteStateMachine.new()
	
	chest_state_machine.add_state("closed", _on_closed_enter)
	chest_state_machine.add_state("open", _on_open_enter)
	chest_state_machine.add_state("peeking", _on_peeking_enter)
	chest_state_machine.change_state("closed")
	
	detection_box.connect("body_entered", _on_detection_box_body_entered)
	detection_box.connect("body_exited", _on_detection_box_body_exited)

func open():
	chest_state_machine.change_state("open")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_closed_enter():
	animated_sprite_2d.play("closed")

func _on_open_enter():
	animated_sprite_2d.play("open")
	
func _on_peeking_enter():
	animated_sprite_2d.play("peeking")

func _on_detection_box_body_entered(body: Node2D):
	if chest_state_machine.get_current_state() == "closed":
		chest_state_machine.change_state("peeking")

func _on_detection_box_body_exited(body: Node2D):
	if chest_state_machine.get_current_state() == "peeking":
		chest_state_machine.change_state("closed")
