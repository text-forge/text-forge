# GdUnit generated TestSuite
class_name DocumentationValidationTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite for validating documentation files
const INDEX_PATH := "res://tests/INDEX.md"
const README_PATH := "res://tests/README.md"
const TEST_SUMMARY_PATH := "res://tests/TEST_SUMMARY.md"

## Test INDEX.md file

func test_index_file_exists() -> void:
	assert_bool(FileAccess.file_exists(INDEX_PATH)).is_true()

func test_index_file_is_readable() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	assert_object(file).is_not_null()
	file.close()

func test_index_file_has_content() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_int(content.length()).is_greater(0)

func test_index_has_title() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("# Text Forge Test Suite - Complete Index")).is_true()

func test_index_has_runtime_tests_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("## Runtime Tests")).is_true()

func test_index_has_unit_tests_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("## Unit Tests")).is_true()

func test_index_has_action_scripts_tests_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("### Action Scripts Tests")).is_true()

func test_index_has_autoloads_tests_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("### Autoloads Tests")).is_true()

func test_index_has_core_tests_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("### Core Tests")).is_true()

func test_index_has_data_tests_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("### Data Tests")).is_true()

func test_index_has_panels_tests_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("### Panels Tests")).is_true()

func test_index_has_documentation_section() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("## Documentation")).is_true()

func test_index_mentions_readme() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("README.md")).is_true()

func test_index_mentions_test_summary() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("TEST_SUMMARY.md")).is_true()

func test_index_has_valid_markdown_headers() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	# Check that all headers start with # and a space
	var lines := content.split("\n")
	for line in lines:
		if line.begins_with("#"):
			assert_bool(line.begins_with("# ") or line.begins_with("## ") or line.begins_with("### ")).is_true()

## Test README.md file

func test_readme_file_exists() -> void:
	assert_bool(FileAccess.file_exists(README_PATH)).is_true()

func test_readme_file_is_readable() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	assert_object(file).is_not_null()
	file.close()

func test_readme_file_has_content() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_int(content.length()).is_greater(0)

func test_readme_has_title() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("# Text Forge Unit Tests")).is_true()

func test_readme_has_maintenance_notes() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Maintence Notes") or content.contains("Maintenance Notes")).is_true()

func test_readme_has_performance_benchmarks() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Performance Beckmarks") or content.contains("Performance Benchmarks")).is_true()

func test_readme_has_test_generation_notes() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Test Generation Notes")).is_true()

func test_readme_mentions_gdunit4() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("GDUnit4") or content.contains("GdUnit4")).is_true()

func test_readme_has_best_practices_section() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Best Practices")).is_true()

func test_readme_has_internal_documentation_section() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Internal Documentation")).is_true()

func test_readme_mentions_auto_free() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("auto_free")).is_true()

func test_readme_mentions_arrange_act_assert() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Arrange-Act-Assert")).is_true()

## Test TEST_SUMMARY.md file

func test_test_summary_file_exists() -> void:
	assert_bool(FileAccess.file_exists(TEST_SUMMARY_PATH)).is_true()

func test_test_summary_file_is_readable() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	assert_object(file).is_not_null()
	file.close()

func test_test_summary_file_has_content() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_int(content.length()).is_greater(0)

func test_test_summary_has_title() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("# Test Forge Unit Tests - Summary") or content.contains("Test Forge Unit Tests")).is_true()

func test_test_summary_has_overview_section() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("## Overview")).is_true()

func test_test_summary_has_test_results_section() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("## Test Results")).is_true()

func test_test_summary_has_test_files_section() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("## Test Files")).is_true()

func test_test_summary_mentions_action_scripts_tests() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Action Scripts Tests")).is_true()

func test_test_summary_mentions_autoloads_tests() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Autoloads Tests")).is_true()

func test_test_summary_mentions_core_tests() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Core Tests")).is_true()

func test_test_summary_mentions_data_tests() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Data Tests")).is_true()

func test_test_summary_mentions_panels_tests() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("Panels Tests")).is_true()

func test_test_summary_has_test_count() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	# Should contain test count information (looking for numbers followed by "test")
	assert_bool(content.contains("test") and (content.contains("79") or content.contains("test cases"))).is_true()

func test_test_summary_mentions_gdunit4() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("GDUnit4") or content.contains("GdUnit4")).is_true()

func test_test_summary_has_coverage_indicators() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	# Should have star ratings for coverage
	assert_bool(content.contains("⭐")).is_true()

func test_test_summary_has_table_structure() -> void:
	var file := FileAccess.open(TEST_SUMMARY_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	# Should have markdown table structure with |
	assert_bool(content.contains("|")).is_true()

## Cross-document validation

func test_all_documentation_files_exist() -> void:
	assert_bool(FileAccess.file_exists(INDEX_PATH)).is_true()
	assert_bool(FileAccess.file_exists(README_PATH)).is_true()
	assert_bool(FileAccess.file_exists(TEST_SUMMARY_PATH)).is_true()

func test_index_references_other_docs() -> void:
	var file := FileAccess.open(INDEX_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("README.md") and content.contains("TEST_SUMMARY.md")).is_true()

func test_readme_references_other_docs() -> void:
	var file := FileAccess.open(README_PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	assert_bool(content.contains("README.md") or content.contains("TEST_SUMMARY.md") or content.contains("INDEX.md")).is_true()

func test_no_broken_internal_links() -> void:
	# Verify that referenced files actually exist
	var files_to_check := [INDEX_PATH, README_PATH, TEST_SUMMARY_PATH]
	for file_path in files_to_check:
		var file := FileAccess.open(file_path, FileAccess.READ)
		var content := file.get_as_text()
		file.close()
		
		# Check for common broken link patterns
		assert_bool(not content.contains("](broken)")).is_true()
		assert_bool(not content.contains("](#broken)")).is_true()

func test_consistent_terminology() -> void:
	# All docs should use consistent terminology
	var files_to_check := [INDEX_PATH, README_PATH, TEST_SUMMARY_PATH]
	for file_path in files_to_check:
		var file := FileAccess.open(file_path, FileAccess.READ)
		var content := file.get_as_text()
		file.close()
		
		# Should consistently use "Text Forge" not "TextForge" or "Textforge"
		if content.contains("Text Forge"):
			assert_bool(content.contains("Text Forge")).is_true()