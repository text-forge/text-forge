extends WindowActionScript

func _check_option_extra() -> bool:
	return Project.has_project()


func _initialize() -> void:
	window_scene = "res://action_scripts/scenes/project_settings.tscn"
