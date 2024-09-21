extends Node

@onready var trigger_area: Area3D = $TriggerArea
@onready var gas_audio: AudioStreamPlayer3D = $GasAudio
@onready var gas_burst: AudioStreamPlayer3D = $GasBurst
@onready var air_explosion: AudioStreamPlayer3D = $AirExplosion
@onready var toxic_spray_particle: Node3D = $ToxicSprayParticle

@onready var toxic_particle: GPUParticles3D = $ToxicSprayParticle/ToxicParticle
@onready var toxic_particle_2: GPUParticles3D = $ToxicSprayParticle/ToxicParticle2
@onready var spore_particle: GPUParticles3D = $ToxicSprayParticle/SporeParticle


var is_triggered = false

func _ready() -> void:
		toxic_particle.emitting = false
		toxic_particle_2.emitting = false
		spore_particle.emitting = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if is_triggered:
		if body == Player.instance:
			Player.instance._handle_cough_audio()
			Player.instance.breath = Player.instance.breath / 1.25


func _on_trigger_area_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		air_explosion.play()
		gas_burst.play()
		gas_audio.play()
		toxic_particle.emitting = true
		toxic_particle_2.emitting = true
		spore_particle.emitting = true
		is_triggered = true

func _on_trigger_area_body_exited(body: Node3D) -> void:
	trigger_area.queue_free()
