extends ActionScript

func _initialize() -> void:
	Signals.open_file.connect(_open_file)


func _run_action() -> void:
	if Global.get_file_name().ends_with("*"):
		Signals.save_request.emit(id)
		return
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, [], _open_file, true, "", Global.get_last_file_path()))


func _open_file(path: String) -> void:
	Tests.open_started.emit()
	if not FileAccess.file_exists(path):
		Global.send_notification(Global.Notification.ERROR, "Can't find this file!", "")
		return
	if path.ends_with(".tfproj"):
		Project.load_project(path)
		return
	if Project.has_project() and not path in Project.all_files:
		Project.close_project()
	Global.set_file_name(path.get_file())
	Global.set_file_path(path)
	Global.get_editor_api().load_file(path)
	Signals.check_options.emit()
