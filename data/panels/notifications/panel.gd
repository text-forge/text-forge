extends TextForgePanel

@export var options: Container
@export var notifications: Container
@export var mute_bottom: Button

var mute: bool = false

func _ready() -> void:
	Signals.editor_notification.connect(_editor_notification)


func _editor_notification(type: int, title: String, text: String) -> void:
	var notification_panel: NotificationPanel = Global.load_resource("res://data/panels/notifications/notification.tscn").instantiate()
	notifications.add_child(notification_panel)
	notifications.move_child(notification_panel, 0)
	match type:
		0: # info/message
			notification_panel.icon.text = "ℹ️"
		1: # warning
			notification_panel.icon.text = "⚠️"
		2: # error
			notification_panel.icon.text = "❌"
	notification_panel.title.text = title
	if text == "":
		notification_panel.text.hide()
	else:
		notification_panel.text.text = text
	if not (get_parent().current_tab == index and visible):
		Global.get_panel_manager().change_panel_icon(place, index, Global.load_resource("res://data/panels/notifications/notification.png"))
	if not mute:
		Global.get_panel_manager().show_panel(place, index)


func _on_tab_changed() -> void:
	if get_parent().current_tab == index and visible:
		Global.get_panel_manager().change_panel_icon(place, index, Global.load_resource("res://data/panels/notifications/icon.png"))


func _on_clear_pressed() -> void:
	SLib.free_all_children(notifications)


func _on_mute_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mute_bottom.icon = Global.load_resource("res://data/panels/notifications/mute.png")
	else:
		mute_bottom.icon = Global.load_resource("res://data/panels/notifications/icon.png")
	mute = toggled_on
