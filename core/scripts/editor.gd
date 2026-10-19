class_name Editor
extends CodeEdit
## Main editor node.

## Emits when [member type_timer] timeout.
signal type_timer_timeout

## Internal type timer to avoid proccess file when user type text.
var type_timer := Timer.new()

func _ready() -> void:
	type_timer.wait_time = 0.3
	type_timer.one_shot = true
	type_timer.timeout.connect(type_timer_timeout.emit)
	add_child(type_timer, false, Node.INTERNAL_MODE_FRONT)
	type_timer_timeout.connect(code_completion_requested.emit)
	set_gutter_clickable(0, true)
	gutter_clicked.connect(_on_gutter_clicked)
	text_changed.connect(_on_text_changed)


## Returns char index in [param line] and [param column], useful for [String]-based functions.
func get_char_index(line: int, column: int) -> int:
	var before = ""
	var counter = 0
	for i in text.split("\n", true, line):
		if counter < line:
			before += i + "\n"
		counter += 1
	return before.length() + column


## Returns [code]true[/code] if this line is including a selection. Any line between each selection
## origin and caret pair is with selection.
func is_selection_in_line(line: int) -> bool:
	for caret in get_caret_count():
		var selection = [get_selection_origin_line(caret), get_caret_line(caret)]
		if selection[0] > selection[1]:
			selection.reverse()
		if line >= selection[0] and line <= selection[1]:
			return true
	return false


## Returns the caret pixel draw position in user screen. This is global version of [method TextEdit.get_caret_draw_pos].
## When [param center] is [code]true[/code] returned position will be in center of caret, otherwise
## will be under caret.
func get_caret_global_draw_pos(caret_index: int = 0, center := false) -> Vector2:
	return (
		get_caret_draw_pos(caret_index)
		+ global_position
		+ Vector2(get_window().position)
		+ Vector2(0, 0.0 if center else get_theme_font_size("font_size") / 2.0)
	)


## Restarts type timer at each text change.
func _on_text_changed() -> void:
	type_timer.start()


func _on_gutter_clicked(line: int, gutter: int) -> void:
	if not editable:
		return
	if gutter != 0: # Just pass bookmarks
		return
	set_line_as_bookmarked(line, not is_line_bookmarked(line))
