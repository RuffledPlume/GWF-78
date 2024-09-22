extends Node3D

@export var lights: Node3D
@export var door: Node3D
@export var red_light: Node3D
#@export var target_door: Node3D
@export var generator_working = false


var is_within = false

@onready var generator_audio: AudioStreamPlayer3D = $GeneratorAudio
@onready var generator_light: OmniLight3D = $Mesh/GeneratorLight

func _ready() -> void:
	generator_light.visible = false
	lights.visible = false
func _process(delta: float) -> void:
	if is_within:
		if Input.is_action_just_pressed("Interact"):
			generator_working = true
			generator_light.visible = true
			generator_audio.play()
			lights.visible = true
			red_light.visible = false
			door.queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		is_within = true
