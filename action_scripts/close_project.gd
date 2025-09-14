extends ActionScript

func _check_option_extra() -> bool:
	return Project.has_project()


func _run_action() -> void:
	Project.close_project()
