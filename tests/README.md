# Tests Directory

This directory contains tests to verify the integrity and functionality of your dotfiles system. These tests help ensure that changes to the system don't break existing functionality.

## Directory Structure

```
.
├── README.md           # This file
└── run_tests.sh        # Main test runner script
```

## Key Files

### run_tests.sh

This script executes all system tests, including:

- Configuration validation
- Script functionality tests
- Package installation verification
- Profile switching tests
- Symlink integrity checks

Tests can be run individually or as a complete suite.

## Purpose

The tests directory serves several important functions:

1. **Validation**: Ensures configuration files are valid
2. **Verification**: Checks that scripts function as expected
3. **Regression Testing**: Prevents changes from breaking existing functionality
4. **Diagnostics**: Helps diagnose issues with the system

## Running Tests

To run all tests:

```bash
./tests/run_tests.sh
```

To run specific test categories:

```bash
./tests/run_tests.sh --category=config
./tests/run_tests.sh --category=scripts
./tests/run_tests.sh --category=profiles
```

## Test Categories

### Configuration Tests

These tests verify that configuration files:

- Have valid syntax
- Follow established patterns
- Don't contain sensitive information
- Are properly linked to their destinations

### Script Tests

These tests verify that scripts:

- Execute without errors
- Produce expected output
- Handle errors gracefully
- Function in different environments

### Profile Tests

These tests verify that the profile system:

- Correctly generates configuration from profiles
- Properly switches between profiles
- Applies changes as expected
- Handles edge cases appropriately

## Adding New Tests

When adding new functionality to the dotfiles system, add corresponding tests:

1. Create a new test script in the appropriate category
2. Make the script executable (`chmod +x tests/new-test.sh`)
3. Add the test to the main test runner
4. Test both successful and failure scenarios

### Test Template

New test scripts should follow this template:

```bash
#!/bin/zsh

# Test description
# ===============
# This test verifies X functionality

# Set up
TEST_NAME="Test Name"
echo "Running $TEST_NAME..."

# Test execution
if [condition]; then
    echo "✅ PASS: $TEST_NAME"
    exit 0
else
    echo "❌ FAIL: $TEST_NAME - reason for failure"
    exit 1
fi
```

## AI-Assisted Testing

The ADW system can be used to create and maintain tests:

1. Create ADW workflows for test creation
2. Use AI to generate test cases for new features
3. Run tests automatically after system changes
4. Document test results in the changelog

See [ADW.md](../ADW.md) for details on using AI for testing.

## Best Practices

- Write tests for all critical system components
- Make tests deterministic and repeatable
- Use descriptive failure messages
- Test edge cases and error conditions
- Run tests before and after significant changes
- Keep tests fast and focused 