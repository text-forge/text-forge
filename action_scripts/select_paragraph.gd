extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	for caret in Global.get_editor().get_caret_count():
		var line = Global.get_editor().get_caret_line(caret)
		if not Global.get_editor().get_line(line).strip_edges():
			continue
		var paragraph := Vector2i(line, line)
		while paragraph.x > 0 and not Global.get_editor().get_line(paragraph.x - 1).strip_edges() == "":
			paragraph.x -= 1
		while paragraph.y < Global.get_editor().get_line_count() - 1 and not Global.get_editor().get_line(paragraph.y + 1).strip_edges() == "":
			paragraph.y += 1
		Global.get_editor().select(paragraph.x, 0, paragraph.y, Global.get_editor().get_line(paragraph.y).length(), caret)
	Global.get_editor().merge_overlapping_carets()
