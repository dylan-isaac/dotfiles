# Principled AI Coding (PAIC)

## Definition
**Principled AI Coding (PAIC)** is a methodology for effectively working with AI coding assistants by applying consistent principles that optimize the interaction between humans and AI models. These principles focus on optimizing prompts, managing context, selecting appropriate models, and implementing structured workflows to produce high-quality code efficiently.

## Key Principles

### 1. Keep It Simple
Focus on solving one problem at a time. Avoid overcomplicating prompts with multiple requests.

**Example:**
```
// Bad approach (too complex):
Add error handling, improve performance, refactor the authentication system, and add a dark mode toggle.

// Good approach (focused):
Add comprehensive error handling to the user registration flow.
```

**T3 Stack Example:**
```
// Bad approach:
Implement the entire user profile system with authentication, preferences, and notifications.

// Good approach:
Create a Prisma schema for the User model with essential profile fields.
```

### 2. Manage the Big Three: Context, Model, Prompt
Ensure alignment between the context (code files), model capabilities, and prompt structure for optimal results.

**Example:**
```
// Before sending a prompt, ensure:
1. Context: All relevant files are available to the AI
2. Model: Using a model powerful enough for the task (e.g., GPT-4o for complex refactoring)
3. Prompt: Clear, specific instructions using Information-Dense Keywords
```

**T3 Stack Implementation:**
```typescript
// Context management for T3 Stack development
function prepareT3Context(task: Task): void {
  // Add essential files based on task type
  if (task.type === 'data_layer') {
    addToContext('prisma/schema.prisma');
    addToContext('src/server/db.ts');
  } else if (task.type === 'api_layer') {
    addToContext('src/server/api/trpc.ts');
    addToContext(`src/server/api/routers/${task.entityName}.ts`);
  } else if (task.type === 'ui_layer') {
    addToContext(`src/components/${task.componentName}.tsx`);
    addToContext('src/styles/globals.css');
  }
  
  // Select appropriate model based on task complexity
  const model = task.complexity === 'high' ? 'gpt-4o' : 'gpt-3.5-turbo';
  
  // Create prompt with appropriate IDKs
  const prompt = createIDKPrompt(task);
  
  // Execute task with aligned context, model, and prompt
  executeAITask(prompt, model);
}
```

### 3. Use Information-Dense Keywords (IDKs)
Employ specific, action-oriented keywords that clearly communicate your intent to the AI assistant.

**Example:**
```
UPDATE chart.py: word_count_bar_chart()
- Top quartile → Green
- Bottom quartile → Red
- Remaining → Blue
```

**T3 Stack Examples with Accessibility:**
```
CREATE src/components/ui/Button.tsx:
IMPLEMENT accessible button component
- Support keyboard navigation
- Include aria-pressed for toggle buttons
- Add focus visible indicators

UPDATE src/components/forms/SignupForm.tsx:
ADD form validation
- Error messages with aria-live
- Required field indicators
- Focus management on submission errors
```

### 4. Balance Context
Provide sufficient code context without overloading the AI with irrelevant files.

**Example:**
```
// Using Aider commands to manage context
/add src/components/Button.tsx
/add src/utils/theme.ts
/drop src/unrelated-file.js
```

**T3 Context Management Example:**
```typescript
// Practical implementation for T3 stack context management
async function manageT3Context(feature: string): Promise<void> {
  // Clear previous context
  clearContext();
  
  // Add core T3 configuration files
  addToContext('package.json');
  addToContext('tsconfig.json');
  
  // Add feature-specific files
  const relatedFiles = await findRelatedFiles(feature);
  for (const file of relatedFiles) {
    addToContext(file);
  }
  
  // Add accessibility utilities for UI components
  if (feature.includes('component')) {
    addToContext('src/utils/accessibility.ts');
  }
  
  // Log context for transparency
  console.log(`Context prepared with ${contextSize()} tokens for feature: ${feature}`);
}
```

### 5. The Plan is the Prompt
Well-crafted planning documents (specifications) serve as effective prompts for AI coding assistants.

**Example:**
```
High-Level Objective:
Add charting and output file functionality to the CLI transcript application.

Mid-Level Objectives:
- Implement bar, pie, and line chart visualization using Matplotlib.
- Create an output format handler for TXT, JSON, Markdown, and YAML formats.

Implementation Notes:
- Use Matplotlib for charting.
- Ensure output files use correct file extensions.

Low-Level Tasks:
1. Create `output_format.py`
   - Define `format_as_json(transcript_analysis: TranscriptAnalysis, word_counts: WordCounts) -> str`
   - Mirror for Markdown, YAML, and TXT formats.
2. Create `charts.py`
   - Define `create_bar_chart(word_counts: WordCounts) -> None`
...
```

**T3 Stack Feature Specification Example:**
```
High-Level Objective:
Implement accessible user authentication system with email verification.

Mid-Level Objectives:
- Create Prisma schema for User model with email verification fields.
- Implement tRPC procedures for registration, login, and verification.
- Build accessible React components for auth forms with validation.

Accessibility Requirements:
- All forms must announce errors using aria-live regions.
- Color contrast minimum ratio of 4.5:1 for all text.
- Keyboard navigation flow should be logical and complete.

Low-Level Tasks:
1. UPDATE prisma/schema.prisma
   - Add User model with email, password, verificationToken fields
2. CREATE src/server/api/routers/auth.ts
   - Implement register, login, verify procedures
3. CREATE src/components/auth/RegisterForm.tsx
   - Include aria attributes for accessibility
   - Implement client-side validation with keyboard support
```

### 6. Close the Loop with Director Pattern
Implement autonomous workflows where AI generates code, executes tests, evaluates results, and refines solutions with minimal human intervention.

**Example:**
```python
# Director Pattern implementation
for i in range(max_iterations):
    prompt = create_prompt(i, evaluation)
    ai_code(prompt)  # Generate code
    output = execute()  # Run tests
    evaluation = evaluate(output)  # Evaluate results
    if evaluation.success:
        break
    # Otherwise, loop continues with refined prompt
```

**T3 Stack Director Implementation:**
```typescript
// Director Pattern for T3 component implementation
async function accessibleComponentDirector(
  componentName: string,
  specification: ComponentSpec
): Promise<boolean> {
  let currentCode = '';
  let iterations = 0;
  let success = false;
  
  // Create initial implementation
  currentCode = await generateInitialComponent(componentName, specification);
  await writeFile(`src/components/${componentName}.tsx`, currentCode);
  
  while (iterations < MAX_ITERATIONS && !success) {
    // Execute tests (Jest + Axe for accessibility)
    const testResult = await runTests(componentName);
    const axeResult = await runAccessibilityTests(componentName);
    
    // Evaluate results
    const evaluation = await evaluateResults(testResult, axeResult);
    
    if (evaluation.success) {
      success = true;
      break;
    }
    
    // Generate improved implementation based on feedback
    const prompt = createFeedbackPrompt(evaluation, currentCode);
    currentCode = await generateImprovedComponent(prompt);
    await writeFile(`src/components/${componentName}.tsx`, currentCode);
    
    iterations++;
  }
  
  return success;
}
```

### 7. Signal Over Noise
Focus on high-value, effective techniques and tools that provide the greatest benefit for your specific coding tasks.

**Example:**
```
// Instead of asking for general improvements:
"Enhance this code."

// Focus on specific, high-value improvements:
"Add error boundary handling for API requests in the UserProfile component."
```

**T3 Stack Signal Example:**
```
// Low-signal approach:
"Make this component better."

// High-signal approach:
"UPDATE UserProfile.tsx:
ENHANCE error handling for tRPC queries
- Add loading states with aria-busy attribute
- Implement error boundaries with accessible error messages
- Add retry functionality with clear user feedback"
```

## Advanced PAIC Techniques

### Architect Mode
Use a two-model approach where one model designs the solution and another implements the code changes.

**Example:**
```
// Using Aider's architect mode
aider --model gpt-4o --architect --editor-model gpt-4o
```

**T3 Stack Architect Implementation:**
```typescript
// Architect pattern for T3 full-stack feature implementation
async function implementT3Feature(featureSpec: FeatureSpec): Promise<void> {
  // Phase 1: Architecture Planning with high-capability model
  const architectModel = 'gpt-4o';
  const architectPlan = await planImplementation(
    featureSpec,
    architectModel
  );
  
  // Log planning phase for transparency
  await createThoughtLog('architect', architectPlan);
  
  // Phase 2: Implementation with specialized models for each layer
  for (const task of architectPlan.tasks) {
    // Select appropriate model based on task type
    const implementationModel = selectModelForTask(task);
    
    // Execute implementation with specialized model
    await implementTask(task, implementationModel);
    
    // Verify implementation
    await verifyTask(task);
  }
  
  // Phase 3: Integration testing
  await runIntegrationTests(featureSpec.name);
}
```

### Spec-Based Coding
Create detailed, structured specifications before asking AI to generate code.

**Example:**
```
// A well-structured spec prompt that follows PAIC principles
High-Level Objective: Create a user authentication system
Mid-Level Objectives:
- Implement JWT-based authentication
- Create login/register forms with validation
- Add secure password storage with bcrypt

Implementation Notes:
- Use Express middleware for auth routes
- Follow OWASP security guidelines

Low-Level Tasks:
1. CREATE src/auth/jwt.js
   - Implement token generation
   - Implement token verification
...
```

**T3 Stack Accessible Feature Specification:**
```
// T3 Stack feature with rich accessibility specifications
High-Level Objective: Create an accessible multi-step form wizard

Mid-Level Objectives:
- Implement form state management with React.useState and Zod validation
- Create accessible navigation between form steps
- Add progress indicators with appropriate ARIA attributes

Accessibility Requirements:
- Keyboard navigation: All form elements must be navigable via Tab key
- Screen reader announcements: Use aria-live to announce step changes
- Focus management: Auto-focus first field in each step, restore focus after submissions
- Error handling: Inline validation with aria-invalid and aria-describedby

Implementation Notes:
- Use headlessui/react for accessible form components
- Follow WAI-ARIA Authoring Practices for wizard pattern
- Implement focus trapping within the active form step

Low-Level Tasks:
1. CREATE src/components/form/FormWizard.tsx
   - Implement container component with step management
   - Add keyboard event handlers for navigation
2. CREATE src/components/form/FormStep.tsx
   - Implement accessible step component with progress indication
   - Add focus management utilities
3. CREATE src/utils/formAccessibility.ts
   - Implement focus management helpers
   - Add announcement utilities for form state changes
```

### Prompt Chaining
Chain multiple prompts together for iterative improvements to code.

**Example:**
```
// First prompt: Implement core functionality
"CREATE user authentication using JWT"

// Second prompt (builds on first): Add security features
"UPDATE authentication system to include rate limiting and prevent brute force attacks"

// Third prompt (builds on previous): Add testing
"ADD unit tests for the JWT authentication system"
```

**T3 Stack Prompt Chaining Example:**
```
// Chain 1: Data Layer Implementation
"CREATE Prisma schema for a blog with User, Post, and Comment models"

// Chain 2: API Layer Implementation
"IMPLEMENT tRPC router for Post CRUD operations using the Prisma schema"

// Chain 3: UI Layer Implementation
"CREATE React component PostList.tsx using the Post tRPC procedures"

// Chain 4: Accessibility Enhancement
"UPDATE PostList.tsx to enhance accessibility:
- Add aria-live region for post updates
- Implement keyboard navigation between posts
- Add screen reader announcements for loading states"

// Chain 5: Testing Implementation
"ADD jest tests for the Post tRPC router"
```

## Practical Implementation in T3 Development

### Accessibility-First PAIC Workflow
```typescript
// Function demonstrating PAIC principles with accessibility focus
async function implementAccessibleT3Feature(
  featureName: string,
  personas: AccessibilityPersona[]
): Promise<void> {
  // 1. Keep It Simple - Break down into focused tasks
  const tasks = breakDownFeature(featureName);
  
  // 2. Manage the Big Three
  for (const task of tasks) {
    const context = prepareT3Context(task);
    const model = selectModelForTask(task);
    const prompt = createAccessibilityFocusedPrompt(task, personas);
    
    // 3. Use IDKs
    const result = await executeWithIDKs(prompt, context, model);
    
    // 4. Balance Context
    cleanupContext();
    
    // 6. Close the Loop - Validate accessibility
    const accessibilityIssues = await validateAccessibility(task.output, personas);
    if (accessibilityIssues.length > 0) {
      // Use director pattern to fix issues
      await fixAccessibilityIssues(task.output, accessibilityIssues);
    }
  }
  
  // 5. Plan is the Prompt - Document implementation for future reference
  documentImplementation(featureName, tasks);
  
  // 7. Signal Over Noise - Focus on high-value improvements
  const keyMetrics = await measureImplementationQuality(featureName);
  console.log(`${featureName} implemented with ${keyMetrics.a11yScore} accessibility score`);
}
```

## Related Concepts
- **AI Developer Workflow (ADW)**: Reusable patterns for common coding tasks using AI.
- **Information-Dense Keywords (IDKs)**: High-value words that efficiently direct AI behavior.
- **Director Pattern**: Autonomous AI coding workflow with feedback loops.
- **Model Context Protocol (MCP)**: Standardized way for AI agents to access tools and data.
- **Accessible Development**: Building applications that are usable by people with disabilities. 