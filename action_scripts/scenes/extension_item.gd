extends PanelContainer

@export var text: Label
@export var enable: CheckBox
@export var uninstall: Button
var id: String

func setup(item_id: String, label: String, enabled: bool = false) -> PanelContainer:
	id = item_id
	text.text = label
	enable.button_pressed = enabled
	if enabled:
		enable.text = "Enabled "
	show()
	return self


func _on_check_box_toggled(toggled_on: bool) -> void:
	Extensions.set_extension_enabled(id, toggled_on)
	if toggled_on:
		enable.text = "Enabled "
	else:
		enable.text = "Disabled "


func _on_button_pressed() -> void:
	add_child(Factory.confirmation_dialog("Are you sure about uninstall this extension?", "Yes", "Cancel", "Please Confirm", Callable(), _uninstall))


func _uninstall() -> void:
	Extensions.uninstall_extension(id)
	await get_tree().process_frame
	queue_free()


func _on_export_pressed() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM, ["*.tfx,*.zip;Text Forge Extensions;application/zip"], _export_self, true))


func _export_self(path: String) -> void:
	var writer = ZIPPacker.new()
	var err = writer.open(path)
	if err != OK:
		Global.send_notification(Global.Notification.ERROR, "Cann't export extension!", "Error code: " + str(err))
		return

	for f in DirAccess.get_files_at(FileDatabase.FOLDER_EXTENSIONS.path_join(id)):
		writer.start_file(id.path_join(f))
		var file := FileAccess.open(FileDatabase.FOLDER_EXTENSIONS.path_join(id).path_join(f), FileAccess.READ)
		writer.write_file(file.get_as_text().to_utf8_buffer())
		writer.close_file()

	writer.close()
	Global.send_notification(Global.Notification.INFO, "Export extension completed.", "Exported file: " + path)
