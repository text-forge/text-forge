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
	order.sort_custom(func(a, b): return new_text.similarity(a) > new_text.similarity(b))
	SLib.free_all_children(options)
	for item in order:
		var option: Button = sample.duplicate()
		option.text = item
		option.get_child(0).text = commands[item][0]
		if option.get_child(0).text == "(Unset)": option.get_child(0).hide()
		option.pressed.connect(commands[item][1])
		option.pressed.connect(self.hide)
		options.add_child(option)
		option.show()
	options.set_deferred("scroll_horizontal", 0)


func _on_line_edit_text_submitted(new_text: String) -> void:
	options.get_child(0).pressed.emit()
