# Director Pattern

## Definition
The Director Pattern is an agentic workflow that enables autonomous code generation, testing, and refinement through a closed loop system. It combines a code generation model, execution commands, and an evaluator (often another LLM acting as judge) to iteratively solve programming problems with minimal human intervention. This pattern automates the feedback loop between code creation and validation, allowing AI systems to autonomously progress toward a coding goal.

## Key Components

1. **Coder Model**: An LLM responsible for generating or modifying code based on specifications and feedback
2. **Execution Command**: A CLI command or script that tests, runs, or otherwise evaluates the generated code
3. **Evaluator**: A mechanism (often another LLM) that assesses execution results and decides on success or failure
4. **Feedback Loop**: The system that passes evaluation results back to the coder model for refinement
5. **Success Criteria**: Clear conditions that determine when the task is successfully completed

## Example Implementation

### Basic Director Pattern (YAML Configuration)

```yaml
# director-config.yaml
name: "HTML Component Generator"
description: "Generates HTML components with validation"
max_iterations: 5

coder:
  model: "gpt-4o"
  prompt_template: |
    Create an HTML component based on this specification:
    
    {specification}
    
    {feedback}
    
    Generate the complete HTML file.

executor:
  command: "npm test"
  timeout_seconds: 30
  working_directory: "./components"

evaluator:
  model: "claude-3-sonnet-20240620"
  prompt_template: |
    Review the test results for the HTML component:
    
    Specification:
    {specification}
    
    Test Output:
    {test_output}
    
    Determine if the component meets all requirements.
    Return a JSON object with these fields:
    {
      "success": boolean,
      "issues": [list of specific issues],
      "suggestions": [list of specific fixes]
    }
```

### Python Implementation of Director Pattern

```python
import subprocess
import json
import os
from typing import Dict, List, Any, Optional

class DirectorPattern:
    """
    Implementation of the Director Pattern for autonomous code generation
    """
    
    def __init__(
        self, 
        specification: str,
        max_iterations: int = 5,
        coder_model: str = "gpt-4o",
        evaluator_model: str = "gpt-4o",
        execution_command: str = "npm test",
        working_dir: str = "./",
    ):
        self.specification = specification
        self.max_iterations = max_iterations
        self.coder_model = coder_model
        self.evaluator_model = evaluator_model
        self.execution_command = execution_command
        self.working_dir = working_dir
        self.logs = []
        
    def log(self, stage: str, message: str) -> None:
        """Log a message with timestamp"""
        import datetime
        timestamp = datetime.datetime.now().isoformat()
        log_entry = {
            "timestamp": timestamp,
            "stage": stage,
            "message": message
        }
        self.logs.append(log_entry)
        print(f"[{timestamp}] {stage}: {message}")
        
        # Also write to log file
        with open("director_log.txt", "a") as f:
            f.write(f"[{timestamp}] {stage}: {message}\n")
    
    def run(self) -> Dict[str, Any]:
        """Execute the director pattern workflow"""
        iteration = 0
        success = False
        feedback = "Initial implementation"
        
        while iteration < self.max_iterations and not success:
            self.log("ITERATION", f"Starting iteration {iteration+1}/{self.max_iterations}")
            
            # 1. Generate code
            self.log("CODING", "Generating code with feedback")
            self._generate_code(feedback)
            
            # 2. Execute code
            self.log("EXECUTION", f"Running command: {self.execution_command}")
            exec_result = self._execute_code()
            
            # 3. Evaluate results
            self.log("EVALUATION", "Evaluating execution results")
            eval_result = self._evaluate_results(exec_result)
            
            # 4. Process evaluation results
            if eval_result.get("success", False):
                self.log("SUCCESS", "Evaluation succeeded!")
                success = True
            else:
                issues = eval_result.get("issues", [])
                suggestions = eval_result.get("suggestions", [])
                
                issues_str = "\n- " + "\n- ".join(issues) if issues else "None"
                suggestions_str = "\n- " + "\n- ".join(suggestions) if suggestions else "None"
                
                self.log("FEEDBACK", f"Issues: {issues_str}")
                self.log("FEEDBACK", f"Suggestions: {suggestions_str}")
                
                # Prepare feedback for next iteration
                feedback = f"""
                Previous implementation had these issues:
                {issues_str}
                
                Suggestions for improvement:
                {suggestions_str}
                """
            
            iteration += 1
        
        result = {
            "success": success,
            "iterations": iteration,
            "logs": self.logs,
            "final_evaluation": eval_result
        }
        
        self.log("COMPLETE", f"Process complete. Success: {success}, Iterations: {iteration}")
        return result
    
    def _generate_code(self, feedback: str) -> None:
        """Generate code using the coder model"""
        import aider  # Assuming aider is installed
        
        prompt = f"""
        # Specification
        {self.specification}
        
        # Feedback from previous iteration
        {feedback}
        
        Implement code based on this specification, addressing any feedback provided.
        """
        
        # Write prompt to file for aider
        with open("director_prompt.txt", "w") as f:
            f.write(prompt)
        
        # Call aider to generate code
        cmd = [
            "aider",
            "--model", self.coder_model,
            "--architect",
            "--input-file", "director_prompt.txt"
        ]
        
        subprocess.run(cmd, check=True, cwd=self.working_dir)
    
    def _execute_code(self) -> Dict[str, str]:
        """Execute the code and return results"""
        try:
            result = subprocess.run(
                self.execution_command.split(),
                capture_output=True,
                text=True,
                cwd=self.working_dir
            )
            
            return {
                "returncode": result.returncode,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "success": result.returncode == 0
            }
        except Exception as e:
            self.log("ERROR", f"Execution error: {str(e)}")
            return {
                "returncode": -1,
                "stdout": "",
                "stderr": str(e),
                "success": False
            }
    
    def _evaluate_results(self, exec_result: Dict[str, Any]) -> Dict[str, Any]:
        """Evaluate execution results using the evaluator model"""
        # If execution was successful, can shortcut evaluation
        if exec_result.get("success", False):
            return {"success": True}
        
        # Use aider to evaluate
        prompt = f"""
        # Specification
        {self.specification}
        
        # Execution Results
        Return Code: {exec_result.get('returncode')}
        
        Stdout:
        {exec_result.get('stdout')}
        
        Stderr:
        {exec_result.get('stderr')}
        
        Analyze these execution results and determine if the implementation meets the specification.
        Return a JSON object with these fields:
        1. "success": boolean indicating if implementation meets spec
        2. "issues": array of specific issues identified
        3. "suggestions": array of specific suggestions for fixing the issues
        
        Return ONLY the JSON object, no other text.
        """
        
        # Write evaluation prompt to file
        with open("director_eval.txt", "w") as f:
            f.write(prompt)
        
        # Call aider in ask mode to evaluate
        cmd = [
            "aider",
            "--model", self.evaluator_model,
            "--ask",
            "--input-file", "director_eval.txt"
        ]
        
        result = subprocess.run(
            cmd, 
            capture_output=True, 
            text=True, 
            check=True,
            cwd=self.working_dir
        )
        
        # Parse JSON result from output
        try:
            output = result.stdout
            
            # Extract JSON from potential text
            start_idx = output.find('{')
            end_idx = output.rfind('}') + 1
            
            if start_idx >= 0 and end_idx > start_idx:
                json_text = output[start_idx:end_idx]
                return json.loads(json_text)
            else:
                self.log("WARNING", "Couldn't find JSON in evaluator output")
                return {"success": False, "issues": ["Evaluator failed to return JSON"]}
                
        except Exception as e:
            self.log("ERROR", f"Evaluation parsing error: {str(e)}")
            return {"success": False, "issues": [f"Evaluation error: {str(e)}"]}


# Example usage
if __name__ == "__main__":
    spec = """
    Create an HTML component for a price filter with these requirements:
    
    1. A slider that lets users select a price range between $0 and $1000
    2. Two input fields showing the min and max selected values
    3. The inputs should update when the slider is moved
    4. The slider should update when the inputs are changed
    5. Add appropriate ARIA attributes for accessibility
    6. Include necessary JavaScript for the interactions
    7. Style with CSS to match modern design principles
    """
    
    director = DirectorPattern(
        specification=spec,
        max_iterations=3,
        execution_command="npx jest price-filter.test.js"
    )
    
    result = director.run()
    
    print("\n=== DIRECTOR PATTERN EXECUTION SUMMARY ===")
    print(f"Success: {result['success']}")
    print(f"Iterations: {result['iterations']}")
    
    if result['success']:
        print("\n✅ Implementation successful!")
    else:
        print("\n❌ Implementation failed after maximum iterations")
        if 'final_evaluation' in result and 'issues' in result['final_evaluation']:
            print("\nRemaining issues:")
            for issue in result['final_evaluation']['issues']:
                print(f"- {issue}")
```

### Real-World Example (Executable Spec for Price Filter Component)

```markdown
# Director Pattern Component Specification

## Component: Price Range Filter

### Requirements
1. Create a price range slider with min/max values
2. Add numeric input fields that sync with the slider
3. Implement all necessary JavaScript for interactivity
4. Include proper ARIA attributes for accessibility
5. Style with a clean, modern appearance

### Files to Create
- price-filter.html
- price-filter.js
- price-filter.css

### Test Command
```bash
npx jest price-filter.test.js
```

### Expected HTML Structure
```html
<div class="price-filter" aria-label="Price range filter">
  <div class="price-filter__inputs">
    <div class="price-filter__input-group">
      <label for="min-price">Min</label>
      <input type="number" id="min-price" min="0" max="1000" value="0" aria-label="Minimum price">
    </div>
    <div class="price-filter__input-group">
      <label for="max-price">Max</label>
      <input type="number" id="max-price" min="0" max="1000" value="1000" aria-label="Maximum price">
    </div>
  </div>
  <div class="price-filter__slider-container">
    <input 
      type="range" 
      id="price-slider" 
      min="0" 
      max="1000" 
      value="500" 
      aria-labelledby="price-slider-label"
    >
    <span id="price-slider-label" class="visually-hidden">Price range slider</span>
  </div>
</div>
```

### Acceptance Criteria
- Slider must update when input fields change
- Input fields must update when slider moves
- All elements must be properly labeled with ARIA attributes
- Component must handle invalid inputs gracefully
- UI must be responsive and work on mobile devices
```

## Director Pattern in MCP Architecture

The Director Pattern can be implemented as an MCP tool that orchestrates workflows with multiple AI agents:

```typescript
import { McpServer, ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { DirectorPatternExecutor } from "./director-pattern.js";

// Create MCP server for Director Pattern
const server = new McpServer({
  name: "Director Pattern MCP Tool",
  version: "1.0.0"
});

// Define schema for director pattern configuration
const DirectorConfigSchema = z.object({
  specification: z.string(),
  maxIterations: z.number().optional().default(5),
  coderModel: z.string().optional().default("gpt-4o"),
  evaluatorModel: z.string().optional().default("gpt-4o"),
  executionCommand: z.string(),
  workingDirectory: z.string().optional().default("./")
});

// Add a tool to run the director pattern
server.tool(
  "run-director-workflow",
  DirectorConfigSchema,
  async (params) => {
    const director = new DirectorPatternExecutor({
      specification: params.specification,
      maxIterations: params.maxIterations,
      coderModel: params.coderModel,
      evaluatorModel: params.evaluatorModel,
      executionCommand: params.executionCommand,
      workingDirectory: params.workingDirectory
    });
    
    const result = await director.run();
    
    return {
      content: [{
        type: "text",
        text: JSON.stringify(result, null, 2)
      }]
    };
  }
);

// Add a resource to expose director logs
server.resource(
  "director-logs",
  "director-logs://latest",
  async (uri) => {
    const logs = await fs.readFile("director_log.txt", "utf-8");
    
    return {
      contents: [{
        uri: uri.href,
        text: logs
      }]
    };
  }
);

// Example prompt for using the director pattern
server.prompt(
  "create-component",
  { specification: z.string() },
  ({ specification }) => ({
    messages: [{
      role: "user",
      content: {
        type: "text",
        text: `Create a component using the Director Pattern based on this specification:\n\n${specification}\n\nPlease implement this component using the run-director-workflow tool, and monitor the results.`
      }
    }]
  })
);
```

## Related Terms
- **AI Developer Workflow (ADW)**: A structured approach to AI-assisted development that often utilizes the Director Pattern
- **Spec-Based AI Coding**: Detailed specifications used as input to the Director Pattern
- **Aider**: An AI coding assistant that can be used in Director Pattern implementations
- **LLM-as-Judge**: Using an LLM as the evaluator component in a Director Pattern
- **Multi-Agent Systems**: Coordination of multiple AI agents to accomplish complex tasks

## References
- See `docs/paic/07-let-the-code-write-itself.md` for detailed explanation of the Director Pattern concept
- See `guides/07-Autonomous-Iteration-Validation.md` for integration examples in the AI Software Development Simulation 