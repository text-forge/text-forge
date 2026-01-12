extends ActionScript

func _initialize() -> void:
	Notif.register_notification(
		"comment_delimiter_required",
		Notif.Type.ERR,
		"There is no comment delimiter!",
		"Please select a mode with comment delimiter."
	)
	requires_file = true

func _run_action() -> void:
	if Global.get_editor().delimiter_comments.size() == 0:
		Notif.notif("comment_delimiter_required")
		return
	Global.get_editor().begin_complex_operation()
	Global.get_editor().begin_multicaret_edit()
	var text := Global.get_editor_text().split("\n")
	var handled_lines := {}
	var handled_ranges := {}
	for caret in Global.get_editor().get_caret_count():
		var line := Global.get_editor().get_caret_line(caret)
		var column := Global.get_editor().get_caret_column(caret)
		var delimiter_start := Global.get_editor().get_delimiter_start_position(line, column)
		var delimiter_end := Global.get_editor().get_delimiter_end_position(line, column)
		if delimiter_start == Vector2(-1, -1) or delimiter_end == Vector2(-1, -1):
			if handled_lines.has(line):
				continue
			handled_lines[line] = true
			var insert_pos := text[line].length() - text[line].strip_edges(true, false).length()
			text[line] = text[line].insert(insert_pos, Global.get_editor().get_delimiter_start_key(0))
			if Global.get_editor().get_delimiter_end_key(0):
				text[line] += Global.get_editor().get_delimiter_end_key(0)
		else:
			var key := "%d:%d-%d:%d" % [delimiter_start.x, delimiter_start.y, delimiter_end.x, delimiter_end.y]
			if handled_ranges.has(key):
				continue
			handled_ranges[key] = true
			var delimiter_index := Global.get_editor().is_in_comment(line, column)
			var start_key := Global.get_editor().get_delimiter_start_key(delimiter_index)
			var end_key := Global.get_editor().get_delimiter_end_key(delimiter_index)
			text[delimiter_start.y] = text[delimiter_start.y].erase(delimiter_start.x, start_key.length())
			var end_erase_pos := delimiter_end.x - end_key.length()
			if delimiter_start.y == delimiter_end.y:
				end_erase_pos -= start_key.length()
			text[delimiter_end.y] = text[delimiter_end.y].erase(end_erase_pos, end_key.length())
	Global.set_editor_text("\n".join(text))
	Global.get_editor().end_multicaret_edit()
	Global.get_editor().end_complex_operation()
	Global.get_editor().text_changed.emit()
