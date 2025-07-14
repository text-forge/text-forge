extends Window

@export var input: LineEdit
@export var submit: Button

func _ready() -> void:
	submit.pressed.connect(func(): close_requested.emit())
	input.text_submitted.connect(func(text): close_requested.emit())
