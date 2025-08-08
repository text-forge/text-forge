# Explanation about Text Forge "Data Driven UI"

Text Forge uses a data driven system for important parts UI, including menu options and texts. This architecture make
a dynamic UI and clean translation system.

## Menus

All data related to menus stored in `data/main_ui.ini`, this file have a section for menus and a key for each menu (or 
submenu). Each item is an array of dictionaries and each dictionary has the following structure:

- `"code"` - a unique integer for connect this option to its action script, its value can be any non-negative int bug must
  be unique.
- `"text"` - english text of option, it will be used for add name to action scripts and call them based on names.
- `"key"` - linked translation key in translation file, menu loader will use it to set item text.
- `"type"` - an integer related to option type, this key can have these values:
  - `-1` - Separator
  - `0` - Regular (this is default value, so items with `0` type haven't `"type"` key)
  - `1` - Submenu
  - `2` - Checkbox
  - `3` - Radio Checkbox

Each key must have `_menu` or `_submenu` suffix, items with `_menu` suffix will load in main menu and items with `_submenu`
suffix will load as submenus based on texts, for example `Convert Case` submenu in `Edit` menu will load from `convert_case_submenu`
key (snake case of submenu text with suffix).

## Panels

To handle panels, we have `data/panels/` folder. Here, each panel have a folder with icon, configuration file, and scene.
In config file, we have place of panel (`R`, `L`, or `B`). Panel manager will load panels from here based on configuration
file and stored files.