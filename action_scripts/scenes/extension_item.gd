class_name ExtensionInstance
extends PanelContainer
## A panel to manage one extension.

## Extension name
@export var text: Label
## Action status [CheckBox]
@export var enable: CheckBox
## Uninstall button
@export var uninstall: Button
## Extension ID
var id: String

## Setups current item for another extension.
func setup(item_id: String, label: String, enabled: bool = false) -> ExtensionInstance:
	id = item_id
	text.text = label
	enable.button_pressed = enabled
	_update_status_text(enabled)
	show()
	return self


## Changes extension status.
func _on_status_toggled(toggled_on: bool) -> void:
	Extensions.set_extension_enabled(id, toggled_on)
	_update_status_text(toggled_on)


## Sends a confirmation request to uninstall extension.
func _on_uninstall_pressed() -> void:
	add_child(Factory.confirmation_dialog(
		"Are you sure you want to uninstall this extension?",
		"Yes",
		"Cancel",
		"Please Confirm",
		Callable(),
		_uninstall
	))


## Uninstalls extension.
func _uninstall() -> void:
	Extensions.uninstall_extension(id)
	await get_tree().process_frame
	queue_free()


## Requests file path to export extension.
func _on_export_pressed() -> void:
	add_child(Factory.file_dialog(
		FileDialog.FILE_MODE_SAVE_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		["*.tfx;Text Forge Extensions;application/zip"],
		_export_self,
		true,
		OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	))


## Exports current extension.
func _export_self(path: String) -> void:
	Extensions.export_extension(id, path)


func _update_status_text(is_enabled: bool) -> void:
	enable.text = "Enabled" if is_enabled else "Disabled"
