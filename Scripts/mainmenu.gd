extends Node

@export var camera : Camera3D
@export var transition_speed: float = 0.5
@export var scroll_speed : float = 1.5
@export var root_ui : Control
@export var black_panel : Control

var should_transition : bool
var transition_t : float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	black_panel.position = Vector2(0, black_panel.size.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_anything_pressed():
		should_transition = true
		
	if !should_transition:
		return
		
	transition_t += delta * transition_speed
	root_ui.modulate = Color(1.0, 1.0, 1.0, 1.0 - (min(transition_t, 0.5) / 0.5))
	if transition_t > 0.5:
		black_panel.position = Vector2(0, lerp(black_panel.size.y, 0.0, (transition_t - 0.5) / 0.5))
	camera.global_position -= (camera.global_basis * Vector3.UP).normalized() * delta * scroll_speed
	
	if transition_t > 1.0:
		black_panel.position = Vector2.ZERO
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Levels/Sandbox.tscn")
