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
- Python setup with pyenv
- Other development tools

### macOS Configuration
- System preferences
- Finder preferences
- Dock configuration
- Safari development settings
- Security & privacy settings

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