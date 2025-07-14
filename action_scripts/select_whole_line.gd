extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	for caret in Global.get_editor().get_caret_count():
		if Global.get_editor().get_char_index(Global.get_editor().get_selection_origin_line(caret), Global.get_editor().get_selection_origin_column(caret)) > Global.get_editor().get_char_index(Global.get_editor().get_caret_line(caret), Global.get_editor().get_caret_column(caret)):
			Global.get_editor().select(Global.get_editor().get_selection_origin_line(caret), Global.get_editor().get_line(Global.get_editor().get_selection_origin_line(caret)).length(), Global.get_editor().get_caret_line(caret), 0, caret)
		else:
			Global.get_editor().select(Global.get_editor().get_selection_origin_line(caret), 0, Global.get_editor().get_caret_line(caret), Global.get_editor().get_line(Global.get_editor().get_caret_line(caret)).length(), caret)
	Global.get_editor().merge_overlapping_carets()
