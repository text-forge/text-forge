extends ActionScript

var last_path := ""

func _initialize() -> void:
	Signals.open_file.connect(_open_file)


func _run_action() -> void:
	if Global.emit_save_request(id): return
	if last_path:
		_open_file(last_path)
	else:
		add_child(Factory.file_dialog(
			FileDialog.FILE_MODE_OPEN_FILE,
			FileDialog.ACCESS_FILESYSTEM,
			[],
			_open_file,
			true,
			"",
			Global.get_last_file_path()
		))


func _open_file(path: String = "") -> void:
	if Global.emit_save_request(id):
		last_path = path
		return
	last_path = ""
	Tests.open_started.emit()
	if not FileAccess.file_exists(path):
		Notif.notif("file_not_found", {"text": path})
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
