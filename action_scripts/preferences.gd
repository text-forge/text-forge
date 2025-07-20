extends ActionScript

func _run_action() -> void:
	add_child(load("res://action_scripts/scenes/preferences.tscn").instantiate())
