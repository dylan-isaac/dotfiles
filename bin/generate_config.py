#!/usr/bin/env python3
"""
Configuration Generator for Dotfiles

This script generates configuration files for various tools based on profile definitions.
It reads a profile YAML file and outputs configurations for Goose, Aider, Brewfile, etc.
"""

import argparse
import os
import sys
from pathlib import Path
import shutil
import yaml
import datetime

# Determine the dotfiles directory
DOTFILES_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def load_profile(profile_name):
    """Load a profile by name from the profiles directory."""
    profile_path = os.path.join(DOTFILES_DIR, 'config', 'profiles', f'{profile_name}.yaml')
    
    if not os.path.exists(profile_path):
        print(f"Error: Profile '{profile_name}' not found at {profile_path}")
        available_profiles = list_available_profiles()
        if available_profiles:
            print(f"Available profiles: {', '.join(available_profiles)}")
        sys.exit(1)
    
    with open(profile_path, 'r') as f:
        try:
            return yaml.safe_load(f)
        except yaml.YAMLError as e:
            print(f"Error parsing profile '{profile_name}': {e}")
            sys.exit(1)

def list_available_profiles():
    """List all available profiles in the profiles directory."""
    profiles_dir = os.path.join(DOTFILES_DIR, 'config', 'profiles')
    return [os.path.splitext(f)[0] for f in os.listdir(profiles_dir) 
            if f.endswith('.yaml') and not f.endswith('.template')]

def generate_goose_config(profile, output_dir=None):
    """Generate Goose configuration from a profile."""
    if not profile['ai_tools'].get('goose', {}).get('enabled', False):
        print("Goose is disabled in this profile. Skipping configuration.")
        return
    
    goose_config = {
        'GOOSE_PROVIDER': profile['ai_tools']['goose']['default_provider'],
        'GOOSE_MODE': 'smart_approve',
        'GOOSE_MODEL': profile['ai_tools']['goose']['default_model'],
        'extensions': {}
    }
    
    # Add extensions
    for ext in profile['ai_tools']['goose'].get('extensions', []):
        ext_name = ext['name']
        
        # Define extension configuration based on known extensions
        if ext_name == 'developer' or ext_name == 'computercontroller' or ext_name == 'memory' or ext_name == 'tutorial':
            goose_config['extensions'][ext_name] = {
                'enabled': ext['enabled'],
                'name': ext_name,
                'timeout': 300,
                'type': 'builtin'
            }
        elif ext_name == 'time':
            goose_config['extensions'][ext_name] = {
                'args': ['-y', '@dandeliongold/mcp-time'],
                'cmd': 'npx',
                'enabled': ext['enabled'],
                'envs': {},
                'name': ext_name,
                'timeout': 300,
                'type': 'stdio'
            }
        elif ext_name == 'repomix':
            goose_config['extensions'][ext_name] = {
                'args': ['--mcp'],
                'cmd': 'repomix',
                'enabled': ext['enabled'],
                'envs': {},
                'name': ext_name,
                'timeout': 300,
                'type': 'stdio'
            }
        elif ext_name == 'mcp-server-git':
            goose_config['extensions'][ext_name] = {
                'args': ['mcp-server-git'],
                'cmd': 'uvx',
                'enabled': ext['enabled'],
                'envs': {},
                'name': ext_name,
                'timeout': 300,
                'type': 'stdio'
            }
        elif ext_name == 'mcp-server-fetch':
            goose_config['extensions'][ext_name] = {
                'args': ['mcp-server-fetch'],
                'cmd': 'uvx',
                'enabled': ext['enabled'],
                'envs': {},
                'name': ext_name,
                'timeout': 300,
                'type': 'stdio'
            }
        elif ext_name == 'mcp-server-puppeteer':
            goose_config['extensions'][ext_name] = {
                'args': ['-y', '@modelcontextprotocol/server-puppeteer'],
                'cmd': 'npx',
                'enabled': ext['enabled'],
                'envs': {},
                'name': ext_name,
                'timeout': 300,
                'type': 'stdio'
            }
        elif ext_name == 'mcp-installer':
            goose_config['extensions'][ext_name] = {
                'args': ['-y', '@anaisbetts/mcp-installer'],
                'cmd': 'npx',
                'enabled': ext['enabled'],
                'envs': {},
                'name': ext_name,
                'timeout': 300,
                'type': 'stdio'
            }
    
    # Write configuration
    output_path = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'config', 'goose'), 'config.yaml')
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w') as f:
        yaml.dump(goose_config, f, default_flow_style=False)
    
    print(f"Generated Goose configuration at {output_path}")
    return output_path

def generate_aider_config(profile, output_dir=None):
    """Generate Aider configuration from a profile."""
    if not profile['ai_tools'].get('aider', {}).get('enabled', False):
        print("Aider is disabled in this profile. Skipping configuration.")
        return
    
    # Generate aider.conf.yml
    aider_config = {
        'alias': []
    }
    
    # Add model aliases
    for model in profile['ai_tools']['aider'].get('models', []):
        aider_config['alias'].append(f"{model['alias']}:{model['model']}")
    
    # Write aider.conf.yml
    aider_conf_path = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'config', 'aider'), 'aider.conf.yml')
    os.makedirs(os.path.dirname(aider_conf_path), exist_ok=True)
    
    with open(aider_conf_path, 'w') as f:
        yaml.dump(aider_config, f, default_flow_style=False)
    
    # Generate .env file with additional settings
    env_content = f"""# Aider API Keys - Update with your actual keys
OPENAI_API_KEY=
ANTHROPIC_API_KEY=

# Editor configuration
AIDER_EDITOR={profile['ai_tools']['aider']['settings'].get('editor', 'code --wait')}
"""
    
    env_path = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'config', 'aider'), '.env')
    
    with open(env_path, 'w') as f:
        f.write(env_content)
    
    print(f"Generated Aider configurations at {aider_conf_path} and {env_path}")
    return aider_conf_path, env_path

def generate_adw_config(profile, output_dir=None):
    """Generate AI Developer Workflow configurations from a profile."""
    if not profile['ai_tools'].get('adw', {}).get('enabled', False):
        print("ADW is disabled in this profile. Skipping configuration.")
        return
    
    output_dir = output_dir or os.path.join(DOTFILES_DIR, 'config', 'adw')
    os.makedirs(output_dir, exist_ok=True)
    
    # Copy the director.py script if it doesn't exist
    director_path = os.path.join(DOTFILES_DIR, 'bin', 'director.py')
    if not os.path.exists(director_path):
        adw_md_path = os.path.join(DOTFILES_DIR, 'contexts', 'ADW.md')
        if os.path.exists(adw_md_path):
            print(f"Extracting director.py from {adw_md_path}")
            with open(adw_md_path, 'r') as f:
                content = f.read()
                
            # Extract the director.py code
            start_marker = "```python:director.py"
            end_marker = "```"
            
            start_idx = content.find(start_marker)
            if start_idx != -1:
                start_idx += len(start_marker)
                end_idx = content.find(end_marker, start_idx)
                
                if end_idx != -1:
                    director_code = content[start_idx:end_idx].strip()
                    
                    # Create the bin directory if it doesn't exist
                    os.makedirs(os.path.dirname(director_path), exist_ok=True)
                    
                    with open(director_path, 'w') as f:
                        f.write(director_code)
                    
                    # Make it executable
                    os.chmod(director_path, 0o755)
                    print(f"Created director.py at {director_path}")
                else:
                    print("Failed to extract director.py code from ADW.md")
        else:
            print(f"Warning: ADW.md not found at {adw_md_path}")
    
    # Generate workflow config files
    for workflow in profile['ai_tools']['adw'].get('workflows', []):
        workflow_name = workflow['name']
        workflow_config = {
            'prompt': f"prompts/{workflow_name}_prompt.md",
            'coder_model': workflow['coder_model'],
            'evaluator_model': workflow['evaluator_model'],
            'max_iterations': workflow['max_iterations'],
            'execution_command': "echo 'Execution command not configured'",
            'context_editable': [],
            'context_read_only': [],
            'evaluator': "default"
        }
        
        # Write configuration
        workflow_path = os.path.join(output_dir, f"{workflow_name}.yaml")
        
        with open(workflow_path, 'w') as f:
            yaml.dump(workflow_config, f, default_flow_style=False)
        
        # Create a placeholder prompt file
        prompt_dir = os.path.join(output_dir, 'prompts')
        os.makedirs(prompt_dir, exist_ok=True)
        
        prompt_path = os.path.join(prompt_dir, f"{workflow_name}_prompt.md")
        if not os.path.exists(prompt_path):
            with open(prompt_path, 'w') as f:
                f.write(f"""# {workflow_name.title()} Workflow Prompt

## Objective
Define the objective of this workflow.

## Implementation Details
1. Step 1
2. Step 2
3. Step 3

## Technical Requirements
- Requirement 1
- Requirement 2
- Requirement 3
""")
        
    print(f"Generated ADW configurations in {output_dir}")
    return output_dir

def generate_brewfile(profile, output_dir=None):
    """Generate a Brewfile from a profile."""
    if not profile.get('homebrew', {}).get('enabled', False):
        print("Homebrew is disabled in this profile. Skipping Brewfile.")
        return
    
    # Determine the output directory
    brew_dir = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'config'), 'brew')
    os.makedirs(brew_dir, exist_ok=True)
    
    # Create the brewfile content
    brewfile_content = "# Brewfile for profile: {}\n# Generated: {}\n\n".format(
        profile.get('name', 'Unknown'),
        datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    )
    
    # Add brew taps
    for tap in profile['homebrew'].get('taps', []):
        brewfile_content += 'tap "{}"\n'.format(tap)
    
    brewfile_content += "\n"
    
    # Add brews
    for brew in profile['homebrew'].get('brews', []):
        if isinstance(brew, dict):
            name = brew['name']
            args = brew.get('args', [])
            args_str = ', '.join(['"{}"'.format(arg) for arg in args]) if args else ''
            brewfile_content += 'brew "{}"'.format(name)
            if args_str:
                brewfile_content += ', {}'.format(args_str)
            brewfile_content += '\n'
        else:
            brewfile_content += 'brew "{}"\n'.format(brew)
    
    brewfile_content += "\n"
    
    # Add casks
    for cask in profile['homebrew'].get('casks', []):
        if isinstance(cask, dict):
            name = cask['name']
            args = cask.get('args', [])
            args_str = ', '.join(['"{}"'.format(arg) for arg in args]) if args else ''
            brewfile_content += 'cask "{}"'.format(name)
            if args_str:
                brewfile_content += ', {}'.format(args_str)
            brewfile_content += '\n'
        else:
            brewfile_content += 'cask "{}"\n'.format(cask)
    
    # Write to profile-specific Brewfile
    brewfile_path = os.path.join(brew_dir, f"Brewfile.{profile['name']}")
    with open(brewfile_path, 'w') as f:
        f.write(brewfile_content)
    
    print(f"Generated Brewfile at {brewfile_path}")
    
    return brewfile_path

def generate_shell_aliases(profile, output_dir=None):
    """Generate shell aliases from a profile."""
    output_path = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'config'), '.aliases')
    
    content = """# Generated aliases from profile: {profile_name}
# These aliases are automatically loaded by .zshrc

""".format(profile_name=profile['name'])
    
    # Add aliases from profile
    for alias in profile['shell'].get('aliases', []):
        content += f"alias {alias['name']}='{alias['command']}'\n"
    
    # Write to file
    with open(output_path, 'w') as f:
        f.write(content)
    
    print(f"Generated shell aliases at {output_path}")
    return output_path

def generate_adw_runner(output_dir=None):
    """Generate a script to run ADW workflows."""
    output_path = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'bin'), 'run_adw.py')
    
    content = """#!/usr/bin/env python3
\"\"\"
AI Developer Workflow Runner

This script runs AI Developer Workflows using the director pattern.
\"\"\"

import argparse
import os
import subprocess
import sys
import yaml

# Determine the dotfiles directory
DOTFILES_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def list_workflows():
    \"\"\"List all available workflows.\"\"\"
    workflows_dir = os.path.join(DOTFILES_DIR, 'config', 'adw')
    workflows = []
    
    if os.path.exists(workflows_dir):
        for f in os.listdir(workflows_dir):
            if f.endswith('.yaml') and not f.startswith('.'):
                workflows.append(os.path.splitext(f)[0])
    
    return workflows

def get_default_workflow(profile=None):
    \"\"\"Get the default workflow from the current or specified profile.\"\"\"
    profile_name = profile or os.environ.get('DOTFILES_PROFILE', 'personal')
    profile_path = os.path.join(DOTFILES_DIR, 'config', 'profiles', f'{profile_name}.yaml')
    
    if os.path.exists(profile_path):
        with open(profile_path, 'r') as f:
            try:
                profile_data = yaml.safe_load(f)
                if profile_data['ai_tools'].get('adw', {}).get('enabled', False):
                    return profile_data['ai_tools']['adw'].get('default_workflow', 'basic')
            except (yaml.YAMLError, KeyError) as e:
                print(f"Error reading profile {profile_name}: {e}")
    
    return 'basic'  # Default fallback

def main():
    parser = argparse.ArgumentParser(description='Run AI Developer Workflows')
    parser.add_argument('workflow', nargs='?', help='Name of the workflow to run')
    parser.add_argument('--list', action='store_true', help='List available workflows')
    parser.add_argument('--profile', help='Use a specific profile')
    parser.add_argument('--prompt', help='Path to a custom prompt file')
    parser.add_argument('--context', help='Path to context file or directory')
    
    args = parser.parse_args()
    
    if args.list:
        workflows = list_workflows()
        if workflows:
            print("Available workflows:")
            for workflow in workflows:
                print(f"  - {workflow}")
        else:
            print("No workflows found.")
        return 0
    
    # Determine which workflow to run
    workflow_name = args.workflow or get_default_workflow(args.profile)
    workflow_path = os.path.join(DOTFILES_DIR, 'config', 'adw', f'{workflow_name}.yaml')
    
    if not os.path.exists(workflow_path):
        print(f"Error: Workflow '{workflow_name}' not found.")
        print("Use --list to see available workflows.")
        return 1
    
    # Run the director with the workflow
    director_path = os.path.join(DOTFILES_DIR, 'bin', 'director.py')
    
    if not os.path.exists(director_path):
        print(f"Error: director.py not found at {director_path}")
        return 1
    
    # Modify workflow with custom prompt if provided
    if args.prompt:
        with open(workflow_path, 'r') as f:
            workflow_data = yaml.safe_load(f)
        
        workflow_data['prompt'] = args.prompt
        
        # Write to a temporary file
        temp_workflow_path = os.path.join('/tmp', f'{workflow_name}_temp.yaml')
        with open(temp_workflow_path, 'w') as f:
            yaml.dump(workflow_data, f)
        
        workflow_path = temp_workflow_path
    
    print(f"Running workflow: {workflow_name}")
    result = subprocess.run([sys.executable, director_path, '-c', workflow_path], check=False)
    return result.returncode

if __name__ == '__main__':
    sys.exit(main())
"""
    
    # Ensure the bin directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    
    with open(output_path, 'w') as f:
        f.write(content)
    
    # Make it executable
    os.chmod(output_path, 0o755)
    
    print(f"Generated ADW runner at {output_path}")
    return output_path

def generate_all_configs(profile_name, output_dir=None):
    """Generate all configurations from a profile."""
    profile = load_profile(profile_name)
    
    # Create output directory
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
    
    # Generate each configuration
    configs = {}
    
    # Goose
    if profile['ai_tools'].get('goose', {}).get('enabled', False):
        configs['goose'] = generate_goose_config(profile, output_dir)
    
    # Aider
    if profile['ai_tools'].get('aider', {}).get('enabled', False):
        configs['aider'] = generate_aider_config(profile, output_dir)
    
    # ADW
    if profile['ai_tools'].get('adw', {}).get('enabled', False):
        configs['adw'] = generate_adw_config(profile, output_dir)
    
    # Brewfile
    configs['brewfile'] = generate_brewfile(profile, output_dir)
    
    # Shell aliases
    configs['aliases'] = generate_shell_aliases(profile, output_dir)
    
    # ADW Runner
    configs['adw_runner'] = generate_adw_runner(output_dir)
    
    return configs

def main():
    parser = argparse.ArgumentParser(description='Generate configurations from profiles')
    parser.add_argument('--profile', '-p', default='personal', help='Profile to use (default: personal)')
    parser.add_argument('--output-dir', '-o', help='Output directory for configurations')
    parser.add_argument('--list', '-l', action='store_true', help='List available profiles')
    parser.add_argument('--apply', '-a', action='store_true', help='Apply the configuration (create symlinks)')
    
    args = parser.parse_args()
    
    if args.list:
        profiles = list_available_profiles()
        if profiles:
            print("Available profiles:")
            for profile in profiles:
                print(f"  - {profile}")
        else:
            print("No profiles found.")
        return 0
    
    try:
        configs = generate_all_configs(args.profile, args.output_dir)
        
        if args.apply:
            # Apply the configurations (create symlinks, etc.)
            apply_configs(args.profile, args.output_dir)
    except Exception as e:
        print(f"Error: {e}")
        return 1
    
    return 0

def safe_create_symlink(source, target):
    """Safely create a symlink, handling existing files and symlinks."""
    if os.path.exists(target):
        if os.path.islink(target):
            os.unlink(target)
        else:
            os.rename(target, f"{target}.bak")
    os.symlink(source, target)

def apply_configs(profile_name, output_dir):
    """Apply the generated configurations to the system."""
    print("\nApplying configurations...")
    
    # Link Goose config
    goose_config_dir = os.path.expanduser("~/.config/goose")
    os.makedirs(goose_config_dir, exist_ok=True)
    goose_config_source = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'config', 'goose'), "config.yaml")
    if os.path.exists(goose_config_source):
        goose_config_dest = os.path.join(goose_config_dir, "config.yaml")
        safe_create_symlink(goose_config_source, goose_config_dest)
        print(f"Linked Goose config to {goose_config_dest}")
    else:
        print(f"Warning: Goose config not found at {goose_config_source}")
    
    # Link Aider config
    aider_config_dir = os.path.join(output_dir or os.path.join(DOTFILES_DIR, 'config', 'aider'))
    aider_config_source = os.path.join(aider_config_dir, "aider.conf.yml")
    if os.path.exists(aider_config_source):
        aider_config_dest = os.path.expanduser("~/.aider.conf.yml")
        safe_create_symlink(aider_config_source, aider_config_dest)
        print(f"Linked Aider config to {aider_config_dest}")
    else:
        print(f"Warning: Aider config not found at {aider_config_source}")
    
    # Link Aider .env
    aider_env_source = os.path.join(aider_config_dir, ".env")
    if os.path.exists(aider_env_source):
        aider_env_dest = os.path.expanduser("~/.env")
        safe_create_symlink(aider_env_source, aider_env_dest)
        print(f"Linked Aider .env to {aider_env_dest}")
    else:
        print(f"Warning: Aider .env not found at {aider_env_source}")
    
    # Link Brewfile
    brew_dir = os.path.join(os.path.dirname(output_dir or os.path.join(DOTFILES_DIR, 'config')), "brew")
    os.makedirs(brew_dir, exist_ok=True)
    
    brewfile_source = os.path.join(brew_dir, f"Brewfile.{profile_name}")
    if os.path.exists(brewfile_source):
        brewfile_dest = os.path.join(brew_dir, "Brewfile")
        safe_create_symlink(brewfile_source, brewfile_dest)
        print(f"Linked Brewfile to {brewfile_dest}")
    else:
        print(f"Warning: Brewfile for profile {profile_name} not found at {brewfile_source}")
    
    # Set current profile
    current_profile_path = os.path.join(os.path.dirname(output_dir or os.path.join(DOTFILES_DIR, 'config')), ".current_profile")
    os.makedirs(os.path.dirname(current_profile_path), exist_ok=True)
    with open(current_profile_path, "w") as f:
        f.write(profile_name)
    print(f"Set current profile to {profile_name}")
    
    # Ensure dotfiles bin directory is in PATH
    dotfiles_bin = os.path.join(DOTFILES_DIR, 'bin')
    zshrc_local = os.path.expanduser("~/.zshrc.local")
    
    if os.path.exists(zshrc_local):
        with open(zshrc_local, 'r') as f:
            zshrc_content = f.read()
        
        if 'export PATH="$HOME/Projects/dotfiles/bin:$PATH"' not in zshrc_content:
            with open(zshrc_local, 'a') as f:
                f.write('\n# Add dotfiles bin to PATH\n')
                f.write('export PATH="$HOME/Projects/dotfiles/bin:$PATH"\n')
            print(f"Added dotfiles bin to PATH in {zshrc_local}")
    
    print("\nConfiguration applied successfully!")
    print("You may need to restart your terminal for some changes to take effect.")

if __name__ == '__main__':
    sys.exit(main()) 