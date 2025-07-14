extends ActionScript

var popup

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	add_child(Factory.signle_line_input("Line", "Go", _go_to_line, true))

func _go_to_line(line: String) -> void:
	var line_int: int
	if line.is_valid_int():
		line_int = min(max(int(line) - 1, 0), Global.get_editor().get_line_count() - 1)
	else:
		line_int = 0
	Global.get_editor().select(line_int, Global.get_editor().get_line(line_int).length(), line_int, Global.get_editor().get_line(line_int).length())
	Global.get_editor().center_viewport_to_caret()
	Global.get_editor().grab_focus()
