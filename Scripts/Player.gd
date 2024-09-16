class_name Player extends CharacterBody3D

static var instance : Player

@export var mouse_sensitivity := 0.001
@export var interaction_distance := 5.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_pivot: Node3D = $CameraPivot
@onready var hud: PlayerHUD = $HUD
@onready var teleporter: Teleporter

var mouse_motion := Vector2.ZERO
var hovering_interactable : Interactable
var is_teleporting: bool

func _ready() -> void:
	instance = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

	
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	_handle_player_movement(delta)
	_handle_camera_rotation()
	_handle_interactions()
	move_and_slide()
	
func _handle_interactions() -> void:
	var ray_start := camera_pivot.global_position
	var ray_end := ray_start + (camera_pivot.global_basis * Vector3.FORWARD) * interaction_distance
	var result := get_world_3d().direct_space_state.intersect_ray(
		PhysicsRayQueryParameters3D.create(ray_start, ray_end))
	
	var new_hovering_interactable : Interactable = null
	if result:
		var collider = result["collider"]
		if collider is Interactable:
			var collider_interactable := collider as Interactable
			if collider_interactable.can_interact_with():
				new_hovering_interactable = collider_interactable
	
	hovering_interactable = new_hovering_interactable
	hud.update_interactable_label(hovering_interactable)
	
	
	
func _handle_player_movement(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * mouse_sensitivity
			
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
	if Input.is_action_just_pressed("Interact") && hovering_interactable:
		print("Player interacted with: %s" % hovering_interactable)
		hovering_interactable.on_interact_with()
			
func _handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO
