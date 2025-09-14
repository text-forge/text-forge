# GdUnit generated TestSuite
class_name ActionScriptsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

func test_action_scripts() -> void:
	for i in DirAccess.get_files_at(FileDatabase.FOLDER_ACTION_SCRIPTS):
		if i.ends_with(".uid"):
			continue
		var script: Node = load(FileDatabase.FOLDER_ACTION_SCRIPTS.path_join(i)).new()
		if not script is MultiActionScript:
			assert_object(script).is_inheriting(ActionScript).append_failure_message("{0} is {1}".format([i, script.get_class()]))
		script.free()
