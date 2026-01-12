# Explanation about Text Forge "Data Driven UI"

Text Forge uses a data-driven system for important parts of the UI, including menu options and texts. This architecture makes a dynamic UI and a clean translation system.

## Menus

All data related to menus is stored in `data/main_ui.ini`. This file has a section for menus and a key for each menu (or submenu). Each item is an array of dictionaries and each dictionary has the following structure:

- `"code"` - a unique integer used to connect this option to its action script; its value can be any non-negative int but must be unique.
- `"text"` - english text of option, it will be used for add name to action scripts and call them based on names.
- `"key"` - linked translation key in translation file, menu loader will use it to set item text.
- `"type"` - an integer related to option type, this key can have these values:
  - `-1` - Separator
  - `0` - Regular (this is default value, so items with `0` type haven't `"type"` key)
  - `1` - Submenu
  - `2` - Checkbox
  - `3` - Radio Checkbox

Each key must have a `_menu` or `_submenu` suffix. Items with the `_menu` suffix will load in the main menu, and items with the `_submenu` suffix will load as submenus based on their texts. For example, the `Convert Case` submenu in the `Edit` menu will load from the `convert_case_submenu` key (snake case of submenu text with suffix).
