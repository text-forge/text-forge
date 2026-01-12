class_name BackupAPI
extends Node
## Backup core of Text Forge.
##
## A global API to work with backups.

## Emits when a backup saved.
signal backup_saved(was_auto: bool)
## Emits when a backup failed.
signal backup_failed(was_auto: bool)

func _ready() -> void:
	Notif.register_notification(
		"backup_restore_completed",
		Notif.Type.INFO,
		"Backup restore completed."
	)
	get_window().close_requested.connect(_cleanup_backups)
	Settings.define_preset("files", "auto_backup", true)
	Settings.define_preset("files", "auto_backup_interval_minutes", 5)
	Settings.define_preset("files", "keep_backup_for_days", 10)
	_handle_auto_save()


# Cleanups backups
func _cleanup_backups() -> void:
	_remove_old_backups()
	_remove_backups_without_reference()


# Starts auto backup saving timer based on settings
func _handle_auto_save() -> void:
	if not Settings.get_setting("files", "auto_backup"):
		return
	var timer := Timer.new()
	timer.autostart = true
	timer.wait_time = 60.0 * Settings.get_setting("files", "auto_backup_interval_minutes")
	timer.timeout.connect(backup_file.bind(true))
	add_child(timer)


## Returns a list of all backups, in this structure:
## [codeblock]
## {
##     "file_path": {
##         "YYYY-MM-DD HH:MM:SS": "Backup code",
##         ....
##     },
##     ....
## }
## [/codeblock]
func get_backups_list() -> Dictionary[String, Dictionary]:
	var config := ConfigFile.new()
	if not FileAccess.file_exists(S.globalize_path(S.BACKUP_DATABASE)):
		return Dictionary({}, TYPE_STRING, "", null, TYPE_DICTIONARY, "", null)
	config.load(S.globalize_path(S.BACKUP_DATABASE))
	if not config.has_section("backups"):
		return Dictionary({}, TYPE_STRING, "", null, TYPE_DICTIONARY, "", null)
	var list: Dictionary[String, Dictionary]
	for file_item in config.get_section_keys("backups"):
		var file_backups = config.get_value("backups", file_item, {})
		list[file_item] = file_backups
	return list


## Restores current backup to given [param path] from given [param code] backup.
func restore_backup(code: String, path: String) -> Error:
	if not FileAccess.file_exists(S.TEMPLATE_BACKUP_FILE.format([code])):
		Notif.notif(
			"file_not_found",
			{"text": S.TEMPLATE_BACKUP_FILE.format([code])}
		)
		return ERR_DOES_NOT_EXIST
	var content := FileAccess.get_file_as_string(S.TEMPLATE_BACKUP_FILE.format([code]))
	Global.set_file_path(path)
	Global.set_file_name(path.get_file())
	Global.set_editor_disabled(false)
	Global.set_editor_text(content)
	Signals.check_options.emit()
	Global.mark_file_as_unsaved()
	Notif.notif("backup_restore_completed")
	return OK


## Makes a backup from current file.
func backup_file(as_auto: bool) -> void:
	if not Global.has_file():
		return
	var config := ConfigFile.new()
	if FileAccess.file_exists(S.globalize_path(S.BACKUP_DATABASE)):
		config.load(S.globalize_path(S.BACKUP_DATABASE))
	var file_backups: Dictionary = config.get_value("backups", Global.get_file_path(), {})
	var backup_id := _generate_new_backup_id()
	var file := FileAccess.open(S.globalize_path(S.TEMPLATE_BACKUP_FILE.format([backup_id])), FileAccess.WRITE)
	if not file:
		if not as_auto:
			Notif.notif(
				"save_file_failed",
				{"format_title": ["backup"], "text_append": error_string(FileAccess.get_open_error())}
			)
		backup_failed.emit(as_auto)
		return
	file.store_string(Global.get_editor_text())
	file.close()
	file_backups[Time.get_datetime_string_from_system(false, true)] = backup_id
	config.set_value("backups", Global.get_file_path(), file_backups)
	config.save(S.globalize_path(S.BACKUP_DATABASE))
	backup_saved.emit(as_auto)


# Returns a probabilistically unique backup id based on unix time and random suffix.
func _generate_new_backup_id() -> String:
	# Use timestamp + random suffix for high-probability uniqueness
	var timestamp := str(int(Time.get_unix_time_from_system()))
	var suffix := str(randi_range(1000, 9999))
	return timestamp + suffix


# Searches backup database for each backup file and removes backups without reference
func _remove_backups_without_reference() -> void:
	var config := ConfigFile.new()
	if FileAccess.file_exists(S.globalize_path(S.BACKUP_DATABASE)):
		config.load(S.globalize_path(S.BACKUP_DATABASE))
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.TEMPLATE_BACKUP_FILE.get_base_dir())):
		DirAccess.make_dir_recursive_absolute(S.globalize_path(S.TEMPLATE_BACKUP_FILE.get_base_dir()))
	var dir := DirAccess.open(S.globalize_path(S.TEMPLATE_BACKUP_FILE.get_base_dir()))
	for file in dir.get_files():
		var code = file.get_file()
		var found := false
		for backuped_file in config.get_section_keys("backups"):
			if Dictionary(config.get_value("backups", backuped_file, {})).find_key(code) != null:
				found = true
		if not found:
			dir.remove(code)


# Remove old backups from database, will do nothing with backup files
func _remove_old_backups() -> void:
	if Settings.get_setting("files", "keep_backup_for_days") == -1:
		return
	var config := ConfigFile.new()
	if FileAccess.file_exists(S.globalize_path(S.BACKUP_DATABASE)):
		config.load(S.globalize_path(S.BACKUP_DATABASE))
	if not config.has_section("backups"):
		return
	for file_item in config.get_section_keys("backups"):
		var file_backups: Dictionary = config.get_value("backups", file_item, {})
		if file_backups.size() <= 1:
			continue
		var to_remove: Array[String] = []
		for backup_time: String in file_backups:
			if file_backups.size() - to_remove.size() <= 1:
				break
			if _convert_to_days(backup_time) + Settings.get_setting("files", "keep_backup_for_days") < _convert_to_days(Time.get_datetime_string_from_system()):
				to_remove.append(backup_time)
		for backup_to_remove in to_remove:
			file_backups.erase(backup_to_remove)
		config.set_value("backups", file_item, file_backups)
	config.save(S.globalize_path(S.BACKUP_DATABASE))


# Converts given date_string to days int, supports both datetime and date formats
func _convert_to_days(date_string: String) -> int:
	if date_string.contains(" "):
		date_string = date_string.get_slice(" ", 0)
	elif date_string.contains("T"):
		date_string = date_string.get_slice("T", 0)
	var date := date_string.split("-")
	var days := int(date[2])
	days += int(date[1]) * 30
	days += int(date[0]) * 365
	return days
