class_name CommandPalette
extends Popup
## Command palette that provides a fast way to search for and run commands.

## Container for all command option buttons.
@export var options: VBoxContainer
## Template button used when instancing command options.
@export var sample: Button
## Input search box.
@export var input: LineEdit

## List of available commands.
var commands := {}

func _ready() -> void:
	popup_hide.connect(func(): queue_free())
	commands = Global.get_command_list()
	input.grab_focus()
	_on_search_box_text_changed("")


func _on_search_box_text_changed(new_text: String) -> void:
	var order := commands.keys()
	order.sort_custom(_sort_commands.bind(new_text))
	S.free_all_children(options)
	for item: String in order:
		var option: Button = sample.duplicate()
		var modified_text := item
		if not new_text.is_empty() and item.containsn(new_text):
			var idx := item.findn(new_text)
			modified_text = (
				item.substr(0, idx)
				+ "[bgcolor=ffffff10]"
				+ item.substr(idx, new_text.length())
				+ "[/bgcolor]"
				+ item.substr(idx + new_text.length())
			)
		option.get_child(0).append_text(modified_text)
		option.get_child(1).text = commands[item][0]
		if option.get_child(1).text == "(Unset)":
			option.get_child(1).hide()
		option.pressed.connect(self.hide)
		option.pressed.connect(commands[item][1])
		options.add_child(option)
		option.show()
	options.set_deferred("scroll_horizontal", 0)


func _sort_commands(a: String, b: String, text: String) -> bool:
	if text.is_empty():
		return a < b
	var score_a: float = text.similarity(a)
	var score_b: float = text.similarity(b)
	if a.contains(text):
		score_a += 1
	elif a.containsn(text):
		score_a += 0.5
	if b.contains(text):
		score_b += 1
	elif b.containsn(text):
		score_b += 0.5
	return score_a > score_b


func _on_search_box_text_submitted(new_text: String) -> void:
	if options.get_child_count() > 0:
		options.get_child(0).pressed.emit()
