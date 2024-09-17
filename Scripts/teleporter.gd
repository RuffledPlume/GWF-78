extends Area3D
class_name Teleporter

@export var is_teleporting_from_a: bool = false
@export var is_teleporting_from_b: bool = false

var is_working: bool
var is_within_a: bool = false
var is_within_b: bool = false
var generating_teleport: bool = false
var interact_timer = false

@onready var point_a: Node3D = %PointA
@onready var point_b: Node3D = %PointB
@onready var portal_a: MeshInstance3D = %PortalA
@onready var portal_b: MeshInstance3D = %PortalB
@onready var teleport_audio: AudioStreamPlayer3D = %TeleportAudio
@onready var generation_audio: AudioStreamPlayer3D = %GenerationAudio
@onready var transit_audio: AudioStreamPlayer = %TransitAudio
@onready var teleport_audio_b: AudioStreamPlayer3D = %TeleportAudioB
@onready var generation_audio_b: AudioStreamPlayer3D = %GenerationAudioB
@onready var transit_audio_b: AudioStreamPlayer = %TransitAudioB

@onready var player_camera_pivot = Player.instance.camera_pivot

@onready var timer: Timer = $Timer


var portal_a_material: ShaderMaterial
var portal_b_material: ShaderMaterial


func _ready() -> void:
	
	portal_a_material = portal_a.get_active_material(0) as ShaderMaterial
	portal_b_material = portal_b.get_active_material(0) as ShaderMaterial
	
	portal_a_material.set_shader_parameter("Mix", 0.0)
	portal_b_material.set_shader_parameter("Mix", 0.0)
	
	is_working = false

func _process(delta: float) -> void:
	print(interact_timer)
	var distance_to_a = point_a.global_position.distance_to(Player.instance.global_position)
	var distance_to_b = point_b.global_position.distance_to(Player.instance.global_position)
	
	fix_teleporter()
	
	if is_within_a and Input.is_action_just_pressed("Interact"):
		if interact_timer == false:
			interact_timer = true
			timer.start()
			generation_audio.play()
			await get_tree().create_timer(2).timeout
			teleport_audio.play(0.4)
			generation_audio.stop()
			transit_audio.play(5.6)
			is_teleporting_from_a = true

	if is_within_b and Input.is_action_just_pressed("Interact"):
		if interact_timer == false:
			interact_timer = true
			print("Teleporting")
			generation_audio_b.play()
			await get_tree().create_timer(2).timeout
			teleport_audio_b.play(0.4)
			generation_audio_b.stop()
			transit_audio_b.play(5.6)
			is_teleporting_from_b = true
				
	if is_teleporting_from_a:
		Player.instance.global_position = lerp(Player.instance.global_position, point_b.global_position, delta * 5)
		if distance_to_b <= 2.0:
			is_teleporting_from_a = false
			
	if is_teleporting_from_b:
		Player.instance.global_position = lerp(Player.instance.global_position, point_a.global_position, delta * 5)
		if distance_to_a <= 2.0:
			is_teleporting_from_b = false
			interact_timer = false

func fix_teleporter() -> void:
		#Below needs to be put into 'working teleporter' function which executes once is_working = true
	if Input.is_action_just_pressed("Interact"):
		var tween := create_tween()
		tween.tween_method(func(t): portal_a_material.set_shader_parameter("Mix", t), 0.0, 1.0, 2.0)
		tween.tween_method(func(t): portal_b_material.set_shader_parameter("Mix", t), 0.0, 1.0, 2.0)
		
func _on_timer_timeout() -> void:
	interact_timer = false

func _on_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		print("Player in bounds")
		is_within_a = true

func _on_body_exited(body: Node3D) -> void:
	is_within_a = false

func _on_teleporter_b_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		print("Player in bounds")
		is_within_b = true

func _on_teleporter_b_body_exited(body: Node3D) -> void:
	is_within_b = false
