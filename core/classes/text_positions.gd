class_name TextPositions
extends RefCounted
## Maps character offsets of a text to line and column positions.
##
## [TextEdit] turns a line and a column into a character offset, but not the other way around. This
## class holds the start offset of every line of a text, so an offset can be turned back into the
## line and the column it belongs to.

## Start offset of every line of the text.
var _starts: Array[int] = []
## Length of the text.
var _length := 0


## Creates the positions of [param text].
func _init(text: String) -> void:
	_length = text.length()
	_starts.append(0)
	for index in text.length():
		if text[index] == "\n":
			_starts.append(index + 1)


## Returns the line and the column of [param offset] in the text. An offset outside the text
## returns the end of the text.
func position(offset: int) -> Vector2i:
	var clamped := clampi(offset, 0, _length)
	var line := maxi(_starts.bsearch(clamped, false) - 1, 0)
	return Vector2i(line, clamped - _starts[line])
