# GdUnit generated TestSuite
class_name ProjectAPITestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/project.gd'

func before_test() -> void:
	# Project state is a global; these tests only assert on unloaded/project-section states.
	Project.current_project.clear()


func test_has_project_is_false_without_project_section() -> void:
	assert_bool(Project.has_project()).is_false()


func test_has_project_is_true_with_project_section() -> void:
	Project.current_project.set_value("project", "name", "Test project")
	assert_bool(Project.has_project()).is_true()


func test_get_project_name_returns_unnamed_default() -> void:
	assert_str(Project.get_project_name()).is_equal("Unnamed Project")


func test_get_project_name_returns_project_name() -> void:
	Project.current_project.set_value("project", "name", "My project")
	assert_str(Project.get_project_name()).is_equal("My project")


func test_project_api_version_is_stable() -> void:
	assert_str(Project.VERSION).is_equal("1.0")
