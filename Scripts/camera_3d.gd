class_name PlayerCamera extends Camera3D

static var instance : PlayerCamera

@export var speed := 40.0
@onready var camera_animator: AnimationPlayer = $CameraAnimator
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


var _current_path : Path3D
var _current_path_frac : float

signal on_finish_following_path()

func follow_path(path: Path3D) -> void:
	_current_path = path
	_current_path_frac = 0.0
	
func _ready() -> void:
	instance = self
	
func _physics_process(delta: float) -> void:
	if _current_path != null:
		var path_frac := _current_path_frac * _current_path.curve.get_baked_length()
		var path_transform := _current_path.curve.sample_baked_with_rotation(path_frac, false, true)
		global_transform = _current_path.global_transform * path_transform
		_current_path_frac += delta * 0.5
		if _current_path_frac >= 1.0:
			_current_path = null
			on_finish_following_path.emit()
		return
	
	var weight = clamp(delta * speed, 0.0, 1.0)
	global_transform = global_transform.interpolate_with(get_parent().global_transform, weight)
	global_position = get_parent().global_position
	
	if Player.instance.velocity.length() <= 0.0:
		playback.travel("Idle")
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_sprinting"] = false
	elif Player.instance.velocity.length() <= 3.0:
		playback.travel("Walk")
		animation_tree["parameters/conditions/is_walking"] = true
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_sprinting"] = false
	elif Player.instance.velocity.length() > 4.0:
		playback.travel("Run")
		animation_tree["parameters/conditions/is_sprinting"] = true
		animation_tree["parameters/conditions/is_walking"] = false
		animation_tree["parameters/conditions/is_idle"] = false
		
