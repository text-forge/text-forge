class_name TestsCore
extends Node
## Handles runtime tests including performance monitoring.

@warning_ignore_start("unused_signal")
signal open_started
signal search_started
@warning_ignore_restore("unused_signal")

## When [code]true[/code], disables all tests.
const DISABLE_ALL := false
## When [code]true[/code], starts [i]Performance Test[/i].
const PERFORMANCE_ALL := true
## When [code]true[/code], [i]Performance Test[/i] will monitor startup time.
const PERFORMANCE_STARTUP := true
## When [code]true[/code], [i]Performance Test[/i] will monitor time to open file.
const PERFORMANCE_OPEN_FILE := true

func _ready() -> void:
	if DISABLE_ALL or not Global.get_editor():
		return
	if PERFORMANCE_ALL:
		var performance_script := U.load_resource("res://tests/runtime/performance.gd")
		if not performance_script:
			return
		add_child(performance_script.new(PERFORMANCE_STARTUP, PERFORMANCE_OPEN_FILE))
