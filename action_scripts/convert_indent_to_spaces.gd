extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	Global.get_editor().begin_complex_operation()

	Global.get_editor().indent_use_spaces = true

	var indent_size = Global.get_editor().indent_size
	var tab_replacement = " ".repeat(indent_size)

	var line_count = Global.get_editor().get_line_count()
	for i in line_count:
		var line = Global.get_editor().get_line(i)
		if line.begins_with("\t"):
			line = line.replace("\t", tab_replacement)
			Global.get_editor().set_line(i, line)

	Global.get_editor().end_complex_operation()
