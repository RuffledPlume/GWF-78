extends Interactable

@export var wheel_root : Node3D
@export var step_size := 0.01

var _frac : float
var _grab_position : Vector3

func get_interact_text() -> String:
	return "Turn Crank"

func can_interact_with() -> bool:
	return true

func on_interact_with_pressed() -> void:
	_grab_position = Player.instance.hovering_interactable_position

func on_interact_with_held() -> void:
	var new_grab_position := Player.instance.hovering_interactable_position
	if _grab_position.distance_to(new_grab_position) > 0.1:
		var center_to_grab := (new_grab_position - global_position).normalized()
		var grab_normal := center_to_grab.cross(global_basis * Vector3.FORWARD).normalized()
		var grab_plane := Plane(grab_normal, _grab_position)
		if grab_plane.is_point_over(new_grab_position):
			if _frac > 0.0:
				wheel_root.rotate_z(-0.25)
				_frac -= step_size
		else:
			if _frac < 1.0:
				wheel_root.rotate_z(0.25)
				_frac += step_size
		_grab_position = new_grab_position
