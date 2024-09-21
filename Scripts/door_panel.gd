extends Interactable

@export var Slide_Amount := 1.0
@export var Slide_Speed := 0.6
@export var Close_Delay := 5.0
@export var Close_Zone : Area3D

@onready var LeftDoor :=  $"../../DoorPanel_Left"
@onready var RightDoor := $"../../DoorPanel_Right"

var current_t := 0.0
var delay := 0.0
var is_closed := true
var is_player_in_bounds := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Close_Zone:
		Close_Zone.body_entered.connect(_on_body_entered)
		Close_Zone.body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var offset := 0.0
	if is_closed:
		offset = lerp(Slide_Amount, 0.0, current_t)
	else:
		offset = lerp(0.0, Slide_Amount, current_t)
	
	LeftDoor.position = Vector3.FORWARD * offset
	RightDoor.position = Vector3.BACK * offset
	
	current_t = min(current_t + delta * Slide_Speed, 1.0)
	
	if !is_closed && current_t == 1.0:
		if is_player_in_bounds:
			delay = Close_Delay
		else:
			delay -= delta
			
		if delay <= 0.0:
			is_closed = true
			current_t = 0.0
		

func get_interact_text() -> String:
	return "Open Door"

func can_interact_with() -> bool:
	return is_closed
	
func on_interact_with_pressed() -> void:
	if !is_closed:
		return
		
	is_closed = false
	current_t = 0.0
	delay = Close_Delay
	
func _on_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		is_player_in_bounds = true
	
func _on_body_exited(body: Node3D) -> void:
	if body == Player.instance:
		is_player_in_bounds = false
