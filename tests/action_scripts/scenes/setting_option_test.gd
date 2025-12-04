# GdUnit generated TestSuite
class_name SettingOptionTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://action_scripts/scenes/setting_option.gd'

var setting_option: SettingOption
var test_section := "test_ui"
var test_key := "test_setting"

func before_test() -> void:
	# Clean up test settings
	if Settings.settings.has_section(test_section):
		Settings.settings.erase_section(test_section)
	if Settings.presets.has_section(test_section):
		Settings.presets.erase_section(test_section)

	# Create a new SettingOption instance
	setting_option = load(__source.replace(".gd", ".tscn")).instantiate()
	add_child(setting_option)

func after_test() -> void:
	# Clean up
	if Settings.settings.has_section(test_section):
		Settings.settings.erase_section(test_section)
	if Settings.presets.has_section(test_section):
		Settings.presets.erase_section(test_section)

func test_setting_option_initializes() -> void:
	assert_object(setting_option).is_not_null()
	assert_object(setting_option).is_instanceof(SettingOption)

func test_label_exists() -> void:
	assert_object(setting_option.label).is_not_null()
	assert_object(setting_option.label).is_instanceof(Label)

func test_options_tab_container_exists() -> void:
	assert_object(setting_option.options).is_not_null()
	assert_object(setting_option.options).is_instanceof(TabContainer)

func test_bool_setting_displays_correctly() -> void:
	Settings.define_preset(test_section, test_key, true)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Should select checkbox tab (index 0)
	assert_int(setting_option.options.current_tab).is_equal(0)
	assert_bool(setting_option.options.get_child(0).button_pressed).is_true()

func test_bool_setting_false_displays_off() -> void:
	Settings.define_preset(test_section, test_key, false)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	assert_int(setting_option.options.current_tab).is_equal(0)
	assert_bool(setting_option.options.get_child(0).button_pressed).is_false()
	assert_str(setting_option.options.get_child(0).text).is_equal("Off")

func test_int_setting_displays_correctly() -> void:
	Settings.define_preset(test_section, test_key, 42)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Should select SpinBox tab (index 1)
	assert_int(setting_option.options.current_tab).is_equal(1)
	assert_float(setting_option.options.get_child(1).value).is_equal(42.0)

func test_float_setting_displays_correctly() -> void:
	Settings.define_preset(test_section, test_key, 3.14)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Should select SpinBox tab (index 1) for floats
	assert_int(setting_option.options.current_tab).is_equal(1)
	assert_float(setting_option.options.get_child(1).value).is_equal(3.14)

func test_float_setting_with_zero() -> void:
	Settings.define_preset(test_section, test_key, 0.0)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	assert_int(setting_option.options.current_tab).is_equal(1)
	assert_float(setting_option.options.get_child(1).value).is_equal(0.0)

func test_float_setting_with_negative_value() -> void:
	Settings.define_preset(test_section, test_key, -1.5)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	assert_int(setting_option.options.current_tab).is_equal(1)
	assert_float(setting_option.options.get_child(1).value).is_equal(-1.5)

func test_float_setting_with_large_value() -> void:
	Settings.define_preset(test_section, test_key, 999.99)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	assert_int(setting_option.options.current_tab).is_equal(1)
	assert_float(setting_option.options.get_child(1).value).is_equal(999.99)

func test_string_setting_displays_correctly() -> void:
	Settings.define_preset(test_section, test_key, "test_string")
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Should select LineEdit tab (index 2)
	assert_int(setting_option.options.current_tab).is_equal(2)
	assert_str(setting_option.options.get_child(2).text).is_equal("test_string")

func test_array_setting_displays_correctly() -> void:
	Settings.define_preset(test_section, test_key, ["item1", "item2", "item3"])
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Should select LineEdit2 tab (index 3) for arrays
	assert_int(setting_option.options.current_tab).is_equal(3)
	assert_str(setting_option.options.get_child(3).text).is_equal("item1, item2, item3")

func test_label_text_capitalized() -> void:
	setting_option.section = test_section
	setting_option.key = "test_key_name"
	Settings.define_preset(test_section, "test_key_name", 0)
	setting_option._ready()

	assert_str(setting_option.label.text).is_equal("Test Key Name")

func test_checkbox_toggle_updates_setting() -> void:
	Settings.define_preset(test_section, test_key, false)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Simulate checkbox press
	setting_option.options.get_child(0).button_pressed = true
	setting_option._on_check_box_pressed()

	assert_bool(Settings.get_setting(test_section, test_key)).is_true()
	assert_str(setting_option.options.get_child(0).text).is_equal("On")

func test_spinbox_change_updates_int_setting() -> void:
	Settings.define_preset(test_section, test_key, 10)
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Simulate SpinBox value change
	setting_option.options.get_child(1).value = 25
	setting_option._on_spin_box_value_changed()

	assert_float(Settings.get_setting(test_section, test_key)).is_equal(25.0)

func test_line_edit_change_updates_string_setting() -> void:
	Settings.define_preset(test_section, test_key, "initial")
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Simulate LineEdit text submission
	setting_option._on_line_edit_text_submitted("updated_text")

	assert_str(Settings.get_setting(test_section, test_key)).is_equal("updated_text")

func test_line_edit2_change_updates_array_setting() -> void:
	Settings.define_preset(test_section, test_key, [])
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Simulate LineEdit2 text submission with comma-separated values
	setting_option._on_line_edit_2_text_submitted("a, b, c")

	var result = Settings.get_setting(test_section, test_key)
	assert_array(result).contains_exactly(["a", "b", "c"])

func test_array_setting_strips_whitespace() -> void:
	Settings.define_preset(test_section, test_key, [])
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	# Submit with extra whitespace
	setting_option._on_line_edit_2_text_submitted("  item1  ,  item2  ,  item3  ")

	var result = Settings.get_setting(test_section, test_key)
	assert_array(result).contains_exactly(["item1", "item2", "item3"])

func test_invalid_type_queues_free() -> void:
	# Dictionary type is not supported
	Settings.define_preset(test_section, test_key, {"key": "value"})
	setting_option.section = test_section
	setting_option.key = test_key
	setting_option._ready()

	await await_idle_frame()

	assert_object(setting_option).is_null()
