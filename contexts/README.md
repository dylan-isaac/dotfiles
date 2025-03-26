# Contexts Directory

This directory contains reference materials, documentation, and context files for AI tools and workflows. These files provide important information for AI models to effectively understand and work with your system.

## Directory Structure

```
.
├── ADW.md          # AI Developer Workflow reference implementation
└── README.md       # This file
```

## Key Files

### ADW.md

This file contains the complete implementation of the Director pattern for AI Developer Workflows. It includes:

- Python implementation of the Director pattern
- Multi-shot examples of how to use the director
- Best practices for creating effective AI workflows
- Troubleshooting guidance and debugging strategies

This file serves as both documentation and as a source for AI assistants to understand the ADW pattern when creating or modifying workflows.

## Purpose

The contexts directory serves several important functions:

1. **AI Reference Materials**: Provides information that AI tools can use to understand your system
2. **Documentation**: Explains complex systems and patterns in detail
3. **Examples**: Shows how to implement specific patterns or workflows
4. **Context Files**: Contains system-level context that should persist across sessions

## Using Context Files with AI

Context files can be provided to AI assistants to give them a better understanding of your system:

### With Aider

```bash
aider -C contexts/ADW.md path/to/file
```

### With Goose

```bash
goose create --context contexts/ADW.md
```

### With Repomix

```bash
repomix --context contexts/ADW.md
```

## Modifying Contexts

### Adding New Context Files

1. Create a new markdown file in the contexts directory
2. Use clear sections and examples
3. Include code snippets where appropriate
4. Link to other relevant context files

### Updating Existing Contexts

When updating existing context files, especially ADW.md:

1. Maintain the overall structure for consistency
2. Add new examples in the same format as existing ones
3. Consider creating a new version rather than modifying extensively
4. Test with AI assistants to ensure the context is helpful

## Best Practices

- Keep contexts focused on a single topic or pattern
- Use markdown formatting for better readability
- Include concrete examples where possible
- Structure information from high-level concepts to specific details
- Include troubleshooting sections for complex patterns