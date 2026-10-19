extends ActionScript

func _initialize() -> void:
	get_window().close_requested.connect(_close)


# To send signal to whole editor
func _run_action() -> void:
	get_window().close_requested.emit()


## Closes every document one by one, asking about the unsaved ones, and quits once none is left.
func _close() -> void:
	if not Documents.close_all(id): return
	await get_tree().process_frame
	get_tree().quit()
