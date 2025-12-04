# Text Forge Unit Tests - Summary

## Overview
This document provides a comprehensive summary of all unit tests generated for the Text Forge
project changes.

## Test Results

- **Overall:** 263 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans (6/6 🟢)
- **Executed test suites:** (19/19)
- **Executed test cases :** (263/263)
- **Total execution time:** 21s 817ms
- **Runner:** GDUnit4 6.0.1

## Test Files

- Unit Tests: 263
- Files: 19

### Action Scripts Tests

- Path: `tests/action_scripts/`
- Tests: 52

|        Test File         | Tests | Lines |        Covers                 | Coverage |
|:------------------------:|:-----:|:-----:|:-----------------------------:|:--------:|
| `action_scripts_test.gd` |   15  |  96   | Class, Loading, Functionality | ⭐⭐⭐⭐ |
|      `close_test.gd`     |   4   |  41   |     Class, Initialization     | ⭐⭐⭐⭐ |
| `scenes/marketplace_test.gd` | 5 |  100  |        Dynamic reload         | ⭐ |
| `scenes/preferences_test.gd` | 9 |  94   |    Initialization, Behavior   | ⭐⭐⭐ |
| `scenes/setting_option_test.gd` | 19 | 209 | Initialization, Type check, Behavior, Signals | ⭐⭐⭐⭐⭐ |

### Autoloads Tests

- Path: `tests/core/autoload/`
- Tests: 103

|           Test File           | Tests | Lines |                         Covers                          | Coverage |
|:-----------------------------:|:-----:|:-----:|:-------------------------------------------------------:|:--------:|
|     `backup_core_test.gd`     |   14  |  87   |          Creation, Restoration, Configuration           | ⭐⭐⭐⭐⭐ |
|       `factory_test.gd`       |   4   |  44   |                      Node creation                      | ⭐⭐ |
|       `global_test.gd`        |   26  |  140  |    Access, File management, Commands, Notifications     | ⭐⭐⭐⭐⭐ |
|       `settings_test.gd`      |   31  |  270  |    Configuration management, Presets, Data storage      | ⭐⭐⭐⭐⭐ |
| `translation_manager_test.gd` |   7   |  47   |              Translation, Language change               | ⭐⭐⭐⭐ |
|        `utils_test.gd`        |   21  |  107  | Syntax colors, Wait, Resource loading, Threaded loading | ⭐⭐⭐⭐ |

### Core Tests

- Path: `tests/core/`
- Tests: 28

|           Test File           | Tests | Lines |                Covers                 | Coverage |
|:-----------------------------:|:-----:|:-----:|:-------------------------------------:|:--------:|
|     `editor_api_test.gd`      |   3   |  31   |           Class, Bookmarks            | ⭐ |
|       `editor_test.gd`        |   25  |  207  | Type timer, Gutter, Utility functions | ⭐⭐⭐⭐⭐ |

### Data Tests

- Path: `tests/data/`
- Tests: 1

|           Test File           | Tests | Lines |                Covers                 | Coverage |
|:-----------------------------:|:-----:|:-----:|:-------------------------------------:|:--------:|
|   `translation_data_test.gd`  |   1   |   16  |           Language coverage           | ⭐⭐⭐⭐ |

### Panels Tests

- Path: `tests/data/panels/`
- Tests: 34

|           Test File            | Tests | Lines |                Covers                 | Coverage |
|:------------------------------:|:-----:|:-----:|:-------------------------------------:|:--------:|
| `bookmarks/item_panel_test.gd` |   20  |  150  |       Initialization, Updating        | ⭐⭐⭐⭐ |
|    `bookmarks/panel_test.gd`   |   14  |  87   |       Initialization, Structure       | ⭐⭐⭐⭐ |
