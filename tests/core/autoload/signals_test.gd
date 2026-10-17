# GdUnit generated TestSuite
class_name SignalBusTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/signals.gd'

## Every module and action script connects to these signals by name, so renaming or removing one
## silently breaks all of its consumers. This list pins the public signal bus contract.
const REQUIRED_SIGNALS: Array[String] = [
	"internal_notification",
	"editor_notification",
	"run_script",
	"run_subscript",
	"run_saved_subscript",
	"check_options",
	"close_file",
	"open_file",
	"new_file",
	"close_project",
	"force_save",
	"force_save_finished",
	"save_request",
	"save_finished",
	"open_find_panel",
	"open_bookmarks_panel",
	"shift_find_result",
	"replace_all",
	"settings_changed",
	"reload_recent_files",
	"module_profiler_refresh",
	"mode_changed",
	"preview_updated",
	"problems_updated",
	"outline_updated",
]

## Argument counts are part of the contract too: emitters and connected callables must match.
const EXPECTED_ARG_COUNTS := {
	"internal_notification": 2,
	"editor_notification": 3,
	"run_script": 1,
	"run_subscript": 3,
	"run_saved_subscript": 1,
	"open_file": 1,
	"save_request": 1,
	"save_finished": 1,
	"shift_find_result": 1,
	"mode_changed": 1,
	"preview_updated": 1,
	"problems_updated": 1,
	"outline_updated": 1,
	"check_options": 0,
	"close_file": 0,
	"new_file": 0,
	"close_project": 0,
	"force_save": 0,
	"force_save_finished": 0,
	"open_find_panel": 0,
	"open_bookmarks_panel": 0,
	"replace_all": 0,
	"settings_changed": 0,
	"reload_recent_files": 0,
	"module_profiler_refresh": 0,
}


func test_signal_bus_exposes_all_documented_signals() -> void:
	var missing: Array[String] = []
	for signal_name: String in REQUIRED_SIGNALS:
		if not Signals.has_signal(signal_name):
			missing.append(signal_name)
	assert_array(missing).is_empty()


func test_signal_argument_counts_are_stable() -> void:
	var arg_counts: Dictionary[String, int] = {}
	for signal_data: Dictionary in Signals.get_signal_list():
		var args: Array = signal_data["args"]
		arg_counts[signal_data["name"]] = args.size()
	for signal_name: String in EXPECTED_ARG_COUNTS:
		assert_int(arg_counts.get(signal_name, -1)).is_equal(EXPECTED_ARG_COUNTS[signal_name])
