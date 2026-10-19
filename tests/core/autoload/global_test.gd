# GdUnit generated TestSuite
class_name GlobalAccessTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/global.gd'

func test_window_manager_exists() -> void:
	assert_object(Global.window_manager).is_not_null()
	assert_object(Global.window_manager).is_instanceof(Global.WindowManager)

func test_damaged_modes_is_dictionary() -> void:
	assert_bool(typeof(Global.damaged_modes) == TYPE_DICTIONARY).is_true()

func test_shortcut_map_loaded() -> void:
	assert_object(Global.shortcut_map).is_not_null()
	assert_object(Global.shortcut_map).is_instanceof(ShortcutMap)

func test_commands_dictionary_exists() -> void:
	var cmds = Global.get_command_list()
	assert_bool(typeof(cmds) == TYPE_DICTIONARY).is_true()

func test_get_editor_returns_editor() -> void:
	var editor = Global.get_editor()
	assert_object(editor).is_not_null()
	assert_object(editor).is_instanceof(Editor)

func test_get_core_returns_core() -> void:
	var core = Global.get_core()
	assert_object(core).is_not_null()
	assert_object(core).is_instanceof(Core)

func test_get_editor_api_returns_api() -> void:
	var api = Global.get_editor_api()
	assert_object(api).is_not_null()
	assert_object(api).is_instanceof(EditorAPI)

func test_get_scripts_node_returns_node() -> void:
	var scripts = Global.get_scripts_node()
	assert_object(scripts).is_not_null()
	assert_object(scripts).is_instanceof(Node)

func test_get_panel_manager_returns_manager() -> void:
	var pm = Global.get_panel_manager()
	assert_object(pm).is_not_null()
	assert_object(pm).is_instanceof(PanelManager)

func test_get_file_name_returns_string() -> void:
	var file_name = Global.get_file_name()
	assert_bool(typeof(file_name) == TYPE_STRING).is_true()

func test_get_file_path_returns_string() -> void:
	var path = Global.get_file_path()
	assert_bool(typeof(path) == TYPE_STRING).is_true()

func test_set_file_name_updates_name() -> void:
	var original_name = Global.get_file_name()
	Global.set_file_name("test_file.txt")
	assert_str(Global.get_file_name()).is_equal("test_file.txt")
	Global.set_file_name(original_name)

func test_set_file_path_updates_path() -> void:
	var original_path = Global.get_file_path()
	Global.set_file_path("/tmp/test_file.txt")
	assert_str(Global.get_file_path()).is_equal("/tmp/test_file.txt")
	Global.set_file_path(original_path)

func test_has_file_checks_absolute_path() -> void:
	var original_path = Global.get_file_path()
	Global.set_file_path("")
	assert_bool(Global.has_file()).is_false()
	Global.set_file_path("/tmp/file.txt")
	assert_bool(Global.has_file()).is_true()
	Global.set_file_path(original_path)

func test_get_editor_text_returns_string() -> void:
	var text = Global.get_editor_text()
	assert_bool(typeof(text) == TYPE_STRING).is_true()

func test_set_editor_text_updates_text() -> void:
	var original_text = Global.get_editor_text()
	Global.set_editor_text("test content", false)
	assert_str(Global.get_editor_text()).is_equal("test content")
	Global.set_editor_text(original_text, false)

func test_set_editor_disabled_changes_state() -> void:
	var original_state = Global.is_editor_disabled()
	Global.set_editor_disabled(true)
	assert_bool(Global.is_editor_disabled()).is_true()
	Global.set_editor_disabled(false)
	assert_bool(Global.is_editor_disabled()).is_false()
	Global.set_editor_disabled(original_state)

func test_is_editor_disabled_returns_boolean() -> void:
	var disabled = Global.is_editor_disabled()
	assert_bool(typeof(disabled) == TYPE_BOOL).is_true()

func test_define_command_adds_command() -> void:
	Global.define_command("TestCommand", "Ctrl+T", func(): pass)
	var cmds = Global.get_command_list()
	assert_bool(cmds.has("TestCommand")).is_true()

func test_define_command_stores_shortcut() -> void:
	Global.define_command("TestCmd", "Ctrl+Shift+X", func(): pass)
	var cmds = Global.get_command_list()
	assert_str(cmds["TestCmd"][0]).is_equal("Ctrl+Shift+X")

func test_has_unsaved_change_checks_star() -> void:
	var original_name = Global.get_file_name()
	Global.set_file_name("file.txt")
	assert_bool(Global.has_unsaved_change()).is_false()
	Global.set_file_name("file.txt*")
	assert_bool(Global.has_unsaved_change()).is_true()
	Global.set_file_name(original_name)

func test_mark_file_as_unsaved_adds_star() -> void:
	var original_name = Global.get_file_name()
	Global.set_file_name("file.txt")
	Global.set_editor_disabled(false)
	Global.mark_file_as_unsaved()
	assert_bool(Global.get_file_name().ends_with("*")).is_true()
	Global.set_file_name(original_name)

func test_temprory_children_is_dictionary() -> void:
	assert_bool(typeof(Global.temprory_children) == TYPE_DICTIONARY).is_true()

func test_get_last_file_path_returns_string() -> void:
	var path = Global.get_last_file_path()
	assert_bool(typeof(path) == TYPE_STRING).is_true()

func test_window_manager_constants() -> void:
	assert_str(Global.WindowManager.WINDOW_SECTION_ID).is_equal("window")
