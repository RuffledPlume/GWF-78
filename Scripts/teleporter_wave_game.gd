extends Panel

@onready var line_renderer := $Line2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var temp_freq := 0.01
var temp_amp := 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT):
		temp_freq -= 0.01 * delta
	elif Input.is_key_pressed(KEY_RIGHT):
		temp_freq += 0.01 * delta
		
	if Input.is_key_pressed(KEY_UP):
		temp_amp -= 0.1 * delta
	elif Input.is_key_pressed(KEY_DOWN):
		temp_amp += 0.1 * delta
		
	update_line(temp_freq, temp_amp)
	
func update_line(freq: float, amp: float) -> void:
	var count := 100
	line_renderer.clear_points()
	for i in count:
		var x_pos := size.x * (i / float(count))
		var y_pos := (0.5 + amp * sin(freq * x_pos * TAU)) * size.y
		line_renderer.add_point(Vector2(x_pos, y_pos), 0)
