extends ActionScript

func _initialize() -> void:
	requires_file = true


func _run_action() -> void:
	for l in Global.get_editor().get_line_count():
		if not Global.get_editor().is_selection_in_line(l):
			continue
		Global.get_editor().set_line_as_bookmarked(l, not Global.get_editor().is_line_bookmarked(l))
	Global.get_editor().type_timer_timeout.emit()
	Global.mark_file_as_unsaved()
