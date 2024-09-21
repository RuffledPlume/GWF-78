extends Area3D

@export var text: String

var _hasbeenseen : bool

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node3D) -> void:
	if _hasbeenseen:
		return
	
	if body == Player.instance:
		PlayerHUD.instance.show_didyouknow(text)
		_hasbeenseen = true
