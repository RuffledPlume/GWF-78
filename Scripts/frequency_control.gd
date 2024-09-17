extends Interactable

@export var target : TeleporterFrequency
@export var slider_mesh : Node3D
@export var max_target : Node3D
@export var is_freq := true
@export var slide_step_amount := 0.05
@export var value_scale : float = 2.0

var start_position : Vector3
var current_value : float

func _ready() -> void:
	start_position = slider_mesh.global_position

func get_interact_text() -> String:
	return "Change Frequency" if is_freq else "Change Amplitude"

func can_interact_with() -> bool:
	return true
	
func on_interact_with() -> void:
	current_value += slide_step_amount
	if current_value > 1.0: current_value = 0
	slider_mesh.global_position = lerp(start_position, max_target.global_position, current_value)
	if is_freq: target.current_freq = current_value * value_scale
	else: target.current_amp = current_value * value_scale
