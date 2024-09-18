class_name CubeMapCapture extends Node3D

@onready var _viewport : SubViewport = $SubViewport
@onready var _camera : Camera3D = $SubViewport/Camera3D

var _directions = [Vector3(1, 0, 0), Vector3(-1, 0, 0),  Vector3(0, 1, 0), Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(0, 0, -1) ]
var _upwards = [ Vector3(0, -1, 0), Vector3(0, -1, 0), Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(0, -1, 0), Vector3(0, -1, 0) ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_camera.fov = 90.0
	_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func capture(position: Vector3, target: Cubemap) -> void:
	_camera.global_position = position
	await _viewport.get_tree().process_frame
	
	var captured_faces : Array[Image]
	captured_faces.resize(_directions.size())
	for face in _directions.size():
		_camera.basis = Basis.looking_at(_directions[face], _upwards[face])
		_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
		await _viewport.get_tree().process_frame
		captured_faces[face] = Image.new()
		captured_faces[face].copy_from(_viewport.get_texture().get_image())
		captured_faces[face].flip_y()
	
	target.create_from_images(captured_faces)
