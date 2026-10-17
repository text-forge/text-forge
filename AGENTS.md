# AGENTS.md

Text Forge — an extensible, modular code editor built with **Godot 4.5** (GDScript).

## Verification

Tests use **gdUnit4** (addon enabled in `project.godot`). No CI workflow runs tests, so
verify locally before handing off. Run suites from the gdUnit4 panel in the Godot editor,
or headless from the CLI:

```bash
export GODOT_BIN=/path/to/godot
./addons/gdUnit4/runtest.sh -a res://tests/                              # all suites (~33s)
./addons/gdUnit4/runtest.sh -a res://tests/core/autoload/utils_test.gd   # one suite
```

- Headless requires `--ignoreHeadlessMode`; UI/interaction tests only work in the editor.
- `-a <dir>` adds a whole tree; there is no per-test-case flag — select one case in the editor.

Exports: two presets, **`Windows Desktop`** and **`Linux`** (`export_presets.cfg`). Release is
tag-driven and produces a **draft** GitHub release using Godot 4.5-stable.

## Architecture (not obvious from filenames)

- **12 autoloads** are declared in `project.godot`. The **autoload name differs from the
  `class_name`** (e.g. `Signals`→`SignalBus`, `U`→`Utils`, `Notif`→`NotificationManager`,
  `Factory`→`NodeFactory`). Use the autoload name to call a singleton, the `class_name` for type hints.
- **SignalBus** (`core/autoload/signals.gd`): every cross-module signal is declared here.
  Emit via `Signals.<name>.emit(...)`, connect in `_ready()`. Key pattern: `run_script.emit(id)`
  broadcasts to *all* ActionScripts and each self-filters by its own id. Extensions must **not**
  touch `Signals` — they use `ExtensionHub` ports/docks.
- **`S`** (`core/classes/static.gd`, `class_name S`, not an autoload) holds every path template
  (`S.TEMPLATE_PANEL_SCENE`, `S.FOLDER_MODES`, …). Never hardcode a project path — `.format()` these.
- **Data-driven registration** — add files, not code:
  - Panels: `core/panels/<name>/{panel.tscn, panel.gd, icon.png}` (auto-discovered, threaded load).
  - Menus: `data/main_ui.ini`; a menu item's script path is derived from its **text** →
    `action_scripts/<snake_case>.gd`. If that file is missing the item is disabled.
  - Modes: `user://modes/<id>/` folders; a `.tfmode` is a zip with a `modes/` prefix.
- **Factory** (`Factory`): builder functions returning configured nodes (dialogs, inputs, `simple_panel`).
  It does not add nodes — the caller `add_child`s. Dialogs self-free when hidden.

## Conventions

- **Tabs** for indentation; **LF** line endings (`.gitattributes` enforces `eol=lf`).
- GDScript style: follow the official GDScript Style Guide. Static typing throughout — `-> void`,
  `:=`, typed dictionaries/arrays.
- Every `core/**/*.gd`: `class_name` on line 1, `extends` on line 2, `##` class doc from line 3.
- Doc comments are `##` with BBCode (`[method]`, `[signal]`, `[param]`, `[member]`, `[code]`).
- Load resources with `U.load_resource(path)` (returns `null` when missing), **not** `preload`;
  batch with `U.load_resources_threaded`. Only one `preload` exists in core, deliberately.
- User-facing errors go through `Notif.notif("<registered_id>", {...})` — register the id in
  `_init`/`_ready` first. Do not use bare `print`/`push_error` for user-facing messages.
- Action scripts: filename = snake_case of the menu text, `extends ActionScript`, no `class_name`.

## Gotchas

- **Pre-1.0** (`config/version = "0.3"`): releases may break compatibility; after upgrades the app
  data folder (`user://`) may need deleting. Read release notes for breaking changes.
- Only `en`, `fa`, `pl` are registered translations in `project.godot` (`cs`, `lo` exist but are
  inactive). Translation is managed on Hosted Weblate, with no in-repo sync script.
- The **`Tests` autoload** (`core/autoload/tests.gd`) is a runtime *performance* harness — it is
  **not** the gdUnit4 unit-test runner. Don't confuse the two.
- Release prep is acceptable: bump `config/version` in `project.godot` and add the `CHANGELOG.md`
  entry as one change. Don't tag/publish on your own.
