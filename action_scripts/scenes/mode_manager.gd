extends Window

@export var mode_list: ItemList
@export var about: VBoxContainer
@export var mode_kit_button: Button
var mode_informations: Array[Dictionary]
var current_mode_index: int

func _ready() -> void:
	close_requested.connect(_close)
	mode_list.item_selected.connect(_show_about)
	_load_mode_list()


func _load_mode_list() -> void:
	mode_list.clear()
	mode_informations = Global.get_editor_api().mode_list
	for item in mode_informations:
		mode_list.add_item(item["name"])


func _show_about(idx) -> void:
	if mode_list.select_mode == ItemList.SELECT_MULTI:
		return
	current_mode_index = idx
	about.get_child(0).text = mode_informations[idx]["name"]
	about.get_child(1).text = mode_informations[idx]["version"]
	about.get_child(2).text = mode_informations[idx]["author"]
	about.get_child(3).text = ", ".join(mode_informations[idx]["extensions"])
	about.get_child(4).text = mode_informations[idx]["description"]
	about.show()


func _on_import_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_OPEN_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfmode,*.zip;Text Forge Modes;application/zip"], _import_mode, true, OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)))


func _import_mode(path: String) -> void:
	var reader = ZIPReader.new()
	var err := reader.open(path)
	if err:
		Global.send_notification(Global.Notification.ERROR, "Can't load this file!", "Load {0} for import mode or mode kit failed. Error code: {1}".format([path, str(err)]))
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
	Global.send_notification(Global.Notification.INFO, "Load mode / mode kit completed.")

func _close() -> void:
	queue_free()


func _on_data_changed(new_text: String) -> void:
	var config = ConfigFile.new()
	config.load(SLib.globalize_path("user://modes".path_join(mode_informations[current_mode_index]["id"]).path_join("mode.cfg")))
	config.set_value("mode", "name", about.get_child(0).text.strip_edges())
	config.set_value("mode", "version", about.get_child(1).text.strip_edges())
	config.set_value("mode", "author", about.get_child(2).text.strip_edges())
	config.set_value("mode", "extensions", Array(about.get_child(3).text.split(",")).map(func(item: String): return item.strip_edges()))
	config.set_value("mode", "description", about.get_child(4).text.strip_edges())
	config.save("user://modes".path_join(mode_informations[current_mode_index]["id"]).path_join("mode.cfg"))


func _on_edit_script_pressed() -> void:
	Signals.open_file.emit(SLib.globalize_path("user://modes".path_join(mode_informations[current_mode_index]["id"]).path_join("mode.gd")))
	_close()


func _on_export_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfmode,*.zip;Text Forge Modes;application/zip"], _export_mode, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)))


func _export_mode(path: String) -> void:
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err != OK:
		Global.send_notification(Global.Notification.ERROR, "Cann't export mode!", "Error code: " + str(err))
		return
	_add_folder_to_zip(writer, "user://modes/".path_join(mode_informations[current_mode_index]["id"]))
	writer.close()
	Global.send_notification(Global.Notification.INFO, "Export mode completed.", "Exported file: " + path)


func _add_folder_to_zip(writer: ZIPPacker, path: String) -> void:
	for file in DirAccess.get_files_at(path):
		writer.start_file(path.erase(0, 7).path_join(file))
		writer.write_file(FileAccess.get_file_as_bytes(path.path_join(file)))
		writer.close_file()
	for dir in DirAccess.get_directories_at(path):
		_add_folder_to_zip(writer, path.path_join(dir))


func _on_remove_pressed() -> void:
	var confirm := ConfirmationDialog.new()
	confirm.dialog_text = "Remove this mode from your modes? You can restore them from your trash"
	confirm.confirmed.connect(_remove_mode)
	confirm.visibility_changed.connect(func(): if not confirm.visible: confirm.queue_free())
	add_child(confirm)
	confirm.popup_centered()

func _remove_mode() -> void:
	OS.move_to_trash(SLib.globalize_path("user://modes".path_join(mode_informations[current_mode_index]["id"])))
	Global.send_notification(Global.Notification.INFO, "Remove mode completed.")
	Global.get_editor_api().reload_modes()
	_load_mode_list()
	about.hide()


func _save_package(path: String) -> void:
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err != OK:
		Global.send_notification(Global.Notification.ERROR, "Cann't export mode kit!", "Error code: " + str(err))
		return
	for index in mode_list.get_selected_items():
		_add_folder_to_zip(writer, FileDatabase.FOLDER_MODES.path_join(mode_informations[index]["id"]))
	writer.close()
	Global.send_notification(Global.Notification.INFO, "Export mode kit completed.", "Exported file: " + path)
	mode_list.select_mode = ItemList.SELECT_SINGLE
	mode_list.deselect_all()


func _on_create_kit_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mode_kit_button.text = "Export Mode Kit..."
		mode_list.select_mode = ItemList.SELECT_MULTI
		mode_list.deselect_all()
		about.hide()
	else:
		mode_kit_button.text = "Create Mode Kit..."
		if mode_list.get_selected_items() == PackedInt32Array():
			mode_list.select_mode = ItemList.SELECT_SINGLE
			mode_list.deselect_all()
			return
		add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfmode,*.zip;Text Forge Modes;application/zip"], _save_package, true, OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)))
