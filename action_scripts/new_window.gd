extends ActionScript

func _run_action() -> void:
	OS.create_process(OS.get_executable_path(), [])
