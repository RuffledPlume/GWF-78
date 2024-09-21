class_name TeleporterNew extends Area3D

static var instance : TeleporterNew

@export var teleporter_target : TeleporterNew
@export var teleporter_path : Path3D

@export_category("Teleporter Frequency")
@export var wave_frequency : float = 0.5
@export var wave_amplitude : float = 0.5
@export var console : TeleporterFrequency

@export_category("Internal")
@export var exit_target: Node3D
@export var portal_mesh: MeshInstance3D
@export var teleport_audio: AudioStreamPlayer3D
@export var generation_audio: AudioStreamPlayer3D
@export var transit_audio: AudioStreamPlayer
@export var timer: Timer

var is_working: bool
var is_within: bool = false
var is_teleporting: bool
var generating_teleport: bool = false
var interact_timer = false
var portal_material: ShaderMaterial

func _ready() -> void:
	portal_material = portal_mesh.get_active_material(0) as ShaderMaterial
	portal_material.set_shader_parameter("Mix", 0.0)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_timer_timeout)
	
	console.set_target(wave_frequency, wave_amplitude)
	
	is_working = false

func _camera_finish_following_path() -> void:
	is_teleporting = false
	transit_audio.play(6)
	Player.instance.global_position = teleporter_target.exit_target.global_position
	PlayerCamera.instance.on_finish_following_path.disconnect(_camera_finish_following_path)

func _process(delta: float) -> void:
	fix_teleporter()
	
	if is_within and Input.is_action_just_pressed("Interact"):
		if interact_timer == false:
			interact_timer = true
			timer.start()
			generation_audio.play()
			await get_tree().create_timer(2).timeout
			teleport_audio.play(0.4)
			generation_audio.stop()
			is_teleporting = true
			
			if teleporter_path != null:
				PlayerCamera.instance.on_finish_following_path.connect(_camera_finish_following_path)
				PlayerCamera.instance.follow_path(teleporter_path)
			else:
				transit_audio.play(6)
							
	if is_teleporting && teleporter_path == null:
		Player.instance.global_position = lerp(Player.instance.global_position, teleporter_target.exit_target.global_position, delta * 5)
		if Player.instance.global_position.distance_to(teleporter_target.exit_target.global_position) <= 2.0:
			is_teleporting = false

func fix_teleporter() -> void:
		#Below needs to be put into 'working teleporter' function which executes once is_working = true
	if Input.is_action_just_pressed("Interact") and not is_working:
		var tween := create_tween()
		tween.tween_method(func(t): portal_material.set_shader_parameter("Mix", t), 0.0, 1.0, 2.0)
		is_working = true
		
func _on_timer_timeout() -> void:
	interact_timer = false

func _on_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		is_within = true
		print("Within")

func _on_body_exited(body: Node3D) -> void:
	is_within = false
