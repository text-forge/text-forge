class_name ModeManager
extends Window
## A window to view, modify, install, and export modes.

## [ItemList] of mode items.
@export var mode_list: ItemList
## About mode container.
@export var about: VBoxContainer
## Create mode kit button.
@export var mode_kit_button: Button
## Information of all modes.
var mode_informations: Array[Dictionary]
## Current mode in about box.
var current_mode_index: int

func _ready() -> void:
	Notif.register_notification(
		"export_mode_failed",
		Notif.Type.ERR,
		"Can't export mode!",
		"Error: ",
	)
	Notif.register_notification(
		"export_mode_completed",
		Notif.Type.INFO,
		"Export mode completed.",
		"Exported file: ",
	)
	Notif.register_notification(
		"remove_mode_failed",
		Notif.Type.ERR,
		"Failed to remove mode!",
		"Error: ",
	)
	Notif.register_notification(
		"remove_mode_completed",
		Notif.Type.INFO,
		"Remove mode completed.",
	)
	mode_list.item_selected.connect(_show_about)
	_load_mode_list()


func _load_mode_list() -> void:
	mode_list.clear()
	mode_informations = Global.get_editor_api().mode_list
	for item in mode_informations:
		mode_list.add_item(item["name"])


func _show_about(idx: int) -> void:
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
	add_child(Factory.file_dialog(
		FileDialog.FILE_MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		["*.tfmode;Text Forge Modes;application/zip"],
		_import_mode,
		true,
		OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	))


func _import_mode(path: String) -> void:
	Global.get_editor_api().import_mode(path)
	_load_mode_list()


func _on_data_changed(_new_text: String) -> void:
	var config = ConfigFile.new()
	var err := config.load(S.globalize_path("user://modes".path_join(mode_informations[current_mode_index]["id"]).path_join("mode.cfg")))
	if err:
		add_child(Factory.accept_dialog(
			"Failed to load mode information: Error " + str(err),
			"Failed to change mode information!"
		))
		return
	config.set_value("mode", "name", about.get_child(0).text.strip_edges())
	config.set_value("mode", "version", about.get_child(1).text.strip_edges())
	config.set_value("mode", "author", about.get_child(2).text.strip_edges())
	config.set_value(
		"mode",
		"extensions",
		Array(about.get_child(3).text.split(","))\
		.map(func(item: String): return item.strip_edges())\
		.filter(func(item: String): return not item.is_empty())
	)
	config.set_value("mode", "description", about.get_child(4).text.strip_edges())
	err = config.save(S.globalize_path("user://modes".path_join(mode_informations[current_mode_index]["id"]).path_join("mode.cfg")))
	if err:
		add_child(Factory.accept_dialog(
			"Failed to update mode information: Error " + str(err),
			"Failed to change mode information!"
		))


func _on_edit_script_pressed() -> void:
	Signals.open_file.emit(
		S.globalize_path("user://modes".path_join(mode_informations[current_mode_index]["id"]).path_join("mode.gd"))
		)
	queue_free()


func _on_export_pressed() -> void:
	add_child(Factory.file_dialog(
		FileDialog.FILE_MODE_SAVE_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		["*.tfmode;Text Forge Modes;application/zip"],
		_export_mode,
		true,
		OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	))


func _export_mode(path: String) -> void:
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err:
		Notif.notif(
			"export_mode_failed",
			{"text_append": error_string(err)}
		)
		return
	_add_folder_to_zip(writer, "user://modes/".path_join(mode_informations[current_mode_index]["id"]))
	writer.close()
	Notif.notif(
		"export_mode_completed",
		{"text_append": path},
	)


func _add_folder_to_zip(writer: ZIPPacker, path: String) -> void:
	for file in DirAccess.get_files_at(path):
		var file_bytes := FileAccess.get_file_as_bytes(path.path_join(file))
		if FileAccess.get_open_error():
			push_warning("Failed to read file: " + path.path_join(file))
			continue
		writer.start_file(path.erase(0, 7).path_join(file))
		writer.write_file(file_bytes)
		writer.close_file()
	for dir in DirAccess.get_directories_at(path):
		_add_folder_to_zip(writer, path.path_join(dir))


func _on_remove_pressed() -> void:
	add_child(Factory.confirmation_dialog(
		"Remove this mode from your modes? You can restore it from your system trash.",
		"Yes, remove",
		"Cancel",
		"Remove Mode?",
		Callable(),
		_remove_mode,
		true
	))


func _remove_mode() -> void:
	var err := OS.move_to_trash(S.globalize_path("user://modes".path_join(mode_informations[current_mode_index]["id"])))
	if err:
		Notif.notif(
			"remove_mode_failed",
			{"text_append": error_string(err)}
		)
		return
	Notif.notif("remove_mode_completed")
	Global.get_editor_api().reload_modes()
	_load_mode_list()
	about.hide()


func _save_package(path: String) -> void:
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err:
		Notif.notif(
			"export_mode_failed",
			{
				"title": "Can't export mode kit!",
				"text_append": error_string(err),
			}
		)
		return
	for index in mode_list.get_selected_items():
		_add_folder_to_zip(writer, S.FOLDER_MODES.path_join(mode_informations[index]["id"]))
	writer.close()
	Notif.notif(
		"export_mode_completed",
		{
			"title": "Export mode kit completed.",
			"text_append": path
		},
	)
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
		if mode_list.get_selected_items().is_empty():
			mode_list.select_mode = ItemList.SELECT_SINGLE
			mode_list.deselect_all()
			return
		add_child(Factory.file_dialog(
			FileDialog.FILE_MODE_SAVE_FILE,
			FileDialog.ACCESS_FILESYSTEM,
			["*.tfmode;Text Forge Modes;application/zip"],
			_save_package,
			true,
			OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
		))
