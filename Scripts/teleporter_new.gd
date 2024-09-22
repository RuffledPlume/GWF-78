class_name TeleporterNew extends Area3D

static var instance : TeleporterNew

@export var teleporter_target : TeleporterNew
@export var teleporter_path : Path3D

@export_category("Internal")
@export var console : TeleporterFrequency
@export var exit_target: Node3D
@export var portal_mesh: MeshInstance3D
@export var teleport_audio: AudioStreamPlayer3D
@export var generation_audio: AudioStreamPlayer3D
@export var transit_audio: AudioStreamPlayer

var is_working: bool
var is_within: bool = false
var is_powered: bool = false
var is_teleporting: bool
var generating_teleport: bool = false
var interact_delay: float
var portal_material: ShaderMaterial

var wave_frequency : float = 0.5
var wave_amplitude : float = 0.5

func _ready() -> void:
	portal_material = portal_mesh.get_active_material(0) as ShaderMaterial
	portal_material.set_shader_parameter("Mix", 0.0)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	wave_frequency = randf_range(0.25, 1.0)
	wave_amplitude = randf_range(0.1, 1.0)
	
	console.set_target(wave_frequency, wave_amplitude)
	
	is_working = false

func _camera_finish_following_path() -> void:
	is_teleporting = false
	interact_delay = 5.0
	transit_audio.play(6)
	Player.instance.global_position = teleporter_target.exit_target.global_position
	PlayerCamera.instance.on_finish_following_path.disconnect(_camera_finish_following_path)

func _process(delta: float) -> void:
	if console != null:
		if !is_working:
			if is_powered:
				if console.is_in_sync():
					tune_teleporter()
					is_working = true
				else:
					console.tuning_label.visible = false
					console.target_line_renderer.visible = true
					console.tuning_line_renderer.visible = true
			else:
				console.tuning_label.visible = true
				console.tuning_label.text = "Insufficient Power"
				console.target_line_renderer.visible = false
				console.tuning_line_renderer.visible = false
			return
		else:
			console.tuning_label.visible = true
			console.tuning_label.text = "Synchronized"
			console.target_line_renderer.visible = false
			console.tuning_line_renderer.visible = false
	else:
		console.tuning_label.visible = false
		console.target_line_renderer.visible = false
		console.tuning_line_renderer.visible = false
		
	
	if interact_delay > 0.0:
		interact_delay -= delta
		return
	
	if is_within && is_working && !is_teleporting:
		is_teleporting = true
		generation_audio.play()
		await get_tree().create_timer(2).timeout
		teleport_audio.play(0.4)
		generation_audio.stop()
		
		if teleporter_path != null:
			PlayerCamera.instance.on_finish_following_path.connect(_camera_finish_following_path)
			PlayerCamera.instance.follow_path(teleporter_path)

func power_teleporter() -> void:
		is_powered = true
		var tween := create_tween()
		tween.tween_method(func(t): portal_material.set_shader_parameter("Mix", t), 0.0, 0.4, 2.0)
		
func tune_teleporter() -> void:
		var tween := create_tween()
		tween.tween_method(func(t): portal_material.set_shader_parameter("Mix", t), 0.4, 1.0, 2.0)
		
func _on_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		is_within = true

func _on_body_exited(body: Node3D) -> void:
	is_within = false
