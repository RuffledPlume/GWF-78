extends Area3D

func _ready() -> void:
	body_entered.connect(_on_body_enter)
	
func _on_body_enter(body: Node3D) -> void:
	if body == Player.instance:
		Player.instance.breath = 0.0
		Player.instance.health = 0.0
