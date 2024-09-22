extends Node

@onready var music: AudioStreamPlayer = $Music
@onready var music_fast: AudioStreamPlayer = $MusicFast
@onready var timer: Timer = $Timer
@onready var music_swap_timer: Timer = $MusicSwapTimer
@onready var first_area: Area3D = $Area3D
@onready var second_area: Area3D = $SecondArea
@onready var thunder_clap: AudioStreamPlayer = $ThunderClap

var trigger_slow_music = false
var trigger_fast_music = false

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if trigger_fast_music:
		music.volume_db -= 15 * delta
		music_fast.volume_db += 5 * delta
		
		if music.volume_db <= -60:
			music.volume_db = -60
		
		if music_fast.volume_db >= -15:
			music_fast.volume_db = -15
			
	if trigger_slow_music:
		music_fast.volume_db -= 20 * delta
		music.volume_db += 0.5 * delta
		
		if music_fast.volume_db <= -60:
			music_fast.volume_db = -60
			
		if music.volume_db >= - 25:
			music.volume_db = -25

func _on_timer_timeout() -> void:
	music.play()
	
func _play_song() -> void:
	music.play()
	
func _play_fast_song() -> void:
	music_fast.play()

func _play_thunder() -> void:
	thunder_clap.play()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		trigger_fast_music = true
		music_fast.volume_db = -60
		_play_thunder()
		_play_fast_song()

func _on_area_3d_body_exited(body: Node3D) -> void:
	first_area.queue_free()

func _on_second_area_body_entered(body: Node3D) -> void:
	if body == Player.instance:
		trigger_fast_music = false
		trigger_slow_music = true
		music.volume_db = -60

func _on_second_area_body_exited(body: Node3D) -> void:
	second_area.queue_free()
