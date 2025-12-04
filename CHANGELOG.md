# Changelog

All notable changes to this project will be documented in this file. (Notable changes means some internal changes may not be here!)

The format is based on [Keep a Changelog (1.1)](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning (2.0)](https://semver.org/spec/v2.0.0.html).

## [unreleased]

### Added
- Mode-driven indentation settings ([#136](https://github.com/text-forge/text-forge/pull/136))
- Bookmarks support and bookmarks panel ([#137](https://github.com/text-forge/text-forge/pull/137))
- **Action Script:** Edit > Evaluate Selection - Evaluates mathematical expressions in selected text ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `Global.mark_file_as_unsaved()` - Marks current file as having unsaved changes ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `Global.has_file()` - Checks if a valid file is currently open ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `backup_failed(was_auto: bool)` signal in BackupCore for backup failure notifications ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `extensions_loaded` signal in Extensions autoload ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `indentation_settings_updated(use_space, indent_size)` signal in EditorAPI ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** Per-mode indentation override support with `EditorAPI.custom_mode_indentations` ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `EditorAPI.reset_to_mode_indentation_settings()` ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `EditorAPI.change_indentation_type(use_spaces)` ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** `EditorAPI.change_indent_size(indent_size)` ([#139](https://github.com/text-forge/text-forge/pull/139))
- Class name declarations to ~40+ files for better type safety ([#139](https://github.com/text-forge/text-forge/pull/139))
- Security validation for plugin/mod file extraction (prevents path traversal attacks) ([#139](https://github.com/text-forge/text-forge/pull/139))
- Auto text writing direction for editor ([#144](https://github.com/text-forge/text-forge/pull/144))
- UI Filter for editor ([#145](https://github.com/text-forge/text-forge/pull/145))
- Enhanced dynamic reload for settings ([#145](https://github.com/text-forge/text-forge/pull/145))

### Changed
- **Action Script:** ~Command > Command Pallete~ to Command > Command Palette (renamed, improved search) ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** ~`Settings.config`~ to `Settings.data` (merged settings loading) ([#139](https://github.com/text-forge/text-forge/pull/139))
- **API:** Extension config keys corrected: `on_activate`, `on_deactivate`, `uninstall` ([#139](https://github.com/text-forge/text-forge/pull/139))
- Backup system ID generation now timestamp-based with random suffix ([#139](https://github.com/text-forge/text-forge/pull/139))
- Unsaved file detection now uses `Global.has_unsaved_change()` instead of filename checks ([#139](https://github.com/text-forge/text-forge/pull/139))

### Removed
- **API:** ~`FileDatabase`~ class - Use direct path references instead ([#139](https://github.com/text-forge/text-forge/pull/112))

### Fixed
- Changelog is not displayed in editor ([#133](https://github.com/text-forge/text-forge/pull/133))
- **Action Script:** Move Lines to New File incorrect behavior ([#139](https://github.com/text-forge/text-forge/pull/92))
- **Action Script:** Reset Font Size not loading configuration properly ([#139](https://github.com/text-forge/text-forge/pull/93))
- **Action Script:** Toggle Bookmark incorrectly marking files as unsaved ([#139](https://github.com/text-forge/text-forge/pull/102))
- **Action Script:** Toggle Comment delimiter detection and multi-caret handling ([#139](https://github.com/text-forge/text-forge/pull/139))
- **Action Script:** Restart error handling with process creation validation ([#139](https://github.com/text-forge/text-forge/pull/139))
- Backup system: Restored backup saving functionality ([#139](https://github.com/text-forge/text-forge/pull/54), [#139](https://github.com/text-forge/text-forge/pull/59))
- Backup system: BackupStatus color updates on failure ([#139](https://github.com/text-forge/text-forge/pull/70), [#139](https://github.com/text-forge/text-forge/pull/71))
- Backup system: Infinite save_request cycles ([#139](https://github.com/text-forge/text-forge/pull/73))
- Backup system: Fixed `auto_backup_interval_minutes` setting name (was misspelled) ([#139](https://github.com/text-forge/text-forge/pull/139))
- Internal modes no longer reinstall on every application run ([#139](https://github.com/text-forge/text-forge/pull/3))
- Asset filename: ~`loafing.png`~ to `loading.png` ([#139](https://github.com/text-forge/text-forge/pull/26))
- Unit test execution errors and disabled custom tests during test runs ([#139](https://github.com/text-forge/text-forge/pull/107), [#139](https://github.com/text-forge/text-forge/pull/109))
- File selection dialog filters improved across multiple scenes ([#139](https://github.com/text-forge/text-forge/pull/139))
- Action scripts loading broken due to incorrect path globalization in `core/main.gd` ([#143](https://github.com/text-forge/text-forge/pull/143))

## [v0.2-rc1] - 2025-11-20

### Added
- Template system ([#117](https://github.com/text-forge/text-forge/pull/117))
- Synchronized preview scrolling with the editor’s vertical scroll ([#124](https://github.com/text-forge/text-forge/pull/124))

### Fixed
- Empty *Mode Viewer* popup menu at startup ([#116](https://github.com/text-forge/text-forge/pull/116))
- Panel status is not restored after startup ([#119](https://github.com/text-forge/text-forge/pull/119))

## [v0.2-beta2] - 2025-10-9

### Added
- Higher priority for main action scripts loading ([#112](https://github.com/text-forge/text-forge/pull/112))
- Syntax highlighting colors by themes ([#113](https://github.com/text-forge/text-forge/pull/113))
- Support custom preview formats ([#115](https://github.com/text-forge/text-forge/pull/115))

## [v0.2-beta1] - 2025-9-25

### Added
- Caret position button ([#96](https://github.com/text-forge/text-forge/pull/96))
- Add Project module (TFPM): .tfproj support, Project menu, Files panel and Recent Projects ([#95](https://github.com/text-forge/text-forge/pull/95))
- Theme support ([#100](https://github.com/text-forge/text-forge/pull/100))
- **API:** `NetSuite` autoload ([#105](https://github.com/text-forge/text-forge/pull/105))
- Marketplace ([#106](https://github.com/text-forge/text-forge/pull/106))

### Fixed
- Preserve editor scroll when text is updated programmatically when `keep_carets` is true ([#101](https://github.com/text-forge/text-forge/pull/101))
- Error when multiple save requests sent at same time ([#102](https://github.com/text-forge/text-forge/pull/102))
- Restore panel open state ([#103](https://github.com/text-forge/text-forge/pull/103))

## [v0.1-stable] - 2025-8-30 & [v0.1-rc2] - 2025-8-26

> [!Note]
> Because of a versioning mistake changelog of these versions is mixed.

### Added
- Open with handling ([#82](https://github.com/text-forge/text-forge/pull/82))
- Backup system ([#92](https://github.com/text-forge/text-forge/pull/92))
- Threaded action script loading ([#93](https://github.com/text-forge/text-forge/pull/93))
- Big performance improve ([#93](https://github.com/text-forge/text-forge/pull/93))

### Fixed
- Error for multiple available modes selection ([#93](https://github.com/text-forge/text-forge/pull/93))

## [v0.1-rc1] - 2025-8-19

### Added

- Highlight matched query segments in command palette ([#72](https://github.com/text-forge/text-forge/pull/72)) 
- Refactor open file action to use NodeFactory ([#73](https://github.com/text-forge/text-forge/pull/73))
- **API:** `Global.get_last_file_path()` ([#75](https://github.com/text-forge/text-forge/pull/75))
- **API:** `current_dir` and `current_path` in `Factory.file_dialog()` ([#75](https://github.com/text-forge/text-forge/pull/75))
- Default directory for export extensions (System documents directory) ([#75](https://github.com/text-forge/text-forge/pull/75))
- Default directory for import extensions (System downloads directory) ([#75](https://github.com/text-forge/text-forge/pull/75))
- Default directory for import modes / packages (System downloads directory) ([#75](https://github.com/text-forge/text-forge/pull/75))
- Default directory for export modes / packages (System documents directory) ([#75](https://github.com/text-forge/text-forge/pull/75))
- Automaticaly navigating to last opened file in "Open" file dialog ([#75](https://github.com/text-forge/text-forge/pull/75))
- Automaticaly navigating to current saved file in "Save As" file dialog ([#75](https://github.com/text-forge/text-forge/pull/75))
- Automaticaly load last opened file at start ([#77](https://github.com/text-forge/text-forge/pull/77))
- Scrolling for preferences tabs ([#78](https://github.com/text-forge/text-forge/pull/78))
- polski translation `PL` ([#84](https://github.com/text-forge/text-forge/pull/84))
- Added Change Log tab to About panel ([#83](https://github.com/text-forge/text-forge/pull/83))
- **Action Script:** More option state check for Format > Auto Format ([#71](https://github.com/text-forge/text-forge/pull/71))
- **Action Script:** Edit > Indention > Auto Indent ([#71](https://github.com/text-forge/text-forge/pull/71))
- **Action Script:** Edit > Completion Query ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Global.damaged_modes` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Global.temprory_children` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Signals.mode_changed` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Signals.preview_updated` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Signals.problems_updated` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Signals.ouline_updated` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `ActionScript._check_option_extra` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `TextForgeMode` class ([#71](https://github.com/text-forge/text-forge/pull/71))
- Comment delimiters by modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- String delimiters by modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- Optional mode panel ([#71](https://github.com/text-forge/text-forge/pull/71))
- Feature enable/disabling for modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- Initialization for modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- Auto indent feature by modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- Code completion by modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- Preview generation by mode ([#71](https://github.com/text-forge/text-forge/pull/71))
- File outline by modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- Linting and problems by modes ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `TextForgePanel` class ([#71](https://github.com/text-forge/text-forge/pull/71))
- Type timer for editor ([#71](https://github.com/text-forge/text-forge/pull/71))
- Mode viewer ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `TextForgePanel.index` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `TextForgePanel.place` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `PanelManager.remove_panel` ([#71](https://github.com/text-forge/text-forge/pull/71))
- Problem counter ([#71](https://github.com/text-forge/text-forge/pull/71))
- Outline panel ([#71](https://github.com/text-forge/text-forge/pull/71))
- Preview panel ([#71](https://github.com/text-forge/text-forge/pull/71))
- Problems panel ([#71](https://github.com/text-forge/text-forge/pull/71))
- Test mode script ([#71](https://github.com/text-forge/text-forge/pull/71))
- Export all mode files from mode manager export option ([#71](https://github.com/text-forge/text-forge/pull/71))
- **Docs:** `mode_development.md` ([#71](https://github.com/text-forge/text-forge/pull/71))
- Close mode manager after `edit script` option pressing ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Factory.simple_panel` ([#71](https://github.com/text-forge/text-forge/pull/71))

### Changed

- ~Editor / Auto Indention~ to Edit / Auto Indention in settings ([#76](https://github.com/text-forge/text-forge/pull/76))
- Modes syntax highlighting logic ([#71](https://github.com/text-forge/text-forge/pull/71))
- ~File based save/load~ to Buffer based save/load ([#71](https://github.com/text-forge/text-forge/pull/71))
- Complete refactor for **EditorAPI** ([#71](https://github.com/text-forge/text-forge/pull/71))
- Load main editor settings in Core instead of EditorAPI ([#71](https://github.com/text-forge/text-forge/pull/71))
- Mode Packages renamed to Mode Kits ([#71](https://github.com/text-forge/text-forge/pull/71))

### Removed

- **API:** `Signals.caret_selected` ([#71](https://github.com/text-forge/text-forge/pull/71))
- **API:** `Signals.mode_selected` ([#71](https://github.com/text-forge/text-forge/pull/71))

### Fixed

- Missing `queue_free()` call for standard file dialogs ([#75](https://github.com/text-forge/text-forge/pull/75), ([#80](https://github.com/text-forge/text-forge/pull/80)))
- **Action Script:** Safer disabling for View > Show Fold Gutter ([#79](https://github.com/text-forge/text-forge/pull/79))
- Wrong value for left panel node ([#81](https://github.com/text-forge/text-forge/pull/81))
- More type check in panel manager ([#71](https://github.com/text-forge/text-forge/pull/71))
- Wrong error for bug in panels ([#71](https://github.com/text-forge/text-forge/pull/71))
- Fixed size for panel icons ([#71](https://github.com/text-forge/text-forge/pull/71))
- Missing icon changes for notification panel ([#71](https://github.com/text-forge/text-forge/pull/71))

## [v0.1-beta] - 2025-7-27

### Added

- Help menu ([ocb31a3](), [5c2a778...a5a4cc0]())
- Panel Support ([#65](https://github.com/text-forge/text-forge/pull/65))
- **API:** `Signals.notification` ([8a6e3df]())
- Notifications System ([41079b2]())
- Notifications Panel ([#67](https://github.com/text-forge/text-forge/pull/67))
- Max FPS: 60 ([3e60689]())
- Max log files: 200 ([6bcadce]())
- **API:** `ExtensionHub` ([6dfb260]())
- Translation System ([#69](https://github.com/text-forge/text-forge/pull/69))
- **API:** `Settings` ([8a90c47]())
- **Language:** Persian ([08f71ac]())
- **Action Script:** Format > Remove All Indents ([7243b7a]())
- **Action Script:** Edit > Evaluate Selection ([ba5d1ce]())
- Font size changing ([fe826a3]())
- **Action Script:** View > Show Breakpoints ([1acfb47]())
- **Action Script:** View > Show Bookmarks ([021f239]())
- **Action Script:** View > Show Line Numbers ([260fe5f]())
- Find and Replace ([2152dc8]())
- New shortcuts ([0d4a12f...b390c84]())
- Drag and drop to open files ([454ca49]())
- **Action Script:** View > Line Length Guides ([582b3fa]())
- **Action Script:** View > Full Screen ([64facc8]())
- Preferences ([2a74a0e]())
- **Action Script:** Tools > Color Picker ([5c455a1]())
- **Action Script:** File > New Window ([7244e28]())
- **Action Script:** File > Restart ([00836f2]())
- Boot splash picture ([ff51476]())
- **Action Script:** Command > Command Palette ([2b91d2a]())
- Mode Manager ([b39f78b]())
- In-repo documentation (see [here](https://text-forge.github.io/docs) for online version) ([59e6305]())
- **API:** `CaseActionScript` class ([367e904]())
- Auto brace completion ([ea3a6dd]())
- Highlight brace matching ([ea3a6dd]())
- **API:** Data reader/writer for custom data ([b0a56a1]())
- Extension Support ([#70](https://github.com/text-forge/text-forge/pull/70))
- **Action Script:** View > Highlight Current Line ([cd8989c]())
- **Action Script:** View > Highlight All Occurrences ([b994286]())
- **API:** `CheckableActionScript` class ([3c560e1]())
- **Action Script:** View > Block Type Caret ([1b02f9a]())
- **Action Script:** View > Show Minimap ([43c58c6]())
- **Action Script:** View > Show Fold Gutter ([0264d7c]())
- **Action Script:** View > Show Control Characters ([4120b19]())
- **Action Script:** View > Show Spaces ([4120b19]())
- **Action Script:** View > Show Tabs ([4120b19]())
- Module Profiler ([0e8877b]())
- **API:** `Editor.is_selection_in_line()` ([8a3cee0]())
- **Action Script:** Format > Auto Indention ([b721689]())

### Changed

- **API:** ~`Signals.script_run`~ to `Signals.run_script` ([2d83e19]())
- **API:** ~`Global.get_main_node()`~ to `Global.get_core()` ([66d94cf]())
- **Shortcut:** Auto Format ~`Ctrl+Alt+F`~ to `Ctrl+Shift+F` ([1fb81c3]())
- **Action Script:** ~Edit > Auto Format~ to Format > Auto Format ([471caed]())
- **Action Script:** ~Command > Remove All Indents~ to Format > Remove All Indents ([471caed]())
- **Shortcut:** Duplicate Selection ~`Ctrl+Shift+D`~ to `Ctrl+D` ([000cae5]())
- Move modes to user data folder ([38c56a2]())
- **Action Script:** ~Tools > Extensions~ to Tools > By Extensions ([d9a4517]())
- Limit *Convert Indent To Spaces* to selected lines ([a5c1b7e]())
- Limit *Convert Indent To Tabs* to selected lines ([147d8f1]())

### Removed

- **API:** ~`ActionScript.main_window`~ ([168a27a]())
- Old highlighter ([bb15981]())

### Fixed

- Fix call `_update_recent_files` from scripts ([8c8ce45]())
- **API:** Missing connections for checkbox and radio checkbox action scripts ([fa06a69]())
- **API:** `has_saved_file` issues in `ActionScript` ([7045905]())
- Few `Signals.check_options` emissions (for update action scripts) ([761722b]())
- `is_outside_tree` in `Global.get_core()` ([6108b64]())

## [v0.1-dev1] - 2025-06-30

### Added

- Core for handle modules.
- EditorAPI to handle modes.
- Action Script support.
- File based shortcut system.
- Data-driven UI.
- Docs in 4 languages (en, fa, es, zh)

[unreleased]: https://github.com/text-forge/text-forge/compare/v0.2.0-rc1...HEAD
[v0.2-rc1]: https://github.com/text-forge/text-forge/releases/tag/v0.2.0-rc1
[v0.2-beta2]: https://github.com/text-forge/text-forge/releases/tag/v0.2.0-beta2
[v0.2-beta1]: https://github.com/text-forge/text-forge/releases/tag/v0.2.0-beta1
[v0.1-stable]: https://github.com/text-forge/text-forge/releases/tag/v0.1.0-stable
[v0.1-rc2]: https://github.com/text-forge/text-forge/releases/tag/v0.1.0-rc2
[v0.1-rc1]: https://github.com/text-forge/text-forge/releases/tag/v0.1.0-rc1
[v0.1-beta]: https://github.com/text-forge/text-forge/releases/tag/v0.1.0-beta
[v0.1-dev1]: https://github.com/text-forge/text-forge/releases/tag/v0.1.0-dev1
