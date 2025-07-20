# GdUnit generated TestSuite
class_name TranslationDataTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

func test_translation_file() -> void:
	var file := FileAccess.open("res://data/translation.csv", FileAccess.READ)
	var column_names := file.get_csv_line()
	var index = 0

	while file.get_position() < file.get_length():
		var line = file.get_csv_line()
		assert_array(line).has_size(column_names.size()).override_failure_message("Invalid value count for key {0} in line {1}, excepted {2} but is {3}".format([line[0], index, column_names.size(), line.size()]))
		index += 1
