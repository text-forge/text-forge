extends ActionScript

func _initialize() -> void:
	Signals.open_file.connect(_open_file)
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, [], _open_file, false))

func _run_action() -> void:
	if Global.get_file_name().ends_with("*"):
		Signals.save_request.emit(id)
		return
	get_child(0).show()


func _open_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		Global.send_notification(Global.Notification.ERROR, "Can't find this file!", "")
		return
	Global.set_file_name(path.get_file())
	Global.set_file_path(path)
	Global.get_editor_api().load_file(path)
	_append_to_recent_files(path)
	Signals.check_options.emit()


func _append_to_recent_files(path: String) -> void:
	var file = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.READ)
	var files = file.get_as_text() if FileAccess.file_exists(FileDatabase.RECENT_FILES_DATA) else ""
	if FileAccess.file_exists(FileDatabase.RECENT_FILES_DATA):
		file.close()
	file = FileAccess.open(FileDatabase.RECENT_FILES_DATA, FileAccess.WRITE)
	file.store_string(path + "\n" + files)
	file.close()
	Signals.reload_recent_files.emit()
	menu.set_item_disabled(menu.get_item_index(id + 1), Global.get_core().recent_files_submenu.item_count == 0)
