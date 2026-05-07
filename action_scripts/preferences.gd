extends WindowActionScript

func _initialize() -> void:
	Notif.register_notification(
		"invalid_setting_type",
		Notif.Type.ERR,
		"Invalid Setting Type!",
		"There is no support for type {0} (in {1} > {2})"
	)
	window_scene = "res://action_scripts/scenes/preferences.tscn"
