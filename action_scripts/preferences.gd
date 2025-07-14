extends ActionScript

var window: Window

func _run_action() -> void:
	window = load("res://action_scripts/scenes/preferences.tscn").instantiate()
	add_child(window)
