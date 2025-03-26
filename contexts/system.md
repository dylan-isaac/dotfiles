
# Dotfiles System Context

## Overview

This context document describes the dotfiles system, a comprehensive personal environment management framework for macOS. It provides centralized configuration, AI-assisted development tools, and workflow automation.

## System Architecture

The dotfiles system is organized as follows:

- `bin/` - Scripts and utilities added to PATH
- `config/` - Configuration files for all tools
  - `templates/` - Profile-specific templates (personal, work, server)
  - `local/` - Machine-specific settings (not in git)
- `contexts/` - Context files for AI tools
- `packages/` - Package management files (Brewfiles)
- `scripts/` - Installation and setup scripts

## Available Commands

### Core Utilities

| Command               | Description                            | Documentation              |
| --------------------- | -------------------------------------- | -------------------------- |
| `context-clip`        | Access context files from command line | `context-clip --help`      |
| `install-analyzer.sh` | AI-powered installation diagnostics    | See `bin/README.md`        |
| `dotfiles-analyzer`   | Wrapper for install-analyzer.sh        | `dotfiles-analyzer --help` |
| `brew-manager.sh`     | Safely manage Homebrew packages        | `brew-manager.sh --help`   |
| `generate-docs.sh`    | Documentation generation tool          | `generate-docs.sh --help`  |

### AI Development Tools

| Command        | Description                                      | Documentation                  |
| -------------- | ------------------------------------------------ | ------------------------------ |
| `goose`        | Block's AI agent for software development        | https://block.github.io/goose/ |
| `aider`        | Terminal-based AI pair programming tool          | https://aider.chat/docs/       |
| `repomix`      | Pack codebase into single file for LLMs          | https://repomix.com/           |
| `ai-workflow`  | Classic Director pattern for AI workflows        | See `contexts/ADW.md`          |
| `pai-workflow` | PydanticAI-based implementation for AI workflows | See `contexts/ADW.md`          |

### Development Utilities

| Command               | Description                        | Documentation                |
| --------------------- | ---------------------------------- | ---------------------------- |
| `scaffold`            | Project scaffolding tool           | `scaffold --help`            |
| `create-node-project` | Create new Node.js projects        | `create-node-project --help` |
| `create-venv`         | Create Python virtual environments | `create-venv --help`         |

## Configuration Locations

- Shell configuration: `~/.zshrc` → `config/.zshrc`
- Machine-specific settings: `~/.zshrc.local` → `config/local/.zshrc.local`
- Git configuration: `~/.gitconfig` → `config/.gitconfig`
- Starship prompt: `~/.config/starship/starship.toml` → `config/starship.toml`
- AI tool configs:
  - Goose: `~/.config/goose/config.yaml` → Profile-specific template
  - Aider: `~/.aider.conf.yml` → `config/local/ai/aider.conf.yml`
  - Repomix: `~/.config/repomix/repomix.config.json` → `config/ai/repomix.config.json`

## Extending the System

### Adding a New Command/Script

1. Create script in `bin/` directory
2. Make it executable: `chmod +x bin/your-script.sh`
3. Update this context document
4. If complex, add detailed documentation in `contexts/`

```bash
# Example: Create a new utility
touch bin/my-utility.sh
chmod +x bin/my-utility.sh
vim bin/my-utility.sh
```

### Creating a New Profile

1. Create a new profile directory in `config/templates/`
2. Add necessary configuration files
3. Create a Brewfile in `packages/`

```bash
# Create new profile structure
mkdir -p config/templates/new-profile/goose
cp config/goose/config.yaml config/templates/new-profile/goose/
cp packages/Brewfile.personal packages/Brewfile.new-profile
```

### Adding New AI Tool Support

1. Add configuration templates to `config/ai/`
2. Add installation logic to `install.sh`
3. Create context document in `contexts/`
4. Update this context document

### Extending AI Workflows

1. Create workflow file in `config/adw/workflows/`
2. Follow existing workflow patterns
3. Test with `ai-workflow your-workflow-name`

```bash
# Create a new workflow
cp config/adw/workflows/example.yml config/adw/workflows/your-workflow.yml
vim config/adw/workflows/your-workflow.yml
```

## Troubleshooting

- Run `dotfiles-analyzer` to diagnose installation issues
- Check logs in `~/.dotfiles.logs/` directory
- Review configuration in `config/local/` for machine-specific issues
- Verify API keys are properly set in `~/.zshrc.local`

## Maintenance

After making any system modifications:
1. Update this context document
2. Update other relevant documentation
3. Add entry to CHANGELOG.md
4. Consider creating tests in the tests/ directory
