extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true

func _run_action() -> void:
	OS.shell_show_in_file_manager(Global.get_file_path())
