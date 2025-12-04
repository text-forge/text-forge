# GdUnit generated TestSuite
class_name BackupCoreTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/backup_core.gd'

var test_backup_file_without_open_file__signal_emitted := false

func test_backup_saved_signal_exists() -> void:
	assert_bool(BackupCore.has_signal("backup_saved")).is_true()

func test_backup_failed_signal_exists() -> void:
	assert_bool(BackupCore.has_signal("backup_failed")).is_true()

func test_get_backups_list_returns_dictionary() -> void:
	var backups = BackupCore.get_backups_list()
	assert_bool(typeof(backups) == TYPE_DICTIONARY).is_true()

func test_get_backups_list_empty_when_no_backups() -> void:
	# Clean up any existing backup database
	if FileAccess.file_exists(S.globalize_path(S.BACKUP_DATABASE)):
		DirAccess.remove_absolute(S.globalize_path(S.BACKUP_DATABASE))
	var backups = BackupCore.get_backups_list()
	assert_int(backups.size()).is_equal(0)

func test_generate_new_backup_id_returns_string() -> void:
	var backup_id = BackupCore._generate_new_backup_id()
	assert_bool(typeof(backup_id) == TYPE_STRING).is_true()
	assert_bool(backup_id.length() > 0).is_true()

func test_generate_new_backup_id_unique() -> void:
	var id1 = BackupCore._generate_new_backup_id()
	await get_tree().create_timer(0.01).timeout
	var id2 = BackupCore._generate_new_backup_id()
	assert_str(id1).is_not_equal(id2)

func test_generate_new_backup_id_format() -> void:
	var backup_id = BackupCore._generate_new_backup_id()
	# Should be timestamp + 4 digit suffix
	assert_bool(backup_id.is_valid_int()).is_true()
	assert_int(backup_id.length()).is_greater_equal(14)

func test_backup_file_without_open_file() -> void:
	var original_path = Global.get_file_path()
	Global.set_file_path("")

	var connection = func(_auto): test_backup_file_without_open_file__signal_emitted = true
	BackupCore.backup_saved.connect(connection)

	BackupCore.backup_file(false)
	await get_tree().create_timer(0.1).timeout

	assert_bool(test_backup_file_without_open_file__signal_emitted).is_false()
	BackupCore.backup_saved.disconnect(connection)
	Global.set_file_path(original_path)

func test_restore_backup_nonexistent_code() -> void:
	var result = BackupCore.restore_backup("nonexistent_code", "/tmp/test.txt")
	assert_int(result).is_equal(ERR_DOES_NOT_EXIST)

func test_convert_to_days_handles_datetime_string() -> void:
	var datetime = "2024-01-15 10:30:00"
	var days = BackupCore._convert_to_days(datetime)
	assert_bool(typeof(days) == TYPE_INT).is_true()
	assert_int(days).is_greater(0)

func test_settings_presets_defined() -> void:
	# Verify backup-related settings are defined
	assert_bool(Settings.presets.has_section_key("files", "auto_backup")).is_true()
	assert_bool(Settings.presets.has_section_key("files", "auto_backup_interval_minutes")).is_true()
	assert_bool(Settings.presets.has_section_key("files", "keep_backup_for_days")).is_true()

func test_auto_backup_default_enabled() -> void:
	var auto_backup = Settings.get_setting("files", "auto_backup")
	assert_bool(auto_backup is bool).is_true()

func test_backup_interval_default_value() -> void:
	var interval: int = Settings.get_setting("files", "auto_backup_interval_minutes")
	assert_int(interval).is_equal(5)

func test_keep_backup_days_default_value() -> void:
	var days: int = Settings.get_setting("files", "keep_backup_for_days")
	assert_int(days).is_equal(10)
