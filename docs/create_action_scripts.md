# Create action scripts

!!! Note
    Reading [Action Scripts Guide](action_scripts.md) is recommended before creating actions scripts.

## When I should use action scripts?

There is a checklist before selecting action script as your solution:

- I need to add an action that a user can trigger?

    If yes, it **can** be an action script. Users can trigger action scripts via menus, shortcuts, and commands. You can add triggerable actions in other ways, but action scripts are the standard approach for many actions.

- I need to add a new option in menus?

    If yes, it **must** be an action script. Everything in menus is implemented via an action script.

- I need to add a new command?

    If yes, it **may** be an action script. Action scripts have an internal command-definition system, and you can use them from the command palette, but commands can also be defined in modes, panels, extensions, action scripts, and other parts of Text Forge.

## Regular action scripts

There are different types of action scripts based on their base classes. The `ActionScript` class is designed for regular action scripts and can handle many tasks.

To add a new action script, first ensure there is a matching menu item. You can add options (or menus) in `data/main_ui.ini`; see the [Data-driven UI menu structure](https://text-forge.github.io/docs/data_driven_ui/#menus). After selecting your option, create a script in the `action_scripts/` directory with the same name in snake_case. In this example, we will create a **Copy Path** action script to copy the currently opened file path to the clipboard, so we create `action_scripts/copy_path.gd` and start with:

```gdscript
extends ActionScript
```

That’s it for setup. Run the project and confirm the option is enabled. There is no behavior yet, so complete these three steps:

### Add initializing

We don't need special initialization for this action script. We only need to disable when no file exists or when the file hasn’t been saved yet; `ActionScript` already provides this:

```gdscript
extends ActionScript

func _initialize() -> void:
    requires_file = true
    requires_saved_file = true
```

With this function, `ActionScript` disables the option when no saved file exists. For example, after creating a new file, the option stays disabled until the file is saved (because no file path exists yet). When opening an existing file, the option is enabled.

### Add main action

We have initialized the action script, but it still has no behavior, so let’s add it. We do this with `_run_action()`, which runs when the user clicks the menu option, presses the shortcut (added later), or uses the command palette.

```gdscript
extends ActionScript

func _initialize() -> void:
	requires_file = true
	requires_saved_file = true

func _run_action() -> void:
	DisplayServer.clipboard_set(Global.get_file_path())
```

Almost done! The action script logic is complete, and you can try it now. Next, we'll add a shortcut.

### Add shortcut

To add a shortcut, open `data/shortcuts.tres` from Godot’s FileSystem dock and add a new `String: InputEventKey` pair (for example, key `copy_path`). Click **Configure** to set the keybinding, run the project, then open the command palette (`Ctrl+P`) and type `copy path` to confirm the shortcut appears.
