class_name NotificationManager
extends Node

## Types (levels) of notifications.
enum Type {
	INFO, ## Information level.
	WARN, ## Warning level.
	ERR, ## Error level.
}

var notifications: Dictionary[String, Dictionary] = {}

func _init() -> void:
	notifications = Settings.read_data("notifications", "registered", Dictionary({}, TYPE_STRING, "", null, TYPE_DICTIONARY, "", null))
	register_notification(
		"dynamic_notification",
		Type.INFO,
		""
	)
	register_notification(
		"file_not_found",
		Type.ERR,
		"Can't find this file:"
	)
	register_notification(
		"open_file_failed",
		Type.ERR,
		"Failed to open file: {0}",
		"Error: "
	)
	register_notification(
		"save_file_failed",
		Type.ERR,
		"Failed to save {0}!",
		"Error: "
	)
	register_notification(
		"invalid_file_extension",
		Type.ERR,
		"Invalid file extension!",
		"Valid extensions: {0}\nProvided: {1}"
	)
	register_notification(
		"security_alert",
		Type.WARN,
		"Security alert! (You are safe)"
	)


func _ready() -> void:
	get_window().close_requested.connect(_save_notifications)


func _notification(what: int) -> void:
	# Additional flush calls to keep changes safe
	if what in [
		NOTIFICATION_CRASH,
		NOTIFICATION_WM_GO_BACK_REQUEST,
		NOTIFICATION_APPLICATION_FOCUS_OUT,
		NOTIFICATION_EXIT_TREE,
		]:
		_save_notifications()


func _save_notifications() -> void:
	Settings.write_data("notifications", "registered", notifications, true)


## Registers a new notification.[br][br]
## [b]Note:[/b] Notifications are persistent between sessions.[br]
## [b]Note:[/b] This function will define a new preset in settings based on [param id] and [param enabled].
## [b]Note:[/b] When [param overwrite] is [code]false[/code], this function ignores the call when there is a
## registered notification with the given [param id].
func register_notification(id: String, type: Type, title: String, text := "", enabled := true, overwrite := false) -> void:
	if notifications.has(id) and not overwrite:
		return
	notifications[id] = {
		"type": type,
		"title": title,
		"text": text,
	}
	Settings.define_preset("notifications", id, enabled)


## Returns [code]true[/code] if there is any registered notification with [method register_notification].
func has_notification(id: String) -> bool:
	return notifications.has(id)


## Sends a notification based on given [param id].[br]
## Available configs for [param changes]: (Is empty by default) [br]
## [codeblock]
## {
## 	"flags": [ # An array to add flags
## 		"force", # Sends this notification even when it's disabled
## 		],
## 	"type": Notif.Type.INFO, # Change type
## 	"title": "", # Change title
## 	"text": "", # Change text
## 	"format_title": [], # Array, dictionary or object to format title with format() function
## 	"format_text": {}, # Array, dictionary or object to format text with format() function
## 	"format_title_placeholder": "{_}", # Placeholder to use in format() function for title, "{_}" is default
## 	"format_text_placeholder": "{_}", # Placeholder to use in format() function for text, "{_}" is default
## 	"title_append": "", # String to append to title (Without any whitespace)
## 	"text_append": "", # String to append to text (Without any whitespace)
## }
## [/codeblock]
## [b]Note:[/b] This is order of changes: [code]Check flags.force -> Change Type -> Change Title ->
## Change Text -> Append to Title -> Append to Text -> Format Title -> Format Text[/code]
func notif(id: String, changes: Dictionary[String, Variant] = {}) -> void:
	if not has_notification(id):
		push_warning("Notification ID " + id + " is not registered!")
		return
	# Detaches passed dictionary and ignores invalid values (by type casting)
	var c: Dictionary[String, Variant] = {
		"flags": changes.get("flags"),
		"type": changes.get("type"),
		"title": changes.get("title"),
		"text": changes.get("text"),
		"format": {
			"title": [changes.get("format_title")] if changes.get("format_title") is String else changes.get("format_title"),
			"text": [changes.get("format_text")] if changes.get("format_text") is String else changes.get("format_text"),
		},
		"format_placeholder": {
			"title": changes.get("format_title_placeholder") if changes.get("format_title_placeholder") is String else "{_}",
			"text": changes.get("format_text_placeholder") if changes.get("format_text_placeholder") is String else "{_}",
		},
		"append": {
			"title": changes.get("title_append"),
			"text": changes.get("text_append"),
		},
	}
	if not Settings.get_setting("notifications", id):
		if not(c.flags is Array and "force" in c.flags):
			return
	var n := notifications[id].duplicate()
	if c.type != null and c.type is Type:
		n.type = c.type
	for p in ["title", "text"]:
		if c[p] != null and c[p] is String:
			n[p] = c[p]
		if c.append[p] != null and c.append[p] is String:
			n[p] += c.append[p]
		if c.format[p] != null:
			n[p] = n[p].format(c.format[p], c.format_placeholder[p])
	Signals.editor_notification.emit(n.type, n.title, n.text)


## Enables or disables a notification, disabled notifications will be ignored in [method notif]. [br][br]
func set_notification_enabled(id: String, enabled: bool) -> void:
	if not has_notification(id):
		return
	Settings.set_setting("notifications", id, enabled)
