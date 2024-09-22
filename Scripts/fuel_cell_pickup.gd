extends Interactable

func get_interact_text() -> String:
	return "Pickup Fuel Cell"

func can_interact_with() -> bool:
	return !Player.instance.has_fuel_cell

func on_interact_with_pressed() -> void:
	Player.instance.has_fuel_cell = true
	queue_free()
