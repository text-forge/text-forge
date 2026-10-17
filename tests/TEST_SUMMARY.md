# Text Forge Unit Tests - Summary

## Overview
This document provides a comprehensive summary of all unit tests generated for the Text Forge
project changes.

## Test Results

- **Overall:** 430 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans (6/6 🟢)
- **Executed test suites:** (30/30)
- **Executed test cases :** (430/430)
- **Total execution time:** 27s 600ms
- **Runner:** GDUnit4 6.2.2

## Test Files

- Unit Tests: 430
- Files: 30

### Action Scripts Tests

- Path: `tests/action_scripts/`
- Tests: 112

|        Test File         | Tests | Lines |        Covers                 | Coverage |
|:------------------------:|:-----:|:-----:|:-----------------------------:|:--------:|
| `action_scripts` |   15  |  96   | Class, Loading, Functionality | ⭐⭐⭐⭐ |
|      `close`     |   4   |  41   |     Class, Initialization     | ⭐⭐⭐⭐ |
| `normalize_line_endings` | 9 | 85  | Setup, Behavior | ⭐⭐⭐ |
| `remove_trailing_whitespaces` | 15 | 139 | Setup, Behavior | ⭐⭐⭐⭐ |
| `use_crlf` | 12 | 87 | Setup, Behavior | ⭐⭐⭐⭐ |
| `use_cr` | 12 | 88 | Setup, Behavior | ⭐⭐⭐⭐ |
| `use_lf` | 12 | 89 | Setup, Behavior | ⭐⭐⭐⭐ |
| `scenes/marketplace` | 5 |  100  |        Dynamic reload         | ⭐ |
| `scenes/preferences` | 9 |  94   |    Initialization, Behavior   | ⭐⭐⭐ |
| `scenes/setting_option` | 19 | 209 | Initialization, Type check, Behavior, Signals | ⭐⭐⭐⭐⭐ |

### Autoloads Tests

- Path: `tests/core/autoload/`
- Tests: 109

|           Test File           | Tests | Lines |                         Covers                          | Coverage |
|:-----------------------------:|:-----:|:-----:|:-------------------------------------------------------:|:--------:|
|     `backup_core`     |   14  |  87   |          Creation, Restoration, Configuration           | ⭐⭐⭐⭐⭐ |
|       `factory`       |   2   |  44   |                      Node creation                      | ⭐⭐ |
|       `global`        |   26  |  140  |    Access, File management, Commands, Notifications     | ⭐⭐⭐⭐⭐ |
| `notification_manager`|   10  |  97   |    Registry, Emit overrides, Formatting, Settings gate  | ⭐⭐⭐⭐ |
|       `project`       |   5   |  34   |              Recent projects, Cleanup                   | ⭐⭐⭐ |
|       `settings`      |   29  |  270  |    Configuration management, Presets, Data storage      | ⭐⭐⭐⭐⭐ |
|       `signals`       |   2   |  84   |                  Signal bus surface                     | ⭐⭐⭐ |
|        `utils`        |   21  |  107  | Syntax colors, Wait, Resource loading, Threaded loading | ⭐⭐⭐⭐ |

### Classes Tests

- Path: `tests/core/classes/`
- Tests: 43

|           Test File           | Tests | Lines |                         Covers                          | Coverage |
|:-----------------------------:|:-----:|:-----:|:-------------------------------------------------------:|:--------:|
| `action_script_extension/checkable_action_script` | 38 | 451 | Initialization, Behavior, Edge cases | ⭐⭐⭐⭐⭐ |
|        `static`       |   5   |  31   |              Recent files/projects cleanup              | ⭐⭐⭐ |

### Scripts Tests

- Path: `tests/core/scripts/`
- Tests: 14

|           Test File           | Tests | Lines |                         Covers                          | Coverage |
|:-----------------------------:|:-----:|:-----:|:-------------------------------------------------------:|:--------:|
| `line_endings_label` | 14 | 128 | Initialization, Update | ⭐⭐⭐⭐⭐ |

### Core Tests

- Path: `tests/core/`
- Tests: 91

|           Test File           | Tests | Lines |                Covers                 | Coverage |
|:-----------------------------:|:-----:|:-----:|:-------------------------------------:|:--------:|
| `editor_api_hooks` | 18 | 141 | Behavior | ⭐⭐⭐ |
|     `editor_api`      |   3   |  31   |           Class, Bookmarks            | ⭐ |
|       `editor`        |   25  |  207  | Type timer, Gutter, Utility functions | ⭐⭐⭐⭐⭐ |
| `main` | 19 | 171 | UIFilter, Theme | ⭐ |
| `shader_validation` | 15 | 139 | File, Members, Validation | ⭐⭐⭐⭐⭐ |
| `ui_filter_integration` | 11 | 180 | Shader Update | ⭐⭐⭐⭐ |

### Panels Tests

- Path: `tests/core/panels/`
- Tests: 34

|           Test File            | Tests | Lines |                Covers                 | Coverage |
|:------------------------------:|:-----:|:-----:|:-------------------------------------:|:--------:|
| `bookmarks/item_panel` |   20  |  150  |       Initialization, Updating        | ⭐⭐⭐⭐ |
|    `bookmarks/panel`   |   14  |  87   |       Initialization, Structure       | ⭐⭐⭐⭐ |

### Docs Tests

- Path: `tests/docs/`
- Tests: 27

|           Test File            | Tests | Lines |                Covers                 | Coverage |
|:------------------------------:|:-----:|:-----:|:-------------------------------------:|:--------:|
| `changelog_validation` |   27  |  326  | Existence, Structure, Formats, Links  | ⭐⭐⭐⭐⭐ |