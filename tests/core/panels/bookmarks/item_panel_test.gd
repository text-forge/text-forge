# GdUnit generated TestSuite
class_name BookmarkItemPanelTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/panels/bookmarks/item_panel.gd'

var item_panel: PanelContainer

func before_test() -> void:
	var scene = load("res://core/panels/bookmarks/item_panel.tscn")
	item_panel = auto_free(scene.instantiate())
	add_child(item_panel)
	await get_tree().process_frame

func test_panel_instantiates_correctly() -> void:
	assert_object(item_panel).is_not_null()
	assert_object(item_panel).is_instanceof(PanelContainer)

func test_has_required_export_variables() -> void:
	assert_object(item_panel.number_label).is_not_null()
	assert_object(item_panel.line_label).is_not_null()
	assert_object(item_panel.goto_button).is_not_null()
	assert_object(item_panel.remove_button).is_not_null()

func test_labels_are_correct_type() -> void:
	assert_object(item_panel.number_label).is_instanceof(Label)
	assert_object(item_panel.line_label).is_instanceof(Label)

func test_buttons_are_correct_type() -> void:
	assert_object(item_panel.goto_button).is_instanceof(Button)
	assert_object(item_panel.remove_button).is_instanceof(Button)

func test_update_sets_line_label_text() -> void:
	var test_text := "    def my_function():"
	var test_line := 42

	item_panel.update(test_text, test_line)

	assert_str(item_panel.line_label.text).is_equal(test_text)

func test_update_sets_line_label_tooltip() -> void:
	var test_text := "Very long line that might get truncated in the UI"
	var test_line := 10

	item_panel.update(test_text, test_line)

	assert_str(item_panel.line_label.tooltip_text).is_equal(test_text)

func test_update_sets_line_number_display() -> void:
	item_panel.update("test", 0)
	assert_str(item_panel.number_label.text).is_equal("1")

func test_update_line_number_zero_indexed() -> void:
	# Line 0 should display as "1"
	item_panel.update("line 0", 0)
	assert_str(item_panel.number_label.text).is_equal("1")

	# Line 5 should display as "6"
	item_panel.update("line 5", 5)
	assert_str(item_panel.number_label.text).is_equal("6")

	# Line 99 should display as "100"
	item_panel.update("line 99", 99)
	assert_str(item_panel.number_label.text).is_equal("100")

func test_update_with_empty_line() -> void:
	item_panel.update("", 5)
	assert_str(item_panel.line_label.text).is_equal("")
	assert_str(item_panel.line_label.tooltip_text).is_equal("")
	assert_str(item_panel.number_label.text).is_equal("6")

func test_update_with_whitespace_only() -> void:
	var whitespace := "     \t  "
	item_panel.update(whitespace, 10)
	assert_str(item_panel.line_label.text).is_equal(whitespace)
	assert_str(item_panel.number_label.text).is_equal("11")

func test_update_with_special_characters() -> void:
	var special := "let x = { foo: 'bar', baz: [1, 2, 3] };"
	item_panel.update(special, 25)
	assert_str(item_panel.line_label.text).is_equal(special)
	assert_str(item_panel.number_label.text).is_equal("26")

func test_update_with_unicode_characters() -> void:
	var unicode := "Hello 世界 🌍"
	item_panel.update(unicode, 5)
	assert_str(item_panel.line_label.text).is_equal(unicode)

func test_update_with_very_long_line() -> void:
	var long_line := "x".repeat(500)
	item_panel.update(long_line, 100)
	assert_str(item_panel.line_label.text).is_equal(long_line)
	assert_str(item_panel.line_label.tooltip_text).is_equal(long_line)

func test_update_preserves_line_internal_value() -> void:
	item_panel.update("test", 42)
	assert_int(item_panel._line).is_equal(42)

func test_line_property_setter() -> void:
	item_panel._line = 42
	assert_str(item_panel.number_label.text).is_equal("43")

	item_panel._line = 0
	assert_str(item_panel.number_label.text).is_equal("1")

	item_panel._line = 999
	assert_str(item_panel.number_label.text).is_equal("1000")

func test_multiple_updates_on_same_panel() -> void:
	# First update
	item_panel.update("first line", 10)
	assert_str(item_panel.line_label.text).is_equal("first line")
	assert_str(item_panel.number_label.text).is_equal("11")

	# Second update
	item_panel.update("second line", 20)
	assert_str(item_panel.line_label.text).is_equal("second line")
	assert_str(item_panel.number_label.text).is_equal("21")

	# Third update
	item_panel.update("third line", 30)
	assert_str(item_panel.line_label.text).is_equal("third line")
	assert_str(item_panel.number_label.text).is_equal("31")

func test_update_doesnt_affect_button_state() -> void:
	var initial_goto_disabled = item_panel.goto_button.disabled
	var initial_remove_disabled = item_panel.remove_button.disabled

	item_panel.update("test", 5)

	assert_bool(item_panel.goto_button.disabled).is_equal(initial_goto_disabled)
	assert_bool(item_panel.remove_button.disabled).is_equal(initial_remove_disabled)

func test_panel_has_theme_type_variation() -> void:
	# The panel should have a custom theme type
	assert_str(item_panel.theme_type_variation).is_equal("BookmarkPanel")

func test_goto_button_has_icon() -> void:
	assert_object(item_panel.goto_button.icon).is_not_null()

func test_remove_button_has_icon() -> void:
	assert_object(item_panel.remove_button.icon).is_not_null()

# Note: Testing button callbacks (_on_go_to_pressed, _on_remove_pressed)
# requires Global singleton which makes unit testing difficult.
# These are better tested as integration tests.
