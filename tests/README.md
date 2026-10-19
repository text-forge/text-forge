# Text Forge Unit Tests

Tests use [b]gdUnit4[/b] (`addons/gdUnit4`). Suites live in `tests/`, mirroring the `core/` and
`action_scripts/` layout of the code they cover.

## Running

```bash
export GODOT_BIN=/path/to/godot
./addons/gdUnit4/runtest.sh -a res://tests/                              # all suites (~25s)
./addons/gdUnit4/runtest.sh -a res://tests/core/autoload/utils_test.gd   # one suite
```

Headless runs need `--ignoreHeadlessMode`. UI/interaction suites only pass in the editor, so run
those from the gdUnit4 panel. There is no per-test-case flag — select a single case in the panel.

## Current numbers

Measured from `reports/report_1/results.xml` (run 2026-10-19, GDUnit4 6.2.2):

| Metric | Value |
|---|---|
| Suites | 30 |
| Test cases | 442 |
| Failures | 0 |
| Errors | 0 |
| Execution time | 29s |

Per directory:

| Directory | Tests | Suites |
|---|---|---|
| `tests/action_scripts/` (incl. `scenes/`) | 112 | 10 |
| `tests/core/` (root) | 91 | 6 |
| `tests/core/autoload/` | 121 | 8 |
| `tests/core/classes/` (incl. `action_script_extension/`) | 43 | 2 |
| `tests/core/panels/bookmarks/` | 34 | 2 |
| `tests/core/scripts/` | 14 | 1 |
| `tests/docs/` | 27 | 1 |

**Do not hand-maintain these numbers.** They come from the runner; re-read `results.xml` after a
run instead of editing the table. This file is the only tests overview — there is no separate
index or summary file to keep in sync.

**Known gap:** `tests/core/autoload/factory_test.gd` (2 cases) did not run in the 2026-10-19
report. It declares `class_name NodeFactoryTest`; check why the runner skips it before trusting
the totals above as complete.

## Writing tests

- One test per behaviour, descriptive names, Arrange–Act–Assert, no cross-test dependencies.
- Use `auto_free()` for nodes created in a test, and specific assertion types for clear messages.
- Don't use local variables inside lambdas — store on the suite as `test_<name>__<var>`:

```gdscript
var test_complete_ui_filter_workflow__signal_emitted := false

func test_complete_ui_filter_workflow() -> void:
	var connection := func(): test_complete_ui_filter_workflow__signal_emitted = true
	Signals.settings_changed.connect(connection)

	Settings.set_setting(test_section, "filter_hue_shift", 0.5)
	await get_tree().process_frame
	assert_bool(test_complete_ui_filter_workflow__signal_emitted).is_true()

	Signals.settings_changed.disconnect(connection)
```

- Cover the obvious axes: initialization, simple and complex behaviour, edge cases, invalid and
  empty input, multi-caret edits, parse and execution errors.

## Notes

- The `Tests` autoload (`core/autoload/tests.gd`) is a runtime **performance harness**, not this
  runner. `tests/runtime/performance.gd` is not part of the unit suite.
- `tests/action_scripts/remove_trailing_whitespaces.gd` has no `_test` suffix but is still
  discovered by the runner.
