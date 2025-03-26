# AI Developer Workflow for System Maintenance

This document outlines how to use AI Developer Workflows (ADW) to maintain and extend your dotfiles system. It provides guidelines for testing, documentation, and change management to ensure system stability.

## System Maintenance Philosophy

The dotfiles system follows these key principles:

1. **Test-Driven**: Changes should be verified by tests
2. **Self-Documenting**: System changes are automatically documented
3. **AI-Assisted**: Leverage AI for routine maintenance and improvements
4. **Reproducible**: Changes should be reproducible across environments

## PydanticAI-based Implementation

The dotfiles system now includes a modern, type-safe implementation of ADW using PydanticAI:

```bash
# Run a workflow using the PydanticAI implementation
pai-workflow workflow-name

# List available workflows
pai-workflow --list

# Run with custom prompt
pai-workflow workflow-name --prompt="Your custom prompt"

# Run in a specific context directory
pai-workflow workflow-name --context=/path/to/context
```

### Key Features

The PydanticAI implementation offers several advantages:

1. **Type Safety**: Fully typed with Pydantic models for structured data
2. **Better Error Handling**: Comprehensive error detection and reporting
3. **Iteration-Aware Prompting**: Customized prompts for each iteration
4. **Structured Evaluation**: Detailed metrics for progress tracking
5. **Failure Analysis**: Comprehensive debugging information when workflows fail
6. **Better Security Checks**: Built-in security validation for code changes

### Structured Evaluation with Pydantic

The ADW system now includes structured evaluation capabilities using Pydantic models, which provides several advantages:

1. **Detailed Metrics**: Quantified task completion, test results, and security checks
2. **Standardized Feedback**: Consistent format across different types of tasks
3. **Actionable Insights**: Clear next steps and recommendations
4. **Security Assessment**: Built-in security validation for code changes
5. **Change Tracking**: Detailed records of all files modified

### Structured Evaluation Models

The structured evaluation uses these core Pydantic models:

```python
class SecurityCheck(BaseModel):
    passed: bool
    issues: List[str]
    risk_level: Literal["low", "medium", "high", "critical"]
    recommendations: List[str]

class TestResult(BaseModel):
    passed: bool
    total_tests: int
    passed_tests: int
    failed_tests: int
    error_messages: List[str]
    coverage: Optional[float]

class StructuredEvaluation(BaseModel):
    success: bool
    task_completion: float  # 0.0 to 1.0
    security_check: SecurityCheck
    test_results: Optional[TestResult]
    changeset: WorkflowChangeset
    feedback: str
    next_steps: List[str]
```

### Using Structured Evaluation

To enable structured evaluation in your workflow:

```yaml
prompt: "Task description"
coder_model: "gpt-4o"
evaluator_model: "gpt-4o"
execution_command: "./tests/test-component.sh"
context_editable:
  - "path/to/editable/file"
context_read_only:
  - "path/to/reference/file"
evaluator: "structured"  # Enable structured evaluation
log_file: "logs/workflow-name.log"
```

Structured evaluation logs will include detailed information about:

- Task completion percentage
- Security validation results
- Test execution statistics
- Changed files and their descriptions
- Recommended next steps

## Using ADW for System Maintenance

The Director pattern implemented in `bin/director.py` enables autonomous AI-driven maintenance workflows:

1. **Configuration Validation**: Verify configuration files are valid
2. **Package Updates**: Safely update package lists
3. **Script Improvements**: Enhance existing scripts
4. **Documentation Generation**: Update READMEs and help text
5. **Change Tracking**: Document changes in CHANGELOG.md

All workflow runs are logged to the `config/adw/logs/` directory for easy review and debugging. This allows you to trace exactly what happened during a workflow execution, which is invaluable for:

- Debugging failed workflows
- Understanding AI reasoning
- Improving workflow prompts
- Documenting system changes

## Maintenance Workflows

### Running System Tests

```bash
# Run all system tests
./tests/run_tests.sh

# Run specific test categories
./tests/run_tests.sh --category=config
```

### Updating the System

```bash
# Use AI to safely update package lists
ai-workflow update-packages

# Use AI to improve script documentation
ai-workflow improve-docs

# Use AI to add a new feature
ai-workflow add-feature --feature="feature-name"
```

## Changelog Management

The system maintains a CHANGELOG.md file to track significant changes:

- **Automatic Updates**: AI workflows automatically update the changelog
- **Change Categories**: Changes are categorized by type (feature, fix, etc.)
- **Attribution**: Changes include who or what made them
- **Timestamps**: All entries include dates

### Changelog Format

```markdown
# Changelog

All notable changes to the dotfiles system will be documented in this file.

## [Unreleased]

### Added
- New feature description

### Changed
- Change description

### Fixed
- Fix description

## [1.0.0] - (give a fun name based off the changes 💅)

### Added
- Initial release features
```

### Updating the Changelog

AI workflows automatically update the changelog, but you can also update it manually:

```bash
# Use AI to generate a changelog entry from recent changes
ai-workflow update-changelog

# Manually add a changelog entry
$EDITOR CHANGELOG.md
```

## Testing Guidelines

### Writing Tests

Tests should be added for all significant system components:

- **Configuration Tests**: Verify config files are valid
- **Script Tests**: Ensure scripts work as expected
- **Integration Tests**: Verify system components work together

### Test Structure

Each test should:

1. Have a clear purpose and description
2. Test one specific aspect of the system
3. Have clear pass/fail criteria
4. Be repeatable across environments

### Adding New Tests

```bash
# Use AI to generate tests for a component
ai-workflow create-tests --component="component-name"

# Run tests after changes
./tests/run_tests.sh
```

## Extending the System

### Adding New Components

When adding new system components:

1. Create appropriate directory structures and READMEs
2. Write tests for the new component
3. Update the main README.md to document the addition
4. Add to the changelog

### Adding New AI Workflows

To add a new AI workflow:

1. Create a workflow YAML file in `config/adw/`:
   ```yaml
   prompt: "Task description"
   coder_model: "gpt-4o"
   evaluator_model: "gpt-4o"
   execution_command: "./tests/test-component.sh"
   context_editable:
     - "path/to/editable/file"
   context_read_only:
     - "path/to/reference/file"
   evaluator: "structured"  # Use structured evaluation for better insights
   log_file: "logs/workflow-name.log"
   ```

2. Register the workflow in your profile:
   ```yaml
   ai:
     adw:
       workflows:
         - workflow-name
   ```

3. Run the workflow:
   ```bash
   ai-workflow workflow-name
   ```

4. Review the logs:
   ```bash
   cat config/adw/logs/workflow-name.log
   ```

## Failure Handling and Debugging

When a workflow fails, the PydanticAI implementation provides comprehensive debugging information:

1. **Root Cause Analysis**: Identifies the primary reasons for failure
2. **Affected Files**: Lists files that need modification to fix issues
3. **Suggested Fixes**: Provides actionable recommendations
4. **Debug Information**: Offers technical details for troubleshooting
5. **Log File Access**: Points to the location of detailed logs

The failure analysis helps developers quickly identify and resolve issues, making the debugging process more efficient.

## System Version Management

The dotfiles system uses semantic versioning:

- **Major**: Significant changes that may be incompatible
- **Minor**: New features that are backward compatible
- **Patch**: Bug fixes and minor improvements

Version updates are managed through tags and documented in the changelog.

## Best Practices

- Run tests before and after making changes
- Let AI handle routine maintenance tasks
- Document significant manual changes
- Keep changelog entries concise but informative
- Use separate profiles for experimental changes
- Periodically audit and clean up the system
- Enable structured evaluation for critical workflows
- Use PydanticAI implementation for important or complex workflows

## Example: Complete Maintenance Cycle

```bash
# 1. Update system and packages
git pull
./install.sh --quick

# 2. Run tests to verify current state
./tests/run_tests.sh

# 3. Use AI to make improvements
pai-workflow improve-system

# 4. Run tests again to verify changes
./tests/run_tests.sh

# 5. Review and commit changes
git add .
git commit -m "Improve system configuration"

# 6. Update the changelog
pai-workflow update-changelog
``` 