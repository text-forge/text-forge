extends ActionScript

func _initialize() -> void:
	Project.close_project_action_script_id = id


func _check_option_extra() -> bool:
	return Project.has_project()


func _run_action() -> void:
	if Global.emit_save_request(id): return
	Signals.close_project.emit()
