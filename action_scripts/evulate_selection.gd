extends ActionScript

func _initialize() -> void:
	requires_file = true

func _run_action() -> void:
	if Global.get_editor().get_caret_count():
		Global.send_notification(Global.Notification.WARNING, "Exulate selection only supports main caret!")

	var expression = Expression.new()
	expression.parse(Global.get_editor().get_selected_text(0))
	var result = expression.execute([], self)
	var selection = Vector2i(Global.get_editor().get_selection_origin_line(), Global.get_editor().get_selection_origin_column())
	var caret = Vector2i(Global.get_editor().get_caret_line(), Global.get_editor().get_caret_column())
	Global.set_editor_text(Global.get_editor_text().substr(0, Global.get_editor().get_char_index(selection.x, selection.y)) + str(result) + Global.get_editor_text().substr(Global.get_editor().get_char_index(caret.x, caret.y)))
	Global.get_editor().select(selection.x, selection.y, selection.x, selection.y + str(result).length())
