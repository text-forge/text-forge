# GdUnit generated TestSuite
class_name MainTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/main.gd'

var test_section := "editor_ui"

func before_test() -> void:
	# Store original values
	pass

func after_test() -> void:
	# Restore original UI filter settings
	if Settings.presets.has_section_key(test_section, "filter_hue_shift"):
		Settings.restore_default(test_section, "filter_hue_shift")
	if Settings.presets.has_section_key(test_section, "filter_saturation"):
		Settings.restore_default(test_section, "filter_saturation")
	if Settings.presets.has_section_key(test_section, "filter_brightness"):
		Settings.restore_default(test_section, "filter_brightness")

func test_ui_filter_presets_defined() -> void:
	# Verify UI filter presets are defined
	assert_bool(Settings.presets.has_section_key(test_section, "filter_hue_shift")).is_true()
	assert_bool(Settings.presets.has_section_key(test_section, "filter_saturation")).is_true()
	assert_bool(Settings.presets.has_section_key(test_section, "filter_brightness")).is_true()

func test_ui_filter_hue_shift_default_value() -> void:
	var default = Settings.get_default(test_section, "filter_hue_shift")
	assert_float(default).is_equal(0.0)

func test_ui_filter_saturation_default_value() -> void:
	var default = Settings.get_default(test_section, "filter_saturation")
	assert_float(default).is_equal(1.0)

func test_ui_filter_brightness_default_value() -> void:
	var default = Settings.get_default(test_section, "filter_brightness")
	assert_float(default).is_equal(1.0)

func test_ui_filter_hue_shift_range() -> void:
	# Test valid hue shift values
	Settings.set_setting(test_section, "filter_hue_shift", 0.5, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.5)

	Settings.set_setting(test_section, "filter_hue_shift", -0.5, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(-0.5)

	Settings.set_setting(test_section, "filter_hue_shift", 1.0, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(1.0)

	Settings.set_setting(test_section, "filter_hue_shift", -1.0, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(-1.0)

func test_ui_filter_saturation_range() -> void:
	# Test valid saturation values
	Settings.set_setting(test_section, "filter_saturation", 0.0, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(0.0)

	Settings.set_setting(test_section, "filter_saturation", 2.0, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(2.0)

	Settings.set_setting(test_section, "filter_saturation", 1.5, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(1.5)

func test_ui_filter_brightness_range() -> void:
	# Test valid brightness values
	Settings.set_setting(test_section, "filter_brightness", 0.0, true)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(0.0)

	Settings.set_setting(test_section, "filter_brightness", 2.0, true)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(2.0)

	Settings.set_setting(test_section, "filter_brightness", 1.5, true)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(1.5)

func test_ui_filter_shader_parameters_updated() -> void:
	# This test verifies the shader parameters are set correctly
	# Note: We can't fully test the visual effect without running the scene
	# But we can verify the settings are properly stored and retrieved
	Settings.set_setting(test_section, "filter_hue_shift", 0.25, true)
	Settings.set_setting(test_section, "filter_saturation", 1.2, true)
	Settings.set_setting(test_section, "filter_brightness", 0.9, true)

	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.25)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(1.2)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(0.9)

func test_theme_preset_exists() -> void:
	assert_bool(Settings.presets.has_section_key(test_section, "theme_name")).is_true()

func test_theme_default_value() -> void:
	var default = Settings.get_default(test_section, "theme_name")
	assert_str(default).is_equal("dark")

func test_ui_filter_settings_independent() -> void:
	# Verify that changing one filter setting doesn't affect others
	var original_saturation = Settings.get_setting(test_section, "filter_saturation")
	var original_brightness = Settings.get_setting(test_section, "filter_brightness")

	Settings.set_setting(test_section, "filter_hue_shift", 0.5, true)

	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(original_saturation)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(original_brightness)

func test_ui_filter_grayscale_effect() -> void:
	# Test configuration for grayscale (saturation = 0)
	Settings.set_setting(test_section, "filter_saturation", 0.0, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(0.0)

func test_ui_filter_maximum_saturation() -> void:
	# Test maximum saturation boost
	Settings.set_setting(test_section, "filter_saturation", 2.0, true)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(2.0)

func test_ui_filter_dark_mode() -> void:
	# Test dark mode (reduced brightness)
	Settings.set_setting(test_section, "filter_brightness", 0.5, true)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(0.5)

func test_ui_filter_bright_mode() -> void:
	# Test bright mode (increased brightness)
	Settings.set_setting(test_section, "filter_brightness", 1.5, true)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(1.5)

func test_ui_filter_hue_rotation_positive() -> void:
	# Test positive hue rotation
	Settings.set_setting(test_section, "filter_hue_shift", 0.333, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_between(0.332, 0.334)

func test_ui_filter_hue_rotation_negative() -> void:
	# Test negative hue rotation
	Settings.set_setting(test_section, "filter_hue_shift", -0.333, true)
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_between(-0.334, -0.332)

func test_ui_filter_reset_to_defaults() -> void:
	# Change all values
	Settings.set_setting(test_section, "filter_hue_shift", 0.5, true)
	Settings.set_setting(test_section, "filter_saturation", 1.5, true)
	Settings.set_setting(test_section, "filter_brightness", 0.8, true)

	# Reset to defaults
	Settings.restore_default(test_section, "filter_hue_shift")
	Settings.restore_default(test_section, "filter_saturation")
	Settings.restore_default(test_section, "filter_brightness")

	# Verify defaults
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.0)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(1.0)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(1.0)

func test_ui_filter_extreme_values() -> void:
	# Test edge case values
	Settings.set_setting(test_section, "filter_hue_shift", 1.0, true)
	Settings.set_setting(test_section, "filter_saturation", 2.0, true)
	Settings.set_setting(test_section, "filter_brightness", 2.0, true)

	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(1.0)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(2.0)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(2.0)

	Settings.set_setting(test_section, "filter_hue_shift", -1.0, true)
	Settings.set_setting(test_section, "filter_saturation", 0.0, true)
	Settings.set_setting(test_section, "filter_brightness", 0.0, true)

	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(-1.0)
	assert_float(Settings.get_setting(test_section, "filter_saturation")).is_equal(0.0)
	assert_float(Settings.get_setting(test_section, "filter_brightness")).is_equal(0.0)
