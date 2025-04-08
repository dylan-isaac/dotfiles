# MCP Tools

## Definition
Model Context Protocol (MCP) Tools are interfaces that enable AI models to interact with structured data, APIs, and services through standardized protocols. These tools allow AI assistants to perform actions in the real world through well-defined inputs and outputs, enabling them to extend their capabilities beyond text generation.

## Key Components

1. **MCP Server**: The backend implementation that hosts tools, resources, and prompts
2. **Tools**: Functions that perform specific actions when called by AI models
3. **Resources**: Data made available to models in a structured format
4. **Schemas**: Zod-based type definitions that enforce input validation
5. **Prompts**: Reusable message templates for common interactions

## Accessibility Considerations

When implementing MCP tools, consider these accessibility requirements:

1. **Screen Reader Compatibility**: Return data formatted for screen readers
2. **Keyboard Navigation**: Ensure UI tools support keyboard-only operation
3. **Clear Error Messages**: Provide descriptive error messages
4. **Alternative Text**: Include alt text for any visual content
5. **Color Contrast**: Adhere to WCAG standards (minimum 4.5:1 ratio)
6. **Input Flexibility**: Accept multiple input formats (text, voice, etc.)
7. **Reduced Motion**: Respect user preferences for animations

## Example Implementation

### Basic MCP Tool for Accessible Component Generation

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import fs from "node:fs/promises";
import path from "node:path";
import { processTemplate } from "./template-engine.js";

// Create MCP server
const server = new McpServer({
  name: "Accessible Component Generator",
  version: "1.0.0"
});

// Define component schema with accessibility requirements
const ComponentSchema = z.object({
  name: z.string(),
  type: z.enum(["button", "input", "select", "modal", "card"]),
  description: z.string(),
  accessibilityLevel: z.enum(["A", "AA", "AAA"]).default("AA"),
  features: z.array(z.string()).optional(),
  styles: z.object({
    colorScheme: z.enum(["light", "dark", "high-contrast"]).default("light"),
    fontScale: z.enum(["normal", "large", "x-large"]).default("normal"),
    reducedMotion: z.boolean().default(false)
  }).optional()
});

// Add a tool to generate accessible components
server.tool(
  "generate-accessible-component",
  ComponentSchema,
  async (params) => {
    // Load appropriate template based on component type
    const templatePath = path.join(
      "templates", 
      `${params.type}-component.hbs`
    );
    
    try {
      const template = await fs.readFile(templatePath, "utf-8");
      
      // Process template with accessibility considerations
      const componentCode = processTemplate(template, {
        ...params,
        // Add ARIA attributes based on component type
        aria: getAriaAttributes(params.type, params.description),
        // Add keyboard handlers
        keyboardSupport: getKeyboardHandlers(params.type),
        // Format styles for appropriate contrast
        styles: getAccessibleStyles(
          params.styles?.colorScheme || "light",
          params.styles?.fontScale || "normal",
          params.accessibilityLevel
        )
      });
      
      // Create the component file
      const fileName = `${params.name.toLowerCase().replace(/\s+/g, "-")}.tsx`;
      await fs.writeFile(fileName, componentCode);
      
      // Create accessibility documentation
      const a11yDocs = generateA11yDocs(params);
      await fs.writeFile(`${fileName}.a11y.md`, a11yDocs);
      
      return {
        content: [{
          type: "text",
          text: `Successfully generated accessible ${params.type} component: ${fileName}\n\nAccessibility documentation: ${fileName}.a11y.md`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: "error",
          text: `Failed to generate component: ${error.message}`
        }]
      };
    }
  }
);

// Add a resource to provide accessibility guidelines
server.resource(
  "accessibility-guidelines",
  "accessibility-guidelines://{level}",
  async (uri) => {
    const level = uri.pathname.split("/").pop() || "AA";
    const guidelinesPath = path.join("resources", `wcag-${level}.md`);
    
    try {
      const guidelines = await fs.readFile(guidelinesPath, "utf-8");
      
      return {
        contents: [{
          uri: uri.href,
          text: guidelines
        }]
      };
    } catch (error) {
      return {
        contents: [{
          uri: uri.href,
          text: `Failed to load accessibility guidelines: ${error.message}`
        }]
      };
    }
  }
);

// Example prompt for generating accessible components
server.prompt(
  "create-accessible-component",
  { 
    componentType: z.enum(["button", "input", "select", "modal", "card"]),
    description: z.string(),
    accessibilityLevel: z.enum(["A", "AA", "AAA"]).optional()
  },
  ({ componentType, description, accessibilityLevel }) => ({
    messages: [{
      role: "user",
      content: {
        type: "text",
        text: `Create an accessible ${componentType} component with the following description: "${description}". ${accessibilityLevel ? `It should meet WCAG ${accessibilityLevel} standards.` : "It should meet WCAG AA standards by default."}`
      }
    }]
  })
);

// Helper functions for accessibility features
function getAriaAttributes(componentType, description) {
  const baseAttrs = {
    "aria-label": description
  };
  
  switch (componentType) {
    case "button":
      return {
        ...baseAttrs,
        "role": "button",
        "aria-pressed": "false"
      };
    case "input":
      return {
        ...baseAttrs,
        "aria-required": "false",
        "aria-invalid": "false"
      };
    case "select":
      return {
        ...baseAttrs,
        "aria-expanded": "false",
        "aria-haspopup": "listbox"
      };
    case "modal":
      return {
        ...baseAttrs,
        "role": "dialog",
        "aria-modal": "true"
      };
    case "card":
      return {
        ...baseAttrs,
        "role": "region"
      };
    default:
      return baseAttrs;
  }
}

function getKeyboardHandlers(componentType) {
  switch (componentType) {
    case "button":
      return {
        "onKeyDown": "handleKeyDown",
        "keyboardTriggers": ["Enter", "Space"]
      };
    case "input":
      return {
        "onKeyDown": "handleKeyDown"
      };
    case "select":
      return {
        "onKeyDown": "handleSelectKeyboard",
        "keyboardTriggers": ["Enter", "Space", "ArrowDown", "ArrowUp"]
      };
    case "modal":
      return {
        "onKeyDown": "handleModalKeyboard",
        "keyboardTriggers": ["Escape"]
      };
    case "card":
      return {
        "onKeyDown": "handleKeyDown",
        "keyboardTriggers": ["Enter"]
      };
    default:
      return {};
  }
}

function getAccessibleStyles(colorScheme, fontScale, accessibilityLevel) {
  const baseStyles = {
    light: {
      textColor: "#333333",
      backgroundColor: "#ffffff",
      accentColor: "#0056b3",
      focusOutlineColor: "#0066CC"
    },
    dark: {
      textColor: "#f0f0f0",
      backgroundColor: "#121212",
      accentColor: "#4c9aff",
      focusOutlineColor: "#66aaff"
    },
    "high-contrast": {
      textColor: "#ffffff",
      backgroundColor: "#000000",
      accentColor: "#ffff00",
      focusOutlineColor: "#ffffff"
    }
  };
  
  const fontScales = {
    normal: 1,
    large: 1.25,
    "x-large": 1.5
  };
  
  // Enhance contrast for higher accessibility levels
  if (accessibilityLevel === "AAA") {
    if (colorScheme === "light") {
      baseStyles.light.textColor = "#000000";
    } else if (colorScheme === "dark") {
      baseStyles.dark.textColor = "#ffffff";
    }
  }
  
  return {
    ...baseStyles[colorScheme],
    fontScale: fontScales[fontScale],
    focusOutline: `3px solid ${baseStyles[colorScheme].focusOutlineColor}`,
    reducedMotionTransitions: "none"
  };
}

function generateA11yDocs(params) {
  return `# Accessibility Documentation for ${params.name}

## Overview
This ${params.type} component was designed to meet WCAG ${params.accessibilityLevel} standards.

## Accessibility Features
- Screen reader support via ARIA attributes
- Keyboard navigation support
- High contrast color options
- Scalable text
- Reduced motion support (when enabled)

## ARIA Attributes
${Object.entries(getAriaAttributes(params.type, params.description))
  .map(([key, value]) => `- \`${key}="${value}"\``)
  .join("\n")}

## Keyboard Interaction
${Object.entries(getKeyboardHandlers(params.type))
  .filter(([key]) => key === "keyboardTriggers")
  .map(([_, triggers]) => 
    Array.isArray(triggers) 
      ? triggers.map(key => `- ${key}`).join("\n") 
      : ""
  )
  .join("\n") || "- No specific keyboard interactions"}

## Testing Checklist
- [ ] Verified with NVDA screen reader
- [ ] Tested keyboard-only navigation
- [ ] Validated color contrast (minimum ratio: ${params.accessibilityLevel === "AAA" ? "7:1" : "4.5:1"})
- [ ] Tested with zoom at 200%
- [ ] Confirmed functionality with reduced motion settings
`;
}

// Start the MCP server
server.listen(3000, () => {
  console.log("MCP Server is running on port 3000");
});
```

### Simplified MCP Tool for Aider Integration with Goose

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { execSync } from "child_process";
import fs from "node:fs/promises";
import path from "path";

// Create MCP server for integrating Aider with Goose
const server = new McpServer({
  name: "Aider-Goose Integration",
  version: "1.0.0"
});

// Define schema for running Aider in Director Pattern mode
const AiderDirectorSchema = z.object({
  workingDirectory: z.string(),
  specification: z.string(),
  modelsConfig: z.object({
    coder: z.string().default("gpt-4o"),
    evaluator: z.string().default("claude-3-sonnet-20240620")
  }).optional(),
  maxIterations: z.number().default(3),
  accessibilityLevel: z.enum(["A", "AA", "AAA"]).default("AA")
});

// Add a tool to run Aider in Director Pattern mode
server.tool(
  "run-aider-director",
  AiderDirectorSchema,
  async (params) => {
    // Ensure working directory exists
    await fs.mkdir(params.workingDirectory, { recursive: true });
    
    // Create specification file with accessibility requirements
    const specPath = path.join(params.workingDirectory, "director-spec.md");
    const specWithA11y = `# Component Specification
    
${params.specification}

## Accessibility Requirements
- Must meet WCAG ${params.accessibilityLevel} standards
- Include proper ARIA attributes
- Support keyboard navigation
- Maintain color contrast ratio of ${params.accessibilityLevel === "AAA" ? "7:1" : "4.5:1"} minimum
- Provide text alternatives for non-text content
- Support screen readers through semantic HTML
`;
    
    await fs.writeFile(specPath, specWithA11y);
    
    // Create configuration file for Aider
    const aiderConfigPath = path.join(params.workingDirectory, ".aider.conf.yml");
    const aiderConfig = `
model: ${params.modelsConfig?.coder || "gpt-4o"}
edit_format: diff
show_diffs: true
auto_commits: false
`;
    
    await fs.writeFile(aiderConfigPath, aiderConfig);
    
    // Create evaluation script
    const evalScriptPath = path.join(params.workingDirectory, "evaluate.js");
    const evalScript = `
// Accessibility evaluation script
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Run accessibility checks
try {
  // Run axe-core checks (assumes axe-cli is installed)
  const axeResults = execSync('npx axe --exit --stdout .', {
    cwd: process.cwd(),
    encoding: 'utf8'
  });
  
  // Run manual checks for keyboard navigation
  // This would be more sophisticated in a real implementation
  
  // Prepare results
  const results = {
    accessibility: {
      passed: !axeResults.includes('Found'),
      issues: axeResults.includes('Found') ? 
        axeResults.split('\\n').filter(line => line.includes('Found')) : []
    },
    recommendations: []
  };
  
  // Add recommendations for common issues
  if (results.accessibility.issues.length > 0) {
    results.recommendations.push(
      'Add proper ARIA attributes to interactive elements',
      'Ensure color contrast meets WCAG ${params.accessibilityLevel} standards',
      'Add keyboard navigation support to interactive elements'
    );
  }
  
  // Write results to file
  fs.writeFileSync(
    path.join(process.cwd(), 'evaluation-results.json'),
    JSON.stringify(results, null, 2)
  );
  
  process.exit(results.accessibility.passed ? 0 : 1);
} catch (error) {
  console.error('Evaluation failed:', error);
  process.exit(1);
}
`;
    
    await fs.writeFile(evalScriptPath, evalScript);
    
    // Create package.json with dependencies
    const packageJsonPath = path.join(params.workingDirectory, "package.json");
    const packageJson = `{
  "name": "accessibility-component-generator",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "evaluate": "node evaluate.js"
  },
  "dependencies": {
    "axe-cli": "^4.7.3"
  }
}`;
    
    await fs.writeFile(packageJsonPath, packageJson);
    
    try {
      // Initialize working directory
      execSync(`cd ${params.workingDirectory} && npm install`, { encoding: 'utf8' });
      
      // Run Aider in a loop (Director Pattern)
      let iteration = 0;
      let success = false;
      
      while (iteration < params.maxIterations && !success) {
        console.log(`Starting iteration ${iteration + 1}/${params.maxIterations}`);
        
        // Run Aider with appropriate prompt
        const prompt = iteration === 0 
          ? `Create components based on the specification in director-spec.md. Focus on meeting the accessibility requirements.`
          : `Review the evaluation results in evaluation-results.json and fix the accessibility issues.`;
        
        execSync(`cd ${params.workingDirectory} && aider --model ${params.modelsConfig?.coder || "gpt-4o"} --input "${prompt}"`, 
          { encoding: 'utf8' });
        
        // Run evaluation
        try {
          execSync(`cd ${params.workingDirectory} && npm run evaluate`, { encoding: 'utf8' });
          success = true;
        } catch (error) {
          // Evaluation failed, continue to next iteration
          console.log("Evaluation failed, continuing to next iteration");
          iteration++;
        }
      }
      
      // Generate final report
      const reportPath = path.join(params.workingDirectory, "a11y-report.md");
      const evalResults = JSON.parse(
        await fs.readFile(
          path.join(params.workingDirectory, "evaluation-results.json"), 
          "utf-8"
        )
      );
      
      const report = `# Accessibility Implementation Report

## Overview
- Specification: ${specPath}
- Accessibility Level: WCAG ${params.accessibilityLevel}
- Iterations: ${iteration + 1}
- Success: ${success ? "Yes" : "No"}

## Accessibility Status
${evalResults.accessibility.passed 
  ? "✅ All accessibility checks passed" 
  : "❌ Some accessibility checks failed"}

${evalResults.accessibility.issues.length > 0 
  ? "### Issues\n" + evalResults.accessibility.issues.map(issue => `- ${issue}`).join("\n")
  : ""}

${evalResults.recommendations.length > 0
  ? "### Recommendations\n" + evalResults.recommendations.map(rec => `- ${rec}`).join("\n")
  : ""}

## Files Created
${(await fs.readdir(params.workingDirectory))
  .filter(file => ![
    ".aider.conf.yml", 
    "director-spec.md", 
    "evaluate.js", 
    "package.json", 
    "package-lock.json", 
    "node_modules", 
    "evaluation-results.json",
    "a11y-report.md"
  ].includes(file))
  .map(file => `- ${file}`)
  .join("\n")}
`;
      
      await fs.writeFile(reportPath, report);
      
      return {
        content: [{
          type: "text",
          text: `Completed Aider Director Pattern run with ${iteration + 1} iterations.\nSuccess: ${success}\nFull report available at: ${reportPath}`
        }]
      };
    } catch (error) {
      return {
        content: [{
          type: "error",
          text: `Failed to run Aider Director Pattern: ${error.message}`
        }]
      };
    }
  }
);

// Add a resource for accessibility guidelines
server.resource(
  "wcag-guidelines",
  "wcag-guidelines://{level}",
  async (uri) => {
    const level = uri.pathname.split("/").pop() || "AA";
    
    const guidelines = {
      "A": `# WCAG 2.1 Level A Guidelines (Essential)

- Text alternatives for non-text content
- Captions for videos
- Content can be presented in different ways
- Content is easier to see and hear
- Users have enough time to read and use content
- Content does not cause seizures
- Users can navigate, find content, and determine where they are
- Users can use different input devices beyond keyboard
- Make it easier to use inputs other than keyboard`,

      "AA": `# WCAG 2.1 Level AA Guidelines (Strong)

## All Level A requirements, plus:

- Captions for live audio
- Audio descriptions for video content
- Content can be presented in different ways
- Content is easier to see and hear
- Users can navigate, find content, and determine where they are
- Text is readable and understandable
- Content appears and operates in predictable ways
- Users are helped to avoid and correct mistakes
- Minimum contrast ratio of 4.5:1 for normal text`,

      "AAA": `# WCAG 2.1 Level AAA Guidelines (Exceptional)

## All Level A and AA requirements, plus:

- Sign language for all audio
- Extended audio description for videos
- Text simplification
- Pronunciation guidance for unusual words
- Reading level appropriate for lower secondary education
- Consistent help and navigation
- Error prevention for all functionality
- Minimum contrast ratio of 7:1 for normal text`
    };
    
    return {
      contents: [{
        uri: uri.href,
        text: guidelines[level] || guidelines["AA"]
      }]
    };
  }
);

// Example prompt for Goose to use the Aider Director tool
server.prompt(
  "create-accessible-feature",
  { 
    featureDescription: z.string(),
    accessibilityLevel: z.enum(["A", "AA", "AAA"]).optional()
  },
  ({ featureDescription, accessibilityLevel }) => ({
    messages: [{
      role: "user",
      content: {
        type: "text",
        text: `Create a new accessible feature based on this description: "${featureDescription}". ${accessibilityLevel ? `It should meet WCAG ${accessibilityLevel} standards.` : "It should meet WCAG AA standards by default."}\n\nPlease use the run-aider-director tool to implement this feature.`
      }
    }]
  })
);

// Start the MCP server
server.listen(3001, () => {
  console.log("Aider-Goose Integration MCP Server is running on port 3001");
});
```

## Use Cases for MCP Tools in AI Development Workflows

1. **Autonomous Code Generation**: Create tools that generate code from specifications
2. **Accessibility Testing**: Validate components against accessibility standards
3. **Workflow Automation**: Chain together development tasks in a defined sequence
4. **Feature Scaffolding**: Generate starter code for new features with best practices built-in
5. **Interactive Tutorials**: Create guided learning experiences for developers
6. **Design System Integration**: Connect AI assistants to component libraries
7. **Documentation Generation**: Auto-generate accessible documentation from code

## Related Terms
- **AI Developer Workflow (ADW)**: A structured approach to AI-assisted development
- **Director Pattern**: An autonomous coding pattern that uses feedback loops
- **Aider**: An AI coding assistant compatible with MCP tools
- **Goose**: An agent framework that can use MCP tools for development tasks
- **WCAG**: Web Content Accessibility Guidelines that MCP tools should support

## References
- See `docs/mcp/getting-started.md` for basic MCP setup
- See `docs/aider/yaml-config.md` for Aider configuration details
- See `guides/accessibility-best-practices.md` for accessibility implementation guides
- See `examples/mcp-tools/` for additional MCP tool examples

## Aider MCP Server Integration

The Aider MCP Server is a specialized MCP tool designed to integrate Aider's AI coding capabilities with the MCP protocol. This integration enables more sophisticated development workflows and leverages Aider's established capabilities within a standardized MCP framework.

### Key Features

1. **AI Code Generation**: Uses Aider to implement code changes based on prompts
2. **Model Selection**: Supports multiple models through a standardized interface
3. **Architect Mode Support**: Enables separate planning and implementation phases
4. **Git Integration**: Works with Git for version control and context

### Available Tools

The Aider MCP Server exposes two primary tools:

#### 1. `aider_ai_code`

```json
{
  "name": "aider_ai_code",
  "parameters": {
    "ai_coding_prompt": "Implement a responsive navbar component with proper accessibility attributes",
    "relative_editable_files": ["src/components/Navbar.tsx"],
    "relative_readonly_files": ["src/utils/accessibility.ts"],
    "model": "openai/gpt-4o",
    "editor_model": "gemini/gemini-2.5-pro-preview-03-25",
    "use_architect": true,
    "use_git": true
  }
}
```

#### 2. `list_models`

```json
{
  "name": "list_models",
  "parameters": {
    "substring": "gemini"
  }
}
```

### Setup and Configuration

To incorporate the Aider MCP Server into your workflow:

1. **Installation**:
   ```bash
   pip install aider-mcp-server
   ```

2. **Configuration in Claude**:
   ```bash
   claude mcp add aider-mcp-server -s local \
     -- \
     uv --directory . \
     run aider-mcp-server \
     --editor-model "gemini/gemini-2.5-pro-preview-03-25" \
     --current-working-dir "."
   ```

3. **MCP Configuration File** (`.mcp.json`):
   ```json
   {
     "mcpServers": {
       "aider-mcp-server": {
         "type": "stdio",
         "command": "uv",
         "args": [
           "--directory",
           ".",
           "run",
           "aider-mcp-server",
           "--editor-model",
           "gemini/gemini-2.5-pro-preview-03-25",
           "--current-working-dir",
           "."
         ],
         "env": {}
       }
     }
   }
   ```

### Integration with Director Pattern

The Aider MCP Server is particularly valuable in Director Pattern workflows:

```javascript
// Director Pattern with Aider MCP Server
async function directorPatternFlow(spec) {
  let iterations = 0;
  let success = false;
  let feedback = "";
  
  while (iterations < MAX_ITERATIONS && !success) {
    // 1. Generate code with Aider
    const codeResult = await callMcpTool("aider-mcp-server", "aider_ai_code", {
      ai_coding_prompt: `${spec}\n${feedback}`,
      relative_editable_files: getEditableFiles(spec),
      relative_readonly_files: getReadOnlyFiles(spec),
      model: iterations === 0 ? "openai/gpt-4o" : "gemini/gemini-2.5-pro-preview-03-25",
      use_architect: true,
      use_git: true
    });
    
    // 2. Run tests
    const testResults = await runTests();
    
    // 3. Evaluate results
    const evaluation = await evaluateResults(testResults);
    
    // 4. Check for success
    if (evaluation.success) {
      success = true;
      break;
    }
    
    // 5. Generate feedback for next iteration
    feedback = `Previous implementation had these issues:\n${evaluation.issues.join('\n')}`;
    iterations++;
  }
  
  return { success, iterations };
}
```

### Accessibility Benefits

The Aider MCP Server enhances accessibility workflows in several ways:

1. **Specialized Accessibility Prompts**: Create tailored prompts focusing on accessibility requirements
2. **Model Tiering for Accessibility**: Use more capable models for accessibility-critical components
3. **Incremental Improvements**: Make targeted accessibility fixes without rewriting entire components
4. **Validation Integration**: Combine with accessibility testing tools for comprehensive validation

### Example: Accessibility-Focused Implementation

```javascript
// Accessibility-focused implementation with Aider MCP
async function implementAccessibleComponent(component, personas) {
  // Create accessibility-rich prompt
  const accessibilityPrompt = `
    Implement a ${component.type} component that meets WCAG AA standards.
    
    Component requirements:
    ${component.requirements}
    
    This component must be accessible to these personas:
    ${personas.map(p => `- ${p.name}: ${p.description}`).join('\n')}
    
    Accessibility requirements:
    1. Support keyboard navigation with visible focus indicators
    2. Include appropriate ARIA attributes and roles
    3. Maintain color contrast ratio of at least 4.5:1
    4. Provide text alternatives for all non-text content
    5. Ensure screen reader compatibility
  `;
  
  // Run implementation with Aider MCP
  return await callMcpTool("aider-mcp-server", "aider_ai_code", {
    ai_coding_prompt: accessibilityPrompt,
    relative_editable_files: [`src/components/${component.name}.tsx`],
    relative_readonly_files: [
      "src/utils/accessibility.ts", 
      "src/styles/theme.ts"
    ],
    model: "openai/gpt-4o", // Use high-capability model for accessibility
    use_architect: true,
    use_git: true
  });
}
```

By leveraging the Aider MCP Server within your development workflow, you can combine the strengths of Aider's AI coding capabilities with the standardization and interoperability of the MCP protocol, resulting in more efficient, cost-effective, and accessible development processes. 