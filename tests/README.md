# Text Forge Unit Tests

This directory contains comprehensive unit tests for the Text Forge text editor.

## Maintenance Notes
- Run tests before commits
- Update tests when changing functionality
- Review coverage monthly

## Performance Benchmarks
Current test suite execution time (estimated):
- **All tests**: ~10 seconds
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