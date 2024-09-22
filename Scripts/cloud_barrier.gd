class_name CloudBarrier extends MeshInstance3D

static var instance : CloudBarrier

@export var speed : float = 0.75

func _ready() -> void:
	instance = self

func _process(delta: float) -> void:
	global_position += Vector3.UP * speed * delta
