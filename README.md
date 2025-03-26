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

# Or use the AI-enhanced installation analyzer
./bin/install-analyzer.sh
```

### Installation Options

```bash
# Skip installing applications
./install.sh --skip-apps

# Quick mode - skip all Homebrew operations and installations that are already complete
./install.sh --quick

# Configure for work environment (different AI settings)
./install.sh --work

# Install with a specific profile
./install.sh --profile=<profile_name>

# Combine options
./install.sh --quick --skip-apps --profile=minimal

# Use AI-powered installation analyzer
./bin/install-analyzer.sh --ai=goose --profile=work
./bin/install-analyzer.sh --ai=pydantic --verbose
```

### AI-Enhanced Installation

The dotfiles include an AI-powered installation analyzer that:

1. Runs the installation process and captures its output
2. Uses AI (either Goose or PydanticAI) to analyze the results
3. Determines if the installation was successful
4. Creates a detailed remediation plan for any issues
5. Provides contextually relevant advice based on your system

```bash
# Run installation with AI analysis (default: PydanticAI)
./bin/install-analyzer.sh

# Choose which AI engine to use
./bin/install-analyzer.sh --ai=goose
./bin/install-analyzer.sh --ai=pydantic

# Show verbose installation output
./bin/install-analyzer.sh --verbose

# Pass any standard install.sh arguments
./bin/install-analyzer.sh --profile=work --skip-apps

# Use the convenient wrapper script
./bin/dotfiles-analyzer --ai=goose --verbose
```

The analyzer saves all logs and analysis to a timestamped directory in `/tmp/` for your reference.

For detailed usage instructions and troubleshooting, see the [Installation Analyzer documentation](bin/README.md#installation-analyzer).

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

### Security Features
- Git security check for detecting sensitive information
- API key leak detection in code changes
- Environment placeholder verification
- Automated security tests

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

The system supports two ADW implementations:

#### 1. Classic Director Pattern

The original Director pattern (described in [`contexts/ADW.md`](contexts/ADW.md)) enables these automated workflows:

```bash
# Run a workflow
ai-workflow workflow-name

# List available workflows
ai-workflow --list

# Run with custom prompt
ai-workflow "Your custom task description" 

# Include files for context
ai-workflow "Update error handling" --files bin/director.py
```

#### 2. PydanticAI-based Implementation

A modern, type-safe implementation using the PydanticAI agent system:

```bash
# Run a workflow with enhanced features
pai-workflow workflow-name

# List available workflows
pai-workflow --list

# Run with custom prompt
pai-workflow workflow-name --prompt="Task description"
```

Key features of the PydanticAI implementation:

- **Type Safety**: Fully typed with Pydantic models
- **Iteration-Aware Prompting**: Customized prompts for each iteration
- **Structured Evaluation**: Detailed metrics for progress tracking
- **Failure Analysis**: Comprehensive debugging information

See [`contexts/ADW.md`](contexts/ADW.md) for detailed documentation on both implementations.

### Browser Automation with Goose

The system includes Goose extensions for browser automation:

```bash
# Run the GitHub stars analyzer
goose extension:bin/goose-github-stars.js "Analyze stars on GitHub repo octocat/Spoon-Knife"

# Add an extension to your Goose config for automatic loading
vim ~/.config/goose/config.yaml
```

### Documentation Generation with Repomix

The system includes a tool for generating comprehensive documentation:

```bash
# Generate documentation for a component
./bin/generate-docs.sh bin

# Copy documentation to clipboard
./bin/generate-docs.sh --clipboard config/profiles

# Specify custom template
./bin/generate-docs.sh --template=my-template.md tests
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
- **Manual Testing Guide**: Follow `tests/MANUAL_TESTING.md` for comprehensive testing of AI tools
- **Automated AI Tools Test**: Run `./tests/ai_tools_test.sh` to quickly verify AI tool functionality
- **Changelog**: System modifications are tracked in `CHANGELOG.md`
- **ADW for Maintenance**: Use AI workflows for system updates and maintenance
- **Homebrew Manager**: Run `./bin/brew-manager.sh` to safely manage Homebrew taps and packages
- **Installation Analyzer**: Run `./bin/install-analyzer.sh` to get AI-powered analysis of installation issues

For details on system maintenance, see [contexts/ADW.md](contexts/ADW.md).

### Installation Analysis

The Installation Analyzer provides AI-powered diagnostics for your dotfiles installation:

```bash
# Run a fresh installation with AI analysis
./bin/install-analyzer.sh --verbose

# Analyze a specific profile installation
./bin/install-analyzer.sh --profile=minimal

# Choose between Goose and PydanticAI analysis engines
./bin/install-analyzer.sh --ai=goose
./bin/install-analyzer.sh --ai=pydantic

# Use the convenient wrapper script from anywhere
dotfiles-analyzer --quick --verbose
```

The analyzer will:
1. Run the installation process
2. Capture and analyze all output
3. Determine if there were any errors or warnings
4. Create a contextually relevant recovery plan
5. Save detailed logs for future reference

This is especially useful when setting up a new machine or updating to a new macOS version where compatibility issues might arise.

#### Testing the Analyzer

You can verify the analyzer's functionality without running a full installation:

```bash
# Run the test script to analyze a mock installation log
./tests/test_install_analyzer.sh
```

This creates a realistic mock installation log with common issues and runs the analyzer on it, allowing you to see how it identifies and suggests fixes for problems.

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
- **Project Initialization**: Quick setup with various templates:
  ```bash
  # Create a new basic Node.js project with LTS Node
  create-node-project my-project
  
  # Create a project with a specific Node version
  create-node-project my-project 18.19.0
  
  # Create a project with a specific template (basic, react, express, typescript)
  create-node-project my-project lts typescript
  ```

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