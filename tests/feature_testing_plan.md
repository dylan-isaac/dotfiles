# Feature Testing Plan

## High-Level Testing Areas

1. **Configuration Management**
   - Core shell configuration (.zshrc)
   - Tool configurations
   - Configuration file locations

2. **Profile System**
   - Available profiles
   - Profile switching
   - Profile-specific configurations

3. **AI Tools Integration**
   - Aider setup
   - Goose setup
   - Repomix setup
   - ADW (AI Developer Workflows)

4. **Installation Automation**
   - Main installation script
   - Package installation (Homebrew)
   - Symlink creation

5. **Project Structure**
   - Directory organization
   - Documentation consistency
   - Proper file placement

## Structure Issues to Address

1. Configuration files in root that should be in `config/`:
   - Brewfile
   - Brewfile.personal
   - Brewfile.work
   - Brewfile.bak
   - .current_profile

2. Documentation file placement:
   - ADW.md should be in `contexts/`

## Testing and Restructuring Approach

### Phase 1: Initial Testing
1. Run existing tests to verify current functionality
2. Document any test failures for reference

### Phase 2: Restructuring Configuration Files
1. Move Brewfile and variants to `config/`
2. Update references in installation script and profile system
3. Move `.current_profile` to `config/`
4. Move ADW.md to `contexts/`
5. Update all references in documentation

### Phase 3: Re-Testing After Changes
1. Run tests again to ensure restructuring didn't break functionality
2. Fix any issues that arise

### Phase 4: Documentation Updates
1. Update all README files to reflect new structure
2. Update CHANGELOG.md to record the changes

## Feature-Specific Test Plans

### 1. Configuration Management
- Test affected areas:
  - Install script (`install.sh`)
  - Profile system (`bin/generate_config.py`)
  - Shell configuration loading (`config/.zshrc`)

### 2. Profile System
- Test the entire profile switching workflow:
  ```bash
  dotfiles-profile list
  dotfiles-profile set [profile]
  ```
- Verify that profile settings are correctly applied after switching

### 3. AI Tools Integration
- Focus on ADW workflow:
  ```bash
  ai-workflow --list
  ai-workflow [workflow_name]
  ```
- Verify that the ADW.md references are updated

### 4. Installation Automation
- Test the install script with new locations:
  ```bash
  ./install.sh --profile=personal
  ```

### 5. Project Structure
- Verify documentation consistency
- Check that all moved files are correctly referenced

## Implementation Plan

1. Move Brewfile and variants:
   ```bash
   mkdir -p config/brew
   mv Brewfile* config/brew/
   ```

2. Move ADW.md:
   ```bash
   mv ADW.md contexts/
   ```

3. Move .current_profile:
   ```bash
   mv .current_profile config/
   ```

4. Update all references in code and documentation 