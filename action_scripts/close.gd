extends ActionScript

func _initialize() -> void:
	requires_file = true
	Signals.close_file.connect(_run_action)


func _run_action() -> void:
	if Global.has_unsaved_change():
		Signals.save_request.emit(id)
		return

	Global.set_file_name("There is no opened file")
	Global.set_file_path("")
	Global.set_editor_text("")
	Global.set_editor_disabled(true)
	Signals.check_options.emit()
