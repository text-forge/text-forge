extends PanelContainer
class_name NotificationPanel

@export var icon: Label
@export var title: Label
@export var text: Label
@export var timestamp: Label

func _ready() -> void:
	timestamp.text = Time.get_time_string_from_system()
