extends ActionScript

var popup

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	add_child(Factory.signle_line_input("Line", "Go", _go_to_line, true))

func _go_to_line(line: String) -> void:
	var line_int := int(line)
	Global.get_editor().set_caret_line(line_int)
	Global.get_editor().set_caret_column(Global.get_editor().get_line(line_int).length())
	Global.get_editor().grab_focus()
