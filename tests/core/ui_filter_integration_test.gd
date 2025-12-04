# GdUnit generated TestSuite
class_name UIFilterIntegrationTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# Integration test suite for UI Filter feature (PR #145)
const __source = 'res://core/main.gd'

var test_section := "editor_ui"

var test_complete_ui_filter_workflow__signal_emitted := false
var test_multiple_filter_changes_batch__signal_count := 0
var test_ui_filter_with_silent_mode__signal_count := 0
var test_settings_changed_signal_propagation__signal_received := false
var test_no_signal_on_identical_value__signal_count := 0

func before_test() -> void:
	# Store original values
	pass

func after_test() -> void:
	# Restore defaults
	Settings.restore_default(test_section, "filter_hue_shift")
	Settings.restore_default(test_section, "filter_saturation")
	Settings.restore_default(test_section, "filter_brightness")

func test_complete_ui_filter_workflow() -> void:
	# Test complete workflow: setting -> signal -> reload
	var connection := func(): test_complete_ui_filter_workflow__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Change hue shift
	Settings.set_setting(test_section, "filter_hue_shift", 0.5)
	await get_tree().process_frame
	assert_bool(test_complete_ui_filter_workflow__signal_emitted).is_true()
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.5)

	Signals.settings_changed.disconnect(connection)

func test_multiple_filter_changes_batch() -> void:
	# Test changing multiple filters in sequence
	var connection := func(): test_multiple_filter_changes_batch__signal_count += 1
	Signals.settings_changed.connect(connection)

	Settings.set_setting(test_section, "filter_hue_shift", 0.2)
	Settings.set_setting(test_section, "filter_saturation", 1.3)
	Settings.set_setting(test_section, "filter_brightness", 0.9)
	await get_tree().process_frame

	# Should emit signal for each change
	assert_int(test_multiple_filter_changes_batch__signal_count).is_equal(3)

	Signals.settings_changed.disconnect(connection)

func test_ui_filter_with_silent_mode() -> void:
	# Test that force_silent prevents signal emission
	var connection := func(): test_ui_filter_with_silent_mode__signal_count += 1
	Signals.settings_changed.connect(connection)

	# Change with silent mode
	Settings.set_setting(test_section, "filter_hue_shift", 0.3, true)
	Settings.set_setting(test_section, "filter_saturation", 1.4, true)
	Settings.set_setting(test_section, "filter_brightness", 1.1, true)
	await get_tree().process_frame

	# No signals should be emitted
	assert_int(test_ui_filter_with_silent_mode__signal_count).is_equal(0)

	# But values should be changed
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.3)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(1.4)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(1.1)

	Signals.settings_changed.disconnect(connection)

func test_ui_filter_preset_consistency() -> void:
	# Verify all UI filter presets are consistent
	assert_bool(Settings.presets.has_section_key(test_section, "filter_hue_shift")).is_true()
	assert_bool(Settings.presets.has_section_key(test_section, "filter_saturation")).is_true()
	assert_bool(Settings.presets.has_section_key(test_section, "filter_brightness")).is_true()
	assert_bool(Settings.presets.has_section_key(test_section, "theme_name")).is_true()

func test_ui_filter_color_transformations() -> void:
	# Test various color transformation scenarios

	# Grayscale (desaturate)
	Settings.set_setting(test_section, "filter_saturation", 0.0, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(0.0)

	# High contrast (max saturation)
	Settings.set_setting(test_section, "filter_saturation", 2.0, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(2.0)

	# Sepia-like (hue shift + desaturate)
	Settings.set_setting(test_section, "filter_hue_shift", 0.1, true)
	Settings.set_setting(test_section, "filter_saturation", 0.5, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.1)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(0.5)

func test_ui_filter_accessibility_modes() -> void:
	# Test common accessibility configurations

	# High contrast mode
	Settings.set_setting(test_section, "filter_saturation", 1.5, true)
	Settings.set_setting(test_section, "filter_brightness", 1.2, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(1.5)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(1.2)

	# Reduced brightness for eye strain
	Settings.set_setting(test_section, "filter_brightness", 0.7, true)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(0.7)

func test_ui_filter_edge_cases() -> void:
	# Test edge cases and boundary values

	# Maximum hue shift
	Settings.set_setting(test_section, "filter_hue_shift", 1.0, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(1.0)

	# Minimum hue shift
	Settings.set_setting(test_section, "filter_hue_shift", -1.0, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(-1.0)

	# Zero brightness (black screen)
	Settings.set_setting(test_section, "filter_brightness", 0.0, true)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(0.0)

func test_ui_filter_restore_all_defaults() -> void:
	# Change all values
	Settings.set_setting(test_section, "filter_hue_shift", 0.5, true)
	Settings.set_setting(test_section, "filter_saturation", 1.5, true)
	Settings.set_setting(test_section, "filter_brightness", 0.8, true)

	# Restore all
	Settings.restore_default(test_section, "filter_hue_shift")
	Settings.restore_default(test_section, "filter_saturation")
	Settings.restore_default(test_section, "filter_brightness")

	# Verify all defaults
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.0)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(1.0)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(1.0)

func test_ui_filter_independent_from_theme() -> void:
	# Verify UI filter settings are independent from theme changes
	var original_theme = Settings.get_setting(test_section, "theme_name")

	Settings.set_setting(test_section, "filter_hue_shift", 0.5, true)
	Settings.set_setting(test_section, "theme_name", "light", true)

	# Filter should remain unchanged
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.5)

	# Restore
	Settings.set_setting(test_section, "theme_name", original_theme, true)

func test_settings_changed_signal_propagation() -> void:
	# Test that settings_changed signal propagates correctly
	var connection := func(): test_settings_changed_signal_propagation__signal_received = true
	Signals.settings_changed.connect(connection)

	# Make a change that should trigger signal
	Settings.set_setting(test_section, "filter_hue_shift", 0.25)
	await get_tree().process_frame

	assert_bool(test_settings_changed_signal_propagation__signal_received).is_true()
	Signals.settings_changed.disconnect(connection)

func test_no_signal_on_identical_value() -> void:
	# Set initial value
	Settings.set_setting(test_section, "filter_hue_shift", 0.5, true)

	var connection := func(): test_no_signal_on_identical_value__signal_count += 1
	Signals.settings_changed.connect(connection)

	# Set same value again
	Settings.set_setting(test_section, "filter_hue_shift", 0.5)
	await get_tree().process_frame

	# Should not emit signal (early return)
	assert_int(test_no_signal_on_identical_value__signal_count).is_equal(0)
	Signals.settings_changed.disconnect(connection)
