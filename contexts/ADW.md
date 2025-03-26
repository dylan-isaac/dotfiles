# AI Developer Workflow for System Maintenance

This document outlines how to use AI Developer Workflows (ADW) to maintain and extend your dotfiles system. It provides guidelines for testing, documentation, and change management to ensure system stability.

## System Maintenance Philosophy

The dotfiles system follows these key principles:

1. **Test-Driven**: Changes should be verified by tests
2. **Self-Documenting**: System changes are automatically documented
3. **AI-Assisted**: Leverage AI for routine maintenance and improvements
4. **Reproducible**: Changes should be reproducible across environments

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

## Example: Complete Maintenance Cycle

```bash
# 1. Update system and packages
git pull
./install.sh --quick

# 2. Run tests to verify current state
./tests/run_tests.sh

# 3. Use AI to make improvements
ai-workflow improve-system

# 4. Run tests again to verify changes
./tests/run_tests.sh

# 5. Review and commit changes
git add .
git commit -m "Improve system configuration"

# 6. Update the changelog
ai-workflow update-changelog
``` 