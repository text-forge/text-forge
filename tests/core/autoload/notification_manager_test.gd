# GdUnit generated TestSuite
class_name NotificationManagerTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/notification_manager.gd'

## Notifications registered by [NotificationManager] itself.
const CORE_IDS: Array[String] = [
	"dynamic_notification",
	"file_not_found",
	"open_file_failed",
	"save_file_failed",
	"invalid_file_extension",
	"security_alert",
]

## Emitted notifications, as [code][type, title, text][/code].
var _emitted: Array = []
## Notification enabled state before the test, restored afterwards. Notification presets are
## persistent user settings, so tests must not leave them changed.
var _previous_enabled_state: Dictionary[String, bool] = {}


func before_test() -> void:
	_emitted = []
	_previous_enabled_state = {}
	for id: String in CORE_IDS:
		_previous_enabled_state[id] = bool(Settings.get_setting("notifications", id))
		Notif.set_notification_enabled(id, true)
	Signals.editor_notification.connect(_on_editor_notification)


func after_test() -> void:
	Signals.editor_notification.disconnect(_on_editor_notification)
	for id: String in _previous_enabled_state:
		Notif.set_notification_enabled(id, _previous_enabled_state[id])


func _on_editor_notification(type: Notif.Type, title: String, text: String) -> void:
	_emitted.append([type, title, text])


func test_core_notifications_are_registered() -> void:
	for id: String in CORE_IDS:
		assert_bool(Notif.has_notification(id)).is_true()


func test_unknown_notification_is_not_registered() -> void:
	assert_bool(Notif.has_notification("this_id_is_not_registered")).is_false()


func test_notif_emits_registered_type_title_and_text() -> void:
	Notif.notif("file_not_found", {"text": "test.txt"})
	assert_array(_emitted).is_equal([[Notif.Type.ERR, "Can't find this file:", "test.txt"]])


func test_notif_applies_text_override_and_append() -> void:
	Notif.notif("file_not_found", {"text": "test.txt", "text_append": " (from recent list)"})
	assert_array(_emitted).is_equal([[Notif.Type.ERR, "Can't find this file:", "test.txt (from recent list)"]])


func test_notif_applies_title_override() -> void:
	Notif.notif("file_not_found", {"title": "Custom title:"})
	assert_array(_emitted).is_equal([[Notif.Type.ERR, "Custom title:", ""]])


func test_notif_applies_type_override() -> void:
	Notif.notif("file_not_found", {"type": Notif.Type.INFO})
	assert_array(_emitted).is_equal([[Notif.Type.INFO, "Can't find this file:", ""]])


func test_notif_formats_text_with_format_text() -> void:
	Notif.notif("invalid_file_extension", {"format_text": ["txt", "png"]})
	assert_array(_emitted).is_equal(
		[[Notif.Type.ERR, "Invalid file extension!", "Valid extensions: txt\nProvided: png"]]
	)


func test_disabled_notification_is_ignored() -> void:
	Notif.set_notification_enabled("security_alert", false)
	Notif.notif("security_alert")
	assert_array(_emitted).is_empty()


func test_force_flag_bypasses_disabled_state() -> void:
	Notif.set_notification_enabled("security_alert", false)
	Notif.notif("security_alert", {"flags": ["force"]})
	assert_array(_emitted).is_equal([[Notif.Type.WARN, "Security alert! (You are safe)", ""]])


func test_register_notification_without_overwrite_keeps_existing_content() -> void:
	var original_title: String = Notif.notifications["file_not_found"]["title"]
	Notif.register_notification("file_not_found", Notif.Type.INFO, "Changed title")
	assert_str(Notif.notifications["file_not_found"]["title"]).is_equal(original_title)
