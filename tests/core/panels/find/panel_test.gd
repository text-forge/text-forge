# GdUnit generated TestSuite
class_name FindPanelTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/panels/find/panel.gd'

var panel: Control


func before_test() -> void:
	var scene = load("res://core/panels/find/panel.tscn")
	panel = auto_free(scene.instantiate())
	add_child(panel)
	await get_tree().process_frame
	Global.set_editor_text("foo bar\nfoo baz", true)


func after_test() -> void:
	Global.set_editor_text("", true)


func test_regex_search_finds_the_matches_of_the_pattern() -> void:
	panel.regex.button_pressed = true
	panel._on_line_edit_text_changed("ba.")
	assert_int(panel.matches.size()).is_equal(2)


func test_regex_search_reports_the_line_and_the_column() -> void:
	panel.regex.button_pressed = true
	panel._on_line_edit_text_changed("ba.")
	assert_str(panel.list.get_item_text(0)).is_equal("Line 1, Column 5")
	assert_str(panel.list.get_item_text(1)).is_equal("Line 2, Column 5")


func test_literal_search_does_not_find_the_pattern() -> void:
	panel.regex.button_pressed = false
	panel._on_line_edit_text_changed("ba.")
	assert_int(panel.matches.size()).is_equal(0)


func test_invalid_pattern_shows_an_error() -> void:
	panel.regex.button_pressed = true
	# The regex engine reports the broken pattern itself as a push error, the panel catches it and says so.
	assert_error(func(): panel._on_line_edit_text_changed("[")).is_push_error(any_string())
	assert_str(panel.counter.text).is_equal("Invalid RegEx")
	assert_int(panel.matches.size()).is_equal(0)


func test_match_lengths_follow_the_matches() -> void:
	Global.set_editor_text("xaa yb", true)
	panel.regex.button_pressed = true
	panel._on_line_edit_text_changed("a+|b")
	assert_int(panel.matches.size()).is_equal(2)
	assert_int(panel.match_lengths[0]).is_equal(2)
	assert_int(panel.match_lengths[1]).is_equal(1)


func test_regex_replace_expands_the_capture_groups() -> void:
	Global.set_editor_text("user@example", true)
	panel.regex.button_pressed = true
	panel.search.text = "(\\w+)@(\\w+)"
	panel.replace.text = "$2:$1"
	panel._on_line_edit_text_changed("(\\w+)@(\\w+)")
	panel._on_replace_pressed()
	assert_str(Global.get_editor_text()).is_equal("example:user")


func test_regex_replace_all_expands_the_capture_groups() -> void:
	Global.set_editor_text("a@1 b@2", true)
	panel.regex.button_pressed = true
	panel.search.text = "(\\w+)@(\\w+)"
	panel.replace.text = "$2:$1"
	panel._on_line_edit_text_changed("(\\w+)@(\\w+)")
	panel._on_replace_all_pressed()
	assert_str(Global.get_editor_text()).is_equal("1:a 2:b")
