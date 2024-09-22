extends Node3D

@onready var toxic_spray_particle: Node3D = $ToxicSprayParticle
@onready var spore_particle: GPUParticles3D = $ToxicSprayParticle/SporeParticle
@onready var toxic_particle: GPUParticles3D = $ToxicSprayParticle/ToxicParticle
@onready var toxic_particle_2: GPUParticles3D = $ToxicSprayParticle/ToxicParticle2


@export var delay_off := 6.0
@export var delay_on := 3.0

var current_delay: float
var is_off: bool

func _ready() -> void:
	current_delay = delay_off
	
func _process(delta: float) -> void:
	current_delay -= delta
	if current_delay <= 0:
		
		if is_off:
			current_delay = delay_on
		else:
			current_delay = delay_off
			
		is_off = !is_off	
		spore_particle.emitting = !is_off
		toxic_particle.emitting = !is_off
		toxic_particle_2.emitting = !is_off
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Player.instance and !is_off:
		Player.instance._handle_cough_audio()
		Player.instance.breath = Player.instance.breath / 1.25
