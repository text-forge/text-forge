extends ActionScript

func _run_action() -> void:
	add_child(load("res://action_scripts/scenes/command_pallete.tscn").instantiate())
