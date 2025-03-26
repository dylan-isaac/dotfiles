# Configuration Directory

This directory contains all configuration files for your system. These files control the behavior of your shell, development tools, AI assistants, and other applications.

## Directory Structure

```
.
├── .config/            # XDG config directory files
├── .gitconfig          # Global Git configuration
├── .gitignore_global   # Global Git ignore patterns
├── .zshrc              # Main Zsh configuration
├── .zshrc.local.template # Template for local Zsh config
├── adw/                # AI Developer Workflow configurations
├── aider/              # Aider AI assistant configurations
├── goose/              # Goose AI assistant configurations
├── local/              # Machine-specific configurations (not in git)
└── profiles/           # Environment profiles
```

## Core Configuration Files

- **`.zshrc`**: Main shell configuration. Customizes your terminal environment with aliases, functions, and plugin setups.
- **`.gitconfig`**: Global Git configuration with user settings, aliases, and behavior preferences.
- **`.gitignore_global`**: Global patterns to ignore in Git repositories.

## Local Configuration

The `local/` directory contains machine-specific configuration that shouldn't be committed to git. This includes:

- API keys and secrets
- User-specific preferences
- Machine-specific paths and settings

During installation, files from `.zshrc.local.template` are created in this directory and symlinked to your home directory.

## AI Tool Configurations

### Aider Configuration

The `aider/` directory contains templates for Aider AI assistant:

- Configuration files for different models
- Environment settings for API access
- Editor preferences

### Goose Configuration

The `goose/` directory contains templates for Goose AI assistant:

- Extension settings
- Model configurations
- Authentication settings

### AI Developer Workflows

The `adw/` directory contains workflow configurations for the AI Developer Workflow system:

- Task specifications
- Model configurations
- Execution commands
- Context file mappings

## Profile System

The `profiles/` directory contains YAML files defining different environment profiles. Each profile configures:

- Package selections
- Environment variables
- Shell aliases
- AI tool settings

See [Profile README](profiles/README.md) for details on creating and managing profiles.

## Modifying Configurations

### Adding a new tool configuration

1. Create a new directory for your tool: `mkdir config/tool-name`
2. Add configuration templates with appropriate extensions
3. Update the installer to link these files during setup

### Customizing shell environment

1. Edit `.zshrc` to add global changes for all users
2. Add machine-specific customizations to `local/.zshrc.local`
3. To add temporary or experimental changes, use `.zshrc.local`

### Creating local configuration

The installer automatically creates `local/.zshrc.local` from the template. To add more local configurations:

1. Create a template file (e.g., `tool-name.conf.template`)
2. Update the installer to create a local copy during setup
3. Add the local configuration to `.gitignore`
