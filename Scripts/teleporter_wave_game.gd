class_name TeleporterFrequency extends Panel

@onready var line_renderer := $Line2D

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
	
	var count := 100
	line_renderer.clear_points()
	for i in count:
		var x_pos := size.x * (i / float(count))
		var y_pos := (0.5 + current_amp * sin(_last_freq * x_pos * TAU)) * size.y
		line_renderer.add_point(Vector2(x_pos, y_pos), 0)
	
