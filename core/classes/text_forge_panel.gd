class_name TextForgePanel
extends Control
## Base class for panels.
##
## [b]Note:[/b] [member place] must be set before using [method PanelManager.add_panel].

## Keeps index of this panel in loaded side, useful for show requests.
var index: int
## Keeps place of this panel, useful for show requests.
var place := PanelManager.Panels.LEFT
