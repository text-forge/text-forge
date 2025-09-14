extends ActionScript

func _initialize() -> void:
	requires_file = true


func _run_action() -> void:
	BackupCore.backup_file(false)
