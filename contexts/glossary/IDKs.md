# Information-Dense Keywords (IDKs)

## Definition
**Information-Dense Keywords (IDKs)** are short, clear, action-oriented words that efficiently communicate precise instructions to AI coding assistants, carrying a high amount of meaning and reducing ambiguity. These keywords act as powerful semantic signals that help AI models understand exactly what actions to take on code.

## Key Concepts

### Core IDKs Categories
- **Creation Keywords**: CREATE, ADD, GENERATE, IMPLEMENT
- **Modification Keywords**: UPDATE, MODIFY, EDIT, CHANGE
- **Removal Keywords**: DELETE, REMOVE, STRIP
- **Positional Keywords**: MOVE, RELOCATE, PLACE
- **Replication Keywords**: MIRROR, CLONE, DUPLICATE
- **Declarative Keywords**: FUNCTION, CLASS, VAR, TYPE, CONST

### Usage Patterns
- **Location → Action → Detail**: Structure prompts to specify where, what, and how.
- **File-level IDKs**: Target specific files (e.g., `CREATE output_format.py`)
- **Function-level IDKs**: Target specific functions (e.g., `UPDATE word_count_bar_chart()`)
- **Component-level IDKs**: Target specific components (e.g., `ADD validation to LoginForm`)

## Examples

### Effective IDK Usage
```
CREATE output_format.py:
CREATE def format_as_string(transcript: TranscriptAnalysis) -> str
```

```
UPDATE word_count_bar_chart()
- Top quartile: Green
- Bottom quartile: Red
- Rest: Blue
```

```
MOVE pagination logic to utils.js
```

### Mirror Pattern
The MIRROR keyword is particularly powerful for extending functionality based on existing patterns:
```
UPDATE output_format.py:
ADD format_as_YAML.
MIRROR format_as_JSON.
```

### T3 Stack-Specific IDK Examples
```
CREATE src/server/api/routers/post.ts:
IMPLEMENT tRPC router with createPost, getPosts, and getPostById procedures
```

```
UPDATE src/components/PostForm.tsx:
ADD accessibility attributes to form elements
- aria-label
- role="form"
- required field indicators
```

```
CREATE src/components/ui/AccessibleButton.tsx:
IMPLEMENT button component with WCAG 2.1 AA compliance
```

## Applied IDKs in Development Workflows

### Progressive Refinement Pattern
Start with high-level IDKs and progressively add details:

1. **Initial Request**:
```
CREATE PostList component
```

2. **Refinement**:
```
UPDATE PostList component:
ADD pagination
ADD sorting by date
IMPLEMENT keyboard navigation for accessibility
```

3. **Final Polish**:
```
UPDATE PostList component:
ADD aria-live="polite" to update announcements
IMPROVE focus management when sorting changes
```

### Multi-File Coordination Pattern
Use IDKs to coordinate changes across related files:

```
UPDATE prisma/schema.prisma:
ADD Comment model with relation to Post

CREATE src/server/api/routers/comment.ts:
IMPLEMENT tRPC router for Comment CRUD operations

UPDATE src/pages/posts/[postId].tsx:
ADD CommentSection component integration
```

## Benefits

1. **Reduced Token Usage**: IDKs communicate more with fewer words, reducing token count and costs.
2. **Improved AI Understanding**: Clear, unambiguous instructions lead to more accurate code generation.
3. **Consistency**: Using standardized keywords creates predictable AI responses.
4. **Decreased Cognitive Load**: Both humans and AI can work more efficiently with a common vocabulary.

## Principles for Effective IDK Usage

1. **Be Explicit**: Choose the most specific keyword for the task.
2. **Be Consistent**: Use the same keywords for similar operations.
3. **Start Low-Level**: Begin with detailed prompts and gradually remove excess detail as you gain experience.
4. **Focus on WHAT, not HOW**: Describe the desired outcome rather than implementation details.
5. **Use Language-Specific Keywords**: Adapt keywords to match programming language conventions (e.g., `def` for Python, `function` for JavaScript).

## Connection to PAIC Principles

IDKs form a cornerstone of the "Signal Over Noise" PAIC principle, enabling developers to:

1. **Maintain Focus**: IDKs help maintain the "Keep It Simple" principle by clearly delineating tasks.
2. **Optimize the Big Three**: IDKs provide clear prompts that work with appropriate context and models.
3. **Support Plan as Prompt**: IDKs structure specifications into actionable, AI-friendly instructions.
4. **Enable the Director Pattern**: IDKs create consistent prompts that can be used in automated loops.

### IDKs in Context Pitfalls (PAIC L4)
Common context pitfalls can be addressed with appropriate IDK usage:

- **Missing Context**: Use file-level IDKs to specify exact targets (`UPDATE src/utils/validation.ts`)
- **Irrelevant Context**: Focus IDKs on specific functions or components (`UPDATE calculateTotal()`)
- **Outdated Context**: Use versioning IDKs (`UPDATE v2 of UserProfile component`)

## Related Concepts
- **Big Three Bullseye**: Alignment of prompt, context, and model for optimal AI coding.
- **Prompt Phrasing**: The structured method of formatting prompts for clarity and consistency.
- **Hermes Technique**: Using meta-models to translate novice prompts into information-dense prompts.
- **PAIC Principles**: Methodology for effectively working with AI coding assistants. 