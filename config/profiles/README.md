# Profile System

The profile system allows you to define and switch between different environment configurations. Profiles customize your shell, tools, packages, and AI assistants based on your current needs.

## Directory Structure

```
.
├── personal.yaml    # Default profile for personal use
├── work.yaml        # Profile for work environments
├── server.yaml      # Minimal profile for servers
└── README.md        # This file
```

## Core Profiles

### personal.yaml

The personal profile includes:

- Full set of development tools
- Entertainment applications
- Personal AI assistant configurations
- Relaxed security settings

### work.yaml

The work profile includes:

- Work-focused development tools
- Productivity applications
- Work-appropriate AI settings
- Stricter security settings

### server.yaml

The server profile includes:

- Minimal CLI-only tools
- Server administration utilities
- Reduced AI functionality
- Performance-focused settings

## Profile Structure

Each profile is defined in a YAML file with the following sections:

```yaml
# Basic profile information
name: "Profile Name"
description: "Profile description"
environment_type: "personal" # or "work" or "server"

# Package selection
packages:
  brew:
    - package1
    - package2
  cask:
    - app1
    - app2

# Shell configuration
shell:
  aliases:
    - alias_name: "command"
  functions:
    - function_name: |
        function_definition() {
          # Function code
        }
  exports:
    - VAR_NAME: "value"

# AI tool settings
ai:
  aider:
    default_model: "gpt-4o"
  goose:
    enabled_extensions:
      - extension1
      - extension2
  adw:
    workflows:
      - workflow1
      - workflow2
```

## Using Profiles

### Viewing Available Profiles

```bash
dotfiles-profile list
```

### Checking Current Profile

```bash
dotfiles-profile show
```

### Switching Profiles

```bash
dotfiles-profile set work
```

### Reapplying Current Profile

```bash
dotfiles-profile apply
```

## Creating Custom Profiles

To create a new profile:

1. Copy an existing profile as a starting point:
   ```bash
   cp config/profiles/personal.yaml config/profiles/custom.yaml
   ```

2. Edit the new profile file:
   ```bash
   $EDITOR config/profiles/custom.yaml
   ```

3. Apply your new profile:
   ```bash
   dotfiles-profile set custom
   ```

## Profile Inheritance

Profiles can inherit from one another to reduce duplication:

```yaml
# Example profile with inheritance
name: "Custom Profile"
description: "My custom profile"
extends: "personal" # Inherit from personal profile

# Override specific settings
environment_type: "work"

# Add additional packages
packages:
  brew:
    - additional-package
  cask:
    - additional-app
```

## Best Practices

- Create specific profiles for different contexts (work, personal, server)
- Keep sensitive settings in the local configuration, not profiles
- Test profile changes before committing
- Document custom profiles clearly
- Use inheritance to reduce duplication between profiles
- Consider performance impact of installed packages 