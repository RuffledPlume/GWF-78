class_name PlayerHUD extends CanvasLayer

static var instance : PlayerHUD

@onready var interaction_text_label := $Interaction_Text
@onready var oxygen_bar := $Bars/O2_Bar
@onready var breath_bar := $Bars/Breath_Bar
@onready var Vinette := $Vignette
@onready var didyouknow_root : Panel = $DidYouKnow
@onready var didyouknow_label : Label = $DidYouKnow/Label
@onready var fog_overlay := $FogBarrier
@onready var fade_overlay := $FogBarrier

@export var didyouknow_trivia : Array[String]
@export var didyouknow_trivia_delay := 60

var _show_didyouknow := false
var _frac_didyouknow := 0.0
var _delay_didyouknow := 0.0
var _delay_random_trivia := -1.0
var _should_fade_in: bool = true
var _should_fade_out: bool
var _fade_t: float

func _ready() -> void:
	instance = self
	didyouknow_root.position.x = -didyouknow_root.size.x
	didyouknow_root.visible = false
	
	_delay_random_trivia = didyouknow_trivia_delay

func _process(delta: float) -> void:
	var breath := Player.instance.breath
	breath_bar.value = breath * 100.0
	oxygen_bar.value = Player.instance.oxygen_reserve * 100.0
	if breath < 0.4:
		Vinette.modulate = Color(1.0, 1.0, 1.0, (0.4 - breath) / 0.4)
	else:
		Vinette.modulate = Color.TRANSPARENT
		
	if _show_didyouknow:
		if _frac_didyouknow < 1.0:
			didyouknow_root.position.x = lerpf(-didyouknow_root.size.x, 0.0, _frac_didyouknow)
			_frac_didyouknow += 2.0 * delta
		else:
			_delay_didyouknow -= delta
			if _delay_didyouknow <= 0.0:
				_show_didyouknow = false
	else:
		if _frac_didyouknow > 0.0:
			_frac_didyouknow -= 2.0 * delta
			didyouknow_root.position.x = lerpf(-didyouknow_root.size.x, 0.0, _frac_didyouknow)
		else:
			didyouknow_root.visible = false
			
		_delay_random_trivia -= delta
		if _delay_random_trivia <= 0.0:
			show_didyouknow(didyouknow_trivia.pick_random())
			
			
	var fog_overlay_modulate = fog_overlay.modulate
	var cloud_distance := Player.instance.global_position.y - (CloudBarrier.instance.global_position.y + 5.0)
	if cloud_distance < 5.0:
		fog_overlay_modulate.a = 0.5 * (1.0 - clamp(cloud_distance / 5.0, 0.0, 1.0))
	else:
		fog_overlay_modulate.a = 0.0
		
	fog_overlay.modulate = fog_overlay_modulate
	
	if _should_fade_in:
		fade_overlay.modulate = Color(0.0, 0.0, 0.0, 1.0 - _fade_t)
		if _fade_t < 1.0:
			_fade_t += delta * 0.5
		else:
			_should_fade_in = false
			_fade_t = 0.0
	else:
		if _should_fade_out:
			fade_overlay.modulate = Color(0.0, 0.0, 0.0, _fade_t)
			if _fade_t < 1.0:
				_fade_t += delta * 0.5
		else:
			fade_overlay.modulate = Color(0.0, 0.0, 0.0, 1.0 - Player.instance.health)
			

func update_interactable_label(target : Interactable) -> void:
	if target:
		interaction_text_label.visible = true
		interaction_text_label.text = target.get_interact_text()
		var current_camera := get_window().get_camera_3d()
		if current_camera != null:
			interaction_text_label.position = current_camera.unproject_position(target.global_position)
	else:
		interaction_text_label.visible = false

func show_didyouknow(text: String) -> void:
	_show_didyouknow = true
	_frac_didyouknow = 0.0
	_delay_didyouknow = 6.0
	didyouknow_label.text = text
	didyouknow_root.position.x = -didyouknow_root.size.x
	didyouknow_root.visible = true
	_delay_random_trivia = didyouknow_trivia_delay
