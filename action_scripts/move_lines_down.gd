extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	Global.get_editor().move_lines_down()
