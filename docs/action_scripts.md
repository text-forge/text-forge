# Action Scripts in Text Forge

Action Scripts are a way to separate and manage possible actions in the Text Forge, helping them keep dozens of different capabilities separately and safely and add new capabilities in the shortest time.

## Design goals

- Modularity: Each action script is an independent unit with a specified output and input, almost all Action Scripts are detachable from the editor without making an error in its performance
- Development: Developers can design new capabilities through simple Action Script APIs 
- Accessibility: Action Scripts are easily accessible through menus, code, command palette, and shortcuts

## Structure

An action script must extend `ActionScript` or `MultiActionScript` class or another class that extends one of these classes. Each action script should be stored in `action_scripts/` directory and have snake_case file name of an option english name in menus. For example if we have a `Save As...` option in `File` menu, editor will load `action_scripts/save_as.gd` as its action script (will remove dots) and otherwise this action script will not be loaded.

Also, action scripts can have a shortcut in `data/shortcuts.tres` resource file with same name as key. Value should be a `InputEventKey` resource. Loading shortcut will be done by `ShortcutMap` and `ActionScript` class.

All loaded action script will be children nodes of `Scripts` node in core, you can use `Global.get_scripts_node()` to access to it.

Each action script should override base class `Virtual` functions, you can see them in docstrings. There is a list of virtual functions of regular `ActionScript`:
- `_initialize()`: For action script initializing
- `_run_action()`: Main part of action script

## Features

### Access to menu option

Each action script have an item in menus, this item is accessible with `menu` and `index` property of action script. For checkbox and radio-checkbox options, editor will handle checking state itself.

### Automated shortcut loading

`ActionScript` and `MultiActionScript` class will load shortcuts from `data/shortcuts.tres` resource and call required functions in shortcut pressing.

### Define commands

An action script will define itself as a command for command palette, so command palettes can list action scripts for user and run them based on selections. If an action script has shortcut, it will add that shortcut in commands database so users can see shortcuts in command palette.

### Automated enabling / disabling

The `requires_file` and `requires_saved_file` properties can make action scripts smarter. Most action scripts should only be available when a file is open, so setting `requires_file = true` disables them otherwise automatically.

## Create new action scripts

To add new action scripts (or edit existing one) see [here](create_action_scripts.md).
