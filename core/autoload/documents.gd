class_name DocumentManager
extends Node
## Keeps every open document and the active one.
##
## You can access to this class using [code]Documents[/code] autoload. See [EditorDocument] for
## what a document is.

## All open documents, in tab order. Empty only before [method ensure_bootstrap].
var docs: Array[EditorDocument] = []
## Document user is looking at, [code]null[/code] before [method ensure_bootstrap].
var active: EditorDocument


## Adopts [param original] as the first document. Idempotent for the same editor, so both
## [method GlobalAccess._ready] and [method Core._ready] can call it. When the first call could
## only get a detached editor (main scene was not in tree yet), the second call replaces it.
func ensure_bootstrap(original: Editor) -> void:
	if docs.is_empty():
		docs.append(EditorDocument.new())
	elif docs[0].editor == original or (docs[0].editor and docs[0].editor.is_inside_tree()):
		return
	docs[0].editor = original
	active = docs[0]
