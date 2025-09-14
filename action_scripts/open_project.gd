extends ActionScript

func _run_action() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM,
			["*.tfproj;Text Forge Project File"], Project.load_project, true, "",
			OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)))
