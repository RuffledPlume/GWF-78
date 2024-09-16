extends Area3D
class_name Teleporter


var is_working: bool
var is_within_a: bool = false
var is_within_b: bool = false
var is_teleporting_from_a: bool = false
var is_teleporting_from_b: bool = false
var generating_teleport: bool = false

@onready var point_a: Node3D = $TorusA/PointA
@onready var point_b: Node3D = $"../TeleporterB/TorusB/PointB"
@onready var portal_a: MeshInstance3D = $TorusA/PortalA

@onready var teleport_audio: AudioStreamPlayer3D = $TeleportAudio
@onready var generation_audio: AudioStreamPlayer3D = $GenerationAudio
@onready var transit_audio: AudioStreamPlayer = $TransitAudio

@onready var teleport_audio_b: AudioStreamPlayer3D = $"../TeleporterB/TeleportAudioB"
@onready var generation_audio_b: AudioStreamPlayer3D = $"../TeleporterB/GenerationAudioB"
@onready var transit_audio_b: AudioStreamPlayer = $"../TeleporterB/TransitAudioB"

@onready var player_camera_pivot = Player.instance.camera_pivot

@export var portal_material: ShaderMaterial

func _ready() -> void:
	is_working = false
	
func _process(delta: float) -> void:
	
	var distance_to_a = point_a.global_position.distance_to(Player.instance.global_position)
	var distance_to_b = point_b.global_position.distance_to(Player.instance.global_position)
	
	if is_within_a and Input.is_action_just_pressed("Interact"):
		
		#generating_teleport = true
		#if generating_teleport:
			#player_camera_pivot.look_at(point_b.global_position)
	
		generation_audio.play()
		await get_tree().create_timer(2).timeout
		teleport_audio.play(0.4)
		generation_audio.stop()
		transit_audio.play(5.6)
		is_teleporting_from_a = true
		
	if is_teleporting_from_a:
		Player.instance.global_position = lerp(Player.instance.global_position, point_b.global_position, delta * 5)
		if distance_to_b <= 2.0:
			is_teleporting_from_a = false
			
	
	if is_within_b and Input.is_action_just_pressed("Interact"):
		print("Teleporting")
		generation_audio_b.play()
		await get_tree().create_timer(2).timeout
		teleport_audio_b.play(0.4)
		generation_audio_b.stop()
		transit_audio_b.play(5.6)
		is_teleporting_from_b = true
		
	if is_teleporting_from_b:
		Player.instance.global_position = lerp(Player.instance.global_position, point_a.global_position, delta * 5)
		if distance_to_a <= 2.0:
			is_teleporting_from_b = false


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
