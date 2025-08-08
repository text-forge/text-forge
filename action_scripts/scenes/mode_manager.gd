extends Window

@export var mode_list: ItemList
@export var about: VBoxContainer
@export var package_button: Button
var modes: PackedStringArray
var current_mode_index: int

func _ready() -> void:
	close_requested.connect(_close)
	mode_list.item_selected.connect(_show_about)
	_load_mode_list()


func _show_about(idx) -> void:
	if mode_list.select_mode == ItemList.SELECT_MULTI: return
	var config = ConfigFile.new()
	current_mode_index = idx
	config.load("user://modes".path_join(modes[idx]).path_join("mode.cfg"))
	about.get_child(0).text = config.get_value("mode", "name", "")
	about.get_child(1).text = str(config.get_value("mode", "version", 0))
	about.get_child(2).text = config.get_value("mode", "author", "")
	about.get_child(3).text = ", ".join(config.get_value("mode", "extensions", []))
	about.get_child(4).text = config.get_value("mode", "description", "")
	about.show()


func _load_mode_list() -> void:
	mode_list.clear()
	modes = DirAccess.get_directories_at("user://modes")
	var config = ConfigFile.new()
	for item in modes:
		config.load("user://modes".path_join(item).path_join("mode.cfg"))
		mode_list.add_item(config.get_value("mode", "name", "Unnamed mode"))


func _on_import_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfmode,*.zip;Text Forge Modes;application/zip"], _import_mode, true, OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)))


# from official docs
func _import_mode(path: String) -> void:
	var reader = ZIPReader.new()
	var err := reader.open(path)
	if err:
		Global.send_notification(Global.Notification.ERROR, "Can't load this file!", "Load {0} for import mode or package failed. Error code: {1}".format([path, str(err)]))
		return

	if not DirAccess.dir_exists_absolute(SLib.globalize_path("user://modes")):
		DirAccess.make_dir_absolute(SLib.globalize_path("user://modes"))
	var root_dir = DirAccess.open("user://modes")

	var files = reader.get_files()
	for file_path in files:
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue

		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)

	Global.get_editor_api().reload_modes()
	_load_mode_list()
	Global.send_notification(Global.Notification.INFO, "Load mode / package completed.")

func _close() -> void:
	queue_free()


func _on_data_changed(new_text: String) -> void:
	var config = ConfigFile.new()
	config.load("user://modes".path_join(modes[current_mode_index]).path_join("mode.cfg"))
	config.set_value("mode", "name", about.get_child(0).text.strip_edges())
	config.set_value("mode", "version", about.get_child(1).text.strip_edges())
	config.set_value("mode", "author", about.get_child(2).text.strip_edges())
	config.set_value("mode", "extensions", Array(about.get_child(3).text.split(",")).map(func(item: String): return item.strip_edges()))
	config.set_value("mode", "description", about.get_child(4).text.strip_edges())
	config.save("user://modes".path_join(modes[current_mode_index]).path_join("mode.cfg"))


func _on_edit_script_pressed() -> void:
	Signals.open_file.emit(SLib.globalize_path("user://modes".path_join(modes[current_mode_index]).path_join("mode.gd")))


func _on_export_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfmode,*.zip;Text Forge Modes;application/zip"], _export_mode, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)))


func _export_mode(path: String) -> void:
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err != OK:
		Global.send_notification(Global.Notification.ERROR, "Cann't export mode!", "Error code: " + str(err))
		return
	writer.start_file(modes[current_mode_index].path_join("mode.cfg"))
	var file := FileAccess.open("user://modes".path_join(modes[current_mode_index]).path_join("mode.cfg"), FileAccess.READ)
	writer.write_file(file.get_as_text().to_utf8_buffer())
	writer.close_file()
	file.close()
	writer.start_file(modes[current_mode_index].path_join("mode.gd"))
	file = FileAccess.open("user://modes".path_join(modes[current_mode_index]).path_join("mode.gd"), FileAccess.READ)
	writer.write_file(file.get_as_text().to_utf8_buffer())
	writer.close_file()
	file.close()

	writer.close()
	Global.send_notification(Global.Notification.INFO, "Export mode completed.", "Exported file: " + path)


func _on_remove_pressed() -> void:
	var confirm := ConfirmationDialog.new()
	confirm.dialog_text = "Remove this mode from your modes? You can restore them from your trash"
	confirm.confirmed.connect(_remove_mode)
	confirm.visibility_changed.connect(func(): if not confirm.visible: confirm.queue_free())
	add_child(confirm)
	confirm.popup_centered()

func _remove_mode() -> void:
	OS.move_to_trash(SLib.globalize_path("user://modes".path_join(modes[current_mode_index])))
	Global.send_notification(Global.Notification.INFO, "Remove mode completed.")
	Global.get_editor_api().reload_modes()
	_load_mode_list()
	about.hide()


func _save_package(path: String) -> void:
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err != OK:
		Global.send_notification(Global.Notification.ERROR, "Cann't export package!", "Error code: " + str(err))
		return
	for index in mode_list.get_selected_items():
		writer.start_file(modes[index].path_join("mode.cfg"))
		var file := FileAccess.open("user://modes".path_join(modes[index]).path_join("mode.cfg"), FileAccess.READ)
		writer.write_file(file.get_as_text().to_utf8_buffer())
		writer.close_file()
		file.close()
		writer.start_file(modes[index].path_join("mode.gd"))
		file = FileAccess.open("user://modes".path_join(modes[index]).path_join("mode.gd"), FileAccess.READ)
		writer.write_file(file.get_as_text().to_utf8_buffer())
		writer.close_file()
		file.close()

	writer.close()
	Global.send_notification(Global.Notification.INFO, "Export package completed.", "Exported file: " + path)
	mode_list.select_mode = ItemList.SELECT_SINGLE
	mode_list.deselect_all()


func _on_create_package_toggled(toggled_on: bool) -> void:
	if toggled_on:
		package_button.text = "Export Package..."
		mode_list.select_mode = ItemList.SELECT_MULTI
		mode_list.deselect_all()
		about.hide()
	else:
		package_button.text = "Create Package..."
		if mode_list.get_selected_items() == PackedInt32Array():
			mode_list.select_mode = ItemList.SELECT_SINGLE
			mode_list.deselect_all()
			return
		add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfmode,*.zip;Text Forge Modes;application/zip"], _save_package, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)))
