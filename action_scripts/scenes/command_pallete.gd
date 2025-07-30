extends Popup

@export var options: VBoxContainer
@export var sample: Button
@export var input: LineEdit

var commands := {}

func _ready() -> void:
	popup_hide.connect(func(): queue_free())
	commands = Global.get_command_list()
	input.grab_focus()
	_on_line_edit_text_changed("")


func _on_line_edit_text_changed(new_text: String) -> void:
	var order := commands.keys()
	order.sort_custom(_sort_commands.bind(new_text))
	SLib.free_all_children(options)
	for item: String in order:
		var option: Button = sample.duplicate()
		var modified_text = item
		if item.containsn(new_text):
			modified_text = item.substr(0, item.findn(new_text)) + "[bgcolor=ffffff10]" + item.substr(item.findn(new_text), new_text.length()) + "[/bgcolor]" + item.substr(item.findn(new_text) + new_text.length())
		option.get_child(1).append_text(modified_text)
		option.get_child(0).text = commands[item][0]
		if option.get_child(0).text == "(Unset)": option.get_child(0).hide()
		option.pressed.connect(commands[item][1])
		option.pressed.connect(self.hide)
		options.add_child(option)
		option.show()
	options.set_deferred("scroll_horizontal", 0)


func _sort_commands(a: String, b: String, text: String) -> bool:
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


func _on_line_edit_text_submitted(new_text: String) -> void:
	options.get_child(0).pressed.emit()
