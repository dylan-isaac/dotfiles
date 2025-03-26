"""
Command-line interface for running PydanticAI-based ADW workflows.
"""

import argparse
import asyncio
import os
import sys
import yaml
from pathlib import Path
from typing import Dict, List, Optional

import pydantic_ai
from .agent import WorkflowAgent
from .models import WorkflowConfig, WorkflowDependencies, ExecutionContext


# Determine the dotfiles directory
DOTFILES_DIR = Path(os.path.expanduser("~/Projects/dotfiles"))
ADW_DIR = DOTFILES_DIR / "config" / "adw"
ADW_CONTEXT = DOTFILES_DIR / "contexts" / "ADW.md"


def list_workflows() -> List[str]:
    """List all available workflows."""
    workflows = []
    
    if ADW_DIR.exists():
        for f in ADW_DIR.glob("*.yaml"):
            if not f.name.startswith(".") and f.name != "workflow.yaml.example":
                workflows.append(f.stem)
    
    return sorted(workflows)


def get_current_profile() -> str:
    """Get the current profile name from .current_profile file."""
    # Default to personal if not found
    profile_path = DOTFILES_DIR / "config" / ".current_profile"
    if profile_path.exists():
        return profile_path.read_text().strip()
    return "personal"


def get_default_workflow(profile: Optional[str] = None) -> str:
    """Get the default workflow from the current or specified profile."""
    profile_name = profile or get_current_profile()
    profile_path = DOTFILES_DIR / "config" / "profiles" / f"{profile_name}.yaml"
    
    if profile_path.exists():
        try:
            with open(profile_path, "r") as f:
                profile_data = yaml.safe_load(f)
                if profile_data.get("ai_tools", {}).get("adw", {}).get("enabled", False):
                    return profile_data["ai_tools"]["adw"].get("default_workflow", "basic")
        except (yaml.YAMLError, KeyError) as e:
            print(f"Error reading profile {profile_name}: {e}")
    
    return "basic"  # Default fallback


def load_workflow(workflow_name: str, custom_prompt: Optional[str] = None) -> WorkflowConfig:
    """Load a workflow configuration from a YAML file."""
    workflow_path = ADW_DIR / f"{workflow_name}.yaml"
    
    if not workflow_path.exists():
        raise FileNotFoundError(f"Workflow '{workflow_name}' not found at {workflow_path}")
    
    with open(workflow_path, "r") as f:
        config_dict = yaml.safe_load(f)
    
    # Add name field to the config
    config_dict["name"] = workflow_name
    
    # If the prompt points to a file, load its contents
    prompt = config_dict.get("prompt", "")
    if isinstance(prompt, str) and prompt.endswith((".md", ".txt")):
        prompt_path = ADW_DIR / prompt
        if prompt_path.exists():
            with open(prompt_path, "r") as f:
                config_dict["prompt"] = f.read()
    
    # Override prompt if custom prompt is provided
    if custom_prompt:
        if os.path.exists(custom_prompt):
            with open(custom_prompt, "r") as f:
                config_dict["prompt"] = f.read()
        else:
            config_dict["prompt"] = custom_prompt
    
    # Convert paths to Path objects
    for path_list in ["context_editable", "context_read_only"]:
        if path_list in config_dict:
            config_dict[path_list] = [
                Path(p) if isinstance(p, str) else p
                for p in config_dict.get(path_list, [])
            ]
    
    # Set log file path to include workflow name
    if "log_file" in config_dict:
        log_path = Path(config_dict["log_file"])
        if not log_path.is_absolute():
            log_path = ADW_DIR / log_path
        config_dict["log_file"] = log_path
    else:
        config_dict["log_file"] = ADW_DIR / "logs" / f"{workflow_name}.log"
    
    return WorkflowConfig(**config_dict)


async def run_workflow(workflow_name: str, custom_prompt: Optional[str] = None, context_dir: Optional[str] = None) -> bool:
    """Run a workflow."""
    try:
        # Load the workflow configuration
        config = load_workflow(workflow_name, custom_prompt)
        
        # If context directory is provided, use files from there
        if context_dir:
            context_path = Path(context_dir)
            if context_path.exists() and context_path.is_dir():
                # Replace editable files with files from the context directory
                config.context_editable = list(context_path.glob("*"))
                
                # Add context directory to reference files
                if context_path not in config.context_read_only:
                    config.context_read_only.append(context_path)
        
        # Create workflow dependencies
        deps = WorkflowDependencies(
            config=config,
            working_directory=Path.cwd(),
            execution_context=ExecutionContext(working_directory=str(Path.cwd())),
        )
        
        # Create and run the workflow agent
        agent = WorkflowAgent(deps)
        success = await agent.run()
        
        return success
    except Exception as e:
        print(f"Error running workflow: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(description="PydanticAI-based ADW workflow runner")
    parser.add_argument("workflow", nargs="?", help="Name of the workflow to run")
    parser.add_argument("--list", action="store_true", help="List available workflows")
    parser.add_argument("--profile", help="Use a specific profile")
    parser.add_argument("--prompt", help="Path to a custom prompt file or prompt text")
    parser.add_argument("--context", help="Path to context file or directory")
    parser.add_argument("--version", action="store_true", help="Show version information")
    
    args = parser.parse_args()
    
    if args.version:
        print(f"PydanticAI ADW version {pydantic_ai.__version__}")
        print(f"PydanticAI version: {pydantic_ai.__version__}")
        return 0
    
    if args.list:
        workflows = list_workflows()
        if workflows:
            print("Available workflows:")
            for workflow in workflows:
                # Load workflow to get prompt
                try:
                    workflow_path = ADW_DIR / f"{workflow}.yaml"
                    with open(workflow_path, "r") as f:
                        config = yaml.safe_load(f)
                        prompt = config.get("prompt", "No description")
                        if isinstance(prompt, str) and prompt.endswith((".md", ".txt")):
                            prompt_path = ADW_DIR / prompt
                            if prompt_path.exists():
                                with open(prompt_path, "r") as pf:
                                    first_line = pf.readline().strip().replace("# ", "")
                                    prompt = first_line
                        if isinstance(prompt, str) and len(prompt) > 60:
                            prompt = prompt[:57] + "..."
                        print(f"  • {workflow}: {prompt}")
                except:
                    print(f"  • {workflow}")
        else:
            print("No workflows found.")
        return 0
    
    # Determine which workflow to run
    workflow_name = args.workflow or get_default_workflow(args.profile)
    if not workflow_name:
        print("Error: No workflow specified and no default workflow found.")
        print("Use --list to see available workflows.")
        return 1
    
    print(f"Running workflow: {workflow_name}")
    
    # Run the workflow
    success = asyncio.run(run_workflow(workflow_name, args.prompt, args.context))
    
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main()) 