# Scripts Directory

This directory contains installation, setup, and utility scripts for managing your system. These scripts automate complex configuration tasks and ensure consistent setup across installations.

## Directory Structure

```
.
├── macos.sh          # macOS system preferences configuration
└── README.md         # This file
```

## Key Scripts

### macos.sh

This script configures macOS system preferences, including:

- Finder settings
- Dock configuration
- Security preferences
- Input device settings
- Application defaults
- System performance options

Run it with:

```bash
./scripts/macos.sh
```

This script is automatically called during installation but can also be run independently to reset or update preferences.

## Purpose

The scripts directory serves several important functions:

1. **Automation**: Reduces manual configuration steps
2. **Consistency**: Ensures the same settings across installations
3. **Documentation**: Scripts document exactly what changes are made
4. **Modularity**: Separates installation logic by function

## Running Scripts

Most scripts can be executed directly:

```bash
# Make the script executable if needed
chmod +x scripts/script-name.sh

# Execute the script
./scripts/script-name.sh
```

Some scripts take optional arguments:

```bash
# Example with arguments
./scripts/macos.sh --skip-finder-settings
```

## Creating New Scripts

When adding new functionality to the dotfiles system, consider creating scripts for:

1. Installing new tools with complex setup requirements
2. Configuring applications with many settings
3. Performing maintenance or update tasks
4. Automating repetitive workflows

### Script Template

New scripts should follow this template:

```bash
#!/bin/zsh

# Set script to exit on error
set -e

# Script description and usage
# ============================
# This script does X, Y, and Z
# Usage: ./script-name.sh [options]

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --option) OPTION=true ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Script logic here
# ================

echo "Starting process..."

# Function definitions
function do_thing() {
    echo "Doing thing..."
    # Function logic
}

# Main execution
do_thing

echo "Process complete!"
```

## Best Practices

- Include descriptive headers and usage information
- Add error handling with helpful messages
- Make scripts idempotent (safe to run multiple times)
- Use variables for paths and configuration values
- Include confirmation prompts for destructive actions
- Add logging for important steps
- Test scripts in isolation before integrating

## Script Maintenance

When updating scripts:

1. Test changes in isolation before committing
2. Document breaking changes in comments
3. Update the main README if behavior changes
4. Consider creating a new script rather than substantially modifying an existing one 