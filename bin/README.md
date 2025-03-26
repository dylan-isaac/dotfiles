# Bin Directory

This directory contains core scripts and utilities that power the dotfiles system. These scripts provide the foundation for configuration management, profile handling, and AI workflows.

## Directory Structure

```
.
├── director.py          # AI Developer Workflow director implementation
├── generate_config.py   # Configuration generator for the profile system
└── README.md            # This file
```

## Key Scripts

### director.py

The director.py script implements the AI Developer Workflow (ADW) pattern, enabling autonomous AI-driven development workflows. It:

- Manages model interactions for code generation
- Executes validation commands
- Evaluates execution outputs
- Provides feedback for refinement
- Handles multiple iterations until success

See [ADW.md](../contexts/ADW.md) for detailed documentation on the Director pattern.

### generate_config.py

The generate_config.py script manages the profile system for the dotfiles. It:

- Reads profile definitions from YAML files
- Generates configuration files based on the active profile
- Applies changes to the system
- Manages switching between profiles

## Purpose

The bin directory serves several important functions:

1. **Core Functionality**: Contains the scripts that drive key dotfiles features
2. **System Management**: Provides tools for maintaining configuration
3. **Automation**: Enables automated workflows and configuration tasks
4. **AI Integration**: Houses the code for AI-assisted development

## Using Bin Scripts

Most scripts in bin/ can be executed directly, but they are usually called from other parts of the system:

```bash
# Generate configuration from a profile
python bin/generate_config.py --profile work --apply

# Run an AI Developer Workflow
python bin/director.py -c config/adw/workflow.yaml
```

These scripts are typically accessed through shell aliases defined in `.zshrc`:

```bash
# Example usage through an alias
dotfiles-profile set work

# Example ADW workflow execution
ai-workflow new-feature
```

## Modifying Bin Scripts

When modifying bin scripts:

1. Test changes thoroughly before committing
2. Update associated documentation if behavior changes
3. Consider backward compatibility
4. Add descriptive comments for complex logic

### Adding New Scripts

When adding new core scripts:

1. Use appropriate shebang lines (e.g., `#!/usr/bin/env python` for Python scripts)
2. Make scripts executable (`chmod +x bin/script-name`)
3. Add clear documentation and help text
4. Update this README with information about the new script
5. Consider adding shell aliases in `.zshrc` for easy access

## Best Practices

- Include comprehensive error handling
- Provide clear help information with `--help` flags
- Use logging for important operations
- Make scripts configuration-driven when possible
- Consider both interactive and non-interactive usage
- Test thoroughly across different environments 