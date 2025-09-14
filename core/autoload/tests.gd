extends Node

@warning_ignore_start("unused_signal")
signal open_started
signal search_started

const DISABLE_ALL := false
const PERFORMANCE_TEST := true

func _ready() -> void:
	if DISABLE_ALL:
		return
	if PERFORMANCE_TEST:
		add_child(load("res://tests/performance.gd").new())
