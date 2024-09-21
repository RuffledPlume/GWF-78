class_name TeleporterFrequency extends Node3D

@export var tuning_line_renderer : Line2D
@export var target_line_renderer : Line2D
@export var tuning_label : Label
@export var curve_resolution := 150
@export var frequency_crank : TeleporterCrank
@export var amplitude_crank : TeleporterCrank

var _target_freq_frac: float
var _target_amp_frac: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var current_freq := lerpf(0.25, 0.3, frequency_crank._frac)
	var current_amp := amplitude_crank._frac * 0.5
		
	tuning_label.text = "Frequency: %f | Amplitude: %f" % [current_freq, current_amp]
	_update_curve(tuning_line_renderer, current_freq, current_amp)

func set_target(freq_frac: float, amp_frac: float) -> void:
	_target_freq_frac = freq_frac
	_target_amp_frac = amp_frac
	_update_curve(target_line_renderer, lerpf(0.25, 0.3, _target_freq_frac), _target_amp_frac * 0.5)

func _update_curve(target: Line2D, freq: float, amp : float) -> void:
	target.clear_points()
	var line_panel := tuning_line_renderer.get_parent() as Panel
	for i in curve_resolution:
		var x_pos := line_panel.size.x * (i / float(curve_resolution))
		var y_pos := (0.5 + amp * sin(freq * x_pos * TAU)) * line_panel.size.y
		target.add_point(Vector2(x_pos, y_pos), 0)
