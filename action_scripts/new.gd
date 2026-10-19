extends ActionScript

func _initialize() -> void:
	Signals.new_file.connect(_run_action)


func _run_action() -> void:
	if Global.emit_save_request(id): return
	var doc := Documents.create("Unsaved", "New file", "", true)
	if not doc:
		return
	Documents.activate(doc)
	Signals.check_options.emit()
	doc.editor.type_timer_timeout.emit()
