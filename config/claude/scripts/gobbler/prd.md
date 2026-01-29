# PRD - Execute a Product Requirements Document

Execute a PRD with full context understanding, implementation planning, and progress tracking.

## Arguments

`<PRD_NUMBER>` - The PRD number to execute (e.g., "003", "003B", "004", "005", etc.)

Example: `/prd 003`

---

## Phase 1: Prime on Project Context

### Read Core Documentation
1. `README.md` - Project overview and architecture
2. `CLAUDE.md` - Project instructions and architecture pattern

### Read Dependency Context
1. Check `docs/PRDs/README.md` for PRD dependencies
2. Verify all dependency PRDs are marked complete
3. If dependencies incomplete: **STOP** and report missing dependencies

### Report Context Understanding
Before proceeding, report:
- Project architecture pattern (monolith with background workers)
- Current phase and completion status
- PRD number being executed
- PRD dependencies and their status
- Existing codebase structure

---

## Phase 2: Review Assigned PRD

### Read PRD File
1. Locate PRD file in `docs/PRD-{NUMBER}*.md`
2. Read complete PRD file
3. Parse key sections:
   - Overview (effort, dependencies)
   - Problem Statement
   - Success Criteria
   - Technical Requirements
   - Deliverables
   - Acceptance Criteria
   - Definition of Done

### Verify Dependencies
For each dependency listed in PRD:
1. Check if dependency PRD is marked complete in `docs/README.md`
2. Verify dependency deliverables exist in codebase
3. If any dependency incomplete: **STOP** and report blocking issues

### Identify Shared Service Dependencies
If PRD is a worker or API endpoint:
1. List all imports from `src/services/` mentioned in PRD
2. Verify these services exist (from PRD-003)
3. If services missing: **STOP** - PRD-003 must be complete first

### Report PRD Understanding
Summarize:
- PRD title and purpose
- Estimated effort
- Dependencies verified (✅ or ❌)
- Key deliverables (files to create/modify)
- Integration points with existing code
- Shared services required

---

## Phase 3: Implementation Strategy

### Think Very Hard About Approach

**For each deliverable in the PRD, plan:**

1. **Order of Implementation**
   - What must be built first?
   - What can be built in parallel?
   - What integration points need attention?

2. **Technical Decisions**
   - Architecture patterns to use
   - Error handling strategy
   - Testing approach
   - Integration with existing code

3. **Challenges & Risks**
   - What could go wrong?
   - Where are the complex parts?
   - What needs extra validation?

4. **Verification Strategy**
   - How to verify each deliverable?
   - What tests to write?
   - How to validate integration?

### Create Implementation Plan

Draft a detailed plan with:

**Phase 1: Foundation (if applicable)**
- Core classes/functions
- Data models
- Configuration

**Phase 2: Core Implementation**
- Main logic
- Service integration
- Business logic

**Phase 3: Integration & Testing**
- Integration with existing components
- Error handling
- Test coverage

**Phase 4: Verification**
- Acceptance criteria checklist
- Integration tests
- Manual testing steps

### Report Implementation Strategy
Present the plan and ask:
- "Does this implementation approach make sense?"
- "Are there any concerns or better approaches?"
- Wait for user confirmation before proceeding

---

## Phase 4: Verification Planning

### Define Success Criteria

**For this PRD to be considered complete:**

1. **Deliverables Created**
   - [ ] All files listed in PRD "Deliverables" section exist
   - [ ] Code follows project patterns and conventions
   - [ ] All imports and dependencies resolve

2. **Acceptance Criteria Met**
   - [ ] Each criterion from PRD "Acceptance Criteria" validated
   - [ ] Manual testing confirms expected behavior
   - [ ] Integration with existing code works

3. **Tests Passing**
   - [ ] Unit tests written and passing
   - [ ] Integration tests written and passing
   - [ ] No regressions in existing tests

4. **Documentation Updated**
   - [ ] Code includes docstrings
   - [ ] README or relevant docs updated if needed
   - [ ] PRD marked complete in index

5. **Integration Verified**
   - [ ] Component runs with rest of application
   - [ ] No errors on startup
   - [ ] End-to-end flow works (if applicable)

### Create Verification Checklist

**Immediate Verification (code complete):**
```
[ ] All files created as specified
[ ] Code passes type checking (mypy)
[ ] No syntax errors
[ ] All imports resolve
[ ] Basic smoke test passes
```

**Functional Verification (feature complete):**
```
[ ] Each acceptance criterion tested manually
[ ] Happy path works end-to-end
[ ] Error cases handled gracefully
[ ] Integration with dependencies works
[ ] Performance acceptable
```

**Final Verification (PRD complete):**
```
[ ] All unit tests pass
[ ] All integration tests pass
[ ] Documentation updated
[ ] No TODOs or placeholders
[ ] Ready for next PRD
```

---

## Phase 5: Update PRD Index

### Mark PRD Status

Update `docs/README.md`:

**If starting PRD:**
```markdown
### PRD-XXX: Title
**Status**: In Progress 🚧
**Started**: YYYY-MM-DD
```

**If PRD complete:**
```markdown
### PRD-XXX: Title ✅
**Status**: Complete
**Completed**: YYYY-MM-DD
```

**If blocked:**
```markdown
### PRD-XXX: Title ⚠️
**Status**: Blocked
**Blocker**: [Dependency PRD or issue description]
```

### Update Implementation Progress

Add implementation notes:
```markdown
**Implementation Notes**:
- Deliverables completed: [list]
- Integration verified: [yes/no]
- Tests passing: [yes/no]
- Next steps: [if applicable]
```

### Track Dependencies

If this PRD unblocks others, note it:
```markdown
**Unblocks**: PRD-XXX, PRD-YYY
```

---

## Phase 6: Execute (After User Approval)

**Only after user confirms the implementation plan:**

1. **Create deliverables** listed in PRD
2. **Follow implementation plan** from Phase 3
3. **Test continuously** as you build
4. **Update PRD index** with progress
5. **Verify completion** using checklist from Phase 4

---

## Important Rules

### ⚠️ Blocking Rules
**STOP and report if:**
- ❌ Dependency PRDs not complete
- ❌ Shared services from PRD-003 missing
- ❌ Required infrastructure not running
- ❌ Conflicting changes in codebase

### ✅ Execution Rules
- All code in monolith (`src/` directory)
- Workers are background asyncio tasks
- Import shared services from `src/services/`
- Follow patterns from existing code
- Test integration continuously

### 📝 Documentation Rules
- Update PRD index in real-time
- Track progress transparently
- Note any deviations from PRD
- Document decisions made

---

## Output Format

### Phase 1 Report: Context
```
# PRD-XXX Context Report

## Project Understanding
- Architecture: [monolith/microservices]
- Current Phase: [1/2/3]
- Completion Status: [X/Y PRDs complete]

## PRD Assignment
- Number: PRD-XXX
- Title: [PRD title]
- Phase: [2/3]
- Estimated Effort: [X days]

## Dependencies
- ✅ PRD-001: Complete
- ✅ PRD-002: Complete
- ❌ PRD-003: **BLOCKER** - Must complete first

## Existing Codebase
[Summary of relevant existing files]
```

### Phase 2 Report: PRD Review
```
# PRD-XXX Review

## Overview
[PRD summary]

## Dependencies Verified
[✅/❌ for each dependency]

## Deliverables
[List of files to create/modify]

## Shared Services Required
[List imports from src/services/]

## Integration Points
[Where this integrates with existing code]
```

### Phase 3 Report: Implementation Plan
```
# PRD-XXX Implementation Plan

## Approach
[Detailed step-by-step plan]

## Order of Operations
1. [Step 1]
2. [Step 2]
...

## Technical Decisions
[Key decisions and rationale]

## Verification Strategy
[How to verify completion]

**Ready to proceed? [Yes/No]**
```

### Phase 4 Report: Verification
```
# PRD-XXX Verification Plan

## Success Criteria
[Checklist from Phase 4]

## Verification Steps
[Manual and automated testing]

## Definition of Done
[Final checklist]
```

### Phase 5: Index Update
```
# PRD Index Updated

Status changed: PRD-XXX → [In Progress/Complete/Blocked]
Updated: docs/PRDs/README.md
```

---

## Example Usage

```bash
# Start PRD-003 (Shared Services)
/prd 003

# Start PRD-004 (PII Worker)
/prd 004

# Start PRD-003B (API Endpoints)
/prd 003B
```

---

## Notes for Implementation

- **Be thorough** in Phase 1-4 (planning)
- **Get approval** before executing (Phase 6)
- **Update index** continuously
- **Verify integration** at each step
- **Ask questions** if anything unclear
- **Think very hard** about approach before coding
