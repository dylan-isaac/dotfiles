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

# Config-only mode - only perform symlinks and configuration, no installations
./install.sh --config-only

# Install with a specific profile
./install.sh --profile=<profile_name>

# Combine options
./install.sh --quick --skip-apps --profile=minimal
./install.sh --config-only --profile=work

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
- **Profile System**: Simple installation profiles for different environments (personal, work, server)
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
│   └── templates/     # Profile-specific templates
│       ├── personal/  # Personal profile templates
│       ├── work/      # Work profile templates
│       └── server/    # Server profile templates
├── contexts/          # Context files for AI tools and reference
├── examples/          # Example configuration templates
├── packages/          # Package management (Homebrew, npm, etc.)
│   ├── Brewfile.personal # Personal profile Homebrew packages
│   ├── Brewfile.work     # Work profile Homebrew packages
│   └── Brewfile.server   # Server profile Homebrew packages
├── scripts/           # Installation and setup scripts
└── tests/             # Test scripts to verify functionality
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
4. **[Firecrawl](https://github.com/mendableai/firecrawl-mcp-server)** - MCP server for web scraping and data extraction
5. **AI Developer Workflows (ADW)** - Automated coding workflows using the Director pattern
6. **Context Clip** - Utility for accessing context files from the command line

#### Context Clip

The `context-clip` utility provides easy access to context files from the command line:

```bash
# Copy a context file to clipboard
context-clip ADW

# List available context files
context-clip --list

# Print context to stdout or pipe to other tools
context-clip -p system-prompt
context-clip ADW | grep Director

# Send context directly to AI tools
context-clip -g architecture  # Open in Goose
context-clip -a prompt        # Open in Aider

# Use context in AI workflows
context-clip -w refactor ADW  # Use ADW context in refactor workflow

# Save context to a file
context-clip -s output.md ADW

# Tab completion is available
context-clip [TAB]  # Press Tab to see available contexts
```

This makes it easy to reuse your context files in various AI-assisted coding workflows. The command features tab completion for context names, making it even faster to access your frequently used contexts.

#### Goose Profile Configuration

Goose configurations are profile-specific, allowing different setups for personal and work environments:

```bash
# Personal profile uses Anthropic models by default
./install.sh --profile=personal

# Work profile typically uses OpenAI models
./install.sh --profile=work
```

The configuration files are located at:
- Default: `config/goose/config.yaml`
- Profile-specific: `config/templates/<profile>/goose/config.yaml`

The system prefers gpt-4o over older models like gpt-4-turbo. You can check and update the current configuration:

```bash
# View current Goose config
cat ~/.config/goose/config.yaml

# Create a profile-specific config (if it doesn't exist)
mkdir -p ~/Projects/dotfiles/config/templates/personal/goose
cp ~/Projects/dotfiles/config/goose/config.yaml ~/Projects/dotfiles/config/templates/personal/goose/
# Then edit to use gpt-4o or your preferred model
```

> **Troubleshooting**: If Goose is not using your configured model, check `~/.zshrc.local` for environment variables like `GOOSE_MODEL` or `GOOSE_PROVIDER` that override your configuration. The install script will detect and offer to remove these variables automatically, but you can also remove them manually.

### AI Developer Workflows

The system supports two ADW implementations:

#### 1. Classic Director Pattern

The original Director pattern (described in [`contexts/ADW.md`](contexts/ADW.md)) enables these automated workflows:

```bash
# Run a workflow
ai-workflow workflow-name

# List available workflows
ai-workflow --list

# Run with custom task description
ai-workflow "Add input validation to this function" 

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

# Run web scraping with Firecrawl MCP
goose "Scrape and summarize the content from https://example.com"

# Add an extension to your Goose config for automatic loading
vim ~/.config/goose/config.yaml
```

### Web Scraping with Firecrawl

The system includes integration with Firecrawl MCP for advanced web scraping:

```bash
# Configure your Firecrawl API key (already set up in templates)
export FIRECRAWL_API_KEY="your_api_key_here"

# Use Goose with Firecrawl for web research
goose "Research and summarize recent developments in AI safety"

# Extract structured data from websites
goose "Extract product information from https://store.example.com"
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

The profile system allows you to easily install configurations for different environments:

```bash
# Install with the default personal profile
./install.sh

# Install with the work profile
./install.sh --profile=work

# Install with the server profile
./install.sh --profile=server
```

Each profile has its own:
1. Brewfile with appropriate packages
2. Template files with environment-specific settings
3. Custom configurations for AI tools

For example, the work profile configures Goose to use OpenAI instead of Anthropic, which is useful in work environments where Anthropic access may not be available.

Available profiles:
- **personal**: Full-featured setup with entertainment apps
- **work**: Professional setup without entertainment apps
- **server**: Minimal CLI-only setup for servers

## 🔄 Maintaining Your System

This repository includes tools for maintaining system integrity:

- **Changelog**: System modifications are tracked in `CHANGELOG.md`
- **ADW for Maintenance**: Use AI workflows for system updates and maintenance
- **Homebrew Manager**: Run `./bin/brew-manager.sh` to safely manage Homebrew taps and packages
- **Installation Analyzer**: Run `./bin/install-analyzer.sh` to get AI-powered analysis of installation issues
- **Context Documentation**: Always update `contexts/system.md` after modifying the system to keep documentation in sync

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

## 📝 Extending Your System

Each component can be extended and customized:

1. **Profiles**: Add new Brewfiles and templates for custom profiles
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
- **Project scaffolding**: Create project templates with `scaffold --type mcp --path <path>`

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

#### Project Scaffolding

The system includes a scaffolding tool to quickly create new projects with best practices:

```bash
# Create a new MCP tool project
scaffold --type mcp --path ~/Projects

# Create other project types (more types coming soon)
scaffold --type <project-type> --path <destination-path>
```

The `scaffold` command is available in your PATH after installation, so you can use it from anywhere.

Available scaffold types:
- **mcp**: Creates a new MCP tool project with FastMCP server setup

The scaffolding system is extensible - see [`scripts/scaffold-scripts/`](scripts/scaffold-scripts/) for implementation details.