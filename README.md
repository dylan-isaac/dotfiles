# Dylan's Dotfiles

This repository contains my personal dotfiles and system configuration scripts. It's designed to make setting up a new Mac system quick and consistent.

## 🚀 Quick Start

```bash
# Clone this repository
git clone https://github.com/dylansheffer/dotfiles.git ~/Projects/dotfiles

# Run the installation script
cd ~/Projects/dotfiles
./install.sh
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
├── config/          # Configuration files
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

#### Configuration

- AI tools are installed automatically by the setup script
- API keys are stored in `~/.zshrc.local` (created from the template)
- Common aliases and functions are in `.zshrc` (commented out by default)

#### Getting Started with AI Tools

1. **Set up your API keys** in `~/.zshrc.local`:
   ```bash
   # For Aider
   export AIDER_OPENAI_API_KEY="sk-..."
   export AIDER_ANTHROPIC_API_KEY="sk-ant-..." # Optional
   
   # For Goose
   export GOOSE_API_KEY="your_key_here"
   ```

2. **Uncomment the tools you want** in `.zshrc` (AI Coding Tools section)

3. **Basic usage examples**:
   ```bash
   # Start aider with default settings
   aider

   # Start aider with specific model
   aider --model gpt-4o

   # Use goose
   goose

   # Explain code with goose
   goose explain -f path/to/file
   ```

#### Troubleshooting

- If you encounter API key issues, verify they're correctly set in `~/.zshrc.local`
- If tools aren't available, try installing manually:
  ```bash
  python3 -m pip install aider-chat
  curl -fsSL https://block.github.io/goose/install.sh | sh
  ```

## 🔐 Sensitive Configuration

See the `examples/` directory for templates of sensitive configuration files. Copy these files and remove the `.example` extension, then add your personal information:

- `config/.gitconfig.local.example` → `config/.gitconfig.local`
- `config/.zshrc.local.example` → `config/.zshrc.local`

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