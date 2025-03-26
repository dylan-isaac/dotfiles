#!/usr/bin/env python3
"""
ADW Creator - Magic Wand for Contextual AI Automation

This script lets you describe an automation in natural language
and creates an AI Developer Workflow for it, contextual to your current directory.
"""

import argparse
import os
import sys
import yaml
import subprocess
from pathlib import Path
import json

# Determine the dotfiles directory
DOTFILES_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIRECTOR_PY = os.path.join(DOTFILES_DIR, "bin", "director.py")
REPOMIX_SCRIPT = os.path.join(DOTFILES_DIR, "bin", "run-repomix.sh")
ADW_DIR = os.path.join(DOTFILES_DIR, "config", "adw")
ADW_CONTEXT = os.path.join(DOTFILES_DIR, "contexts", "ADW.md")

# Default models - can be overridden in profile settings
DEFAULT_CODER_MODEL = "claude-3-sonnet-20240229"
DEFAULT_EVALUATOR_MODEL = "gpt-4o"
DEFAULT_MAX_ITERATIONS = 3

# Flag to enable or disable repomix
ENABLE_REPOMIX = True

def get_current_profile():
    """Get the current profile name from .current_profile file."""
    # Default to personal if not found
    profile_path = os.path.join(DOTFILES_DIR, "config", ".current_profile")
    if os.path.exists(profile_path):
        with open(profile_path, 'r') as f:
            return f.read().strip()
    return "personal"

def get_model_from_profile(profile_name=None):
    """Get preferred AI models from the current profile."""
    if not profile_name:
        profile_name = get_current_profile()
    
    profile_path = os.path.join(DOTFILES_DIR, "config", "profiles", f"{profile_name}.yaml")
    
    if os.path.exists(profile_path):
        try:
            with open(profile_path, "r") as f:
                profile_data = yaml.safe_load(f)
                
                # Get ADW settings if available
                adw_settings = profile_data.get("ai_tools", {}).get("adw", {})
                if adw_settings.get("enabled", False):
                    return {
                        "coder_model": adw_settings.get("coder_model", DEFAULT_CODER_MODEL),
                        "evaluator_model": adw_settings.get("evaluator_model", DEFAULT_EVALUATOR_MODEL),
                        "max_iterations": adw_settings.get("max_iterations", DEFAULT_MAX_ITERATIONS),
                        "enable_repomix": adw_settings.get("enable_repomix", ENABLE_REPOMIX)
                    }
        except Exception as e:
            print(f"Error reading profile: {e}")
    
    # Default values if profile doesn't have ADW settings
    return {
        "coder_model": DEFAULT_CODER_MODEL,
        "evaluator_model": DEFAULT_EVALUATOR_MODEL,
        "max_iterations": DEFAULT_MAX_ITERATIONS,
        "enable_repomix": ENABLE_REPOMIX
    }

def generate_workflow_yaml(description, current_dir, test_command=None, editable_files=None, context_files=None, models=None):
    """Generate a workflow YAML file based on the description and context."""
    if not models:
        models = get_model_from_profile()
    
    # Create a sanitized name for the workflow file
    workflow_name = description.split()[0].lower()
    for char in " ,.!?;:'\"\\/[]{}()":
        workflow_name = workflow_name.replace(char, "")
    workflow_name = f"{workflow_name}_workflow"
    
    # Default test command if none provided
    if not test_command:
        test_command = 'echo "Testing workflow..."'
    
    # If no files specified, include some files from current directory
    if not editable_files:
        editable_files = []
        try:
            # Add up to 5 most relevant files from current directory
            files = [f for f in os.listdir(current_dir) if os.path.isfile(os.path.join(current_dir, f))]
            for f in files[:5]:
                if not f.startswith('.') and not f.endswith(('.pyc', '.class', '.o')):
                    editable_files.append(os.path.join(current_dir, f))
        except Exception as e:
            print(f"Warning: Couldn't list files in current directory: {e}")
    
    # Add dotfiles README as context
    if not context_files:
        context_files = [os.path.join(DOTFILES_DIR, "README.md")]
    
    # Add ADW.md to context_files if exists
    if os.path.exists(ADW_CONTEXT):
        context_files.append(ADW_CONTEXT)
    
    # Create the workflow configuration
    workflow_config = {
        "prompt": description,
        "coder_model": models["coder_model"],
        "evaluator_model": models["evaluator_model"],
        "max_iterations": models["max_iterations"],
        "execution_command": test_command,
        "context_editable": editable_files,
        "context_read_only": context_files,
        "evaluator": "default",
        "log_file": f"logs/{workflow_name}.log"
    }
    
    # Ensure the ADW and logs directories exist
    os.makedirs(ADW_DIR, exist_ok=True)
    os.makedirs(os.path.join(ADW_DIR, "logs"), exist_ok=True)
    
    # Write the workflow file
    workflow_path = os.path.join(ADW_DIR, f"{workflow_name}.yaml")
    with open(workflow_path, "w") as f:
        yaml.dump(workflow_config, f, default_flow_style=False)
    
    return workflow_path, workflow_name

def create_ai_prompt_for_test_generation(description, workflow_name, current_dir):
    """Create a prompt for the AI to generate tests for this workflow."""
    return f"""Generate a test script for the AI Developer Workflow "{workflow_name}" that will validate the success of this automation:

Description: {description}

Context: This workflow will be run in the directory {current_dir}

Please create a test script that:
1. Verifies the workflow executed successfully
2. Checks that the expected changes were made
3. Returns appropriate exit codes (0 for success, non-zero for failure)

The test script should be written in bash and include clear comments explaining what is being tested.
"""

def generate_test_script(description, workflow_name, current_dir):
    """Generate a test script for the workflow using AI."""
    # This would normally call an AI API, but for now we'll create a simple template
    test_script = f"""#!/bin/bash

# Test script for {workflow_name}
# Description: {description}

set -e  # Exit on error

echo "Testing {workflow_name}..."

# Navigate to target directory
cd "{current_dir}" || {{ echo "Failed to navigate to directory"; exit 1; }}

# Run basic validation
echo "Running basic validation..."

# Add specific tests here based on workflow goals

if [ $? -eq 0 ]; then
    echo "✅ Test passed!"
    exit 0
else
    echo "❌ Test failed!"
    exit 1
fi
"""
    
    # Create tests directory if it doesn't exist
    tests_dir = os.path.join(DOTFILES_DIR, "tests", "adw")
    os.makedirs(tests_dir, exist_ok=True)
    
    # Write the test script
    test_path = os.path.join(tests_dir, f"test_{workflow_name}.sh")
    with open(test_path, "w") as f:
        f.write(test_script)
    
    # Make it executable
    os.chmod(test_path, 0o755)
    
    return test_path

def run_repomix(workflow_name, verbose=False):
    """Run repomix after a workflow to create a compact representation."""
    if os.path.exists(REPOMIX_SCRIPT):
        print(f"\nCreating repomix representation for workflow: {workflow_name}")
        
        cmd = [REPOMIX_SCRIPT, f"--workflow={workflow_name}"]
        if verbose:
            print(f"Running: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(cmd, check=False, capture_output=not verbose)
            if result.returncode == 0:
                print("✅ Repomix completed successfully")
                return True
            else:
                print(f"❌ Repomix failed with exit code {result.returncode}")
                if not verbose and result.stderr:
                    print(f"Error: {result.stderr.decode('utf-8')}")
                return False
        except Exception as e:
            print(f"Error running repomix: {e}")
            return False
    else:
        print(f"Warning: repomix script not found at {REPOMIX_SCRIPT}")
        return False

def list_available_workflows():
    """List all available workflows in the ADW directory."""
    if not os.path.exists(ADW_DIR):
        print("No workflows found")
        return
    
    workflows = []
    for file in os.listdir(ADW_DIR):
        if file.endswith(".yaml") and not file.startswith("."):
            workflow_path = os.path.join(ADW_DIR, file)
            try:
                with open(workflow_path, "r") as f:
                    config = yaml.safe_load(f)
                    prompt = config.get("prompt", "No description")
                    workflows.append((file[:-5], prompt))
            except Exception:
                workflows.append((file[:-5], "Could not read workflow"))
    
    if workflows:
        print("\nAvailable workflows:")
        for name, prompt in sorted(workflows):
            print(f"  • {name}: {prompt[:60]}{'...' if len(prompt) > 60 else ''}")
    else:
        print("No workflows found")

def main():
    parser = argparse.ArgumentParser(description="Create and run contextual AI automations")
    parser.add_argument("description", nargs="?", help="Natural language description of what you want to automate")
    parser.add_argument("--files", "-f", nargs="+", help="Files to include in the automation context")
    parser.add_argument("--test", "-t", help="Command to test the automation")
    parser.add_argument("--context", "-c", nargs="+", help="Additional context files to include")
    parser.add_argument("--model", "-m", help="AI model to use (will override profile settings)")
    parser.add_argument("--create-only", action="store_true", help="Only create the workflow, don't run it")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show verbose output")
    parser.add_argument("--list", "-l", action="store_true", help="List available workflows")
    parser.add_argument("--no-repomix", action="store_true", help="Disable running repomix after workflow")
    
    args = parser.parse_args()
    
    # Check if we just want to list workflows
    if args.list:
        list_available_workflows()
        return 0
    
    # Get description from argument or prompt
    description = args.description
    if not description:
        print("What would you like to automate? (describe in natural language)")
        description = input("> ")
    
    # Get current directory
    current_dir = os.getcwd()
    
    # Models configuration
    models = get_model_from_profile()
    if args.model:
        models["coder_model"] = args.model
    
    # Override repomix setting if flag is provided
    if args.no_repomix:
        models["enable_repomix"] = False
    
    # Generate the workflow YAML
    workflow_path, workflow_name = generate_workflow_yaml(
        description=description,
        current_dir=current_dir,
        test_command=args.test,
        editable_files=args.files,
        context_files=args.context,
        models=models
    )
    
    # Generate test script
    test_path = generate_test_script(description, workflow_name, current_dir)
    
    print(f"Created workflow: {workflow_path}")
    print(f"Created test script: {test_path}")
    
    # Run the workflow unless --create-only flag is set
    workflow_success = False
    if not args.create_only:
        if os.path.exists(DIRECTOR_PY):
            print(f"\nRunning workflow: {workflow_name}")
            result = subprocess.run([sys.executable, DIRECTOR_PY, "-c", workflow_path], check=False)
            workflow_success = result.returncode == 0
            print(f"Workflow {'completed successfully' if workflow_success else 'failed'}")
        else:
            print(f"Warning: director.py not found at {DIRECTOR_PY}")
            print("The workflow has been created but cannot be run.")
    
    # Run repomix if the workflow was successful
    if workflow_success and models.get("enable_repomix", ENABLE_REPOMIX):
        run_repomix(workflow_name, args.verbose)
    
    return 0

if __name__ == "__main__":
    sys.exit(main()) 