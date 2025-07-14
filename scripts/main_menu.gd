extends CanvasLayer
@onready var volume_slider = $Control/SettingsContainer/VolumeSlider
@onready var settings_container = $Control/SettingsContainer
@onready var settings_button = $Control/VBoxContainer/SettingsButton
@onready var close_settings_button = $Control/SettingsContainer/CloseSettingsButton
@onready var audio_stream_player = $"../AudioStreamPlayer"

# Called when the node enters the scene tree for the first time.
func _ready():
	settings_container.hide()
	volume_slider.value = Globals.volume_value_db + Globals.volume_value_offset
	volume_slider.connect("value_changed", _on_volume_slider_value_changed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level_1-1.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_settings_button_pressed():
	settings_container.show()


func _on_close_settings_button_pressed():
	settings_container.hide()


func _on_volume_slider_value_changed(value):
	Globals.volume_value_db = value
	audio_stream_player.volume_db = value - Globals.volume_value_offset
