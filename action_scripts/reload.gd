extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true

func _run_action() -> void:
	if Global.get_file_name().ends_with("*"):
		Signals.save_request.emit(id)
		return
	Signals.open_file.emit(Global.get_file_path())
