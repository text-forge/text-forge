# GdUnit generated TestSuite
class_name BookmarkPanelTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/panels/bookmarks/panel.gd'

var panel: Control

func before_test() -> void:
	var scene = load("res://core/panels/bookmarks/panel.tscn")
	panel = auto_free(scene.instantiate())
	add_child(panel)
	await get_tree().process_frame

func test_panel_instantiates_correctly() -> void:
	assert_object(panel).is_not_null()
	assert_object(panel).is_instanceof(Control)

func test_panel_extends_text_forge_panel() -> void:
	# Check if script is attached and extends TextForgePanel
	var script: Script = panel.get_script()
	assert_object(script).is_not_null()
	assert_str(script.get_base_script().get_global_name()).is_equal("TextForgePanel")

func test_has_items_container() -> void:
	assert_object(panel.items).is_not_null()
	assert_object(panel.items).is_instanceof(VBoxContainer)

func test_items_container_starts_empty() -> void:
	# Items container should start with no children
	assert_int(panel.items.get_child_count()).is_equal(0)

func test_has_update_bookmarks_method() -> void:
	assert_bool(panel.has_method("_update_bookmarks")).is_true()

func test_panel_has_minimum_size() -> void:
	# Panel should have a minimum width set
	assert_float(panel.custom_minimum_size.x).is_greater(0.0)

func test_margin_container_exists() -> void:
	# The scene should have a MarginContainer
	var has_margin := false
	for child in panel.get_children():
		if child is MarginContainer:
			has_margin = true
			break
	assert_bool(has_margin).is_true()

func test_item_scene_constant_exists() -> void:
	# The ITEM constant should be defined
	var script = panel.get_script()
	assert_object(script).is_not_null()
	assert_object(script.ITEM).is_not_null()

func test_panel_layout_structure() -> void:
	# Verify basic layout structure
	assert_int(panel.get_child_count()).is_greater(0)

func test_items_are_in_vbox() -> void:
	# The items VBoxContainer should be properly set up
	assert_str(panel.items.get_class()).is_equal("VBoxContainer")

func test_panel_anchors_fill_parent() -> void:
	# Panel should be set to fill its parent
	assert_float(panel.anchor_right).is_equal(1.0)
	assert_float(panel.anchor_bottom).is_equal(1.0)

# Note: More comprehensive tests for _update_bookmarks would require
# mocking the Global singleton and Editor, which is complex in unit tests.
# These behaviors are better tested as integration tests where the full
# application context is available.

func test_panel_is_visible_by_default() -> void:
	assert_bool(panel.visible).is_true()

func test_panel_can_be_hidden() -> void:
	panel.hide()
	assert_bool(panel.visible).is_false()

func test_panel_can_be_shown() -> void:
	panel.hide()
	panel.show()
	assert_bool(panel.visible).is_true()
