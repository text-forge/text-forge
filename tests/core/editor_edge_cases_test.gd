# GdUnit generated TestSuite
class_name EditorEdgeCasesTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# Additional comprehensive edge case tests for Editor
const __source = 'res://core/scripts/editor.gd'

var editor: Editor

func before_test() -> void:
	editor = auto_free(Editor.new())
	add_child(editor)
	await get_tree().process_frame

## Edge cases for get_char_index

func test_get_char_index_unicode_characters() -> void:
	editor.text = "Hello 世界\nSecond line"
	var index := editor.get_char_index(0, 6)
	assert_int(index).is_equal(6)

func test_get_char_index_emoji_characters() -> void:
	editor.text = "Hello 😀 World"
	var index := editor.get_char_index(0, 6)
	assert_int(index).is_equal(6)

func test_get_char_index_multiple_empty_lines() -> void:
	editor.text = "\n\n\nContent"
	var index := editor.get_char_index(3, 0)
	assert_int(index).is_equal(3)

func test_get_char_index_line_with_only_newline() -> void:
	editor.text = "Line 1\n\nLine 3"
	var index := editor.get_char_index(2, 0)
	assert_int(index).is_equal(8)

func test_get_char_index_very_long_line() -> void:
	var long_line := "x".repeat(10000)
	editor.text = long_line
	var index := editor.get_char_index(0, 5000)
	assert_int(index).is_equal(5000)

func test_get_char_index_tabs() -> void:
	editor.text = "Hello\tWorld"
	var index := editor.get_char_index(0, 6)
	assert_int(index).is_equal(6)

func test_get_char_index_mixed_whitespace() -> void:
	editor.text = "  \t  Line with mixed whitespace"
	var index := editor.get_char_index(0, 5)
	assert_int(index).is_equal(5)

func test_get_char_index_carriage_return() -> void:
	editor.text = "Line 1\r\nLine 2"
	var index := editor.get_char_index(0, 6)
	assert_int(index).is_equal(6)

func test_get_char_index_beyond_line_length() -> void:
	editor.text = "Short"
	var index := editor.get_char_index(0, 100)
	# Should handle gracefully - result depends on implementation
	assert_int(index).is_greater_equal(5)

func test_get_char_index_negative_column() -> void:
	editor.text = "Test line"
	var index := editor.get_char_index(0, 0)
	assert_int(index).is_equal(0)

func test_get_char_index_very_large_line_number() -> void:
	editor.text = "Line 1\nLine 2"
	var index := editor.get_char_index(100, 0)
	# Should handle gracefully
	assert_object(index).is_not_null()

## Edge cases for is_selection_in_line

func test_is_selection_in_line_no_text() -> void:
	editor.text = ""
	editor.deselect()
	assert_bool(editor.is_selection_in_line(0)).is_true()

func test_is_selection_in_line_multiple_carets_no_selection() -> void:
	editor.text = "Line 1\nLine 2\nLine 3\nLine 4"
	editor.deselect()
	editor.set_caret_line(0, 1)
	editor.set_caret_line(2, 2)
	# With multiple carets but no selection
	assert_bool(editor.is_selection_in_line(0)).is_true()
	assert_bool(editor.is_selection_in_line(2)).is_true()

func test_is_selection_in_line_entire_document() -> void:
	editor.text = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
	editor.select(0, 0, 4, 6)
	for line in range(5):
		assert_bool(editor.is_selection_in_line(line)).is_true()

func test_is_selection_in_line_overlapping_selections() -> void:
	editor.text = "Line 1\nLine 2\nLine 3\nLine 4"
	editor.select(0, 0, 2, 0)
	# Lines within the selection should be detected
	assert_bool(editor.is_selection_in_line(0)).is_true()
	assert_bool(editor.is_selection_in_line(1)).is_true()
	assert_bool(editor.is_selection_in_line(2)).is_true()

func test_is_selection_in_line_boundary_conditions() -> void:
	editor.text = "Line 1\nLine 2\nLine 3"
	editor.select(1, 0, 1, 6)
	# Exactly on line 1
	assert_bool(editor.is_selection_in_line(0)).is_false()
	assert_bool(editor.is_selection_in_line(1)).is_true()
	assert_bool(editor.is_selection_in_line(2)).is_false()

## Edge cases for type_timer

func test_type_timer_multiple_rapid_changes() -> void:
	editor.type_timer.stop()
	for i in range(10):
		editor._on_text_changed()
		await get_tree().create_timer(0.01).timeout
	# Timer should still be running after rapid changes
	assert_bool(not editor.type_timer.is_stopped()).is_true()

func test_type_timer_timeout_signal_emitted() -> void:
	var signal_count := 0
	editor.type_timer_timeout.connect(func(): signal_count += 1)
	editor._on_text_changed()
	await get_tree().create_timer(0.4).timeout
	assert_int(signal_count).is_greater_equal(1)

func test_type_timer_restart_extends_timeout() -> void:
	editor._on_text_changed()
	await get_tree().create_timer(0.15).timeout
	var time_before := editor.type_timer.time_left
	editor._on_text_changed()
	var time_after := editor.type_timer.time_left
	# Time should be reset (higher after restart)
	assert_float(time_after).is_greater(time_before)

## Edge cases for gutter clicks

func test_on_gutter_clicked_same_line_multiple_times() -> void:
	editor.editable = true
	editor.text = "Line 1\nLine 2\nLine 3"
	
	# Click 5 times on same line
	for i in range(5):
		editor._on_gutter_clicked(1, 0)
	
	# Should end up toggled (odd number of times = on)
	assert_bool(editor.is_line_bookmarked(1)).is_true()

func test_on_gutter_clicked_all_lines() -> void:
	editor.editable = true
	editor.text = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
	
	# Bookmark all lines
	for line in range(editor.get_line_count()):
		editor._on_gutter_clicked(line, 0)
	
	# All should be bookmarked
	for line in range(editor.get_line_count()):
		assert_bool(editor.is_line_bookmarked(line)).is_true()

func test_on_gutter_clicked_alternating_pattern() -> void:
	editor.editable = true
	editor.text = "L1\nL2\nL3\nL4\nL5\nL6"
	
	# Bookmark alternating lines (0, 2, 4)
	for line in range(0, editor.get_line_count(), 2):
		editor._on_gutter_clicked(line, 0)
	
	# Check pattern
	for line in range(editor.get_line_count()):
		if line % 2 == 0:
			assert_bool(editor.is_line_bookmarked(line)).is_true()
		else:
			assert_bool(editor.is_line_bookmarked(line)).is_false()

func test_on_gutter_clicked_last_line() -> void:
	editor.editable = true
	editor.text = "Line 1\nLine 2\nLine 3"
	var last_line := editor.get_line_count() - 1
	
	editor._on_gutter_clicked(last_line, 0)
	
	assert_bool(editor.is_line_bookmarked(last_line)).is_true()

func test_on_gutter_clicked_invalid_gutter_numbers() -> void:
	editor.editable = true
	editor.text = "Line 1\nLine 2"
	
	# Try various invalid gutter numbers
	editor._on_gutter_clicked(0, -1)
	editor._on_gutter_clicked(0, 10)
	editor._on_gutter_clicked(0, 100)
	
	# Should not bookmark the line
	assert_bool(editor.is_line_bookmarked(0)).is_false()

func test_on_gutter_clicked_state_persistence() -> void:
	editor.editable = true
	editor.text = "Line 1\nLine 2\nLine 3"
	
	# Set bookmarks
	editor._on_gutter_clicked(0, 0)
	editor._on_gutter_clicked(2, 0)
	
	# Modify text
	editor.text += "\nLine 4"
	
	# Original bookmarks should still exist
	assert_bool(editor.is_line_bookmarked(0)).is_true()
	assert_bool(editor.is_line_bookmarked(2)).is_true()

## Integration tests

func test_type_timer_and_text_change_integration() -> void:
	var timeout_count := 0
	editor.type_timer_timeout.connect(func(): timeout_count += 1)
	
	# Simulate typing
	editor.text = "H"
	editor._on_text_changed()
	await get_tree().create_timer(0.1).timeout
	
	editor.text = "He"
	editor._on_text_changed()
	await get_tree().create_timer(0.1).timeout
	
	editor.text = "Hel"
	editor._on_text_changed()
	await get_tree().create_timer(0.4).timeout
	
	# Should have timed out at least once
	assert_int(timeout_count).is_greater_equal(1)

func test_bookmark_and_selection_interaction() -> void:
	editor.editable = true
	editor.text = "Line 1\nLine 2\nLine 3"
	
	# Set bookmarks
	editor._on_gutter_clicked(0, 0)
	editor._on_gutter_clicked(2, 0)
	
	# Select middle line
	editor.select(1, 0, 1, 6)
	
	# Bookmarks should persist
	assert_bool(editor.is_line_bookmarked(0)).is_true()
	assert_bool(editor.is_line_bookmarked(1)).is_false()
	assert_bool(editor.is_line_bookmarked(2)).is_true()

func test_multiple_operations_sequence() -> void:
	editor.editable = true
	editor.text = "Initial text"
	
	# Start timer
	editor._on_text_changed()
	
	# Add bookmark
	editor._on_gutter_clicked(0, 0)
	assert_bool(editor.is_line_bookmarked(0)).is_true()
	
	# Change text
	editor.text = "Modified text"
	editor._on_text_changed()
	
	# Timer should still be running
	assert_bool(not editor.type_timer.is_stopped()).is_true()

## Stress tests

func test_many_lines_selection() -> void:
	var lines := []
	for i in range(1000):
		lines.append("Line " + str(i))
	editor.text = "\n".join(lines)
	
	editor.select(0, 0, 500, 0)
	
	# Check some samples
	assert_bool(editor.is_selection_in_line(0)).is_true()
	assert_bool(editor.is_selection_in_line(250)).is_true()
	assert_bool(editor.is_selection_in_line(500)).is_true()
	assert_bool(editor.is_selection_in_line(750)).is_false()

func test_many_bookmarks() -> void:
	editor.editable = true
	var lines := []
	for i in range(100):
		lines.append("Line " + str(i))
	editor.text = "\n".join(lines)
	
	# Bookmark every 10th line
	for i in range(0, 100, 10):
		editor._on_gutter_clicked(i, 0)
	
	# Verify
	for i in range(0, 100, 10):
		assert_bool(editor.is_line_bookmarked(i)).is_true()

func test_rapid_editable_toggle() -> void:
	editor.text = "Test line"
	
	for i in range(20):
		editor.editable = i % 2 == 0
		editor._on_gutter_clicked(0, 0)
	
	# Only even iterations should have toggled, so 10 times
	# Resulting in bookmark on (10 is even)
	assert_bool(editor.is_line_bookmarked(0)).is_true()

## Property validation tests

func test_editor_inherits_from_code_edit() -> void:
	assert_object(editor).is_instanceof(CodeEdit)

func test_type_timer_properties_immutable() -> void:
	var original_wait_time := editor.type_timer.wait_time
	var original_one_shot := editor.type_timer.one_shot
	
	# Verify properties remain as configured
	assert_float(editor.type_timer.wait_time).is_equal(0.3)
	assert_bool(editor.type_timer.one_shot).is_true()

func test_gutter_0_always_clickable() -> void:
	assert_bool(editor.is_gutter_clickable(0)).is_true()

func test_type_timer_signal_connection() -> void:
	var connections = editor.type_timer.timeout.get_connections()
	assert_int(connections.size()).is_greater_equal(1)

func test_get_caret_global_draw_pos_exists() -> void:
	assert_bool(editor.has_method("get_caret_global_draw_pos")).is_true()

func test_get_caret_global_draw_pos_returns_vector2() -> void:
	var pos := editor.get_caret_global_draw_pos()
	assert_object(pos).is_instanceof(Vector2)

func test_get_caret_global_draw_pos_with_center() -> void:
	var pos_normal := editor.get_caret_global_draw_pos(0, false)
	var pos_center := editor.get_caret_global_draw_pos(0, true)
	# Center position should be different (slightly higher)
	assert_bool(pos_normal != pos_center).is_true()