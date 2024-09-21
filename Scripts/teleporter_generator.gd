extends Node3D

@export var target_teleporter: Node3D
@export var generator_working = false

var is_within = false
var has_fuel = false

@onready var generator_audio: AudioStreamPlayer3D = $GeneratorAudio
@onready var generator_light: OmniLight3D = $Mesh/GeneratorLight

func _ready() -> void:
	generator_light.visible = false

func _process(delta: float) -> void:
	if is_within:
		if Input.is_action_just_pressed("Interact") and has_fuel:
			generator_working = true
			generator_light.visible = true
			generator_audio.play()
			target_teleporter.power_teleporter()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		is_within = true
