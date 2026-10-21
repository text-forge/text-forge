# GdUnit generated TestSuite
class_name SaveAsSnippetTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://action_scripts/save_as_snippet.gd'

## Name of the snippet the tests write, it is removed again after every test.
const SNIPPET_NAME := "gdunit_test_snippet"

var save_script: ActionScript


func before_test() -> void:
	save_script = auto_free(load(__source).new())
	save_script._initialize()
	Global.set_editor_text("snippet body", true)


func after_test() -> void:
	Global.set_editor_text("", true)
	var path := S.TEMPLATE_SNIPPETS.format([SNIPPET_NAME])
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(S.globalize_path(path))


func test_save_writes_the_snippet_file() -> void:
	save_script._save_snippet(SNIPPET_NAME)
	var path := S.TEMPLATE_SNIPPETS.format([SNIPPET_NAME])
	assert_bool(FileAccess.file_exists(path)).is_true()
	assert_str(FileAccess.get_file_as_string(path)).is_equal("snippet body")


func test_save_replaces_an_existing_snippet() -> void:
	save_script._save_snippet(SNIPPET_NAME)
	Global.set_editor_text("other body", true)
	save_script._save_snippet(SNIPPET_NAME)
	var path := S.TEMPLATE_SNIPPETS.format([SNIPPET_NAME])
	assert_str(FileAccess.get_file_as_string(path)).is_equal("other body")


func test_save_ignores_an_empty_name() -> void:
	save_script._save_snippet("  ")
	assert_bool(FileAccess.file_exists(S.TEMPLATE_SNIPPETS.format([""]))).is_false()
