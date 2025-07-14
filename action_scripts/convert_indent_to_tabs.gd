extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	Global.get_editor().begin_complex_operation()

	var indent_size = Global.get_editor().indent_size
	var space_pattern = " ".repeat(indent_size)

	var line_count = Global.get_editor().get_line_count()
	for i in line_count:
		var line = Global.get_editor().get_line(i)
		var new_line = line
		var count = 0
		while new_line.begins_with(space_pattern):
			count += 1
			new_line = new_line.substr(indent_size, new_line.length() - indent_size)
		Global.get_editor().set_line(i, "\t".repeat(count) + new_line)

	Global.get_editor().indent_use_spaces = false

	Global.get_editor().end_complex_operation()
