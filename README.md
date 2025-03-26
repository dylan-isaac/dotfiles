# Dylan's Dotfiles

This repository contains my personal dotfiles and system configuration scripts. It's designed to make setting up a new Mac system quick and consistent.

## 🚀 Quick Start

```bash
# Clone this repository
git clone https://github.com/dylansheffer/dotfiles.git ~/Projects/dotfiles

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

## 📦 What's Included

- `zsh` configuration with modern CLI tools
- macOS system preferences configuration
- Git configuration
- Homebrew package installation
- Development tools setup
- Terminal configuration (iTerm2)

### Directory Structure

```
.
├── bin/              # Scripts and utilities
│   ├── director.py   # AI Developer Workflow director
│   └── generate_config.py # Configuration generator
├── config/          # Configuration files
│   ├── .gitconfig   # Git configuration
│   ├── .zshrc       # Zsh configuration
│   ├── profiles/    # Profile definitions
│   ├── goose/       # Goose configuration templates
│   ├── aider/       # Aider configuration templates
│   ├── adw/         # AI Developer Workflow configurations
│   └── local/       # Machine-specific configurations (not in git)
├── scripts/         # Installation and setup scripts
└── examples/        # Example configuration files for sensitive data
```

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

### Configuration

- All AI tool configurations are managed through the profile system
- Each profile can specify:
  - Which extensions to enable in Goose
  - Default models to use in Aider
  - AI Developer Workflow settings
  - Custom shell aliases

#### Getting Started with AI Tools

1. **Set up your API keys** in `config/local/.zshrc.local`:
   ```bash
   # For both Aider and Goose
   export OPENAI_API_KEY="sk-..."
   export ANTHROPIC_API_KEY="sk-ant-..." # Optional
   ```

2. **Use the built-in aliases**:
   ```bash
   # Start AI coding assistant with preferred model
   ai-code
   
   # Explain code in a file
   ai-explain path/to/file
   
   # Create a context file from your codebase (copies to clipboard)
   ai-context
   
   # Start Repomix MCP server for AI assistants
   repomix-mcp
   ```

3. **Repomix features**:
   ```bash
   # Basic usage (copy to clipboard, XML format, compressed)
   repomix
   
   # Create instruction template for better AI context
   repomix-init-explain
   
   # Use with instruction file
   repomix-explain
   
   # Process remote repository
   repomix-remote user/repo
   ```

4. **MCP Server**:
   The installation automatically configures Repomix as an MCP server for VS Code (Cline extension) and Claude Desktop if installed. This allows AI assistants to directly interact with your codebase.
   
   - **Automatic Startup**: The MCP server is configured to start automatically when you log in
   - **Manual Control**: If needed, you can control the service with:
     ```bash
     # Start the service
     launchctl load ~/Library/LaunchAgents/com.repomix.mcp.plist
     
     # Stop the service
     launchctl unload ~/Library/LaunchAgents/com.repomix.mcp.plist
     
     # Start manually (one-time use)
     repomix-mcp
     ```
   - **Logs**: Server logs are available at `~/.repomix/logs/`

## 🔐 Sensitive Configuration

All machine-specific configuration is stored in the `config/local/` directory, which is excluded from git by `.gitignore`.

The install script will:
1. Create the `config/local/` directory
2. Create machine-specific config files from templates
3. Symlink these files to your home directory

This approach allows you to:
- Keep all your configuration in one place
- Avoid committing sensitive information to git
- Easily update your dotfiles on multiple machines

Key local config files:
- `config/local/.zshrc.local` - Machine-specific zsh settings and API keys
- `config/local/ai/aider.conf.yml` - Aider configuration  
- `config/local/ai/.env` - Aider environment variables

## 📋 Profile System

The dotfiles repository now includes a comprehensive profile system that allows you to easily switch between different configuration setups for various environments.

### Available Profiles

- **personal** - Full-featured development environment with all tools and games
- **work** - Work-focused setup without games and entertainment apps
- **server** - Minimal CLI-only setup for servers

### Managing Profiles

Once installed, you can manage profiles using the `dotfiles-profile` command:

```bash
# List available profiles
dotfiles-profile list

# Show current profile
dotfiles-profile show

# Switch to a different profile
dotfiles-profile set work

# Re-apply current profile settings
dotfiles-profile apply

# Show help
dotfiles-profile help
```

### Creating Custom Profiles

You can create your own profiles by copying and modifying existing profile templates:

1. Create a new profile file:
   ```bash
   cp config/profiles/personal.yaml config/profiles/custom.yaml
   ```

2. Edit the new profile file to adjust settings:
   ```bash
   vim config/profiles/custom.yaml
   ```

3. Apply your new profile:
   ```bash
   dotfiles-profile set custom
   ```

### What Profiles Configure

Each profile can configure:

- **Environment Type** - personal, work, or server
- **Package Selection** - Which applications to install via Homebrew
- **AI Tool Settings** - Configurations for Goose, Aider, and AI Developer Workflows
- **Shell Aliases** - Custom aliases for the current profile
- **Default Models** - Which AI models to use by default

## 📝 Manual Steps

Some things still need to be done manually:

1. Generate SSH keys and add to GitHub
2. Sign in to App Store
3. Configure Apple ID
4. Install App Store applications

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

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

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