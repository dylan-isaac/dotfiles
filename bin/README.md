# Bin Directory

This directory contains executable scripts and utilities for managing your dotfiles environment.

## Core Utilities

| File                    | Description                                                       |
| ----------------------- | ----------------------------------------------------------------- |
| `ai-workflow`           | Run AI-assisted workflows for code editing and project management |
| `pai-workflow`          | PydanticAI implementation of AI-assisted workflows                |
| `install-analyzer.sh`   | AI-powered installation diagnostics and repair suggestions        |
| `dotfiles-analyzer`     | Convenient wrapper for install-analyzer.sh                        |
| `generate-docs.sh`      | Generate documentation for components using AI                    |
| `run-repomix.sh`        | Pack your codebase for use with LLMs                              |
| `git-security-check.sh` | Check git commits for sensitive information                       |

## AI Tools

| File                    | Description                                                        |
| ----------------------- | ------------------------------------------------------------------ |
| `director.py`           | AI workflow orchestration system for multi-step AI automated tasks |
| `goose-github-stars.js` | Goose extension for GitHub stars analysis                          |
| `run_adw.py`            | Run AI Developer Workflow system (legacy)                          |
| `adw-create.py`         | Create new AI Developer Workflows                                  |

## Usage Examples

### AI Workflows

```bash
# Run a workflow with default settings
ai-workflow update-readme

# Run a workflow with a custom prompt
ai-workflow "Add input validation to user.py"

# Use the PydanticAI implementation
pai-workflow refactor --prompt="Improve error handling in auth.py"
```

### Installation Analysis

```bash
# Analyze an installation with default settings
./install-analyzer.sh

# Analyze with verbose output
./install-analyzer.sh --verbose

# Use a specific AI engine
./install-analyzer.sh --ai=goose
```

### Documentation Generation

```bash
# Generate docs for a component
./generate-docs.sh bin

# Generate docs and copy to clipboard
./generate-docs.sh --clipboard config

# Use a custom template
./generate-docs.sh --template=my-template.md lib
```

## Customization

You can modify or extend these scripts to fit your workflow. For example:

1. Add new AI workflows to `config/adw/workflows/`
2. Create new Goose extensions in this directory
3. Update the documentation templates in `contexts/templates/`

## Security Notes

1. The `git-security-check.sh` script is run automatically on commits if configured
2. Never store API keys directly in these scripts
3. Use the `.env` file or `.zshrc.local` for sensitive configuration
