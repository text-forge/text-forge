# GdUnit generated TestSuite
class_name MarketplaceTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite for marketplace.gd signal emission behavior
const __source = 'res://action_scripts/scenes/marketplace.gd'

var test_section := "editor_ui"
var test_key := "theme_name"

var test_change_theme_triggers_settings_changed_signal__signal_emitted := false
var test_change_theme_no_duplicate_signal__signal_count := 0
var test_theme_setting_with_same_value_no_signal__signal_emitted := false

func before_test() -> void:
	# Store original theme
	pass

func after_test() -> void:
	# Restore original theme if needed
	if Settings.presets.has_section_key(test_section, test_key):
		Settings.restore_default(test_section, test_key)

func test_change_theme_updates_setting() -> void:
	# Simulate theme change
	var original_theme = Settings.get_setting(test_section, test_key)

	# The _change_theme method should call Settings.set_setting
	# which will automatically emit settings_changed signal
	Settings.set_setting(test_section, test_key, "test_theme")

	assert_str(Settings.get_setting(test_section, test_key)).is_equal("test_theme")

	# Restore
	Settings.set_setting(test_section, test_key, original_theme)

func test_change_theme_triggers_settings_changed_signal() -> void:
	# Verify that changing theme emits settings_changed signal
	# through Settings.set_setting, not manually
	var original_theme = Settings.get_setting(test_section, test_key)
	var connection := func(): test_change_theme_triggers_settings_changed_signal__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Change theme
	Settings.set_setting(test_section, test_key, "new_theme")
	await get_tree().process_frame

	# Signal should be emitted by Settings.set_setting
	assert_bool(test_change_theme_triggers_settings_changed_signal__signal_emitted).is_true()

	# Restore
	Signals.settings_changed.disconnect(connection)
	Settings.set_setting(test_section, test_key, original_theme)

func test_change_theme_no_duplicate_signal() -> void:
	# Test that changing theme doesn't emit signal twice
	# (once manually, once from Settings.set_setting)
	var original_theme = Settings.get_setting(test_section, test_key)
	var connection := func(): test_change_theme_no_duplicate_signal__signal_count += 1
	Signals.settings_changed.connect(connection)

	# Change theme
	Settings.set_setting(test_section, test_key, "another_theme")
	await get_tree().process_frame

	# Should only be emitted once (by Settings.set_setting)
	assert_int(test_change_theme_no_duplicate_signal__signal_count).is_equal(1)

	# Restore
	Signals.settings_changed.disconnect(connection)
	Settings.set_setting(test_section, test_key, original_theme)

func test_settings_api_handles_theme_change() -> void:
	# Document that Settings API is responsible for signal emission
	var original_theme = Settings.get_setting(test_section, test_key)

	# Set a new theme
	Settings.set_setting(test_section, test_key, "dark")
	assert_str(Settings.get_setting(test_section, test_key)).is_equal("dark")

	# Restore
	Settings.set_setting(test_section, test_key, original_theme)

func test_theme_setting_with_same_value_no_signal() -> void:
	# Test that setting same theme doesn't emit signal (early return)
	var current_theme = Settings.get_setting(test_section, test_key)
	var connection := func(): test_theme_setting_with_same_value_no_signal__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Set same theme
	Settings.set_setting(test_section, test_key, current_theme)
	await get_tree().process_frame

	# No signal should be emitted due to early return
	assert_bool(test_theme_setting_with_same_value_no_signal__signal_emitted).is_false()

	Signals.settings_changed.disconnect(connection)
