# GdUnit generated TestSuite
class_name GdUnitRunnerConfigTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite for validating GdUnitRunner.cfg structure and integrity
const CONFIG_PATH := "res://addons/gdUnit4/GdUnitRunner.cfg"

var config_data: Dictionary

func before_test() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	if error == OK:
		config_data = json.data
	else:
		push_error("Failed to parse config: " + json.get_error_message())

## Test file existence and readability

func test_config_file_exists() -> void:
	assert_bool(FileAccess.file_exists(CONFIG_PATH)).is_true()

func test_config_file_is_readable() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	assert_object(file).is_not_null()
	file.close()

func test_config_file_is_valid_json() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var error := json.parse(json_string)
	assert_int(error).is_equal(OK)

## Test root structure

func test_config_has_server_port() -> void:
	assert_bool(config_data.has("server_port")).is_true()

func test_server_port_is_integer() -> void:
	assert_bool(config_data.server_port is int or config_data.server_port is float).is_true()

func test_server_port_is_valid() -> void:
	var port = int(config_data.server_port)
	assert_int(port).is_greater(0)
	assert_int(port).is_less_equal(65535)

func test_config_has_tests_array() -> void:
	assert_bool(config_data.has("tests")).is_true()

func test_tests_is_array() -> void:
	assert_bool(config_data.tests is Array).is_true()

func test_tests_array_not_empty() -> void:
	assert_int(config_data.tests.size()).is_greater(0)

## Test individual test case structure

func test_all_tests_have_required_fields() -> void:
	var required_fields := [
		"@path",
		"@subpath",
		"assembly_location",
		"attribute_index",
		"display_name",
		"fully_qualified_name",
		"guid",
		"line_number",
		"metadata",
		"require_godot_runtime",
		"source_file",
		"suite_name",
		"suite_resource_path",
		"test_name"
	]
	
	for test_case in config_data.tests:
		for field in required_fields:
			assert_bool(test_case.has(field)).is_true().override_failure_message(
				"Test case missing field: " + field
			)

func test_all_test_paths_are_valid() -> void:
	for test_case in config_data.tests:
		assert_str(test_case["@path"]).is_not_empty()

func test_all_source_files_start_with_res() -> void:
	for test_case in config_data.tests:
		var source_file: String = test_case["source_file"]
		assert_bool(source_file.begins_with("res://")).is_true()

func test_all_suite_resource_paths_start_with_res() -> void:
	for test_case in config_data.tests:
		var suite_path: String = test_case["suite_resource_path"]
		assert_bool(suite_path.begins_with("res://")).is_true()

func test_all_line_numbers_are_positive() -> void:
	for test_case in config_data.tests:
		var line_number: int = int(test_case["line_number"])
		assert_int(line_number).is_greater(0)

func test_all_guids_are_valid_format() -> void:
	for test_case in config_data.tests:
		var guid: String = test_case["guid"]
		# GUID should contain hyphens and hex characters
		assert_bool(guid.length()).is_greater(0)
		assert_bool(guid.contains("-")).is_true()

func test_all_require_godot_runtime_are_boolean() -> void:
	for test_case in config_data.tests:
		var require_runtime = test_case["require_godot_runtime"]
		assert_bool(require_runtime is bool).is_true()

## Test specific test paths

func test_config_includes_action_scripts_tests() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("tests/action_scripts/"):
			found = true
			break
	assert_bool(found).is_true()

func test_config_includes_core_tests() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("tests/core/"):
			found = true
			break
	assert_bool(found).is_true()

func test_config_includes_editor_tests() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("editor_test.gd"):
			found = true
			break
	assert_bool(found).is_true()

func test_config_includes_editor_api_tests() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("editor_api_test.gd"):
			found = true
			break
	assert_bool(found).is_true()

func test_config_includes_data_tests() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("tests/data/"):
			found = true
			break
	assert_bool(found).is_true()

func test_config_includes_autoload_tests() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("tests/core/autoload/"):
			found = true
			break
	assert_bool(found).is_true()

## Test path correctness after reorganization

func test_no_old_scripts_directory_references() -> void:
	# After reorganization, tests should not reference tests/core/scripts/
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		var fqn: String = test_case["fully_qualified_name"]
		
		# Should not contain old "scripts" subdirectory
		assert_bool(not source.contains("tests/core/scripts/")).is_true().override_failure_message(
			"Found old path reference: " + source
		)
		assert_bool(not fqn.contains(".scripts.")).is_true().override_failure_message(
			"Found old FQN reference: " + fqn
		)

func test_editor_tests_use_correct_path() -> void:
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("editor_test.gd") or source.contains("editor_api_test.gd"):
			# Should be directly in tests/core/, not tests/core/scripts/
			assert_bool(source.begins_with("res://tests/core/editor")).is_true()
			assert_bool(not source.contains("/scripts/")).is_true()

func test_action_scripts_test_in_correct_location() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("action_scripts_test.gd"):
			# Should be in tests/action_scripts/, not tests/
			assert_bool(source == "res://tests/action_scripts/action_scripts_test.gd").is_true()
			found = true
	assert_bool(found).is_true()

func test_translation_data_test_in_correct_location() -> void:
	var found := false
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		if source.contains("translation_data_test.gd"):
			# Should be in tests/data/, not tests/
			assert_bool(source == "res://tests/data/translation_data_test.gd").is_true()
			found = true
	assert_bool(found).is_true()

## Test fully qualified names

func test_fully_qualified_names_match_paths() -> void:
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		var fqn: String = test_case["fully_qualified_name"]
		
		# FQN should reflect the directory structure
		if source.contains("tests/action_scripts/"):
			assert_bool(fqn.begins_with("tests.action_scripts.")).is_true()
		elif source.contains("tests/core/autoload/"):
			assert_bool(fqn.begins_with("tests.core.autoload.")).is_true()
		elif source.contains("tests/core/") and not source.contains("/autoload/"):
			assert_bool(fqn.begins_with("tests.core.")).is_true()
		elif source.contains("tests/data/panels/"):
			assert_bool(fqn.begins_with("tests.data.panels.")).is_true()
		elif source.contains("tests/data/"):
			assert_bool(fqn.begins_with("tests.data.")).is_true()

## Test metadata structure

func test_all_metadata_are_dictionaries() -> void:
	for test_case in config_data.tests:
		var metadata = test_case["metadata"]
		assert_bool(metadata is Dictionary).is_true()

func test_attribute_index_is_numeric() -> void:
	for test_case in config_data.tests:
		var attr_index = test_case["attribute_index"]
		assert_bool(attr_index is int or attr_index is float).is_true()

## Test display names and test names

func test_display_names_match_test_names() -> void:
	for test_case in config_data.tests:
		var display_name: String = test_case["display_name"]
		var test_name: String = test_case["test_name"]
		# Display name should match test name
		assert_str(display_name).is_equal(test_name)

func test_test_names_follow_convention() -> void:
	for test_case in config_data.tests:
		var test_name: String = test_case["test_name"]
		# Test names should start with "test_"
		assert_bool(test_name.begins_with("test_")).is_true()

## Test suite names

func test_suite_names_end_with_test() -> void:
	for test_case in config_data.tests:
		var suite_name: String = test_case["suite_name"]
		# Suite names should end with "_test"
		assert_bool(suite_name.ends_with("_test")).is_true()

func test_source_files_match_suite_names() -> void:
	for test_case in config_data.tests:
		var source: String = test_case["source_file"]
		var suite_name: String = test_case["suite_name"]
		# Source file should contain the suite name
		assert_bool(source.contains(suite_name + ".gd")).is_true()

## Test uniqueness

func test_all_guids_are_unique() -> void:
	var guids := {}
	for test_case in config_data.tests:
		var guid: String = test_case["guid"]
		assert_bool(not guids.has(guid)).is_true().override_failure_message(
			"Duplicate GUID found: " + guid
		)
		guids[guid] = true

func test_all_fully_qualified_names_are_unique() -> void:
	var fqns := {}
	for test_case in config_data.tests:
		var fqn: String = test_case["fully_qualified_name"]
		assert_bool(not fqns.has(fqn)).is_true().override_failure_message(
			"Duplicate FQN found: " + fqn
		)
		fqns[fqn] = true

## Test assembly location

func test_all_assembly_locations_are_empty_strings() -> void:
	for test_case in config_data.tests:
		var assembly_loc: String = test_case["assembly_location"]
		# For GDScript tests, assembly_location should be empty
		assert_str(assembly_loc).is_equal("")

## Test subpath

func test_all_subpaths_are_empty_strings() -> void:
	for test_case in config_data.tests:
		var subpath: String = test_case["@subpath"]
		# Subpath should be empty for standard tests
		assert_str(subpath).is_equal("")

## Test completeness

func test_config_has_expected_test_count() -> void:
	# Based on TEST_SUMMARY.md, there should be approximately 79+ tests
	assert_int(config_data.tests.size()).is_greater_equal(70)

func test_config_has_all_major_test_suites() -> void:
	var required_suites := [
		"action_scripts_test",
		"close_test",
		"editor_test",
		"editor_api_test",
		"translation_data_test",
		"factory_test",
		"translation_manager_test"
	]
	
	for required_suite in required_suites:
		var found := false
		for test_case in config_data.tests:
			if test_case["suite_name"] == required_suite:
				found = true
				break
		assert_bool(found).is_true().override_failure_message(
			"Missing test suite: " + required_suite
		)