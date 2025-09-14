extends Node
## Backup core of Text Forge

## Emits when a backup saved.
signal backup_saved(was_auto: bool)
## Emits when a backup failed.
signal backup_failed(was_auto: bool)

func _ready() -> void:
	get_window().close_requested.connect(_cleanup_backups)
	Settings.define_preset("files", "auto_backup", true)
	Settings.define_preset("files", "auto_backup_iterval_minutes", 5)
	Settings.define_preset("files", "keep_backup_for_days", 10)
	_handle_auto_save()


# Cleanups backups
func _cleanup_backups() -> void:
	_remove_old_backups()
	_remove_backups_without_refrence()


# Starts auto backup saving timer based on settings
func _handle_auto_save() -> void:
	if not Settings.get_setting("files", "auto_backup"):
		return
	var timer := Timer.new()
	timer.autostart = true
	timer.wait_time = 60.0 * Settings.get_setting("files", "auto_backup_iterval_minutes")
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
	if not FileAccess.file_exists(SLib.globalize_path(FileDatabase.BACKUP_DATABASE)):
		return Dictionary({}, TYPE_STRING, "", null, TYPE_DICTIONARY, "", null)
	config.load(SLib.globalize_path(FileDatabase.BACKUP_DATABASE))
	if not config.has_section("backups"):
		return Dictionary({}, TYPE_STRING, "", null, TYPE_DICTIONARY, "", null)

	var list: Dictionary[String, Dictionary]
	for file_item in config.get_section_keys("backups"):
		var file_backups = config.get_value("backups", file_item, {})
		list[file_item] = file_backups
	return list


## Restores current backup to given [param path] from given [param code] backup.
func restore_backup(code: String, path: String) -> void:
	var content := FileAccess.get_file_as_string(FileDatabase.TEMPLATE_BACKUP_FILE.format([code]))
	Global.set_file_path(path)
	Global.set_file_name(path.get_file())
	Global.set_editor_disabled(false)
	Global.set_editor_text(content)
	Signals.save_request.emit(-1)
	Global.send_notification(Global.Notification.INFO, "Backup sucefully restored.")


## Makes a backup from current file.
func backup_file(as_auto: bool) -> void:
	if not Global.has_file():
		return
	var config := ConfigFile.new()
	if FileAccess.file_exists(SLib.globalize_path(FileDatabase.BACKUP_DATABASE)):
		config.load(SLib.globalize_path(FileDatabase.BACKUP_DATABASE))

	var file_backups: Dictionary = config.get_value("backups", Global.get_file_path(), {})
	var backup_id := _generate_new_backup_id()
	if backup_id == "":
		backup_failed.emit(as_auto)
		return
	var file := FileAccess.open(SLib.globalize_path(FileDatabase.TEMPLATE_BACKUP_FILE.format([backup_id])), FileAccess.WRITE)
	file.store_string(Global.get_editor_text())
	file.close()
	file_backups[Time.get_datetime_string_from_system(false, true)] = backup_id
	config.set_value("backups", Global.get_file_path(), file_backups)
	config.save(SLib.globalize_path(FileDatabase.BACKUP_DATABASE))
	backup_saved.emit(as_auto)


# Returns a new random backup id (max tries: 10^8)
func _generate_new_backup_id() -> String:
	var path := ""
	for i in range(10 ** 8):
		var codes := Array()
		codes.resize(8)
		codes = codes.map(func(j): return randi_range(0, 9))
		path = SLib.globalize_path(FileDatabase.TEMPLATE_BACKUP_FILE.format(["".join(codes)]))
		if not FileAccess.file_exists(path):
			return "".join(codes)
	Global.send_notification(Global.Notification.ERROR, "Failed to generate random backup ID in 10^8 tries.")
	return ""


# Searchs backup database for each backup file and removes backups without refrence
func _remove_backups_without_refrence() -> void:
	var config := ConfigFile.new()
	if FileAccess.file_exists(SLib.globalize_path(FileDatabase.BACKUP_DATABASE)):
		config.load(SLib.globalize_path(FileDatabase.BACKUP_DATABASE))
	if not DirAccess.dir_exists_absolute(SLib.globalize_path(FileDatabase.TEMPLATE_BACKUP_FILE.get_base_dir())):
		DirAccess.make_dir_recursive_absolute(SLib.globalize_path(FileDatabase.TEMPLATE_BACKUP_FILE.get_base_dir()))
	var dir := DirAccess.open(SLib.globalize_path(FileDatabase.TEMPLATE_BACKUP_FILE.get_base_dir()))
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
	if FileAccess.file_exists(SLib.globalize_path(FileDatabase.BACKUP_DATABASE)):
		config.load(SLib.globalize_path(FileDatabase.BACKUP_DATABASE))

	if not config.has_section("backups"):
		return
	for file_item in config.get_section_keys("backups"):
		var file_backups = config.get_value("backups", file_item, {})
		if file_backups.size() <= 1:
			continue
		for backup_time in file_backups:
			if file_backups.size() <= 1:
				break
			if _convert_to_days(backup_time) + Settings.get_setting("files", "keep_backup_for_days") < _convert_to_days(Time.get_datetime_string_from_system()):
				file_backups.erase(backup_time)
		config.set_value("backups", file_item, file_backups)
	config.save(SLib.globalize_path(FileDatabase.BACKUP_DATABASE))


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
