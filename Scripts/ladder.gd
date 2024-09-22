extends Area3D

var _is_within : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !_is_within:
		return
	
	Player.instance.fall_time = 0
	if global_basis.z.dot(Player.instance.direction.normalized()) < 0.0:
		Player.instance.velocity.x = 0.0
		Player.instance.velocity.y = 5.0 * Player.instance.camera_pivot.rotation.x
		Player.instance.velocity.z = 0.0
	else:
		Player.instance.velocity.y = 0.0

func _on_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		_is_within = true
		
func _on_body_exited(body: Node3D) -> void:
	if body == Player.instance:
		_is_within = false
