# Examples Directory

This directory contains example configuration files that serve as templates for sensitive or machine-specific configuration. These examples demonstrate proper formatting and structure without containing actual sensitive data.

## Directory Structure

```
.
├── .gitconfig.local.example    # Example of local Git configuration
├── .zshrc.local.example        # Example of local Zsh configuration
└── README.md                   # This file
```

## Key Example Files

### .gitconfig.local.example

This file demonstrates how to set up machine-specific Git configuration, including:

- User name and email
- Credential helpers
- Work-specific settings
- Custom hooks and paths

### .zshrc.local.example

This file demonstrates how to set up machine-specific shell configuration, including:

- API keys for various services
- Local path adjustments
- Machine-specific aliases
- Environment-specific overrides

## Purpose

These example files serve several important purposes:

1. **Documentation**: Show users what configuration options are available
2. **Templates**: Provide starting points for creating local configuration
3. **Reference**: Demonstrate best practices for configuration
4. **Education**: Help users understand what should be kept private

## Using Example Files

During installation, the system will:

1. Check if you have existing local configuration
2. If not, create new local files based on these examples
3. Prompt you to update the created files with your specific information

You can also manually use these examples:

```bash
# Create a new local Git config from the example
cp examples/.gitconfig.local.example config/local/.gitconfig.local

# Create a new local shell config from the example
cp examples/.zshrc.local.example config/local/.zshrc.local
```

## Creating New Example Files

When adding new tools or configurations to the system, consider creating example files:

1. Create your configuration with placeholders instead of real values
2. Save it with `.example` suffix in this directory
3. Add documentation comments to explain each section
4. Update the installation script to use this example

## Best Practices

- Never include real API keys or credentials in example files
- Use placeholders like `YOUR_API_KEY_HERE` for sensitive values
- Include detailed comments explaining each setting
- Structure files in the same way as the actual configuration
- Keep examples up-to-date with changes to actual configuration formats 