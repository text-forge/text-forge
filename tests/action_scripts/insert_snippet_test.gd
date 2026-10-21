# GdUnit generated TestSuite
class_name InsertSnippetTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://action_scripts/insert_snippet.gd'

## Name of the snippet the tests write, it is removed again after every test.
const SNIPPET_NAME := "gdunit_test_snippet"

var insert_script: MultiActionScript


func before_test() -> void:
	insert_script = auto_free(load(__source).new())
	# The editor creates the folder when it builds the menu, the test has to do it itself.
	if not DirAccess.dir_exists_absolute(S.globalize_path(S.FOLDER_SNIPPETS)):
		DirAccess.make_dir_recursive_absolute(S.globalize_path(S.FOLDER_SNIPPETS))
	var file := FileAccess.open(S.TEMPLATE_SNIPPETS.format([SNIPPET_NAME]), FileAccess.WRITE)
	file.store_string("hello")
	file.close()
	Global.set_editor_text("ab", true)


func after_test() -> void:
	Global.set_editor_text("", true)
	var path := S.TEMPLATE_SNIPPETS.format([SNIPPET_NAME])
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(S.globalize_path(path))
	Global.get_core().reload_snippets()


func test_insert_snippet_is_a_multi_action_script() -> void:
	assert_object(insert_script).is_instanceof(MultiActionScript)


func test_insert_puts_the_snippet_at_the_caret() -> void:
	Global.get_editor().set_caret_line(0)
	Global.get_editor().set_caret_column(1)
	Global.get_core().insert_snippet(SNIPPET_NAME)
	assert_str(Global.get_editor_text()).is_equal("ahellob")


func test_insert_replaces_the_selection() -> void:
	Global.get_editor().select(0, 0, 0, 1)
	Global.get_core().insert_snippet(SNIPPET_NAME)
	assert_str(Global.get_editor_text()).is_equal("hellob")


func test_snippet_is_in_the_command_list() -> void:
	Global.get_core().reload_snippets()
	var commands := Global.get_command_list()
	var command_name := "Insert > " + SNIPPET_NAME
	assert_bool(commands.has(command_name)).is_true()
	Global.get_editor().set_caret_line(0)
	Global.get_editor().set_caret_column(1)
	commands[command_name][1].call()
	assert_str(Global.get_editor_text()).is_equal("ahellob")
