extends Node3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		Player.instance._handle_cough_audio()
		Player.instance.breath = Player.instance.breath / 1.25
