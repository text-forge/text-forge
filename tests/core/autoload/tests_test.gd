# GdUnit generated TestSuite
class_name TestsCoreTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/tests.gd'

var tests_core: TestsCore

func before_test() -> void:
	tests_core = auto_free(TestsCore.new())
	add_child(tests_core)

func test_class_name_is_tests_core() -> void:
	assert_str(tests_core.get_class()).contains("TestsCore")

func test_extends_node() -> void:
	assert_object(tests_core).is_instanceof(Node)

func test_has_open_started_signal() -> void:
	assert_bool(tests_core.has_signal("open_started")).is_true()

func test_has_search_started_signal() -> void:
	assert_bool(tests_core.has_signal("search_started")).is_true()

func test_disable_all_constant_exists() -> void:
	assert_bool(tests_core.has("DISABLE_ALL")).is_true()

func test_disable_all_is_bool() -> void:
	var disable_all = tests_core.get("DISABLE_ALL")
	assert_bool(disable_all is bool).is_true()

func test_performance_all_constant_exists() -> void:
	assert_bool(tests_core.has("PERFORMANCE_ALL")).is_true()

func test_performance_all_is_bool() -> void:
	var performance_all = tests_core.get("PERFORMANCE_ALL")
	assert_bool(performance_all is bool).is_true()

func test_performance_startup_constant_exists() -> void:
	assert_bool(tests_core.has("PERFORMANCE_STARTUP")).is_true()

func test_performance_startup_is_bool() -> void:
	var performance_startup = tests_core.get("PERFORMANCE_STARTUP")
	assert_bool(performance_startup is bool).is_true()

func test_performance_open_file_constant_exists() -> void:
	assert_bool(tests_core.has("PERFORMANCE_OPEN_FILE")).is_true()

func test_performance_open_file_is_bool() -> void:
	var performance_open_file = tests_core.get("PERFORMANCE_OPEN_FILE")
	assert_bool(performance_open_file is bool).is_true()

func test_constants_default_values() -> void:
	# Test that constants have expected default values
	assert_bool(tests_core.DISABLE_ALL).is_false()
	assert_bool(tests_core.PERFORMANCE_ALL).is_true()
	assert_bool(tests_core.PERFORMANCE_STARTUP).is_true()
	assert_bool(tests_core.PERFORMANCE_OPEN_FILE).is_true()

func test_open_started_signal_can_be_connected() -> void:
	var callable := Callable(self, "_dummy_callback")
	tests_core.open_started.connect(callable)
	assert_bool(tests_core.open_started.is_connected(callable)).is_true()

func test_search_started_signal_can_be_connected() -> void:
	var callable := Callable(self, "_dummy_callback")
	tests_core.search_started.connect(callable)
	assert_bool(tests_core.search_started.is_connected(callable)).is_true()

func test_open_started_signal_can_be_emitted() -> void:
	var signal_emitted := false
	tests_core.open_started.connect(func(): signal_emitted = true)
	tests_core.open_started.emit()
	assert_bool(signal_emitted).is_true()

func test_search_started_signal_can_be_emitted() -> void:
	var signal_emitted := false
	tests_core.search_started.connect(func(): signal_emitted = true)
	tests_core.search_started.emit()
	assert_bool(signal_emitted).is_true()

func test_performance_script_path_is_correct() -> void:
	# Verify the path to performance.gd is correct
	var perf_path := "res://tests/runtime/performance.gd"
	assert_bool(FileAccess.file_exists(perf_path)).is_true()

func test_performance_script_can_be_loaded() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	assert_object(perf_script).is_not_null()

func test_performance_script_can_be_instantiated() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	var perf_instance = auto_free(perf_script.new(true, true))
	assert_object(perf_instance).is_not_null()
	assert_object(perf_instance).is_instanceof(Node)

func test_performance_instance_has_startup_property() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	var perf_instance = auto_free(perf_script.new(true, false))
	assert_bool(perf_instance.has("startup")).is_true()
	assert_bool(perf_instance.startup).is_true()

func test_performance_instance_has_open_file_property() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	var perf_instance = auto_free(perf_script.new(false, true))
	assert_bool(perf_instance.has("open_file")).is_true()
	assert_bool(perf_instance.open_file).is_true()

func test_performance_instance_respects_startup_false() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	var perf_instance = auto_free(perf_script.new(false, true))
	assert_bool(perf_instance.startup).is_false()

func test_performance_instance_respects_open_file_false() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	var perf_instance = auto_free(perf_script.new(true, false))
	assert_bool(perf_instance.open_file).is_false()

func test_performance_instance_both_params_true() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	var perf_instance = auto_free(perf_script.new(true, true))
	assert_bool(perf_instance.startup).is_true()
	assert_bool(perf_instance.open_file).is_true()

func test_performance_instance_both_params_false() -> void:
	var perf_script = load("res://tests/runtime/performance.gd")
	var perf_instance = auto_free(perf_script.new(false, false))
	assert_bool(perf_instance.startup).is_false()
	assert_bool(perf_instance.open_file).is_false()

func _dummy_callback() -> void:
	pass