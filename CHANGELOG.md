# Changelog

All notable changes to the dotfiles system will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- ADW workflows for documentation and feature verification
- Documentation tests in test suite
- Feature verification test script
- Repomix integration with ADW workflows
- Automatic Repomix documentation after workflow runs
- System test for ADW components
- Comprehensive documentation with README files for each directory
- Created packages directory for better organization of package management
- Added tests directory framework for system integrity verification
- Added ADW.md for system maintenance guidelines
- Created CHANGELOG.md for tracking system changes
- Dedicated logs directory for ADW workflows in config/adw/logs/
- Git security check script for detecting sensitive information in code changes
- Goose extension for GitHub repository stars analysis
- Documentation generator using Repomix for creating component documentation
- Browser automation capabilities with Goose extensions
- Security tests for Git security check feature
- Browser integration tests for Goose extensions

### Changed
- Enhanced ADW creator to support repomix integration
- Test runner now supports documentation tests
- Restructured main README to better explain system components
- Moved Brewfile and variants to config/brew/ directory for better organization
- Moved .current_profile to config/ directory for consistent configuration management
- Moved ADW.md to contexts/ directory for proper documentation organization
- Updated all references to moved files across the codebase
- Improved symlink creation handling in bin/generate_config.py
- Improved log file handling in director.py for better organization and accessibility
- Updated test runner to include security and browser test categories
- Enhanced README with new security, browser automation, and documentation features

### Fixed
- Fixed missing documentation for key system components
- Path issues in shell configuration
- Package conflicts in Brewfile
- Permission handling for executable scripts

## [1.0.0] - The Foundation 🏗️

### Added
- Initial repository structure and documentation
- Core shell configuration with Zsh and Starship
- Profile system for environment-specific settings
- AI tool integration (Aider, Goose, Repomix)
- macOS system preferences configuration
- Git configuration
- Homebrew package installation
- Development tools setup
- Terminal configuration

## [1.1.0] - The Foundation 🏗️

### Added
- Simplified profile system with flag-based approach
- Profile-specific Brewfiles: Brewfile.personal, Brewfile.work, Brewfile.server
- Profile-specific templates for different environments

### Changed
- Removed complex profile system with YAML configuration
- Removed tests directory for a simpler codebase
- Updated installation script to use profile flags
- Updated README.md with new profile system documentation

## 2024-03-01

### Added
- New PydanticAI-based implementation of AI Developer Workflows
- AI-powered installation analyzer (bin/install-analyzer.sh)
- Testing framework for verifying installer functionality
- Automated documentation generation for components
- Repomix integration for context packing

### Changed
- Enhanced template system for profile configuration
- Improved Python environment with UV package manager
- Better structure for Brewfiles to support modular profiles
- Reorganized script documentation

### Fixed
- Improved symlink creation handling in bin/generate_config.py
- Fixed shell integration for iTerm2
- Better GPU detection for AI models
- Enhanced error handling for network operations
- Smarter defaults for .zshrc.local templates

## 2024-02-15

### Added
- AI Developer Workflows (ADW) system
- Aider and Goose integration
- Profile system for environment management
- Machine-specific configuration handling
- Modern CLI tool replacements (eza, bat, ripgrep, etc.)

### Changed
- Reorganized directory structure for better organization
- Enhanced documentation with usage examples
- Modernized zsh configuration

### Fixed
- Numerous bugfixes for shell aliases
- Corrected path handling in configuration scripts
- Fixed environment variable conflicts 