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


# Loads backup database, or returns a new empty one when it doesn't exist.
func _load_backup_database() -> ConfigFile:
	var config := ConfigFile.new()
	if FileAccess.file_exists(S.globalize_path(S.BACKUP_DATABASE)):
		config.load(S.globalize_path(S.BACKUP_DATABASE))
	return config


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
	var config := _load_backup_database()
	if not config.has_section("backups"):
		return Dictionary({}, TYPE_STRING, "", null, TYPE_DICTIONARY, "", null)
	var list: Dictionary[String, Dictionary]
	for file_item in config.get_section_keys("backups"):
		var file_backups = config.get_value("backups", file_item, {})
		list[file_item] = file_backups
	return list


## Restores given [param code] backup to given [param path]. It opens the document of that path, or
## adds a tab for it, so the backup lands in its own file and not in whatever is active.
func restore_backup(code: String, path: String) -> Error:
	var backup_path := S.TEMPLATE_BACKUP_FILE.format([code])
	if not FileAccess.file_exists(backup_path):
		Notif.notif(
			"file_not_found",
			{"text": backup_path}
		)
		return ERR_DOES_NOT_EXIST
	var content := FileAccess.get_file_as_string(backup_path)
	var doc := Documents.find_by_path(path)
	if not doc:
		doc = Documents.create(path, path.get_file(), content, true)
	if not doc:
		return ERR_CANT_CREATE
	Documents.activate(doc)
	Global.set_editor_disabled(false)
	if doc.editor.text != content:
		Global.set_editor_text(content)
	Global.set_file_path(path)
	Global.set_file_name(path.get_file())
	Signals.check_options.emit()
	Global.mark_file_as_unsaved()
	Notif.notif("backup_restore_completed")
	return OK


## Makes a backup of every open file, a tab that is not active is backed up as well, otherwise a
## crash would lose it while the auto backup timer only watches the active document.
func backup_file(as_auto: bool) -> void:
	var config := _load_backup_database()
	var saved := 0
	var failed := 0
	var failure := OK
	for doc in Documents.docs:
		if not doc.path.is_absolute_path() or not is_instance_valid(doc.editor):
			continue
		var file_backups: Dictionary = config.get_value("backups", doc.path, {})
		var backup_id := _generate_new_backup_id()
		var file := FileAccess.open(S.globalize_path(S.TEMPLATE_BACKUP_FILE.format([backup_id])), FileAccess.WRITE)
		if not file:
			failed += 1
			failure = FileAccess.get_open_error()
			continue
		file.store_string(doc.editor.text)
		file.close()
		file_backups[Time.get_datetime_string_from_system(false, true)] = backup_id
		config.set_value("backups", doc.path, file_backups)
		saved += 1
	if not saved:
		return
	var err := config.save(S.globalize_path(S.BACKUP_DATABASE))
	if err:
		failed += 1
		failure = err
	if failed and not as_auto:
		Notif.notif(
			"save_file_failed",
			{"format_title": ["backup"], "text_append": error_string(failure)}
		)
	if failed:
		backup_failed.emit(as_auto)
	else:
		backup_saved.emit(as_auto)


# Returns a probabilistically unique backup id based on unix time and random suffix.
func _generate_new_backup_id() -> String:
	# Use timestamp + random suffix for high-probability uniqueness
	var timestamp := str(int(Time.get_unix_time_from_system()))
	var suffix := str(randi_range(1000, 9999))
	return timestamp + suffix


# Searches backup database for each backup file and removes backups without reference
func _remove_backups_without_reference() -> void:
	var config := _load_backup_database()
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
	var config := _load_backup_database()
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
