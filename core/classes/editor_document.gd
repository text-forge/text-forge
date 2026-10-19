class_name EditorDocument
extends RefCounted
## One open file in Text Forge and its text-indepented state.
##
## The [member editor] node keeps text, undo stack, carets, bookmarks and folding, so this class
## only keeps what must survive switching or closing. See [DocumentManager] for open documents.

## [Editor] node of this document, it is the page of this document in tab container.
var editor: Editor
## Absolute file path, [code]"Unsaved"[/code] or [code]""[/code] while this document has no file on
## disk.
var path := "Unsaved"
## Base of this document tab title. See [method DocumentManager.ensure_bootstrap].
var display_name := "New file"
## [code]true[/code] when this document has unsaved change (its tab title gets a [code]*[/code]).
var dirty := false
## TextForgeMode [code]data[/code] of this document, empty [Dictionary] means plain text.
var mode: Dictionary = {}
## Navigation marks of this document as [code]{line: int, label: String}[/code]. Session only.
var marks: Array[Dictionary] = []
## Caret position, written when this document stops being active.
var caret := Vector2i.ZERO
## Scroll offsets, written when this document stops being active.
var scroll := Vector2i.ZERO
