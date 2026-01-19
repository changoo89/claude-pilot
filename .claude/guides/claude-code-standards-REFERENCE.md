# Claude Code Standards Reference

> **Purpose**: Detailed reference for Claude Code official standards
> **Companion**: @.claude/guides/claude-code-standards.md (Quick Reference)

---

## Official Directory Structure (Detailed)

### Complete Layout

```
project-root/
├── .claude/
│   ├── commands/           # Slash commands (8-10 files)
│   │   ├── 00_plan.md      # Create SPEC-First plan
│   │   ├── 01_confirm.md   # Confirm plan + gap detection
│   │   ├── 02_execute.md   # Execute with TDD + Ralph Loop
│   │   ├── 03_close.md     # Archive and commit
│   │   ├── 90_review.md    # Multi-angle code review
│   │   ├── 91_document.md  # Sync documentation
│   │   ├── 92_init.md      # Initialize new project
│   │   ├── 999_release.md  # Bump version + git tag
│   │   └── CONTEXT.md      # Commands navigation
│   ├── guides/             # Methodology guides (6-10 files)
│   │   ├── prp-framework.md           # SPEC-First requirements
│   │   ├── gap-detection.md           # Gap detection review
│   │   ├── test-environment.md        # Test framework detection
│   │   ├── review-checklist.md        # Code review criteria
│   │   ├── 3tier-documentation.md     # 3-Tier documentation
│   │   ├── parallel-execution.md      # Agent orchestration
│   │   ├── todo-granularity.md        # Granular todo breakdown
│   │   ├── claude-code-standards.md   # This file
│   │   └── CONTEXT.md                 # Guides navigation
│   ├── skills/              # Auto-discoverable skills
│   │   ├── tdd/            # Test-Driven Development
│   │   │   ├── SKILL.md     # Quick reference (~80 lines)
│   │   │   └── REFERENCE.md  # Detailed guide (~300 lines)
│   │   ├── ralph-loop/     # Autonomous completion loop
│   │   ├── vibe-coding/    # Code quality standards
│   │   ├── git-master/     # Version control workflow
│   │   ├── documentation-best-practices/
│   │   └── CONTEXT.md      # Skills navigation
│   ├── agents/             # Specialized agents (8 agents)
│   │   ├── explorer.md     # Fast codebase exploration (haiku)
│   │   ├── researcher.md   # External docs research (haiku)
│   │   ├── coder.md        # TDD implementation (sonnet)
│   │   ├── tester.md       # Test writing (sonnet)
│   │   ├── validator.md    # Quality verification (haiku)
│   │   ├── plan-reviewer.md # Plan analysis (sonnet)
│   │   ├── code-reviewer.md # Deep review (opus)
│   │   ├── documenter.md   # Documentation (haiku)
│   │   └── CONTEXT.md      # Agents navigation
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   ├── scripts/hooks/      # Type check, lint, todos
│   └── rules/              # Core workflow rules
├── .pilot/                 # Plan management
│   └── plan/
│       ├── pending/        # Awaiting confirmation
│       ├── in_progress/    # Currently executing
│       ├── done/           # Completed plans
│       └── active/         # Branch pointers
├── scripts/                # Sync and build scripts
├── src/ or lib/            # Source code
├── tests/                  # Test files
├── CLAUDE.md               # Project entry point
└── README.md               # Project README
```

### CLAUDE.md Precedence Rules (Detailed)

**Rule 1: CLAUDE.md is the single source of truth**
- Overrides conflicting information in other docs
- Always check CLAUDE.md first for project-specific conventions
- Project-specific conventions > general best practices

**Rule 2: CLAUDE.md links to CONTEXT.md for navigation**
- Each major folder has CONTEXT.md
- CONTEXT.md provides file-by-file navigation
- Keep CLAUDE.md focused, delegate details to CONTEXT.md
- Use `@.claude/{folder}/CONTEXT.md` cross-references

**Rule 3: Version tracking**
- **Project version**: Line 4 (`> **Version**: X.Y.Z`)
- **Current status**: Line ~23 (`- **Version**: X.Y.Z`)
- **Template version**: Near end (`**Template Version**: claude-pilot X.Y.Z`)
- Keep project version consistent (lines 4 and 23)
- Template version may differ (tracks upstream claude-pilot)

**Version Example**:
```markdown
Line 4:    > **Version**: 4.2.0
Line ~23: - **Version**: 4.2.0
Line ~425: **Template Version**: claude-pilot 4.2.0
```

---

## Command Frontmatter Reference (Detailed)

### Required Frontmatter

**All commands require this frontmatter**:

```yaml
---
description: {trigger-rich description for slash command discovery}
---
```

### Description Guidelines

**Length**: Under 200 characters
**Keywords**: Action verbs (plan, execute, review, document, create, fix)
**Scenarios**: Specific use cases
**Discovery**: Semantic matching for auto-suggestion

### Good vs Bad Examples

**Good Examples**:
```yaml
---
description: Create SPEC-First plan from user request. Use for new features, bug fixes, refactoring.
---

description: Execute implementation with TDD + Ralph Loop. Auto-delegates to GPT on failure.
---

description: Review code from multiple angles. Use for security, architecture, quality verification.
---
```

**Bad Examples**:
```yaml
---
description: Planning command
---

description: Executes things
---

description: Review command for reviewing
---
```

### Auto-Discovery Test

```bash
# Test: Claude Code should suggest command for relevant input
User: "I need to plan a new feature"
# Suggested: /00_plan (because description contains "plan", "new features")

User: "I need to review my code"
# Suggested: /review (because description contains "review")
```

---

## Skill Auto-Discovery (Detailed)

### How Auto-Discovery Works

1. Skills are auto-discovered via frontmatter `description`
2. Claude Code matches user intent to skill descriptions
3. Trigger-rich keywords improve matching accuracy
4. Skills with "use proactively" are suggested automatically

### Required Frontmatter

```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

### Description Quality Checklist

- [ ] Contains action keywords (use, apply, implement, execute, write)
- [ ] Mentions specific scenarios (when testing, when refactoring, after implementing)
- [ ] Under 200 characters
- [ ] Clear and concise
- [ ] Avoids generic phrases ("tool for", "library for", "framework for")

### Good vs Bad Examples

**Good**:
```yaml
---
name: tdd
description: Test-Driven Development cycle (Red-Green-Refactor). Use proactively for implementation tasks with test coverage requirements.
---

name: ralph-loop
description: Autonomous iteration until quality gates pass. Use after code changes to verify tests, type check, lint, coverage.
---

name: vibe-coding
description: Code quality enforcement (≤50 lines functions, ≤200 lines files, ≤3 levels nesting). Apply during Green/Refactor phases.
---
```

**Bad**:
```yaml
---
name: tdd
description: About test driven development methodology
---

name: ralph-loop
description: A skill for autonomous completion loops
---

name: vibe-coding
description: Vibe coding standards for code quality
---
```

### Auto-Discovery Test

```bash
# Test: Search for skill by trigger keyword
grep -r "implementation tasks" .claude/skills/
# Should find: tdd/SKILL.md

grep -r "quality gates pass" .claude/skills/
# Should find: ralph-loop/SKILL.md

grep -r "Green/Refactor" .claude/skills/
# Should find: vibe-coding/SKILL.md
```

---

## Agent Model Allocation (Detailed)

### Model Allocation Strategy

**Match model capabilities to task requirements**

| Model | Characteristics | Best For | Cost | Speed |
|-------|----------------|---------|-------|-------|
| **Haiku** | Fast, pattern-based | Structured, repetitive tasks | Low | Fastest |
| **Sonnet** | Balanced quality/speed | Complex implementation | Medium | Medium |
| **Opus** | Deep reasoning | Critical review | High | Slowest |

### Agent Responsibilities (Detailed)

**explorer (haiku)**
- **Purpose**: Fast codebase exploration
- **Tools**: Glob, Grep, Read
- **Tasks**:
  - Find files by pattern
  - Search for patterns across codebase
  - Read file structure
  - Analyze code organization
- **Why Haiku**: Simple pattern matching, no deep analysis required
- **Example Tasks**:
  - "Find all files using authentication"
  - "Search for API endpoints in routes/"
  - "Analyze project structure"

**researcher (haiku)**
- **Purpose**: External documentation research
- **Tools**: WebSearch, WebFetch, query-docs
- **Tasks**:
  - Find external documentation
  - Research best practices
  - Extract information from docs
  - Summarize findings
- **Why Haiku**: Information retrieval, not synthesis
- **Example Tasks**:
  - "Research JWT best practices"
  - "Find React 19 documentation"
  - "Research TypeScript 5.4 features"

**coder (sonnet)**
- **Purpose**: TDD implementation
- **Tools**: Read, Write, Edit, Bash
- **Tasks**:
  - Red-Green-Refactor cycle
  - Ralph Loop iteration
  - Code implementation
  - Bug fixes
- **Why Sonnet**: Balanced reasoning for implementation tasks
- **Example Tasks**:
  - "Implement user authentication"
  - "Fix null pointer bug"
  - "Refactor validation logic"

**tester (sonnet)**
- **Purpose**: Test writing and execution
- **Tools**: Read, Write, Bash
- **Tasks**:
  - Generate test cases
  - Run test suites
  - Debug test failures
  - Analyze coverage
- **Why Sonnet**: Test strategy requires moderate reasoning
- **Example Tasks**:
  - "Write unit tests for User model"
  - "Add integration tests for auth flow"
  - "Debug failing tests"

**validator (haiku)**
- **Purpose**: Quality verification
- **Tools**: Bash, Read
- **Tasks**:
  - Run type checks (tsc --noEmit, mypy)
  - Run linters (eslint, ruff, gofmt)
  - Extract coverage percentages
  - Verify quality gates
- **Why Haiku**: Deterministic checks, no reasoning required
- **Example Tasks**:
  - "Verify all tests pass"
  - "Check coverage ≥80%"
  - "Run type check and lint"

**plan-reviewer (sonnet)**
- **Purpose**: Plan analysis and gap detection
- **Tools**: Read, Glob, Grep
- **Tasks**:
  - Review plans for completeness
  - Detect gaps in external service integration
  - Verify success criteria
  - Identify missing requirements
- **Why Sonnet**: Analysis requires moderate reasoning
- **Example Tasks**:
  - "Review plan for API integration gaps"
  - "Verify success criteria are measurable"
  - "Detect missing external service calls"

**code-reviewer (opus)**
- **Purpose**: Deep code review
- **Tools**: Read, Glob, Grep, Bash
- **Tasks**:
  - Async bug detection
  - Memory leak analysis
  - Performance issues
  - Security vulnerabilities
  - Code quality assessment
- **Why Opus**: Critical issues require deepest reasoning
- **Example Tasks**:
  - "Review for async bugs and race conditions"
  - "Analyze memory usage patterns"
  - "Security audit of authentication flow"

**documenter (haiku)**
- **Purpose**: Documentation generation
- **Tools**: Read, Write
- **Tasks**:
  - Generate documentation
  - Sync template files
  - Ensure consistency
  - Update API docs
- **Why Haiku**: Template-based generation, no deep reasoning
- **Example Tasks**:
  - "Generate CLAUDE.md from codebase"
  - "Update API documentation"
  - "Sync documentation templates"

---

## File Size Limits (Detailed)

### Why Size Limits Matter

**Performance**:
- Faster context processing (LLM reads less)
- Lower token costs (fewer tokens loaded)
- Better response times (smaller context)

**Maintainability**:
- Focused files (single responsibility)
- Easier updates (clear scope)
- Better discoverability (clear purpose)

**Quality**:
- Prevents bloated files
- Encourages modular design
- Improves code organization

### Size Limits by Type

| Type | Target | Max | Action When Exceeded |
|------|--------|-----|----------------------|
| **Command** | 100 | 150 | Extract methodology to guides |
| **SKILL.md** | 80 | 100 | Move details to REFERENCE.md |
| **REFERENCE.md** | 250 | 300 | Split into multiple guides |
| **Guide** | 250 | 300 | Extract sections to separate guides |
| **Agent** | 150 | 200 | Simplify workflow description |
| **CONTEXT.md** | 120 | 150 | Focus on navigation only |

### Enforcement Strategy

1. **Check line count during review**
   - Use `wc -l` to verify file sizes
   - Check during code review phase

2. **Extract content if limit exceeded**
   - Move detailed content to REFERENCE.md
   - Extract methodology to guides
   - Split large files into focused modules

3. **Use cross-references to preserve information**
   - Link to REFERENCE.md for details
   - Link to methodology guides
   - Maintain information accessibility

---

## Best Practices (Detailed)

### For Commands

**Keep commands focused**:
- Focus on workflow steps
- Extract methodology to guides/skills
- Use cross-references (@.claude/skills/tdd/SKILL.md)

**Preserve MANDATORY ACTION sections**:
- Do NOT change wording
- Do NOT remove agent invocations
- Do NOT modify workflow logic

**Example**:
```markdown
BEFORE (in command):
## TDD Methodology
[200 lines of explanation]

AFTER (in command):
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

### For Skills

**SKILL.md = Quick reference**:
- Quick start (when to use)
- Core concepts (essential patterns only)
- Further reading (links to REFERENCE.md)

**REFERENCE.md = Deep dive**:
- Detailed examples
- Good/bad patterns
- Advanced techniques
- External resources

**Example**:
```markdown
SKILL.md (80 lines):
## Quick Start
### When to Use
### Quick Reference
## Core Concepts
### The TDD Cycle (brief)
## Further Reading
- @.claude/skills/tdd/REFERENCE.md

REFERENCE.md (250 lines):
## Advanced Patterns
[Detailed explanations]
## Test Doubles
[Examples and tables]
## External Resources
[Links to books, articles]
```

### For Agents

**Clear mission statement**:
- What the agent does
- When to use it
- Key principles

**Concise workflow**:
- Don't repeat skill content
- Focus on agent-specific logic
- Use cross-references to skills

**Example**:
```markdown
You are the Coder Agent. Your mission is to implement features using TDD + Ralph Loop.

## Core Principles
- Context isolation: ~80K tokens
- TDD discipline: Red-Green-Refactor
- Ralph Loop: Iterate until quality gates pass

## Workflow
### Phase 2: TDD Cycle
> **Methodology**: @.claude/skills/tdd/SKILL.md
### Phase 3: Ralph Loop
> **Methodology**: @.claude/skills/ralph-loop/SKILL.md
```

### For CONTEXT.md

**Standard structure**:
```markdown
# {Folder} Context
## Purpose
[What this folder does]
## Key Files
| File | Purpose | Lines |
## Common Tasks
- **Task**: Description → Command
## Patterns
[Key patterns in this folder]
## See Also
[Related guides and skills]
```

**Purpose**: Navigation and patterns
- File-by-file overview
- Common tasks with commands
- Key patterns and conventions
- Cross-references to related docs

---

## Cross-Reference Patterns (Detailed)

### Internal Cross-References

**Format**: `@.claude/{path}/{file}`

**Best practices**:
- Use absolute paths from `.claude/` root
- Link to specific files (not folders)
- Include descriptive text
- Verify targets exist

**Examples**:
```markdown
Good:
> **Methodology**: @.claude/skills/tdd/SKILL.md - TDD cycle
See @.claude/guides/parallel-execution.md for orchestration patterns

Bad:
See the TDD skill (not clickable)
See .claude/skills/tdd (ambiguous file)
```

### Cross-Reference Verification

**Manual verification**:
```bash
# Find all cross-references
grep -rh "@.claude/" .claude/ | grep -v "^#"

# Verify each target exists
ls .claude/skills/tdd/SKILL.md
```

**Automated verification** (add to CI):
```bash
#!/bin/bash
# Verify all @.claude/ references exist
REFERENCES=$(grep -rh "@.claude/" .claude/ | grep -v "^#" | sed 's/.*@\.claude\///' | sed 's/).*//' | sort -u)
for REF in $REFERENCES; do
  if ! find .claude -name "$REF" | grep -q .; then
    echo "❌ Broken reference: $REF"
  fi
done
```

---

## Common Patterns (Detailed)

### Command Flow Pattern

```
User Request → /00_plan → Pending Plan
                                    ↓
                              /01_confirm → In Progress Plan
                                                    ↓
                                                  /02_execute → Implementation
                                                                ↓
                                                              /03_close → Done + Commit
```

### Agent Invocation Pattern

All commands use MANDATORY ACTION sections:
```markdown
> **⚠️ MANDATORY ACTION**: YOU MUST invoke {Agent} Agent NOW with:
- Plan path
- Success criteria
- Key constraints
```

### Methodology Extraction Pattern

Extract methodology to guides/skills:
```markdown
BEFORE:
## TDD Methodology (200 lines in command)

AFTER:
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

### Frontmatter Pattern

**Commands**:
```yaml
---
description: {trigger-rich description}
---
```

**Skills**:
```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

**Agents**:
```yaml
---
name: {agent-name}
description: {clear purpose}
model: {haiku|sonnet|opus}
tools: [tool list]
skills: [skill list]
---
```

---

## Version Management (Detailed)

### Version Types

**Project version** (lines 4, 23 in CLAUDE.md):
- Tracks this repository's version
- Format: `X.Y.Z` (major.minor.patch)
- Bump on releases

**Template version** (near end of CLAUDE.md):
- Tracks upstream claude-pilot template
- Format: `claude-pilot X.Y.Z`
- Update when syncing from upstream

### Version Sync Strategy

**Before release**:
1. Update project version in CLAUDE.md (lines 4 and 23)
2. Ensure consistency: `grep "Version" CLAUDE.md` shows same project version
3. Template version may differ (upstream tracking)

**Example**:
```markdown
Line 4:    > **Version**: 4.2.0
Line ~23:  - **Version**: 4.2.0
Line ~425: **Template Version**: claude-pilot 4.2.0
```

---

## Further Reading

**Internal**:
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation standards quick reference
- @.claude/skills/documentation-best-practices/REFERENCE.md - Detailed documentation patterns
- @.claude/guides/3tier-documentation.md - Complete 3-Tier documentation system
- @.claude/guides/parallel-execution.md - Agent orchestration patterns

**External**:
- [Claude Code: Best practices for agentic coding - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code overview - Official Docs](https://code.claude.com/docs/en/overview)
