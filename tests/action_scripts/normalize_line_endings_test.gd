# GdUnit generated TestSuite
class_name NormalizeLineEndingsTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://action_scripts/normalize_line_endings.gd'

var normalize_script: CheckableActionScript
var test_section := "edit"
var test_key := "normalize_line_endings"

var test_set_value_emits_check_options__signal_emitted := false

func before_test() -> void:
	normalize_script = load(__source).new()
	normalize_script._setup()

func after_test() -> void:
	if normalize_script:
		# Disconnect from hook if connected
		var api := Global.get_editor_api()
		if api.hooks.has(EditorAPI.Hooks.BEFORE_SAVE):
			if api.hooks[EditorAPI.Hooks.BEFORE_SAVE].has(normalize_script._normalizer):
				api.disconnect_from_hook(EditorAPI.Hooks.BEFORE_SAVE, normalize_script._normalizer)
		normalize_script.free()

func test_setup_defines_settings_section() -> void:
	assert_str(normalize_script.settings_section).is_equal("edit")

func test_setup_defines_settings_key() -> void:
	assert_str(normalize_script.settings_key).is_equal("normalize_line_endings")

func test_setup_defines_default_value() -> void:
	assert_bool(normalize_script.default).is_true()

func test_setup_defines_line_endings_preset() -> void:
	assert_bool(Settings.presets.has_section_key("edit", "line_endings")).is_true()
	# The preset default, the live value is the one the user picked and can be any of them.
	assert_str(Settings.get_default("edit", "line_endings")).is_equal("LF")

func test_setup_connects_to_before_save_hook() -> void:
	var api := Global.get_editor_api()
	assert_bool(api.hooks.has(EditorAPI.Hooks.BEFORE_SAVE)).is_true()
	assert_bool(api.hooks[EditorAPI.Hooks.BEFORE_SAVE].has(normalize_script._normalizer)).is_true()

func test_get_value_returns_setting() -> void:
	Settings.set_setting(test_section, test_key, true)
	assert_bool(normalize_script._get_value()).is_true()

	Settings.set_setting(test_section, test_key, false)
	assert_bool(normalize_script._get_value()).is_false()

func test_set_value_emits_check_options() -> void:
	var connection := func(): test_set_value_emits_check_options__signal_emitted = true
	Signals.check_options.connect(connection)

	normalize_script._set_value(true)
	await get_tree().process_frame

	assert_bool(test_set_value_emits_check_options__signal_emitted).is_true()
	Signals.check_options.disconnect(connection)

func test_normalizer_handles_empty_text() -> void:
	Settings.set_setting(test_section, test_key, true)
	Settings.set_setting("edit", "line_endings", "\n")
	Global.set_editor_text("", true)

	normalize_script._normalizer()

	var result := Global.get_editor_text()
	assert_str(result).is_equal("")

func test_normalizer_handles_single_line() -> void:
	Settings.set_setting(test_section, test_key, true)
	Settings.set_setting("edit", "line_endings", "\n")
	Global.set_editor_text("single line without ending", true)

	normalize_script._normalizer()

	var result := Global.get_editor_text()
	assert_str(result).is_equal("single line without ending")
