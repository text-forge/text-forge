# Text Forge Unit Tests

This directory contains comprehensive unit tests for the Text Forge text editor.

## Maintenance Notes
- Run tests before commits
- Update tests when changing functionality
- Review coverage monthly

## Performance Benchmarks
Current test suite execution time (estimated):
- **All tests**: ~20 seconds
- **Individual file**: ~1 second

## Test Generation Notes
- Use **GDUnit4** as test framework
- Place all tests in `tests/` directory
- Have coverage example in mind:
  - Initialization and setup
  - Simple behavior
  - Complex behavior
  - Edge-cases
  - Invalid input handling
  - Empty input handling
  - Complex states like multi-caret edit
  - Parse error handling
  - Execute error handling
- Don't use local variables in lambda functions, use like this (`test_neme__var_name`):
```
# GdUnit generated TestSuite
class_name UIFilterIntegrationTestSuite
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

...

var test_complete_ui_filter_workflow__signal_emitted := false

...

func test_complete_ui_filter_workflow() -> void:
	# Test complete workflow: setting -> signal -> reload
	var connection := func(): test_complete_ui_filter_workflow__signal_emitted = true
	Signals.settings_changed.connect(connection)

	# Change hue shift
	Settings.set_setting(test_section, "filter_hue_shift", 0.5)
	await get_tree().process_frame
	assert_bool(test_complete_ui_filter_workflow__signal_emitted).is_true()
	assert_float(Settings.get_setting(test_section, "filter_hue_shift")).is_equal(0.5)

	Signals.settings_changed.disconnect(connection)

...

```

### Best Practices
1. **One Test Per Behavior**: Each test should verify one specific behavior
2. **Descriptive Names**: Use clear, descriptive test names
3. **Arrange-Act-Assert**: Structure tests with setup, action, verification
4. **Independent Tests**: Tests should not depend on each other
5. **Use auto_free**: Prevent memory leaks with auto_free()
6. **Meaningful Assertions**: Use specific assertion types for better error messages

## Internal Documentation
- `tests/README.md` - Getting started
- `tests/TEST_SUMMARY.md` - Detailed coverage
- `tests/INDEX.md` - Complete index