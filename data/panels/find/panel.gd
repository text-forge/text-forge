extends Control

@export var counter: Label
@export var match_case: CheckBox
@export var whole_words: CheckBox
@export var backwards: CheckBox
@export var search: LineEdit
@export var replace: LineEdit
@export var list: ItemList

var index: int

var matches: Array[Vector2i] = []

func _ready() -> void:
	Signals.open_find_panel.connect(Global.get_panel_manager().show_panel.bind(PanelManager.Panels.RIGHT, index))
	Signals.shift_find_result.connect(func(next):
		if next:
			_on_next_pressed()
		else:
			_on_prev_pressed()
	)
	Signals.replace_all.connect(_on_replace_all_pressed)


func _on_line_edit_text_changed(new_text: String) -> void:
	matches.clear()
	while true:
		var next = Global.get_editor().search(
			new_text,
			(TextEdit.SearchFlags.SEARCH_MATCH_CASE if match_case.button_pressed else 0) +
			(TextEdit.SearchFlags.SEARCH_WHOLE_WORDS if whole_words.button_pressed else 0) +
			(TextEdit.SearchFlags.SEARCH_BACKWARDS if backwards.button_pressed else 0),
			0 if matches.size() == 0 else matches[-1].y,
			0 if matches.size() == 0 else matches[-1].x + (-1 if backwards.button_pressed else 1)
		)
		if next == Vector2i(-1, -1) or matches.has(next): break
		matches.append(next)
	counter.text = str(matches.size()) + " match" + ("es" if matches.size() > 1 else "")
	list.clear()
	if matches.size() == 0: return
	for item in matches:
		list.add_item("Line {0}, Column {1}".format([item.y + 1, item.x + 1]))
	list.select(0)
	_on_item_list_item_selected(0)


func _on_option_pressed() -> void:
	_on_line_edit_text_changed(search.text)


func _on_item_list_item_selected(idx: int) -> void:
	Global.get_editor().select(matches[idx].y, matches[idx].x, matches[idx].y, matches[idx].x + search.text.length())
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
		Global.get_editor().select(matches[idx].y, matches[idx].x, matches[idx].y, matches[idx].x + search.text.length(), idx)


func _on_replace_pressed() -> void:
	if list.item_count == 0: return
	_on_item_list_item_selected(list.get_selected_items()[0] if list.is_anything_selected() else 0)
	var origin := Vector2i(Global.get_editor().get_selection_origin_line(), Global.get_editor().get_selection_origin_column())
	Global.set_editor_text(
		Global.get_editor_text().substr(0, Global.get_editor().get_char_index(origin.x, origin.y)) +
		replace.text +
		Global.get_editor_text().substr(Global.get_editor().get_char_index(origin.x, origin.y) + search.text.length())
	)
	Global.get_editor().select(origin.x, origin.y, origin.x, origin.y + replace.text.length())
	_on_line_edit_text_changed(search.text)


func _on_replace_all_pressed() -> void:
	Global.get_editor().begin_complex_operation()
	while list.item_count != 0:
		_on_replace_pressed()
	Global.get_editor().end_complex_operation()
	Global.get_editor().text_changed.emit()
