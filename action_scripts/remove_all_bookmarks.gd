extends ActionScript

func _initialize() -> void:
	requires_file = true


func _run_action() -> void:
	if Global.get_editor().get_bookmarked_lines().is_empty():
		return
	Global.get_editor().clear_bookmarked_lines()
	Global.get_editor().type_timer_timeout.emit()
	Global.mark_file_as_unsaved()
