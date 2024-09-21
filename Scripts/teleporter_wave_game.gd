class_name TeleporterFrequency extends Node3D

@export var tuning_line_renderer : Line2D
@export var curve_resolution := 150
@export var frequency_crank : TeleporterCrank
@export var amplitude_crank : TeleporterCrank

var _last_freq := 0.0
var _last_amp := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_freq := frequency_crank._frac
	var current_amp := amplitude_crank._frac
	
	_last_freq = lerpf(_last_freq, current_freq, delta)
	_last_amp = lerpf(_last_amp, current_amp, delta)
	
	_update_curve(tuning_line_renderer, _last_freq, _last_amp)
	
func _update_curve(target: Line2D, freq: float, amp : float) -> void:
	target.clear_points()
	var line_panel := tuning_line_renderer.get_parent() as Panel
	for i in curve_resolution:
		var x_pos := line_panel.size.x * (i / float(curve_resolution))
		var y_pos := (0.5 + amp * sin(freq * x_pos * TAU)) * line_panel.size.y
		target.add_point(Vector2(x_pos, y_pos), 0)
