class_name Player extends CharacterBody3D

static var instance : Player

@export var mouse_sensitivity := 0.001
@export var interaction_distance := 5.0
@export var breath_replenishment_rate := 0.5
@export var breath_depletion_rate := 0.025
@export var oxygen_depletion_rate := 0.05
@export var direction: Vector3

@export var speed = 3.0

const JUMP_VELOCITY = 4.5

@onready var camera_pivot: Node3D = $CameraPivot
@onready var mask_animator := $CameraPivot/Camera3D/AnimationPlayer
@onready var mask_root := $CameraPivot/Camera3D/Mask
@onready var footsteps_audio: AudioStreamPlayer3D = $CameraPivot/Camera3D/FootstepsAudio
@onready var run_audio: AudioStreamPlayer3D = $CameraPivot/Camera3D/RunAudio
@onready var breath_audio: AudioStreamPlayer3D = $CameraPivot/Camera3D/BreathAudio
@onready var cough_audio: AudioStreamPlayer3D = $CameraPivot/Camera3D/CoughAudio


var current_speed: float
var mouse_motion := Vector2.ZERO
var is_teleporting: bool
var has_put_on_mask : bool
var oxygen_reserve : float = 1.0
var breath : float = 1.0
var last_input : Vector2
var is_within_safe_zone : bool
var is_walking: bool
var is_sprinting: bool
var shown_breath_dyk: bool

var hovering_interactable : Interactable
var hovering_interactable_position : Vector3

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

	if breath < 0.4 && !shown_breath_dyk:
		PlayerHUD.instance.show_didyouknow("You can hold right click to take a breath of oxygen!")
		shown_breath_dyk = true
	
	var is_above_cloud := camera_pivot.global_position.y > CloudBarrier.instance.global_position.y
	if Input.is_action_pressed("UseMask") && is_above_cloud:
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
				hovering_interactable_position = result["position"]
	
	if hovering_interactable != new_hovering_interactable:
		if hovering_interactable != null && Input.is_action_pressed("Interact"):
			hovering_interactable.on_interact_with_released()
	
	hovering_interactable = new_hovering_interactable
	
	if hovering_interactable != null:
		if Input.is_action_just_pressed("Interact"):
			hovering_interactable.on_interact_with_pressed()
		elif Input.is_action_pressed("Interact"):
			hovering_interactable.on_interact_with_held()
		elif Input.is_action_just_released("Interact"):
			hovering_interactable.on_interact_with_released()
			
	
	PlayerHUD.instance.update_interactable_label(hovering_interactable)
	
			
func _handle_player_movement(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	current_speed = speed
	if Input.is_key_pressed(KEY_SHIFT):
		is_sprinting = true
		current_speed *= 1.5
		breath_depletion_rate = 0.050
	else:
		is_sprinting = false
		breath_depletion_rate = 0.025
		
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		is_walking = true
		
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	else:
		is_walking = false
		
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
		
	last_input = input_dir

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * mouse_sensitivity
			
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
func _handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO

func _handle_footstep_audio() -> void:
	if is_on_floor() and !is_sprinting:
		footsteps_audio.pitch_scale = randf_range(0.5, 0.8)
		footsteps_audio.play()

func _handle_run_audio() -> void:
	if is_on_floor() and is_sprinting:
		run_audio.pitch_scale = randf_range(0.6, 1.0)
		run_audio.play()

func _handle_breath_audio() -> void:
	breath_audio.play()
	
func _handle_cough_audio() -> void:
	cough_audio.play()
