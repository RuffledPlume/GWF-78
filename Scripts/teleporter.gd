extends Area3D
class_name Teleporter

var is_within: bool = false
var is_teleporting: bool = false

@onready var point_a: Node3D = $PointA
@onready var point_b: Node3D = $PointB

	
func _process(delta: float) -> void:
	var distance = point_b.global_position.distance_to(Player.instance.global_position)
	if is_within and Input.is_action_just_pressed("Interact"):
		print("Teleporting")
		is_teleporting = true
	if is_teleporting:
		Player.instance.global_position = lerp(Player.instance.global_position, point_b.global_position, delta * 3)
	if distance <= 5.0:
		is_teleporting = false


func _on_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		print("Player in bounds")
		is_within = true

func _on_body_exited(body: Node3D) -> void:
	is_within = false
