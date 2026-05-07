extends ActionScript

func _initialize() -> void:
	Notif.register_notification(
		"restart_editor_failed",
		Notif.Type.ERR,
		"Failed to restart the editor!",
		"Creating new instance of editor failed."
	)


func _run_action() -> void:
	if Global.emit_save_request(id): return
	var pid := OS.create_process(OS.get_executable_path(), [])
	if pid != -1:
		get_window().close_requested.emit()
	else:
		Notif.notif("restart_editor_failed")
