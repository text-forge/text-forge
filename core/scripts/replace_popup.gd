class_name ReplacePopup
extends PopupPanel
## An advanced [PopupPanel] for intractive replace in templates.

## Keeps available options for auto-insert.
const AUTO_INSERT_OPTIONS = {
	FILE_NAME = "{{{!file_name}}}",
	FILE_PATH = "{{{!file_path}}}",
	DATE = "{{{!date}}}",
	TIME = "{{{!time}}}",
	DATE_TIME = "{{{!datetime}}}",
}

## Auto-insert button.
@export var insert: Button
## Replace value.
@export var replace: LineEdit
## Next button.
@export var next: Button
## Previous button.
@export var previous: Button
## Close popup button.
@export var close: Button

## [Regex] to find and replace patterns.
var regex: RegEx
## Matches for RegEx search.
var result: Array[RegExMatch] = []
## Index of current match.
var i: int = 0
## Positions of the searched text, to turn the offset of a match into a line and a column.
var _positions: TextPositions

## Continutes a search recursivly.
func start(pattern: String, reset := true) -> void:
	regex = RegEx.new()
	if regex.compile(pattern):
		hide()
		return
	var text := Global.get_editor_text()
	result = regex.search_all(text)
	_positions = TextPositions.new(text)
	if reset:
		i = -1
	if result.is_empty():
		_on_close_pressed()
		return
	_on_next_pressed()


## Selects the match at [param index] in the editor. The match is placed by its offset, a literal
## search for its text would land on an earlier match with the same text.
func _select_match(index: int) -> void:
	var found := result[index]
	var spot := _positions.position(found.get_start())
	var length := found.get_end() - found.get_start()
	var editor := Global.get_editor()
	editor.select(spot.x, spot.y, spot.x, spot.y + length)
	# The view follows the match, so the popup lands on it and the user sees what it replaces.
	editor.center_viewport_to_caret()


## Moves between the matches with the arrow keys, the replace field has no use for them.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	var key := event as InputEventKey
	if not key or not key.pressed:
		return
	if key.keycode == KEY_UP:
		_on_previous_pressed()
	elif key.keycode == KEY_DOWN:
		_on_next_pressed()
	else:
		return
	get_viewport().set_input_as_handled()


## Replace current match and keep here (because matches will shift to behind).
func _on_replace_text_submitted(new_text: String) -> void:
	Global.set_editor_text(regex.sub(Global.get_editor_text(), new_text, false, result[i].get_start()))
	i -= 1
	start(regex.get_pattern(), false)


## Select next match and show popup.
func _on_next_pressed() -> void:
	i = clampi(i + 1, 0, result.size() - 1)
	_select_match(i)
	await U.wait()
	_show_popup()


## Select previous match and show popup.
func _on_previous_pressed() -> void:
	i = clampi(i - 1, 0, result.size() - 1)
	_select_match(i)
	await U.wait()
	_show_popup()


## Show popup with optional auto-insert.
func _show_popup() -> void:
	if Global.get_editor().get_selected_text(0) in AUTO_INSERT_OPTIONS.values():
		insert.show()
	else:
		insert.hide()
	match Global.get_editor().get_selected_text(0):
		AUTO_INSERT_OPTIONS.FILE_PATH:
			if Global.has_file():
				insert.tooltip_text = "Auto Insert\nYou can insert file path in one click."
				insert.disabled = false
			else:
				insert.tooltip_text = "Auto Insert\nThis file isn't saved yet!"
				insert.disabled = true
		AUTO_INSERT_OPTIONS.FILE_NAME:
			if Global.has_file():
				insert.tooltip_text = "Auto Insert\nYou can insert file name in one click."
				insert.disabled = false
			else:
				insert.tooltip_text = "Auto Insert\nThis file isn't saved yet!"
				insert.disabled = true
		AUTO_INSERT_OPTIONS.DATE:
			insert.tooltip_text = "Auto Insert\nYou can insert current date as YYYY-MM-DD in one click."
			insert.disabled = false
		AUTO_INSERT_OPTIONS.TIME:
			insert.tooltip_text = "Auto Insert\nYou can insert current time as HH:MM:SS in one click."
			insert.disabled = false
		AUTO_INSERT_OPTIONS.DATE_TIME:
			insert.tooltip_text = "Auto Insert\nYou can insert current date and time as YYYY-MM-DD HH:MM:SS in one click."
			insert.disabled = false
		_:
			insert.tooltip_text = "Auto Insert\nThis feature isn't available for this placeholder!"
			insert.disabled = true
	popup(Rect2i(Global.get_editor().get_caret_global_draw_pos(), size))
	replace.grab_focus()
	replace.select_all()


## Hides popup and deselects match.
func _on_close_pressed() -> void:
	Global.get_editor().deselect()
	hide()


## Inserts automatic generated values.
func _on_insert_pressed() -> void:
	var text := ""
	match Global.get_editor().get_selected_text(0):
		AUTO_INSERT_OPTIONS.FILE_PATH:
			text = Global.get_file_path()
		AUTO_INSERT_OPTIONS.FILE_NAME:
			text = Global.get_file_name()
		AUTO_INSERT_OPTIONS.DATE:
			text = Time.get_date_string_from_system()
		AUTO_INSERT_OPTIONS.TIME:
			text = Time.get_time_string_from_system()
		AUTO_INSERT_OPTIONS.DATE_TIME:
			text = Time.get_datetime_string_from_system(false, true)
	_on_replace_text_submitted(text)
