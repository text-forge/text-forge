# GdUnit generated TestSuite
class_name StaticTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/classes/static.gd'


func test_clean_recent_list_removes_duplicates() -> void:
	assert_array(S.clean_recent_list("res://icon.png\nres://icon.png")).is_equal(["res://icon.png"])


func test_clean_recent_list_removes_non_existent_paths() -> void:
	var list := S.clean_recent_list("res://icon.png\nres://not_a_real_file_xyz.txt")
	assert_array(list).is_equal(["res://icon.png"])


func test_clean_recent_list_ignores_empty_lines() -> void:
	assert_array(S.clean_recent_list("res://icon.png\n\n")).is_equal(["res://icon.png"])


func test_clean_recent_list_empty_content_returns_empty_list() -> void:
	assert_array(S.clean_recent_list("")).is_empty()


func test_clean_recent_list_respects_limit() -> void:
	var content := "res://icon.png\nres://README.md\nres://CHANGELOG.md"
	assert_int(S.clean_recent_list(content, 2).size()).is_equal(2)
	assert_int(S.clean_recent_list(content, 15).size()).is_equal(3)
