extends TextForgePanel

@export var counter: Label
@export var match_case: CheckBox
@export var whole_words: CheckBox
@export var backwards: CheckBox
@export var regex: CheckBox
@export var search: LineEdit
@export var replace: LineEdit
@export var list: ItemList

## Start position of every match.
var matches: Array[Vector2i] = []
## Length of every match, a regular expression can match a different length every time.
var match_lengths: Array[int] = []
## The compiled pattern of the last regular expression search.
var _pattern: RegEx

func _init() -> void:
	place = PanelManager.Panels.RIGHT


func _ready() -> void:
	# The panel manager is shared, so a second panel of the same place takes the connection over.
	var show_panel := Global.get_panel_manager().show_panel.bind(place, index)
	if Signals.open_find_panel.is_connected(show_panel):
		Signals.open_find_panel.disconnect(show_panel)
	Signals.open_find_panel.connect(show_panel)
	if Signals.open_find_panel.is_connected(_on_open_find_panel):
		Signals.open_find_panel.disconnect(_on_open_find_panel)
	Signals.open_find_panel.connect(_on_open_find_panel)
	Signals.shift_find_result.connect(func(next):
		if next:
			_on_next_pressed()
		else:
			_on_prev_pressed()
	)
	Signals.replace_all.connect(_on_replace_all_pressed)
	Signals.interactive_replace.connect(_on_interactive_replace_pressed)


func _on_line_edit_text_changed(new_text: String) -> void:
	matches.clear()
	match_lengths.clear()
	Tests.search_started.emit()
	if regex.button_pressed:
		if not _search_regex(new_text):
			# The pattern does not compile, the old list would point at matches that are gone.
			list.clear()
			return
	else:
		_search_literal(new_text)
	counter.text = str(matches.size()) + " match" + ("es" if matches.size() > 1 else "")
	list.clear()
	if matches.size() == 0: return
	var idx := 0
	for item in matches:
		var line := Global.get_editor_text().split("\n")[item.y]
		list.add_item(
			"({0}:{1}) ".format([item.y + 1, item.x + 1])
			+ ("..." if item.x - 3 > 0 else "")
			+ (line.substr(max(0, item.x - 3), min(line.length(), item.x + match_lengths[idx] + 3)))
			+ ("..." if item.x + match_lengths[idx] > line.length() else "")
		)
		idx += 1
	list.select(0)
	_on_item_list_item_selected(0)


## Searches the text literally, the way [method TextEdit.search] does it.
func _search_literal(pattern: String) -> void:
	while true:
		var next = Global.get_editor().search(
			pattern,
			(TextEdit.SearchFlags.SEARCH_MATCH_CASE if match_case.button_pressed else 0) +
			(TextEdit.SearchFlags.SEARCH_WHOLE_WORDS if whole_words.button_pressed else 0) +
			(TextEdit.SearchFlags.SEARCH_BACKWARDS if backwards.button_pressed else 0),
			0 if matches.size() == 0 else matches[-1].y,
			0 if matches.size() == 0 else matches[-1].x + (-1 if backwards.button_pressed else 1)
		)
		if next == Vector2i(-1, -1) or matches.has(next): break
		matches.append(next)
		match_lengths.append(pattern.length())


## Searches the text with a regular expression. Returns [code]false[/code] when the pattern does not
## compile, the editor is not touched in that case.
func _search_regex(pattern: String) -> bool:
	_pattern = RegEx.new()
	if _pattern.compile(pattern) != OK:
		counter.text = "Invalid RegEx"
		return false
	if pattern.is_empty():
		return true
	var text := Global.get_editor_text()
	var positions := TextPositions.new(text)
	for found in _pattern.search_all(text):
		var spot := positions.position(found.get_start())
		# [method TextEdit.search] returns the column first, the match list keeps that order.
		matches.append(Vector2i(spot.y, spot.x))
		match_lengths.append(found.get_end() - found.get_start())
	return true


func _on_option_pressed() -> void:
	_on_line_edit_text_changed(search.text)


func _on_item_list_item_selected(idx: int) -> void:
	Global.get_editor().select(matches[idx].y, matches[idx].x, matches[idx].y, matches[idx].x + match_lengths[idx])
	Global.get_editor().center_viewport_to_caret(0)


func _on_prev_pressed() -> void:
	if list.item_count == 0: return
	_on_item_list_item_selected(list.get_selected_items()[0] - 1 if list.get_selected_items()[0] != 0 else list.item_count - 1)
	list.select(list.get_selected_items()[0] - 1 if list.get_selected_items()[0] != 0 else list.item_count - 1)


func _on_next_pressed() -> void:
	if list.item_count == 0: return
	_on_item_list_item_selected(list.get_selected_items()[0] + 1 if list.item_count - 1 != list.get_selected_items()[0] else 0)
	list.select(list.get_selected_items()[0] + 1 if list.item_count - 1 != list.get_selected_items()[0] else 0)


func _on_all_pressed() -> void:
	for idx in matches.size():
		if idx != 0: Global.get_editor().add_caret(0, 0)
		Global.get_editor().select(matches[idx].y, matches[idx].x, matches[idx].y, matches[idx].x + match_lengths[idx], idx)


func _on_replace_pressed() -> void:
	if list.item_count == 0: return
	var match_index := list.get_selected_items()[0] if list.is_anything_selected() else 0
	_on_item_list_item_selected(match_index)
	var origin := Vector2i(Global.get_editor().get_selection_origin_line(), Global.get_editor().get_selection_origin_column())
	if regex.button_pressed:
		# A regular expression replaces through the pattern, so the capture groups expand.
		var offset := Global.get_editor().get_char_index(origin.x, origin.y)
		Global.set_editor_text(_pattern.sub(Global.get_editor_text(), replace.text, false, offset))
	else:
		Global.set_editor_text(
			Global.get_editor_text().substr(0, Global.get_editor().get_char_index(origin.x, origin.y)) +
			replace.text +
			Global.get_editor_text().substr(Global.get_editor().get_char_index(origin.x, origin.y) + match_lengths[match_index])
		)
	Global.get_editor().select(origin.x, origin.y, origin.x, origin.y + replace.text.length())
	_on_line_edit_text_changed(search.text)


func _on_replace_all_pressed() -> void:
	Global.get_editor().begin_complex_operation()
	if regex.button_pressed:
		Global.set_editor_text(_pattern.sub(Global.get_editor_text(), replace.text, true))
		Global.get_editor().end_complex_operation()
		Global.get_editor().text_changed.emit()
		_on_line_edit_text_changed(search.text)
		return
	while list.item_count != 0:
		_on_replace_pressed()
	Global.get_editor().end_complex_operation()
	Global.get_editor().text_changed.emit()


## Compiles the pattern of the find field and hands it to the replace popup, which walks the
## matches one by one.
func _on_interactive_replace_pressed() -> void:
	if search.text.is_empty():
		return
	Global.get_core().start_replace_action(search.text)


func _on_open_find_panel() -> void:
	search.grab_focus()
