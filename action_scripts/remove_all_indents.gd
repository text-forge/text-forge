extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	var lines := Array(Global.get_editor_text().split("\n"))
	lines = lines.map(func(line: String): return line.strip_edges())
	Global.set_editor_text("\n".join(lines))
