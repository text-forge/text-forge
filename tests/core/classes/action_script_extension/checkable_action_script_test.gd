# GdUnit generated TestSuite
class_name CheckableActionScriptTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/classes/action_script_extension/checkable_action_script.gd'

var test_checkable_script: TestCheckableActionScript
var test_menu: PopupMenu
var test_section := "test_checkable_section"
var test_key := "test_checkable_key"

var test_run_action_triggers_settings_changed_signal__signal_emitted := false

# Test implementation of CheckableActionScript
class TestCheckableActionScript extends CheckableActionScript:
	var test_section := "test_checkable_section"
	var test_key := "test_checkable_key"
	var setup_called := false
	var set_value_call_count := 0
	var last_set_value: Variant = null
	var get_value_return := false
	var get_value_call_count := 0
	var custom_default = null

	func _setup() -> void:
		setup_called = true
		settings_section = test_section
		settings_key = test_key
		if custom_default != null:
			default = custom_default
		else:
			default = false

	func _set_value(to: bool) -> void:
		set_value_call_count += 1
		last_set_value = to

	func _get_value() -> bool:
		get_value_call_count += 1
		return get_value_return

func before_test() -> void:
	# Clean up test data before each test
	if Settings.settings.has_section(test_section):
		Settings.settings.erase_section(test_section)
	if Settings.presets.has_section(test_section):
		Settings.presets.erase_section(test_section)

	# Create test menu and checkable action script
	test_menu = auto_free(PopupMenu.new())
	test_menu.add_check_item("Test Checkable Action", 200)
	add_child(test_menu)

	test_checkable_script = auto_free(TestCheckableActionScript.new())
	test_checkable_script.id = 200
	test_checkable_script.menu = test_menu

func after_test() -> void:
	# Clean up after each test
	if Settings.settings.has_section(test_section):
		Settings.settings.erase_section(test_section)
	if Settings.presets.has_section(test_section):
		Settings.presets.erase_section(test_section)

# ===== INITIALIZATION TESTS =====

func test_checkable_action_script_initializes() -> void:
	assert_object(test_checkable_script).is_not_null()
	assert_object(test_checkable_script).is_instanceof(CheckableActionScript)

func test_inherits_from_action_script() -> void:
	assert_object(test_checkable_script).is_instanceof(ActionScript)

func test_settings_section_property_exists() -> void:
	add_child(test_checkable_script)
	assert_str(test_checkable_script.settings_section).is_not_empty()

func test_settings_key_property_exists() -> void:
	add_child(test_checkable_script)
	assert_str(test_checkable_script.settings_key).is_not_empty()

func test_default_property_default_false() -> void:
	var fresh_script = auto_free(CheckableActionScript.new())
	assert_bool(fresh_script.default).is_false()

# ===== SETUP TESTS =====

func test_setup_method_is_virtual() -> void:
	var base_script = auto_free(CheckableActionScript.new())
	# _setup should do nothing in base class
	base_script._setup()
	assert_str(base_script.settings_section).is_empty()

func test_setup_called_during_initialization() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame
	assert_bool(test_checkable_script.setup_called).is_true()

func test_setup_configures_settings_section() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame
	assert_str(test_checkable_script.settings_section).is_equal(test_section)

func test_setup_configures_settings_key() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame
	assert_str(test_checkable_script.settings_key).is_equal(test_key)

# ===== INITIALIZATION FLOW TESTS =====

func test_initialize_defines_preset() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame
	var preset_value = Settings.get_default(test_section, test_key)
	assert_bool(preset_value).is_false()

func test_initialize_with_custom_default() -> void:
	var custom_script = auto_free(TestCheckableActionScript.new())
	custom_script.id = 201
	custom_script.menu = test_menu
	test_menu.add_check_item("Custom Default", 201)
	custom_script.custom_default = true
	add_child(custom_script)
	await get_tree().process_frame
	var preset_value = Settings.get_default(test_section, test_key)
	assert_bool(preset_value).is_true()

func test_initialize_loads_config() -> void:
	# Set a value before initialization
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, true)

	add_child(test_checkable_script)
	await get_tree().process_frame

	# _load_config should have been called, triggering _set_value
	assert_int(test_checkable_script.set_value_call_count).is_greater(0)

func test_initialize_connects_to_settings_changed_signal() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame

	# Change settings and verify _load_config is called
	var initial_count = test_checkable_script.set_value_call_count
	Settings.set_setting(test_section, test_key, true)
	await get_tree().process_frame

	assert_int(test_checkable_script.set_value_call_count).is_greater(initial_count)

# ===== RUN ACTION TESTS (CRITICAL FOR BUG FIX) =====

func test_run_action_toggles_setting_from_false_to_true() -> void:
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, false)
	test_checkable_script.get_value_return = false

	add_child(test_checkable_script)
	await get_tree().process_frame

	test_checkable_script._run_action()

	var new_value = Settings.get_setting(test_section, test_key)
	assert_bool(new_value).is_true()

func test_run_action_toggles_setting_from_true_to_false() -> void:
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, true)
	test_checkable_script.get_value_return = true

	add_child(test_checkable_script)
	await get_tree().process_frame

	test_checkable_script._run_action()

	var new_value = Settings.get_setting(test_section, test_key)
	assert_bool(new_value).is_false()

func test_run_action_calls_get_value() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame

	var initial_count = test_checkable_script.get_value_call_count
	test_checkable_script._run_action()

	assert_int(test_checkable_script.get_value_call_count).is_greater(initial_count)

func test_run_action_does_not_directly_call_set_value() -> void:
	# This is the critical test for the bug fix (PR #146)
	# _run_action should NOT call _set_value directly
	# It should only call Settings.set_setting, which triggers the signal
	# that causes _load_config to call _set_value

	add_child(test_checkable_script)
	await get_tree().process_frame

	# Reset the counter after initialization
	test_checkable_script.set_value_call_count = 0

	test_checkable_script._run_action()

	# Wait for signal propagation
	await get_tree().process_frame

	# _set_value should be called exactly once via _load_config
	# (not twice as it would have been before the bug fix)
	assert_int(test_checkable_script.set_value_call_count).is_equal(1)

func test_run_action_triggers_settings_changed_signal() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame

	var connection := func(): test_run_action_triggers_settings_changed_signal__signal_emitted = true
	Signals.settings_changed.connect(connection)

	test_checkable_script._run_action()
	await get_tree().process_frame

	assert_bool(test_run_action_triggers_settings_changed_signal__signal_emitted).is_true()
	Signals.settings_changed.disconnect(connection)

# ===== LOAD CONFIG TESTS =====

func test_load_config_calls_get_setting() -> void:
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, true)

	add_child(test_checkable_script)
	await get_tree().process_frame

	test_checkable_script._load_config()

	# Should call _set_value with the setting value
	assert_bool(test_checkable_script.last_set_value).is_true()

func test_load_config_calls_set_value() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame

	var initial_count = test_checkable_script.set_value_call_count
	test_checkable_script._load_config()

	assert_int(test_checkable_script.set_value_call_count).is_greater(initial_count)

func test_load_config_updates_menu_checked_state_true() -> void:
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, true)
	test_checkable_script.get_value_return = true

	add_child(test_checkable_script)
	await get_tree().process_frame

	test_checkable_script._load_config()
	await get_tree().process_frame

	var item_index = test_menu.get_item_index(200)
	assert_bool(test_menu.is_item_checked(item_index)).is_true()

func test_load_config_updates_menu_checked_state_false() -> void:
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, false)
	test_checkable_script.get_value_return = false

	add_child(test_checkable_script)
	await get_tree().process_frame

	test_checkable_script._load_config()
	await get_tree().process_frame

	var item_index = test_menu.get_item_index(200)
	assert_bool(test_menu.is_item_checked(item_index)).is_false()

func test_load_config_with_default_value() -> void:
	# Don't set any value, should use default
	Settings.define_preset(test_section, test_key, false)

	add_child(test_checkable_script)
	await get_tree().process_frame

	test_checkable_script._load_config()

	# Should use default value (false)
	assert_bool(test_checkable_script.last_set_value).is_false()

# ===== GET/SET VALUE VIRTUAL METHODS TESTS =====

func test_get_value_default_returns_false() -> void:
	var base_script = auto_free(CheckableActionScript.new())
	assert_bool(base_script._get_value()).is_false()

func test_set_value_default_does_nothing() -> void:
	var base_script = auto_free(CheckableActionScript.new())
	# Should not throw error
	base_script._set_value(true)
	base_script._set_value(false)

func test_custom_get_value_implementation() -> void:
	test_checkable_script.get_value_return = true
	assert_bool(test_checkable_script._get_value()).is_true()

	test_checkable_script.get_value_return = false
	assert_bool(test_checkable_script._get_value()).is_false()

func test_custom_set_value_tracks_calls() -> void:
	test_checkable_script._set_value(true)
	assert_int(test_checkable_script.set_value_call_count).is_equal(1)
	assert_bool(test_checkable_script.last_set_value).is_true()

	test_checkable_script._set_value(false)
	assert_int(test_checkable_script.set_value_call_count).is_equal(2)
	assert_bool(test_checkable_script.last_set_value).is_false()

# ===== INTEGRATION TESTS =====

func test_full_toggle_cycle_off_to_on_to_off() -> void:
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, false)
	test_checkable_script.get_value_return = false

	add_child(test_checkable_script)
	await get_tree().process_frame

	# Initial state: false
	assert_bool(Settings.get_setting(test_section, test_key)).is_false()

	# Toggle to true
	test_checkable_script.get_value_return = false  # Current state before toggle
	test_checkable_script._run_action()
	await get_tree().process_frame
	assert_bool(Settings.get_setting(test_section, test_key)).is_true()

	# Toggle back to false
	test_checkable_script.get_value_return = true  # Current state before toggle
	test_checkable_script._run_action()
	await get_tree().process_frame
	assert_bool(Settings.get_setting(test_section, test_key)).is_false()

func test_settings_changed_signal_propagates_to_all_instances() -> void:
	var script2 = auto_free(TestCheckableActionScript.new())
	script2.id = 201
	script2.menu = test_menu
	test_menu.add_check_item("Second Checkable", 201)

	add_child(test_checkable_script)
	add_child(script2)
	await get_tree().process_frame

	# Reset counters
	test_checkable_script.set_value_call_count = 0
	script2.set_value_call_count = 0

	# Change setting externally
	Settings.set_setting(test_section, test_key, true)
	await get_tree().process_frame

	# Both scripts should react to the signal
	assert_int(test_checkable_script.set_value_call_count).is_equal(1)
	assert_int(script2.set_value_call_count).is_equal(1)

# ===== EDGE CASES AND ERROR HANDLING =====

func test_run_action_with_uninitialized_settings() -> void:
	# Don't define preset or set setting
	add_child(test_checkable_script)
	await get_tree().process_frame

	# Should handle gracefully (Settings will use null default)
	test_checkable_script._run_action()
	# Should not crash

func test_load_config_with_missing_setting() -> void:
	Settings.define_preset(test_section, test_key, false)
	# Don't set the setting

	add_child(test_checkable_script)
	await get_tree().process_frame

	test_checkable_script._load_config()

	# Should use default value
	assert_bool(test_checkable_script.last_set_value).is_false()

func test_menu_item_checked_state_consistency() -> void:
	Settings.define_preset(test_section, test_key, false)
	Settings.set_setting(test_section, test_key, true)
	test_checkable_script.get_value_return = true

	add_child(test_checkable_script)
	await get_tree().process_frame

	var item_index = test_menu.get_item_index(200)
	var is_checked = test_menu.is_item_checked(item_index)
	var setting_value = Settings.get_setting(test_section, test_key)

	# Menu state should match setting value
	assert_bool(is_checked).is_equal(setting_value)

func test_rapid_toggle_operations() -> void:
	add_child(test_checkable_script)
	await get_tree().process_frame

	# Reset counter
	test_checkable_script.set_value_call_count = 0

	# Perform multiple rapid toggles
	for i in range(5):
		test_checkable_script.get_value_return = (i % 2 == 0)
		test_checkable_script._run_action()
		await get_tree().process_frame

	# Each toggle should trigger exactly one _set_value call
	assert_int(test_checkable_script.set_value_call_count).is_equal(5)

func test_default_true_initialization() -> void:
	var script_with_true_default = auto_free(TestCheckableActionScript.new())
	script_with_true_default.id = 202
	script_with_true_default.menu = test_menu
	script_with_true_default.custom_default = true
	test_menu.add_check_item("True Default", 202)

	add_child(script_with_true_default)
	await get_tree().process_frame

	var preset_value = Settings.get_default(test_section, test_key)
	assert_bool(preset_value).is_true()

func test_null_menu_handled_gracefully() -> void:
	var script_no_menu = auto_free(TestCheckableActionScript.new())
	script_no_menu.id = 203
	# Don't set menu

	# Should not crash during setup
	script_no_menu._setup()

# ===== PROPERTY TESTS =====

func test_settings_section_can_be_customized() -> void:
	var custom_script = auto_free(CheckableActionScript.new())
	custom_script.settings_section = "custom_section"
	assert_str(custom_script.settings_section).is_equal("custom_section")

func test_settings_key_can_be_customized() -> void:
	var custom_script = auto_free(CheckableActionScript.new())
	custom_script.settings_key = "custom_key"
	assert_str(custom_script.settings_key).is_equal("custom_key")

func test_default_can_be_customized() -> void:
	var custom_script = auto_free(CheckableActionScript.new())
	custom_script.default = true
	assert_bool(custom_script.default).is_true()
