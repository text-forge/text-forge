# GdUnit generated TestSuite
class_name TextPositionsTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/classes/text_positions.gd'


func test_position_of_the_first_character() -> void:
	var position := TextPositions.new("abc").position(0)
	assert_int(position.x).is_equal(0)
	assert_int(position.y).is_equal(0)


func test_position_inside_the_first_line() -> void:
	var position := TextPositions.new("abc\ndef").position(2)
	assert_int(position.x).is_equal(0)
	assert_int(position.y).is_equal(2)


func test_position_of_the_newline_itself() -> void:
	var position := TextPositions.new("abc\ndef").position(3)
	assert_int(position.x).is_equal(0)
	assert_int(position.y).is_equal(3)


func test_position_of_the_character_after_the_newline() -> void:
	var position := TextPositions.new("abc\ndef").position(4)
	assert_int(position.x).is_equal(1)
	assert_int(position.y).is_equal(0)


func test_position_at_the_end_of_the_text() -> void:
	var position := TextPositions.new("abc\ndef").position(7)
	assert_int(position.x).is_equal(1)
	assert_int(position.y).is_equal(3)


func test_position_past_the_end_returns_the_end_of_the_text() -> void:
	var position := TextPositions.new("abc\ndef").position(100)
	assert_int(position.x).is_equal(1)
	assert_int(position.y).is_equal(3)


func test_position_before_the_start_returns_the_start_of_the_text() -> void:
	var position := TextPositions.new("abc").position(-5)
	assert_int(position.x).is_equal(0)
	assert_int(position.y).is_equal(0)


func test_position_of_an_empty_text() -> void:
	var position := TextPositions.new("").position(0)
	assert_int(position.x).is_equal(0)
	assert_int(position.y).is_equal(0)


func test_position_of_a_text_with_an_empty_line() -> void:
	var position := TextPositions.new("a\n\nb").position(2)
	assert_int(position.x).is_equal(1)
	assert_int(position.y).is_equal(0)
