extends ActionScript

func _initialize() -> void:
	Signals.new_file.connect(_run_action)

func _run_action() -> void:
	if Global.get_file_name().ends_with("*"):
		Signals.save_request.emit(id)
		return
	Global.set_file_name("New file")
	Global.set_file_path("Unsaved")
	Global.set_editor_text("")
	Global.set_editor_disabled(false)
	Signals.check_options.emit()
