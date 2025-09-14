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
	type_timer.timeout.connect(func(): type_timer_timeout.emit())
	add_child(type_timer, false, Node.INTERNAL_MODE_FRONT)

	type_timer_timeout.connect(func(): code_completion_requested.emit())

## Returns char index in [param line] and [param column], useful for use original [LineEdit]
## functions with [String] options.
func get_char_index(line: int, column: int) -> int:
	var before = ""
	var counter = 0
	for i in text.split("\n", true, line):
		if counter < line:
			before += i + "\n"
		counter += 1
	return before.length() + column


## Returns [code]true[/code] if this line in in a selection.
func is_selection_in_line(line: int) -> bool:
	for caret in get_caret_count():
		var selection = [get_selection_origin_line(caret), get_caret_line(caret)]
		if selection[0] > selection[1]:
			selection.reverse()
		if line >= selection[0] and line <= selection[1]:
			return true
	return false


func _on_text_changed() -> void:
	type_timer.start()
