extends Node

@onready var fade = $CanvasLayer/Control2/Fade

var fade_t: float

func _process(delta: float) -> void:
	if fade_t >= 1.0:
		return
		
	fade.modulate = Color(0.0, 0.0, 0.0, 1.0 - fade_t)
	fade_t += delta * 0.5
