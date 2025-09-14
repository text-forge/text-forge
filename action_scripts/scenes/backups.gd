extends Window

@export var file_list: ItemList
@export var backup_list: ItemList

var backups: Dictionary[String, Dictionary]
var current_file: String
var current_backup: String

func _ready() -> void:
	backups = BackupCore.get_backups_list()
	for file in backups:
		file_list.add_item(file)


func _on_item_list_item_selected(index: int) -> void:
	current_file = file_list.get_item_text(index)
	backup_list.clear()
	for backup in backups[current_file]:
		var content := FileAccess.get_file_as_string(FileDatabase.TEMPLATE_BACKUP_FILE.format([backups[current_file][backup]]))
		backup_list.add_item(backup + " (" + str(content.count("\n") + 1) + " Lines)")


func _on_item_list_2_item_selected(index: int) -> void:
	current_backup = backup_list.get_item_text(index).get_slice(" (", 0)
	add_child(Factory.confirmation_dialog("Do you want restore this backup?", "Yes", "No", "Please Confirm", Callable(), _pick_save_path, true))


func _pick_save_path() -> void:
	add_child(Factory.file_dialog(FileDialog.FILE_MODE_SAVE_FILE, FileDialog.ACCESS_FILESYSTEM, PackedStringArray(), _restore_backup, true, "", current_file))


func _restore_backup(path: String):
	BackupCore.restore_backup(backups[current_file][current_backup], path)
	queue_free()
