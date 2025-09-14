extends TextureRect

@export var hide_timer: Timer

func _ready() -> void:
	BackupCore.backup_saved.connect(_on_backup_saved)
	BackupCore.backup_failed.connect(_on_backup_failed)
	hide_timer.timeout.connect(SLib.play_animation.bind(SLib.Animations.FADE_OUT, self))


func _on_backup_saved(was_auto: bool) -> void:
	texture = load("res://assets/backup.png")
	tooltip_text = "Backup Status\n{0} backup saved: {1}".format([
		"Auto" if was_auto else "Manual", Time.get_datetime_string_from_system(false, true)
	])
	modulate = Color.WHITE
	show()
	hide_timer.start()


func _on_backup_failed(was_auto: bool) -> void:
	texture = load("res://assets/backup_fail.png")
	tooltip_text = "Backup Status\n{0} backup failed: {1}".format([
		"Auto" if was_auto else "Manual", Time.get_datetime_string_from_system(false, true)
	])
	modulate = Color.WHITE
	show()
	hide_timer.start()
