extends ActionScript

func _initialize() -> void:
	requires_file = true


func _run_action() -> void:
	if Global.emit_save_request(id): return
	Global.get_editor().merge_overlapping_carets()
	var text: Array = []
	for line in Global.get_editor().get_line_count():
		if not Global.get_editor().is_selection_in_line(line):
			continue
		text.append(Global.get_editor().get_line(line))
	Signals.new_file.emit()
	Global.set_editor_text("\n".join(text))
	Global.get_editor().clear_undo_history()
	Global.get_editor().type_timer_timeout.emit()
	Global.mark_file_as_unsaved()
