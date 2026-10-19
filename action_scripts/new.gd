extends ActionScript

func _initialize() -> void:
	Signals.new_file.connect(_run_action)


## A new file opens its own tab, it never replaces the active document, so nothing needs saving.
func _run_action() -> void:
	var doc := Documents.create("Unsaved", "New file", "", true)
	if not doc:
		return
	Documents.activate(doc)
	Signals.check_options.emit()
	doc.editor.type_timer_timeout.emit()
