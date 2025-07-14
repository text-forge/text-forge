extends ActionScript

func _run_action():
	if Global.get_file_name().ends_with("*"):
		Signals.save_request.emit(id)
		return
	SLib.os_open(OS.get_executable_path())
	get_window().close_requested.emit()
