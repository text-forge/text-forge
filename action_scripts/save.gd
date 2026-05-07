extends ActionScript

var callback: int = -1

func _initialize() -> void:
	Signals.force_save.connect(_run_action)
	requires_file = true


func _run_action() -> void:
	if Global.get_file_path() == "Unsaved":
		Global.get_scripts_node().get_node("save_as").callback = callback
		callback = -1
		Signals.run_script.emit(id + 1)
		Signals.force_save_finished.emit()
		return
	if not Global.has_unsaved_change():
		if callback != -1:
			Signals.save_finished.emit(callback)
			callback = -1
		Signals.force_save_finished.emit()
		return
	_save_file(Global.get_file_path())
	Global.set_file_name(Global.get_file_name().replace("*", ""))
	Signals.force_save_finished.emit()


func _save_file(path: String) -> void:
	Global.get_editor_api().save_file(path)
	if callback != -1:
		Signals.save_finished.emit(callback)
		callback = -1
