# GdUnit generated TestSuite
class_name InteractiveReplaceActionTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://action_scripts/interactive_replace.gd'

var interactive_script: ActionScript
## Signals the action emitted, a lambda writes into a member, not into a local.
var test_run_action_emits_the_signal__emitted := 0

func before_test() -> void:
	interactive_script = load(__source).new()

func after_test() -> void:
	if interactive_script:
		interactive_script.free()

func test_initialize_sets_requires_file() -> void:
	interactive_script._initialize()
	assert_bool(interactive_script.requires_file).is_true()

func test_script_extends_action_script() -> void:
	assert_object(interactive_script).is_instanceof(ActionScript)

func test_run_action_emits_the_signal() -> void:
	var connection := func(): test_run_action_emits_the_signal__emitted += 1
	Signals.interactive_replace.connect(connection)
	interactive_script._run_action()
	assert_int(test_run_action_emits_the_signal__emitted).is_equal(1)
	Signals.interactive_replace.disconnect(connection)
