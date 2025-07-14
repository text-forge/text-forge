extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	var selections := []
	var breakes := []
	var text := Global.get_editor_text()

	Global.get_editor().begin_complex_operation()
	Global.get_editor().begin_multicaret_edit()

	for caret in Global.get_editor().get_caret_count():
		var sel_text = Global.get_editor().get_selected_text(caret)
		if sel_text == "":
			continue

		var lines: Array = sel_text.split("\n")
		breakes.append(lines.size() - 1 + breakes[-1] if breakes else 0)
		lines = lines.map(func(item):
			return item.strip_edges())
		var joined := " ".join(lines)

		var origin_char = Global.get_editor().get_char_index(Global.get_editor().get_selection_origin_line(caret), Global.get_editor().get_selection_origin_column(caret))
		var caret_char = Global.get_editor().get_char_index(Global.get_editor().get_caret_line(caret), Global.get_editor().get_caret_column(caret))
		var start: Vector2i
		if origin_char > caret_char:
			start = Vector2i(Global.get_editor().get_caret_line(caret), Global.get_editor().get_caret_column(caret))
		else:
			start = Vector2i(Global.get_editor().get_selection_origin_line(caret), Global.get_editor().get_selection_origin_column(caret))

		text = text.substr(0, Global.get_editor().get_char_index(start.x, start.y) - breakes[-1]) + joined + text.substr(Global.get_editor().get_char_index(start.x, start.y) - breakes[-1] + sel_text.length())

	for select in Global.get_editor().get_caret_count():
		selections.append(Global.get_editor().get_caret_line(select))
		if Global.get_editor().get_selection_origin_line(select) < selections[-1]:
			selections[-1] = Global.get_editor().get_selection_origin_line(select)
		selections[-1] -= breakes[select]

	Global.set_editor_text(text, false)
	Global.get_editor().end_multicaret_edit()
	for i in selections.size():
		if i == Global.get_editor().get_caret_count():
			Global.get_editor().add_caret(0, 0)
		Global.get_editor().select(selections[i], 0, selections[i], Global.get_editor().get_line(selections[i]).length(), i)
	Global.get_editor().end_complex_operation()
	Global.get_editor().text_changed.emit()
