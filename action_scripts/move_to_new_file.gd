extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	if Global.get_file_name().ends_with("*"):
		Signals.save_request.emit(id)
		return

	for caret in Global.get_editor().get_caret_count():
		if Global.get_editor().get_char_index(Global.get_editor().get_selection_origin_line(caret), Global.get_editor().get_selection_origin_column(caret)) > Global.get_editor().get_char_index(Global.get_editor().get_caret_line(caret), Global.get_editor().get_caret_column(caret)):
			Global.get_editor().select(Global.get_editor().get_selection_origin_line(caret), Global.get_editor().get_line(Global.get_editor().get_selection_origin_line(caret)).length(), Global.get_editor().get_caret_line(caret), 0, caret)
		else:
			Global.get_editor().select(Global.get_editor().get_selection_origin_line(caret), 0, Global.get_editor().get_caret_line(caret), Global.get_editor().get_line(Global.get_editor().get_caret_line(caret)).length(), caret)
	Global.get_editor().merge_overlapping_carets()
	var text: Array = []
	for select in Global.get_editor().get_caret_count():
		text.append(Global.get_editor().get_selected_text(select))
	Signals.new_file.emit()
	Global.set_editor_text("\n".join(text))
	Global.get_editor().clear_undo_history()
	Global.get_editor().text_changed.emit()
