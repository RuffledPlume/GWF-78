class_name PlayerHUD extends CanvasLayer

static var instance : PlayerHUD

@onready var interaction_text_label := $Interaction_Text
@onready var oxygen_bar := $Bars/O2_Bar
@onready var breath_bar := $Bars/Breath_Bar
@onready var Vinette := $Vignette

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	var breath := Player.instance.breath
	breath_bar.value = breath * 100.0
	oxygen_bar.value = Player.instance.oxygen_reserve * 100.0
	if breath < 0.4:
		Vinette.modulate = Color(1.0, 1.0, 1.0, (0.4 - breath) / 0.4)
	else:
		Vinette.modulate = Color.TRANSPARENT

func update_interactable_label(target : Interactable) -> void:
	if target:
		interaction_text_label.visible = true
		interaction_text_label.text = target.get_interact_text()
		var current_camera := get_window().get_camera_3d()
		if current_camera != null:
			interaction_text_label.position = current_camera.unproject_position(target.global_position)
	else:
		interaction_text_label.visible = false
