class_name TFP_Preview
extends TextForgePanel
## A standard panel that receive preview and show it.
##
## This panel is connected to SignalBus.preview_updated and updates preview with this signal.

## [TabContainer] to switch between preview types.
@export var tab: TabContainer
## Preview [RichTextLabel] with BBCode support.
@export var preview: RichTextLabel
## Preview [MarginContainer] to keep node-based preview.
@export var preview_node: MarginContainer
@export var preview_scroll_container: ScrollContainer

@onready var preview_v_scroll_bar: VScrollBar = preview.get_v_scroll_bar()
@onready var preview_node_v_scroll_bar: VScrollBar = preview_scroll_container.get_v_scroll_bar()
@onready var editor_v_scroll_bar: VScrollBar = Global.get_editor().get_v_scroll_bar()

func _init() -> void:
	place = PanelManager.Panels.RIGHT


func _ready() -> void:
	editor_v_scroll_bar.value_changed.connect(_update_scroll)

	Signals.preview_updated.connect(_update_preview)


func _update_scroll(value: float) -> void:
	preview_v_scroll_bar.set_value(value * preview_v_scroll_bar.max_value / editor_v_scroll_bar.max_value)
	preview_node_v_scroll_bar.set_value(value * preview_node_v_scroll_bar.max_value / editor_v_scroll_bar.max_value)


func _update_preview(_preview) -> void:
	if _preview is String and _preview != "":
		_set_preview_enabled(true, true)
		preview.text = _preview
	elif _preview is Control and _preview != null:
		_set_preview_enabled(true, false)
		S.free_all_children(preview_node)
		preview_node.add_child(_preview)
	else:
		_set_preview_enabled(false, false)


func _set_preview_enabled(enabled: bool, as_text: bool) -> void:
	if not enabled:
		tab.set_current_tab(0)
	elif as_text:
		tab.set_current_tab(1)
	else:
		tab.set_current_tab(2)
