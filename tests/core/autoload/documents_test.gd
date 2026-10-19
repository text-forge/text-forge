# GdUnit generated TestSuite
class_name DocumentManagerTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://core/autoload/documents.gd'

var tabs: TabContainer
var _bootstrap: EditorDocument
var test_activate_emits_active_document_changed__emitted := 0
var test_watch_connects_to_every_document__seen := 0

func before_test() -> void:
	collect_orphan_node_details()
	tabs = auto_free(TabContainer.new())
	add_child(tabs)
	Documents.attach_tabs(tabs)
	# [Documents] is a global with state from the last suite, so normalize it to the single
	# bootstrap document that owns the editor [method GlobalAccess.get_editor] falls back to. Its
	# path keeps it out of the placeholder rules, so nothing below frees that editor.
	if _bootstrap == null:
		if Documents.docs.is_empty():
			Documents.ensure_bootstrap(Editor.new())
		_bootstrap = Documents.docs[0]
	for index in range(Documents.docs.size() - 1, 0, -1):
		_drop_document(Documents.docs[index])
	_bootstrap.path = "user://kept_alive"
	Documents.docs.clear()
	Documents.docs.append(_bootstrap)
	Documents.active = _bootstrap

func after_test() -> void:
	for index in range(Documents.docs.size() - 1, 0, -1):
		_drop_document(Documents.docs[index])
	_bootstrap.path = "user://kept_alive"
	Documents.docs.clear()
	Documents.docs.append(_bootstrap)
	Documents.active = _bootstrap
	Documents.tabs = null

## Adds a document on top of the normalized baseline of exactly one bootstrap document.
func new_doc(path: String) -> EditorDocument:
	return Documents.create(path, path.get_file())

## Removes [param doc] and its editor from the manager. The editor is freed right away and its
## reference is dropped, [method DocumentManager.close] only queues the deletion and a node that is
## deleted but still referenced counts as an orphan.
func _drop_document(doc: EditorDocument) -> void:
	var editor := doc.editor
	doc.editor = null
	if is_instance_valid(editor):
		if editor.get_parent():
			editor.get_parent().remove_child(editor)
		editor.free()
	Documents.docs.erase(doc)

## Closes [param doc] the way the editor does, without leaving a node behind.
func close_doc(doc: EditorDocument, keep_one := true) -> void:
	var editor := doc.editor
	doc.editor = null
	if is_instance_valid(editor):
		if editor.get_parent():
			editor.get_parent().remove_child(editor)
		editor.free()
	Documents.close(doc, keep_one)

func test_attach_tabs_binds_the_container() -> void:
	assert_object(Documents.tabs).is_equal(tabs)

func test_create_adds_a_document_and_a_tab() -> void:
	var count_before := Documents.docs.size()
	var tab_before := tabs.get_tab_count()
	assert_object(new_doc("user://a.gd")).is_not_null()
	assert_int(Documents.docs.size()).is_equal(count_before + 1)
	assert_int(tabs.get_tab_count()).is_equal(tab_before + 1)

func test_create_stores_path_and_name() -> void:
	var doc := new_doc("user://a.gd")
	assert_str(doc.path).is_equal("user://a.gd")
	assert_str(doc.display_name).is_equal("a.gd")
	assert_bool(doc.dirty).is_false()

func test_create_makes_a_new_tab_each_time() -> void:
	var first := new_doc("user://a.gd")
	var second := new_doc("user://b.gd")
	assert_object(first).is_not_equal(second)
	assert_int(Documents.docs.size()).is_equal(3)

func test_activate_makes_the_document_active() -> void:
	var doc := new_doc("user://a.gd")
	Documents.activate(doc)
	assert_object(Documents.active).is_equal(doc)

func test_activate_emits_active_document_changed() -> void:
	var connection := func(_doc): test_activate_emits_active_document_changed__emitted += 1
	Signals.active_document_changed.connect(connection)
	Documents.activate(new_doc("user://a.gd"))
	assert_int(test_activate_emits_active_document_changed__emitted).is_equal(1)
	Signals.active_document_changed.disconnect(connection)

func test_activate_ignores_a_document_outside_the_manager() -> void:
	var previous := Documents.active
	Documents.activate(EditorDocument.new())
	assert_object(Documents.active).is_equal(previous)

func test_close_removes_the_document() -> void:
	var doc := new_doc("user://a.gd")
	var count := Documents.docs.size()
	close_doc(doc)
	assert_int(Documents.docs.size()).is_equal(count - 1)
	assert_bool(Documents.docs.has(doc)).is_false()

func test_close_makes_the_next_document_active() -> void:
	var first := new_doc("user://a.gd")
	var second := new_doc("user://b.gd")
	Documents.activate(first)
	close_doc(first)
	assert_object(Documents.active).is_equal(second)

func test_close_leaves_a_document_behind() -> void:
	var doc := new_doc("user://a.gd")
	Documents.activate(doc)
	close_doc(doc)
	assert_int(Documents.docs.size()).is_equal(1)
	assert_object(Documents.active).is_not_null()
	assert_object(Documents.active).is_not_equal(doc)

func test_close_can_leave_the_manager_without_an_active_document() -> void:
	var doc := new_doc("user://a.gd")
	Documents.docs.clear()
	Documents.docs.append(doc)
	Documents.activate(doc)
	close_doc(doc, false)
	assert_bool(Documents.docs.is_empty()).is_true()
	assert_object(Documents.active).is_null()

func test_find_by_path_returns_the_open_document() -> void:
	var doc := new_doc("user://a.gd")
	assert_object(Documents.find_by_path("user://a.gd")).is_equal(doc)
	assert_object(Documents.find_by_path("user://missing.gd")).is_null()

func test_reuse_or_create_adds_a_document_when_there_is_no_free_one() -> void:
	var doc := Documents.reuse_or_create()
	assert_object(doc).is_not_null()
	assert_object(doc).is_equal(Documents.active)

func test_reuse_or_create_takes_over_an_empty_placeholder() -> void:
	# A real document that lost its file is the placeholder, its editor is an ordinary one.
	var placeholder := new_doc("user://a.gd")
	placeholder.path = ""
	Documents.activate(placeholder)
	var count := Documents.docs.size()
	assert_object(Documents.reuse_or_create()).is_equal(placeholder)
	assert_int(Documents.docs.size()).is_equal(count)

func test_watch_connects_to_every_document() -> void:
	var doc := new_doc("user://a.gd")
	var callback := func(): test_watch_connects_to_every_document__seen += 1
	Documents.watch(&"type_timer_timeout", callback)
	assert_bool(doc.editor.is_connected(&"type_timer_timeout", callback)).is_true()
	doc.editor.type_timer_timeout.emit()
	assert_int(test_watch_connects_to_every_document__seen).is_equal(1)
