extends Window

const FILE_NODE_SCN: PackedScene = preload("res://action_scripts/scenes/project_file_item.tscn")

@export var details_edit: TextEdit
@export var exclude_files: VBoxContainer
@export var icon_button: Button
@export var include_files: VBoxContainer
@export var name_edit: LineEdit
@export var path_button: Button
@export var tags_edit: LineEdit

func _add_file(path, container: VBoxContainer) -> void:
	if path is PackedStringArray:
		for p in path:
			if p in container.get_children().map(func(file): return file.get_child(0).text):
				continue
			var n: HBoxContainer = FILE_NODE_SCN.instantiate()
			n.get_child(0).text = p
			n.get_child(1).pressed.connect(_remove_file.bind(p, container))
			n.show()
			container.add_child(n)
	else:
		if path in container.get_children().map(func(file): return file.get_child(0).text):
			return
		var n: HBoxContainer = FILE_NODE_SCN.instantiate()
		n.get_child(0).text = path
		n.get_child(1).pressed.connect(_remove_file.bind(path, container))
		n.show()
		container.add_child(n)


func _icon_selected(path: String) -> void:
	icon_button.text = path


func _on_create_pressed() -> void:
	if not path_button.text.to_lower().ends_with(".tfproj"):
		add_child(Factory.accept_dialog("Please select a valid .tfproj file path to save your project.",
				"Alert!", Callable(), Vector2i(500, 50), true, true))
		return
	if name_edit.text.is_empty():
		add_child(Factory.accept_dialog("Please enter a name for your project.", "Alert!",
				Callable(), Vector2i(500, 50), true, true))
		return
	if include_files.get_child_count() == 0:
		add_child(Factory.accept_dialog("Your project must include at least one file or folder.",
				"Alert!", Callable(), Vector2i(500, 50), true, true))
		return

	var config := ConfigFile.new()
	config.set_value("project", "name", name_edit.text)
	config.set_value("project", "details", details_edit.text)
	if icon_button.text.get_extension().to_lower() in FileDatabase.IMAGE_EXTS:
		config.set_value("project", "icon", Project.cache_icon(icon_button.text))
	else:
		config.set_value("project", "icon", "")
	config.set_value("project", "tags", tags_edit.text.strip_edges())
	config.set_value("project", "created", Time.get_datetime_string_from_system(false, true))
	config.set_value("project", "modified", Time.get_datetime_string_from_system(false, true))
	config.set_value("project", "version", Project.VERSION)
	config.set_value("files", "include", include_files.get_children().map(func(file):
		return file.get_child(0).text))
	config.set_value("files", "exclude", exclude_files.get_children().map(func(file):
		return file.get_child(0).text))
	config.set_value("files", "open", "")
	config.set_value("files", "caret_line", 0)
	config.set_value("files", "caret_column", 0)
	var err := config.save(path_button.text)
	if err == OK:
		Global.send_notification(Global.Notification.INFO, "New project created at {0}.".format([path_button.text]))
		queue_free()
	else:
		Global.send_notification(Global.Notification.ERROR, "Failed to save project at {0}!".format([path_button.text]), "Error code: {0}".format([err]))


func _on_add_exclude_pressed(type: int) -> void:
	add_child(Factory.file_dialog(type, FileDialog.ACCESS_FILESYSTEM, [],
	_add_file.bind(exclude_files), true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _on_icon_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM,
			["*.bmp,*.dds,*.ktx,*.exr,*.hdr,*.jpg,*.jpeg,*.png,*.tga,*.svg,*.webp;Image Files;image/bmp,image/vnd.ms-dds,image/ktx,image/exr,image/vnd.radiance,image/jpeg,image/png,image/x-tga,image/svg+xml,image/webp"],
			_icon_selected, true, OS.get_system_dir(OS.SYSTEM_DIR_PICTURES), ""))


func _on_add_include_pressed(type: int) -> void:
	add_child(Factory.file_dialog(type, FileDialog.ACCESS_FILESYSTEM, [],
	_add_file.bind(include_files), true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _on_path_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM,
			["*.tfproj;Text Forge Project File"], _path_selected, true,
			OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS), ""))


func _path_selected(path: String) -> void:
	path_button.text = path


func _remove_file(path: String, container: VBoxContainer) -> void:
	for file in container.get_children():
		if file.get_child(0).text == path:
			file.queue_free()
			break
