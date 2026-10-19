class_name CaretPos
extends Button
## Shows caret position and provides fast caret move.

## [LineEdit] to change line.
@export var line: LineEdit
## [LineEdit] to change column.
@export var column: LineEdit

func _ready() -> void:
	Documents.watch(&"caret_changed", _update_caret_pos)


func _update_caret_pos() -> void:
	text = "{0} : {1}".format([Global.get_editor().get_caret_line() + 1, Global.get_editor().get_caret_column()])


func _on_popup_panel_about_to_popup() -> void:
	line.text = str(Global.get_editor().get_caret_line() + 1)
	column.text = str(Global.get_editor().get_caret_column())


func _on_go_pressed() -> void:
	if not line.text.is_valid_int() or not column.text.is_valid_int():
		return
	Global.get_editor().set_caret_line(clampi(int(line.text) - 1, 0, Global.get_editor().get_line_count() - 1))
	Global.get_editor().set_caret_column(int(column.text))
	get_child(0).hide()
	Global.get_editor().grab_focus()


func _on_pressed() -> void:
	get_child(0).popup()
	line.grab_focus()
