#!/usr/bin/env python3
"""
AI Developer Workflow Runner

This script runs AI Developer Workflows using the director pattern.
"""

import argparse
import os
import subprocess
import sys
import yaml

# Determine the dotfiles directory
DOTFILES_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def list_workflows():
    """List all available workflows."""
    workflows_dir = os.path.join(DOTFILES_DIR, 'config', 'adw')
    workflows = []
    
    if os.path.exists(workflows_dir):
        for f in os.listdir(workflows_dir):
            if f.endswith('.yaml') and not f.startswith('.'):
                workflows.append(os.path.splitext(f)[0])
    
    return workflows

def get_default_workflow(profile=None):
    """Get the default workflow from the current or specified profile."""
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
