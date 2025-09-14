extends Button

@export var line: LineEdit
@export var column: LineEdit

func _ready() -> void:
	Global.get_editor().caret_changed.connect(_update_caret_pos)


func _update_caret_pos() -> void:
	text = "{0} : {1}".format([Global.get_editor().get_caret_line(), Global.get_editor().get_caret_column()])


func _on_popup_panel_about_to_popup() -> void:
	line.text = str(Global.get_editor().get_caret_line())
	column.text = str(Global.get_editor().get_caret_column())


func _on_go_pressed() -> void:
	Global.get_editor().set_caret_line(int(line.text))
	Global.get_editor().set_caret_column(int(column.text))
	get_child(0).hide()
	Global.get_editor().grab_focus()


func _on_pressed() -> void:
	get_child(0).popup()
	line.grab_focus()
