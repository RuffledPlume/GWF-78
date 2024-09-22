class_name Generator extends Interactable

@export var generator_working = false
@export var teleporter_target: TeleporterNew
@export var generator_audio: AudioStreamPlayer3D
@export var generator_light: OmniLight3D
@export var generator_fuelcell: Node3D
@export var generator_mesh_emission : Array[MeshInstance3D]

var has_fuel = false

func _ready() -> void:
	generator_light.visible = false
	generator_fuelcell.visible = false
	
	for mesh in generator_mesh_emission:
		var material := mesh.get_active_material(0) as StandardMaterial3D
		material.emission_enabled = false
		
	if teleporter_target != null:
		teleporter_target.is_working = false
		
func get_interact_text() -> String:
	if !Player.instance.has_fuel_cell:
		return "Requires Fuel Cell"
	return "Insert Fuel Cell"

func can_interact_with() -> bool:
	return !has_fuel

func on_interact_with_pressed() -> void:
	if !Player.instance.has_fuel_cell:
		return
		
	Player.instance.has_fuel_cell = false
	has_fuel = true
	generator_working = true
	generator_light.visible = true
	generator_fuelcell.visible = true
	generator_audio.play()
	
	for mesh in generator_mesh_emission:
		var material := mesh.get_active_material(0) as StandardMaterial3D
		material.emission_enabled = true
		
	if teleporter_target != null:
		teleporter_target.power_teleporter()
