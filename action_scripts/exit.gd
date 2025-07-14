extends ActionScript

func _initialize() -> void:
	get_window().close_requested.connect(func():_close())


# To send signal to whole editor
func _run_action() -> void:
	get_window().close_requested.emit()


func _close() -> void:
	if Global.get_file_name().ends_with("*"):
		Signals.save_request.emit(id)
		return
	await get_tree().process_frame
	SLib.exit()
