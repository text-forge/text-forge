extends ActionScript

func _initialize() -> void:
	requires_file = true
	Signals.close_file.connect(_run_action)


func _run_action() -> void:
	if Global.emit_save_request(id): return
	Documents.close(Documents.active)
	Signals.check_options.emit()
