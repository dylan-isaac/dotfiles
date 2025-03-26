# Dylan's Dotfiles

A comprehensive personal environment management system for macOS. This repository serves as the central hub for customizing, configuring, and maintaining your development environment with AI-assisted automation.

## 🚀 Quick Start

```bash
# Clone this repository
git clone https://github.com/dylan-isaac/dotfiles.git ~/Projects/dotfiles

# Run the installation script
cd ~/Projects/dotfiles
./install.sh

# Or install with a specific profile
./install.sh --profile=work
```

### Installation Options

```bash
# Skip installing applications
./install.sh --skip-apps

# Quick mode - skip installations that are already complete
./install.sh --quick

# Configure for work environment (different AI settings)
./install.sh --work

# Install with a specific profile
./install.sh --profile=<profile_name>

# Combine options
./install.sh --quick --skip-apps --profile=minimal
```

## 📦 System Overview

This dotfiles repository is designed as a complete system with several key components:

- **Configuration Management**: Core configurations for your shell, tools, and applications
- **Profile System**: Environment-specific configurations you can switch between
- **AI Tools Integration**: Setup for AI coding assistants and workflows
- **Installation Automation**: Scripts to set up your environment consistently
- **Documentation**: README files in each directory explaining its purpose

### Directory Structure

```
.
├── README.md          # Main documentation (you are here)
├── CHANGELOG.md       # System modification history
├── bin/               # Core scripts and utilities
├── config/            # Configuration files for all tools
├── contexts/          # Context files for AI tools and reference
├── examples/          # Example configuration templates
├── packages/          # Package management (Homebrew, npm, etc.)
├── scripts/           # Installation and setup scripts
└── tests/             # System integrity tests
```

Each directory contains its own README with detailed information about its purpose and how to modify its contents.

## 🔧 Components

### Shell Setup
- Zsh configuration with Oh My Zsh
- Starship prompt customization
- Modern CLI alternatives:
  - `eza` instead of `ls`
  - `bat` instead of `cat`
  - `ripgrep` instead of `grep`
  - `zoxide` instead of `cd`

### Development Tools
- Git configuration
- Node.js setup with nvm
- Python setup with pyenv and UV (modern Python package manager)
- Other development tools

### macOS Configuration
- System preferences
- Finder preferences
- Dock configuration
- Safari development settings
- Security & privacy settings

### 🤖 AI Coding Tools

The dotfiles include setup for these AI coding assistants:

1. **[Aider](https://aider.chat/)** - A terminal-based AI pair programming tool
2. **[Goose](https://block.github.io/goose/)** - Block's AI agent for software development
3. **[Repomix](https://repomix.com/)** - Pack your codebase into a single file for LLMs
4. **AI Developer Workflows (ADW)** - Automated coding workflows using the Director pattern

### AI Developer Workflows

The Director pattern (described in [`contexts/ADW.md`](contexts/ADW.md)) allows you to create autonomous AI coding workflows:

1. Profile-specific workflows are defined in `config/adw/`
2. Run a workflow using:
   ```bash
   ai-workflow [workflow_name]
   ```
3. List available workflows:
   ```bash
   ai-workflow --list
   ```

## 🔐 Sensitive Configuration

All machine-specific configuration is stored in the `config/local/` directory, which is excluded from git by `.gitignore`.

The install script will:
1. Create the `config/local/` directory
2. Create machine-specific config files from templates
3. Symlink these files to your home directory

Key local config files:
- `config/local/.zshrc.local` - Machine-specific zsh settings and API keys
- `config/local/ai/aider.conf.yml` - Aider configuration  
- `config/local/ai/.env` - Aider environment variables

## 📋 Profile System

The profile system allows you to easily switch between different configuration setups:

```bash
# List available profiles
dotfiles-profile list

# Switch to a different profile
dotfiles-profile set work

# Show help
dotfiles-profile help
```

See the [Profile System documentation](config/profiles/README.md) for more details.

## 🔄 Maintaining Your System

This repository includes tools for maintaining system integrity:

- **System Tests**: Run `./tests/run_tests.sh` to verify your configuration
- **Changelog**: System modifications are tracked in `CHANGELOG.md`
- **ADW for Maintenance**: Use AI workflows for system updates and maintenance

For details on system maintenance, see [ADW.md](ADW.md).

## 📝 Extending Your System

Each component can be extended and customized:

1. **Profiles**: Add new profiles in `config/profiles/`
2. **Packages**: Modify package lists in `packages/`
3. **Configuration**: Add tool configs in `config/`
4. **AI Workflows**: Create new workflows in `config/adw/`

See the README in each directory for specific extension guidelines.

## 🔄 Updating

To update your dotfiles:

```bash
cd ~/Projects/dotfiles
git pull
./install.sh

# Or update with specific profile
./install.sh --profile=<profile_name>
```

## 📜 License

This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0) - see the [LICENSE](LICENSE) file for details.

This means you can freely share and adapt the code for non-commercial purposes, as long as you provide attribution to the original author.

### 🐍 Python Environment

The dotfiles configure Python with modern tools for a better development experience:

1. **UV** - A faster, more reliable Python package manager and installer:
   - Replaces `pip` commands with UV alternatives
   - Sets up proper dependency resolution
   - Generates lockfiles for reproducible environments

2. **pyenv** - Manages Python versions

#### Python Features

- **Virtual environments**: Create with `create-venv [name]`
- **Package management**: Use UV commands with aliases like `uvpip`, `uvinstall`, etc.

#### Configuration

UV settings can be customized in your `~/.zshrc.local` file:

```bash
# Example custom UV configuration
export UV_VIRTUALENV_PYTHON="/usr/local/bin/python3.11"
export UV_EXTRA_INDEX_URL="https://my-custom-index/simple/"
```

### 🟩 Node.js Environment

The dotfiles configure Node.js with enhanced tools for better development:

1. **NVM** - Node Version Manager for switching between Node versions:
   - Lazy-loaded for faster shell startup
   - Automatic version switching using `.nvmrc` files
   - Enhanced `npx` command that respects project Node versions

2. **Project Management**:
   - `create-node-project` - Create a new Node project with proper setup

#### Node.js Features

- **Version Management**: Auto-switching when changing directories with `.nvmrc` files
- **Smart npx**: Uses the project's Node version based on `.nvmrc` or `package.json`
- **Project Initialization**: Quick setup with `create-node-project [name] [version]`

#### Usage Examples

```bash
# Create a new project with the latest LTS Node
create-node-project my-project

# Create a project with a specific Node version
create-node-project my-project 18.19.0

# Use npx with the project's Node version (automatic)
cd my-project
npx some-package
```