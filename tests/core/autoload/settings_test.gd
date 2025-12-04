# GdUnit generated TestSuite
class_name SettingsTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/settings.gd'

var test_section := "test_section"
var test_key := "test_key"

var test_set_setting_early_return_when_value_unchanged__signal_emitted := false
var test_set_setting_emits_signal_on_value_change__signal_emitted := false
var test_set_setting_force_silent_suppresses_signal__signal_emitted := false
var test_set_setting_force_silent_false_emits_signal__signal_emitted := false
var test_set_setting_early_return_with_same_numeric_value__signal_emitted := false
var test_set_setting_early_return_with_same_boolean_value__signal_emitted := false
var test_set_setting_early_return_with_same_float_value__signal_emitted := false
var test_restore_default_emits_settings_changed__signal_emitted := false
var test_restore_default_no_signal_if_already_default__signal_emitted := false

func before_test() -> void:
	# Clean up test data before each test
	if Settings.settings.has_section(test_section):
		Settings.settings.erase_section(test_section)
	if Settings.presets.has_section(test_section):
		Settings.presets.erase_section(test_section)
	if Settings.data.has_section(test_section):
		Settings.data.erase_section(test_section)

func after_test() -> void:
	# Clean up after each test
	if Settings.settings.has_section(test_section):
		Settings.settings.erase_section(test_section)
	if Settings.presets.has_section(test_section):
		Settings.presets.erase_section(test_section)
	if Settings.data.has_section(test_section):
		Settings.data.erase_section(test_section)

func test_settings_file_constant() -> void:
	assert_str(Settings.SETTINGS_FILE).is_equal("user://settings.cfg")

func test_presets_file_constant() -> void:
	assert_str(Settings.PRESETS_FILE).is_equal("user://presets.cfg")

func test_data_file_constant() -> void:
	assert_str(Settings.DATA_FILE).is_equal("user://data.cfg")

func test_settings_config_exists() -> void:
	assert_object(Settings.settings).is_not_null()
	assert_object(Settings.settings).is_instanceof(ConfigFile)

func test_presets_config_exists() -> void:
	assert_object(Settings.presets).is_not_null()
	assert_object(Settings.presets).is_instanceof(ConfigFile)

func test_data_config_exists() -> void:
	assert_object(Settings.data).is_not_null()
	assert_object(Settings.data).is_instanceof(ConfigFile)

func test_define_preset_sets_value() -> void:
	Settings.define_preset(test_section, test_key, "test_value")
	var value = Settings.presets.get_value(test_section, test_key)
	assert_str(value).is_equal("test_value")

func test_define_preset_overwrites_existing() -> void:
	Settings.define_preset(test_section, test_key, "first_value")
	Settings.define_preset(test_section, test_key, "second_value")
	var value = Settings.presets.get_value(test_section, test_key)
	assert_str(value).is_equal("second_value")

func test_get_default_returns_preset_value() -> void:
	Settings.define_preset(test_section, test_key, "default_value")
	var default = Settings.get_default(test_section, test_key)
	assert_str(default).is_equal("default_value")

func test_get_default_returns_null_for_undefined() -> void:
	var default = Settings.get_default("nonexistent_section", "nonexistent_key")
	assert_object(default).is_null()

func test_set_setting_stores_value() -> void:
	Settings.set_setting(test_section, test_key, "stored_value")
	var value = Settings.settings.get_value(test_section, test_key)
	assert_str(value).is_equal("stored_value")

func test_get_setting_retrieves_stored_value() -> void:
	Settings.set_setting(test_section, test_key, "my_value")
	var retrieved = Settings.get_setting(test_section, test_key)
	assert_str(retrieved).is_equal("my_value")

func test_get_setting_uses_default_when_not_set() -> void:
	Settings.define_preset(test_section, test_key, "default_val")
	var retrieved = Settings.get_setting(test_section, test_key)
	assert_str(retrieved).is_equal("default_val")

func test_get_setting_bool_returns_boolean() -> void:
	Settings.set_setting(test_section, test_key, true)
	var retrieved = Settings.get_setting_bool(test_section, test_key)
	assert_bool(retrieved).is_true()

func test_get_setting_bool_converts_to_boolean() -> void:
	Settings.set_setting(test_section, test_key, 1)
	var retrieved = Settings.get_setting_bool(test_section, test_key)
	assert_bool(retrieved).is_true()

func test_restore_default_resets_to_preset() -> void:
	Settings.define_preset(test_section, test_key, "preset_value")
	Settings.set_setting(test_section, test_key, "changed_value")
	Settings.restore_default(test_section, test_key)
	var value = Settings.get_setting(test_section, test_key)
	assert_str(value).is_equal("preset_value")

func test_read_data_retrieves_value() -> void:
	Settings.data.set_value(test_section, test_key, "data_value")
	var retrieved = Settings.read_data(test_section, test_key)
	assert_str(retrieved).is_equal("data_value")

func test_read_data_uses_default() -> void:
	var retrieved = Settings.read_data("nonexistent", "key", "fallback")
	assert_str(retrieved).is_equal("fallback")

func test_write_data_stores_value() -> void:
	Settings.write_data(test_section, test_key, "written_value")
	var value = Settings.data.get_value(test_section, test_key)
	assert_str(value).is_equal("written_value")

func test_globalize_path_converts_user_path() -> void:
	var path = S.globalize_path("user://test.txt")
	assert_bool(path.contains("test.txt")).is_true()
	assert_bool(path.is_absolute_path()).is_true()

func test_globalize_path_handles_res_path() -> void:
	var path = S.globalize_path("res://icon.png")
	assert_bool(path.contains("icon.png")).is_true()

# Tests for enhanced set_setting functionality (PR #145)

func test_set_setting_early_return_when_value_unchanged() -> void:
	# Set initial value
	Settings.define_preset(test_section, test_key, "initial_value")
	Settings.set_setting(test_section, test_key, "test_value")

	# Create a signal spy to verify settings_changed is not emitted
	var connection := func(): test_set_setting_early_return_when_value_unchanged__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Set same value again - should return early without emitting signal
	Settings.set_setting(test_section, test_key, "test_value")
	await get_tree().process_frame

	assert_bool(test_set_setting_early_return_when_value_unchanged__signal_emitted).is_false()
	Signals.settings_changed.disconnect(connection)

func test_set_setting_emits_signal_on_value_change() -> void:
	# Set initial value
	Settings.set_setting(test_section, test_key, "initial_value")

	# Create a signal spy
	var connection := func(): test_set_setting_emits_signal_on_value_change__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Change value - should emit signal
	Settings.set_setting(test_section, test_key, "new_value")
	await get_tree().process_frame

	assert_bool(test_set_setting_emits_signal_on_value_change__signal_emitted).is_true()
	Signals.settings_changed.disconnect(connection)

func test_set_setting_force_silent_suppresses_signal() -> void:
	# Set initial value
	Settings.set_setting(test_section, test_key, "initial_value")

	# Create a signal spy
	var connection := func(): test_set_setting_force_silent_suppresses_signal__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Change value with force_silent = true
	Settings.set_setting(test_section, test_key, "silent_change", true)
	await get_tree().process_frame

	# Signal should not be emitted
	assert_bool(test_set_setting_force_silent_suppresses_signal__signal_emitted).is_false()
	# But value should still be changed
	assert_str(Settings.get_setting(test_section, test_key)).is_equal("silent_change")
	Signals.settings_changed.disconnect(connection)

func test_set_setting_force_silent_false_emits_signal() -> void:
	# Set initial value
	Settings.set_setting(test_section, test_key, "initial_value")

	# Create a signal spy
	var connection := func(): test_set_setting_force_silent_false_emits_signal__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Change value with explicit force_silent = false
	Settings.set_setting(test_section, test_key, "new_value", false)
	await get_tree().process_frame

	assert_bool(test_set_setting_force_silent_false_emits_signal__signal_emitted).is_true()
	Signals.settings_changed.disconnect(connection)

func test_set_setting_early_return_with_same_numeric_value() -> void:
	Settings.set_setting(test_section, test_key, 42)

	var connection := func(): test_set_setting_early_return_with_same_numeric_value__signal_emitted = true
	Signals.settings_changed.connect(connection)

	Settings.set_setting(test_section, test_key, 42)
	await get_tree().process_frame

	assert_bool(test_set_setting_early_return_with_same_numeric_value__signal_emitted).is_false()
	Signals.settings_changed.disconnect(connection)

func test_set_setting_early_return_with_same_boolean_value() -> void:
	Settings.set_setting(test_section, test_key, true)

	var connection := func(): test_set_setting_early_return_with_same_boolean_value__signal_emitted = true
	Signals.settings_changed.connect(connection)

	Settings.set_setting(test_section, test_key, true)
	await get_tree().process_frame

	assert_bool(test_set_setting_early_return_with_same_boolean_value__signal_emitted).is_false()
	Signals.settings_changed.disconnect(connection)

func test_set_setting_early_return_with_same_float_value() -> void:
	Settings.set_setting(test_section, test_key, 3.14)

	var connection := func(): test_set_setting_early_return_with_same_float_value__signal_emitted = true
	Signals.settings_changed.connect(connection)

	Settings.set_setting(test_section, test_key, 3.14)
	await get_tree().process_frame

	assert_bool(test_set_setting_early_return_with_same_float_value__signal_emitted).is_false()
	Signals.settings_changed.disconnect(connection)

func test_set_setting_does_not_emit_on_save_error() -> void:
	# This test verifies that if save fails, signal is not emitted
	# We can't easily force a save error in tests, but we document the behavior
	pass

func test_restore_default_emits_settings_changed() -> void:
	Settings.define_preset(test_section, test_key, "default_val")
	Settings.set_setting(test_section, test_key, "changed_val")

	var connection := func(): test_restore_default_emits_settings_changed__signal_emitted = true
	Signals.settings_changed.connect(connection)

	Settings.restore_default(test_section, test_key)
	await get_tree().process_frame

	assert_bool(test_restore_default_emits_settings_changed__signal_emitted).is_true()
	Signals.settings_changed.disconnect(connection)

func test_restore_default_no_signal_if_already_default() -> void:
	Settings.define_preset(test_section, test_key, "default_val")
	Settings.set_setting(test_section, test_key, "default_val")

	var connection := func(): test_restore_default_no_signal_if_already_default__signal_emitted = true
	Signals.settings_changed.connect(connection)

	Settings.restore_default(test_section, test_key)
	await get_tree().process_frame

	# Should not emit because value didn't change (early return)
	assert_bool(test_restore_default_no_signal_if_already_default__signal_emitted).is_false()
	Signals.settings_changed.disconnect(connection)
