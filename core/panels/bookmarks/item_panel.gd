class_name BookmarkItemPanel
extends PanelContainer
## Base class for each bookmark item in [BookmarksPanel]. Instances of this class are reusable objects.

## Label to show line number. This number is from [code]1[/code].
@export var number_label: Label
## Label to show line text.
@export var line_label: Label
## Go to line button.
@export var goto_button: Button
## Remove bookmark button.
@export var remove_button: Button

## Internal line number value (from [code]0[/code]) to keep target line number. Sets [member number_label]
## [param text] parameter at changes.
var _line: int:
	set(value):
		_line = value
		number_label.text = str(value + 1)

## Updates line number and string for this item.
func update(line_text: String, line: int) -> void:
	line_label.text = line_text
	line_label.tooltip_text = line_text
	_line = line


## Moves main caret to target line and centers viewport to this caret, then calls [method Control.grab_focus]
## on [Editor].
func _on_go_to_pressed() -> void:
	Global.get_editor().set_caret_line(_line, true, false)
	Global.get_editor().grab_focus()


## Removes bookmark from target line, hides itself and appends [code]*[/code] to file name to show
## there are unsaved changes.
func _on_remove_pressed() -> void:
	Global.get_editor().set_line_as_bookmarked(_line, false)
	if not Global.has_unsaved_change():
		Global.set_file_name(Global.get_file_name() + "*")
	hide()
