extends PanelContainer
class_name NotificationPanel

@onready var icon: Label = get_child(0).get_child(0)
@onready var title: Label = get_child(0).get_child(1).get_child(0)
@onready var text: Label = get_child(0).get_child(1).get_child(1)

func _ready() -> void:
	get_child(0).get_child(1).get_child(2).text = Time.get_time_string_from_system()
