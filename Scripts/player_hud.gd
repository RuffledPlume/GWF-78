class_name PlayerHUD extends CanvasLayer

@onready var interaction_text_label := $Interaction_Text
	
func update_interactable_label(target : Interactable) -> void:
	if target:
		interaction_text_label.visible = true
		interaction_text_label.text = target.get_interact_text()
		var current_camera := get_window().get_camera_3d()
		if current_camera != null:
			interaction_text_label.position = current_camera.unproject_position(target.global_position)
	else:
		interaction_text_label.visible = false
