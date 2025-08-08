extends ActionScript

var callback: int = -1
var dialog: FileDialog

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM, [], _save_file, true, "", Global.get_file_path()))

func _save_file(path: String) -> void:
	Global.get_editor_api().save_file(path)
	Global.set_file_name(path.get_file())
	Global.set_file_path(path)
	Signals.save_finished.emit(callback)
	callback = -1
