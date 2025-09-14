extends Window

@export var color_picker: ColorPicker

func _ready() -> void:
	color_picker.resized.connect(func(): size = color_picker.size)
