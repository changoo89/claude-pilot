# Guides Context

## Purpose

Methodology guides providing detailed explanations of development workflows, patterns, and best practices. Guides serve as the single source of truth for methodology, keeping commands focused on execution.

## Key Files

| File | Purpose | Lines | Usage |
|------|---------|-------|-------|
| `prp-framework.md` | SPEC-First requirements methodology | 245 | Planning phase: What, Why, How, Success Criteria |
| `gap-detection.md` | Gap detection review for external services | 255 | Confirmation phase: Detect BLOCKING issues |
| `test-environment.md` | Test framework auto-detection | 212 | Execution phase: Detect test command |
| `review-checklist.md` | Code review criteria and checklist | 258 | Quality phase: Multi-angle review |
| `3tier-documentation.md` | 3-Tier documentation system | 297 | Documentation: L0-L3 hierarchy |
| `parallel-execution.md` | Agent orchestration patterns | 565 | Workflow: Parallel agent delegation |
| `claude-code-standards.md` | Official Claude Code standards | 514 | Reference: Directory structure, conventions |
| `requirements-tracking.md` | User Requirements Collection methodology | 192 | Planning: Track user requirements verbatim |
| `requirements-verification.md` | Requirements Verification methodology | 254 | Confirmation: Verify 100% coverage |
| `instruction-clarity.md` | LLM-readable instruction patterns (NEW) | 271 | Authoring: Clear conditional logic for LLMs |

**Total**: 10 guides, 3063 lines (average: 306 lines per guide)

## Common Tasks

### Create SPEC-First Requirements
- **Task**: Generate clear requirements from user request
- **Guide**: @.claude/guides/prp-framework.md
- **Output**: Plan with What, Why, How, Success Criteria, Constraints
- **Usage**: Used by `/00_plan` command

**Structure**:
```markdown
## What (Functionality)
[What needs to be built]

## Why (Context)
[Business value and rationale]

## How (Approach)
[Implementation strategy]

## Success Criteria
[Measurable acceptance criteria]
```

### Collect User Requirements
- **Task**: Track ALL user requests verbatim to prevent omissions
- **Guide**: @.claude/guides/requirements-tracking.md
- **Output**: User Requirements (Verbatim) table with coverage check
- **Usage**: Used by `/00_plan` command (Step 0)

**Process**:
1. Collect verbatim input (original language, exact wording)
2. Assign UR-IDs (UR-1, UR-2, ...)
3. Build requirements table
4. Update during conversation
5. Present in plan summary

### Verify Requirements Coverage
- **Task**: Verify ALL user requirements are captured in plan
- **Guide**: @.claude/guides/requirements-verification.md
- **Output**: Requirements Coverage Check with 100% verification
- **Usage**: Used by `/01_confirm` command (Step 1.7)

**Process**:
1. Extract User Requirements (Verbatim) table
2. Extract Success Criteria from PRP Analysis
3. Verify 1:1 mapping (UR → SC)
4. BLOCKING if any requirement missing
5. Update plan with coverage check

### Run Gap Detection Review
- **Task**: Detect gaps in plans involving external services
- **Guide**: @.claude/guides/gap-detection.md
- **Output**: List of findings (BLOCKING, Critical, Warning, Suggestion)
- **Usage**: Used by `/01_confirm` command

**Severity levels**:
- **BLOCKING** (🛑): Cannot proceed, triggers Interactive Recovery
- **Critical** (🚨): Must fix before execution
- **Warning** (⚠️): Should fix, advisory
- **Suggestion** (💡): Nice to have

**Categories**:
- External API integration
- Database operations
- Async operations
- File operations
- Environment variables
- Error handling

### Auto-Detect Test Framework
- **Task**: Detect test command and framework
- **Guide**: @.claude/guides/test-environment.md
- **Output**: Test command (pytest, npm test, go test, cargo test)
- **Usage**: Used by Ralph Loop in `/02_execute` command

**Detection order**:
1. Check for `pyproject.toml` → `pytest`
2. Check for `package.json` → `npm test`
3. Check for `go.mod` → `go test ./...`
4. Check for `Cargo.toml` → `cargo test`
5. Fallback → `npm test`

### Run Multi-Angle Code Review
- **Task**: Comprehensive code review from multiple perspectives
- **Guide**: @.claude/guides/review-checklist.md
- **Output**: Review report with findings
- **Usage**: Used by `/90_review` command

**Review angles**:
1. **Tester Agent**: Test coverage, test quality, edge cases
2. **Validator Agent**: Type safety, linting, code quality
3. **Code-Reviewer Agent**: Deep analysis (async bugs, memory leaks, performance)
4. **Plan-Reviewer Agent**: Requirements verification, success criteria

### Organize Documentation
- **Task**: Structure documentation using 3-Tier system
- **Guide**: @.claude/guides/3tier-documentation.md
- **Output**: Organized docs with clear hierarchy
- **Usage**: Used by `/91_document` command

**Hierarchy**:
- **L0** (Immediate): Quick reference, 30-second context
- **L1** (Structural): Architecture, patterns, workflows
- **L2** (Detailed): Implementation details, best practices
- **L3** (Reference): Deep dives, history, alternatives

### Orchestrate Parallel Execution
- **Task**: Coordinate multiple agents working in parallel
- **Guide**: @.claude/guides/parallel-execution.md
- **Output**: Efficient parallel workflow
- **Usage**: Used by `/00_plan`, `/02_execute`, `/90_review` commands

**Parallel patterns**:
- **Planning**: Explorer + Researcher (parallel exploration)
- **Execution**: Multiple Coder agents (parallel SC implementation)
- **Verification**: Tester + Validator + Code-Reviewer (parallel verification)

**Key principles**:
- Analyze dependencies before parallel execution
- Each agent works on different files
- Merge results after parallel phase
- Run verification after all agents complete

### Reference Official Standards
- **Task**: Look up Claude Code conventions
- **Guide**: @.claude/guides/claude-code-standards.md
- **Output**: Official standards and best practices
- **Usage**: Reference for all documentation work

**Contents**:
- Official directory structure
- CLAUDE.md precedence rules
- Command frontmatter reference
- Skill auto-discovery mechanism
- Agent model allocation rationale
- File size limits
- Cross-reference patterns

### Write Clear Instructions for LLMs
- **Task**: Ensure LLMs can reliably understand conditional logic
- **Guide**: @.claude/guides/instruction-clarity.md
- **Output**: Clear, unambiguous instructions
- **Usage**: Authoring command files with conditionals

**Key patterns**:
- Default Behavior First: State default action, then exceptions
- Positive Framing: "EXECUTE" instead of "DO NOT SKIP"
- Separate Sections: Default vs Exception in different sections
- No "unless" in conditional logic

**Before** (confusing):
```markdown
**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):
```

**After** (clear):
```markdown
### Default Behavior
Always invoke Documenter Agent after plan completion.

### Exception: --no-docs flag
When `--no-docs` flag is provided, skip this step entirely.
```

## Patterns

### Guide Structure Pattern
Standard structure for all guides:
```markdown
# Guide Name

## Purpose
[What this guide covers]

## Quick Reference
[Table or summary for fast lookup]

## Core Concepts
[Detailed explanation]

## Examples
[Practical examples]

## See Also
[Related guides and skills]
```

### Methodology Extraction Pattern
Guides contain methodology details that commands reference:
```markdown
In command:
> **Methodology**: @.claude/guides/prp-framework.md

In guide:
[Detailed methodology explanation]
```

**Purpose**: Keep commands concise (150 lines), guides comprehensive (300 lines).

### Cross-Reference Pattern
Guides cross-reference related guides and skills:
```markdown
## See Also
**Related guides**:
- @.claude/guides/parallel-execution.md

**Related skills**:
- @.claude/skills/tdd/SKILL.md
```

### Quick Reference Pattern
Most guides start with a quick reference table for fast lookup:
```markdown
## Quick Reference

| Phase | Goal | Output |
|-------|------|--------|
| Planning | Requirements | Plan file |
| Execution | Implementation | Code + tests |
```

## Usage by Commands

### `/00_plan` (Planning)
- `requirements-tracking.md`: Collect user requirements verbatim
- `prp-framework.md`: Create SPEC-First plan
- `parallel-execution.md`: Orchestrate Explorer + Researcher

### `/01_confirm` (Confirmation)
- `requirements-verification.md`: Verify 100% requirements coverage
- `gap-detection.md`: Run gap detection review
- `parallel-execution.md`: Orchestrate Plan-Reviewer

### `/02_execute` (Execution)
- `test-environment.md`: Auto-detect test command
- `parallel-execution.md`: Orchestrate multiple Coders

### `/90_review` (Review)
- `review-checklist.md`: Multi-angle review criteria
- `parallel-execution.md`: Orchestrate Tester + Validator + Code-Reviewer

### `/91_document` (Documentation)
- `3tier-documentation.md`: Structure documentation
- `claude-code-standards.md`: Apply official standards

## Guide Categories

### Workflow Guides
- `requirements-tracking.md`: User Requirements Collection
- `requirements-verification.md`: Requirements Verification
- `prp-framework.md`: Requirements methodology
- `gap-detection.md`: External service review
- `test-environment.md`: Test framework detection
- `instruction-clarity.md`: LLM-readable instruction patterns (NEW)

### Quality Guides
- `review-checklist.md`: Code review criteria

### Documentation Guides
- `3tier-documentation.md`: Documentation hierarchy
- `claude-code-standards.md`: Official standards

### Orchestration Guides
- `parallel-execution.md`: Agent coordination

## Improvement Opportunities

**Current state**: Average 335 lines per guide (within 300-line target)

**Improvements needed**:
1. `prp-framework.md` (245 lines): Add "Quick Reference" table at top
2. `gap-detection.md` (255 lines): No change needed (good)
3. `test-environment.md` (212 lines): Add link to claude-code-standards.md
4. `review-checklist.md` (258 lines): Ensure completeness
5. `3tier-documentation.md` (297 lines): Add examples
6. `parallel-execution.md` (565 lines): Verify patterns (may need splitting)
7. `requirements-tracking.md` (192 lines): Newly created, good size
8. `requirements-verification.md` (254 lines): Newly created, good size
9. `instruction-clarity.md` (271 lines): Newly created, good size (NEW)

**Note**: `claude-code-standards.md` (514 lines) is newly created and comprehensive.

## File Relationships

### Planning Workflow
```
requirements-tracking.md (collection)
       ↓
prp-framework.md (requirements)
       ↓
gap-detection.md (review)
       ↓
requirements-verification.md (verification)
       ↓
test-environment.md (setup)
```

### Execution Workflow
```
test-environment.md (detect)
       ↓
parallel-execution.md (orchestrate)
```

### Quality Workflow
```
review-checklist.md (criteria)
       ↓
parallel-execution.md (orchestrate)
```

### Documentation Workflow
```
3tier-documentation.md (structure)
       ↓
claude-code-standards.md (standards)
```

## Frontmatter

**Note**: Guides do not require frontmatter (unlike skills and agents).

Guides are referenced directly by commands via cross-references:
```markdown
> **Methodology**: @.claude/guides/prp-framework.md
```

## Size Guidelines

**Target**: 250-300 lines per guide

**When to split**:
- If guide exceeds 300 lines
- If guide covers multiple distinct topics
- If sections can be standalone guides

**Example**: `parallel-execution.md` (565 lines) may need splitting into:
- `parallel-execution-basics.md`: Core patterns
- `parallel-execution-advanced.md`: Complex orchestration

## See Also

**Command specifications**:
- @.claude/commands/CONTEXT.md - Command workflow and usage

**Skill specifications**:
- @.claude/skills/CONTEXT.md - Auto-discoverable capabilities

**Agent specifications**:
- @.claude/agents/CONTEXT.md - Agent capabilities and model allocation

**Documentation standards**:
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation quick reference
- @.claude/guides/claude-code-standards.md - Official Claude Code standards
