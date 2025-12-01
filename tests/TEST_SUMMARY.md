# Text Forge Unit Tests - Summary

## Overview
This document provides a comprehensive summary of all unit tests generated for the Text Forge
project changes.

## Test Results

- **Overall:** 79 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans
- **Executed test suites:** (9/9)
- **Executed test cases :** (79/79)
- **Total execution time:** 7s 429ms
- **Runner:** GDUnit4 6.0.1

## Test Files

- Unit Tests: 79
- Files: 9

### Action Scripts Tests

- Path: `tests/action_scripts/`
- Tests: 5

|        Test File         | Tests | Lines |        Covers         | Coverage |
|:------------------------:|:-----:|:-----:|:---------------------:|:--------:|
| `action_scripts_test.gd` |   1   |  15   | Class, Loading        | ⭐⭐ |
|      `close_test.gd`     |   4   |  41   | Class, Initialization | ⭐⭐⭐⭐ |

### Autoloads Tests

- Path: `tests/core/autoload/`
- Tests: 11

|           Test File           | Tests | Lines |            Covers            | Coverage |
|:-----------------------------:|:-----:|:-----:|:----------------------------:|:--------:|
|       `factory_test.gd`       |   4   |  44   |         Node creation        | ⭐⭐ |
| `translation_manager_test.gd` |   7   |  47   | Translation, Language change | ⭐⭐⭐⭐ |

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
