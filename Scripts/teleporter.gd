extends Area3D


var is_within_a: bool = false
var is_within_b: bool = false
var is_teleporting_from_a: bool = false
var is_teleporting_from_b: bool = false

@onready var point_a: Node3D = $TorusA/PointA
@onready var point_b: Node3D = $"../TeleporterB/TorusB/PointB"
@onready var teleport_audio: AudioStreamPlayer3D = $TeleportAudio
@onready var generation_audio: AudioStreamPlayer3D = $GenerationAudio
@onready var transit_audio: AudioStreamPlayer = $TransitAudio


func _process(delta: float) -> void:
	
	var distance_to_a = point_a.global_position.distance_to(Player.instance.global_position)
	var distance_to_b = point_b.global_position.distance_to(Player.instance.global_position)
	
	if is_within_a and Input.is_action_just_pressed("Interact"):
		print("Teleporting")
		generation_audio.play()
		await get_tree().create_timer(2).timeout
		teleport_audio.play(0.4)
		generation_audio.stop()
		transit_audio.play(5.6)
		#await get_tree().create_timer(0.8).timeout
		is_teleporting_from_a = true
		
	if is_teleporting_from_a:
		Player.instance.global_position = lerp(Player.instance.global_position, point_b.global_position, delta * 5)
		if distance_to_b <= 2.0:
			is_teleporting_from_a = false
	
	if is_within_b and Input.is_action_just_pressed("Interact"):
		print("Teleporting")
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
