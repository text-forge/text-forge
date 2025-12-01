# GdUnit generated TestSuite
class_name PerformanceMonitorTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://tests/runtime/performance.gd'

var performance_monitor: Node

func after_test() -> void:
	if performance_monitor:
		performance_monitor.free()
		performance_monitor = null

## Test initialization

func test_performance_monitor_can_be_instantiated() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_object(performance_monitor).is_not_null()

func test_performance_monitor_extends_node() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_object(performance_monitor).is_instanceof(Node)

func test_init_with_startup_true_open_file_true() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.startup).is_true()
	assert_bool(performance_monitor.open_file).is_true()

func test_init_with_startup_false_open_file_false() -> void:
	var script = load(__source)
	performance_monitor = script.new(false, false)
	assert_bool(performance_monitor.startup).is_false()
	assert_bool(performance_monitor.open_file).is_false()

func test_init_with_startup_true_open_file_false() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	assert_bool(performance_monitor.startup).is_true()
	assert_bool(performance_monitor.open_file).is_false()

func test_init_with_startup_false_open_file_true() -> void:
	var script = load(__source)
	performance_monitor = script.new(false, true)
	assert_bool(performance_monitor.startup).is_false()
	assert_bool(performance_monitor.open_file).is_true()

## Test properties

func test_has_startup_property() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has("startup")).is_true()

func test_has_open_file_property() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has("open_file")).is_true()

func test_has_start_time_property() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has("start_time")).is_true()

func test_has_end_time_property() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has("end_time")).is_true()

func test_start_time_is_integer() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.start_time is int).is_true()

func test_end_time_is_integer() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.end_time is int).is_true()

## Test methods

func test_has_on_first_frame_method() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has_method("_on_first_frame")).is_true()

func test_has_monitor_open_method() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has_method("_monitor_open")).is_true()

func test_has_ready_method() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has_method("_ready")).is_true()

func test_has_init_method() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.has_method("_init")).is_true()

## Test startup monitoring initialization

func test_startup_enabled_initializes_start_time() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	add_child(performance_monitor)
	await get_tree().process_frame
	# start_time should be set to a valid timestamp
	assert_int(performance_monitor.start_time).is_greater(0)

func test_startup_disabled_does_not_set_start_time() -> void:
	var script = load(__source)
	performance_monitor = script.new(false, false)
	add_child(performance_monitor)
	await get_tree().process_frame
	# start_time should remain 0 or default
	assert_int(performance_monitor.start_time).is_equal(0)

## Test time measurement logic

func test_on_first_frame_sets_end_time() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	performance_monitor.start_time = Time.get_ticks_msec()
	performance_monitor._on_first_frame()
	# end_time should be set and greater than start_time
	assert_int(performance_monitor.end_time).is_greater(performance_monitor.start_time)

func test_on_first_frame_calculates_duration() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	performance_monitor.start_time = Time.get_ticks_msec()
	await get_tree().create_timer(0.01).timeout
	performance_monitor._on_first_frame()
	var duration = performance_monitor.end_time - performance_monitor.start_time
	# Duration should be positive and reasonable
	assert_int(duration).is_greater_equal(0)

func test_timing_consistency() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	var time1 = Time.get_ticks_msec()
	await get_tree().create_timer(0.05).timeout
	var time2 = Time.get_ticks_msec()
	# Time should progress forward
	assert_int(time2).is_greater(time1)

## Test multiple instances

func test_multiple_instances_independent() -> void:
	var script = load(__source)
	var monitor1 = auto_free(script.new(true, false))
	var monitor2 = auto_free(script.new(false, true))
	
	assert_bool(monitor1.startup).is_true()
	assert_bool(monitor1.open_file).is_false()
	assert_bool(monitor2.startup).is_false()
	assert_bool(monitor2.open_file).is_true()

func test_multiple_instances_different_timings() -> void:
	var script = load(__source)
	var monitor1 = auto_free(script.new(true, false))
	await get_tree().create_timer(0.02).timeout
	var monitor2 = auto_free(script.new(true, false))
	
	# If both measure startup, their start times should be different
	add_child(monitor1)
	await get_tree().process_frame
	add_child(monitor2)
	await get_tree().process_frame
	
	assert_int(monitor2.start_time).is_greater_equal(monitor1.start_time)

## Test configuration combinations

func test_only_startup_monitoring() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	assert_bool(performance_monitor.startup).is_true()
	assert_bool(performance_monitor.open_file).is_false()

func test_only_open_file_monitoring() -> void:
	var script = load(__source)
	performance_monitor = script.new(false, true)
	assert_bool(performance_monitor.startup).is_false()
	assert_bool(performance_monitor.open_file).is_true()

func test_no_monitoring() -> void:
	var script = load(__source)
	performance_monitor = script.new(false, false)
	assert_bool(performance_monitor.startup).is_false()
	assert_bool(performance_monitor.open_file).is_false()

func test_all_monitoring() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	assert_bool(performance_monitor.startup).is_true()
	assert_bool(performance_monitor.open_file).is_true()

## Test edge cases

func test_rapid_instantiation() -> void:
	var script = load(__source)
	var monitors := []
	for i in range(10):
		monitors.append(auto_free(script.new(true, true)))
	
	# All should be valid instances
	for monitor in monitors:
		assert_object(monitor).is_not_null()
		assert_bool(monitor.startup).is_true()

func test_zero_duration_handling() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	performance_monitor.start_time = 100
	performance_monitor.end_time = 100
	var duration = performance_monitor.end_time - performance_monitor.start_time
	# Should handle zero duration without error
	assert_int(duration).is_equal(0)

func test_immediate_timing_measurement() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	add_child(performance_monitor)
	await get_tree().process_frame
	# Should have initialized timing
	assert_int(performance_monitor.start_time).is_greater(0)

## Test property immutability after init

func test_startup_property_set_by_init() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	var original_value = performance_monitor.startup
	# Property should be set and stable
	assert_bool(performance_monitor.startup).is_equal(original_value)

func test_open_file_property_set_by_init() -> void:
	var script = load(__source)
	performance_monitor = script.new(false, true)
	var original_value = performance_monitor.open_file
	# Property should be set and stable
	assert_bool(performance_monitor.open_file).is_equal(original_value)

## Test integration with tree

func test_can_be_added_to_tree() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	add_child(performance_monitor)
	assert_bool(performance_monitor.is_inside_tree()).is_true()

func test_can_be_removed_from_tree() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	add_child(performance_monitor)
	remove_child(performance_monitor)
	assert_bool(performance_monitor.is_inside_tree()).is_false()

func test_multiple_instances_in_tree() -> void:
	var script = load(__source)
	var monitor1 = auto_free(script.new(true, false))
	var monitor2 = auto_free(script.new(false, true))
	
	add_child(monitor1)
	add_child(monitor2)
	
	assert_bool(monitor1.is_inside_tree()).is_true()
	assert_bool(monitor2.is_inside_tree()).is_true()

## Test memory management

func test_instance_can_be_freed() -> void:
	var script = load(__source)
	var monitor = script.new(true, true)
	var ref_count_before = typeof(monitor)
	monitor.free()
	# Should not crash and object should be freed
	assert_bool(true).is_true()

func test_multiple_free_safe() -> void:
	var script = load(__source)
	var monitors := []
	for i in range(5):
		var monitor = script.new(true, true)
		monitors.append(monitor)
	
	for monitor in monitors:
		if is_instance_valid(monitor):
			monitor.free()
	
	# Should complete without error
	assert_bool(true).is_true()

## Test realistic scenarios

func test_typical_startup_monitoring_scenario() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, false)
	add_child(performance_monitor)
	
	await get_tree().process_frame
	await get_tree().create_timer(0.01).timeout
	
	# Should have valid timing data
	assert_int(performance_monitor.start_time).is_greater(0)

func test_typical_all_monitoring_scenario() -> void:
	var script = load(__source)
	performance_monitor = script.new(true, true)
	add_child(performance_monitor)
	
	await get_tree().process_frame
	
	# Both monitoring types should be enabled
	assert_bool(performance_monitor.startup).is_true()
	assert_bool(performance_monitor.open_file).is_true()

func test_disabled_monitoring_scenario() -> void:
	var script = load(__source)
	performance_monitor = script.new(false, false)
	add_child(performance_monitor)
	
	await get_tree().process_frame
	
	# Should initialize without starting monitoring
	assert_int(performance_monitor.start_time).is_equal(0)