class_name Player extends CharacterBody3D

static var instance : Player

@export var mouse_sensitivity := 0.001
@export var interaction_distance := 5.0
@export var breath_replenishment_rate := 0.5
@export var breath_depletion_rate := 0.025
@export var oxygen_depletion_rate := 0.05

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera_pivot: Node3D = $CameraPivot
@onready var mask_animator := $CameraPivot/Camera3D/AnimationPlayer
@onready var mask_root := $CameraPivot/Camera3D/Mask

var mouse_motion := Vector2.ZERO
var hovering_interactable : Interactable
var is_teleporting: bool
var has_put_on_mask : bool
var oxygen_reserve : float = 1.0
var breath : float = 1.0
var last_input : Vector2
var is_within_safe_zone : bool

func _ready() -> void:
	instance = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mask_root.visible = false
	
func _process(delta: float) -> void:
	if is_within_safe_zone:
		if breath < 1.0:
			breath += breath_replenishment_rate * delta
		if oxygen_reserve < 1.0:
			oxygen_reserve += breath_replenishment_rate * delta
		return
	
	var depltion_rate := breath_depletion_rate
	if last_input.length() > 0.1:
		if Input.is_action_pressed("UseMask"):
			depltion_rate *= 2.0
		else:
			depltion_rate *= 1.5
	breath -= depltion_rate * delta
	
	if Input.is_action_pressed("UseMask"):
		if !has_put_on_mask:
			mask_animator.play("Mask_Place")
			has_put_on_mask = true
		elif !mask_animator.is_playing():
			if breath < 1.0 && oxygen_depletion_rate > 0.0:
				breath += (breath_depletion_rate + breath_replenishment_rate) * delta
				oxygen_reserve -= oxygen_depletion_rate * delta
	elif has_put_on_mask:
		mask_animator.play_backwards("Mask_Place")
		has_put_on_mask = false
	
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
	PlayerHUD.instance.update_interactable_label(hovering_interactable)
	
			
func _handle_player_movement(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var Current_Speed := SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		Current_Speed *= 2.0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * Current_Speed
		velocity.z = direction.z * Current_Speed
	else:
		velocity.x = move_toward(velocity.x, 0, Current_Speed)
		velocity.z = move_toward(velocity.z, 0, Current_Speed)
		
	last_input = input_dir

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
