# Claude Code Standards Guide

## Purpose

Official Claude Code directory structure, file conventions, and best practices for the claude-pilot template.

## Quick Reference

| Component | Location | Purpose | Size Limit |
|-----------|----------|---------|------------|
| **CLAUDE.md** | Project root | Project entry point | 400+ lines |
| **Commands** | `.claude/commands/` | Slash commands for workflow | 150 lines |
| **Guides** | `.claude/guides/` | Methodology and patterns | 300 lines |
| **Skills** | `.claude/skills/{name}/` | Auto-discoverable capabilities | SKILL: 100, REF: 300 |
| **Agents** | `.claude/agents/` | Specialized agent configs | 200 lines |
| **CONTEXT.md** | Each folder | Navigation and patterns | 150 lines |

## Core Concepts

### Official Directory Structure

```
project-root/
├── .claude/
│   ├── commands/           # Slash commands (8 files)
│   │   ├── 00_plan.md      # Create SPEC-First plan
│   │   ├── 01_confirm.md   # Confirm plan + gap detection
│   │   ├── 02_execute.md   # Execute with TDD + Ralph Loop
│   │   ├── 03_close.md     # Archive and commit
│   │   ├── 90_review.md    # Multi-angle code review
│   │   ├── 91_document.md  # Sync documentation
│   │   ├── 92_init.md      # Initialize new project
│   │   ├── 999_publish.md  # Sync templates + deploy
│   │   └── CONTEXT.md      # Commands navigation
│   ├── guides/             # Methodology guides (6 files)
│   │   ├── prp-framework.md      # SPEC-First requirements
│   │   ├── gap-detection.md      # Gap detection review
│   │   ├── test-environment.md   # Test framework detection
│   │   ├── review-checklist.md   # Code review criteria
│   │   ├── 3tier-documentation.md # 3-Tier documentation
│   │   ├── parallel-execution.md  # Agent orchestration
│   │   ├── claude-code-standards.md # This file
│   │   └── CONTEXT.md             # Guides navigation
│   ├── skills/              # Auto-discoverable skills (4 skills × 2 files)
│   │   ├── tdd/            # Test-Driven Development
│   │   │   ├── SKILL.md
│   │   │   └── REFERENCE.md
│   │   ├── ralph-loop/     # Autonomous completion loop
│   │   │   ├── SKILL.md
│   │   │   └── REFERENCE.md
│   │   ├── vibe-coding/    # Code quality standards
│   │   │   ├── SKILL.md
│   │   │   └── REFERENCE.md
│   │   ├── git-master/     # Version control workflow
│   │   │   ├── SKILL.md
│   │   │   └── REFERENCE.md
│   │   ├── documentation-best-practices/ # Documentation standards
│   │   │   ├── SKILL.md
│   │   │   └── REFERENCE.md
│   │   └── CONTEXT.md      # Skills navigation
│   ├── agents/             # Specialized agents (8 agents)
│   │   ├── explorer.md     # Fast codebase exploration (haiku)
│   │   ├── researcher.md   # External docs research (haiku)
│   │   ├── coder.md        # TDD implementation (sonnet)
│   │   ├── tester.md       # Test writing and execution (sonnet)
│   │   ├── validator.md    # Type check, lint, coverage (haiku)
│   │   ├── plan-reviewer.md # Plan analysis and gaps (sonnet)
│   │   ├── code-reviewer.md # Deep code review (opus)
│   │   ├── documenter.md   # Documentation generation (haiku)
│   │   └── CONTEXT.md      # Agents navigation
│   ├── templates/          # PRP, CONTEXT, SKILL templates
│   │   ├── plan-template.md
│   │   ├── context-template.md
│   │   └── skill-template.md
│   └── scripts/hooks/      # Type check, lint, todos
│       ├── typecheck.sh
│       ├── lint.sh
│       ├── check-todos.sh
│       └── branch-guard.sh
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

### CLAUDE.md Precedence Rules

**Rule 1**: CLAUDE.md is the single source of truth for project standards
- Overrides conflicting information in other docs
- Always check CLAUDE.md first for project-specific conventions

**Rule 2**: CLAUDE.md links to CONTEXT.md for navigation
- Each major folder has CONTEXT.md
- CONTEXT.md provides file-by-file navigation
- Keep CLAUDE.md focused, delegate details to CONTEXT.md

**Rule 3**: Version tracking
- Project version: Line 4 (`> **Version**: 3.3.1`)
- Current status: Line 23 (`- **Version**: 3.3.1`)
- Template version: Near end (`**Template Version**: claude-pilot 3.3.2`)
- Keep project version consistent (lines 4 and 23)

### Command Frontmatter Reference

**Required frontmatter for all commands**:

```yaml
---
description: {trigger-rich description for slash command discovery}
---
```

**Description guidelines**:
- **Length**: Under 200 characters
- **Keywords**: Action verbs (plan, execute, review, document)
- **Scenarios**: Specific use cases
- **Discovery**: Semantic matching for auto-suggestion

**Examples**:

```yaml
Good:
description: Create SPEC-First plan from user request. Use for new features, bug fixes, refactoring.

Bad:
description: Planning command
```

### Skill Auto-Discovery

**How it works**:
1. Skills are auto-discovered via frontmatter `description`
2. Claude Code matches user intent to skill descriptions
3. Trigger-rich keywords improve matching accuracy

**Required frontmatter**:

```yaml
---
name: {skill-name}
description: {trigger-rich description}
---
```

**Description quality checklist**:
- [ ] Contains action keywords (use, apply, implement, execute)
- [ ] Mentions specific scenarios (when testing, when refactoring)
- [ ] Under 200 characters
- [ ] Clear and concise

**Examples**:

```yaml
Good:
name: tdd
description: Test-Driven Development cycle (Red-Green-Refactor). Use when implementing features with test coverage.

Bad:
name: tdd
description: About test driven development methodology
```

**Auto-discovery test**:
```bash
# Search for skill by trigger keyword
grep -r "implementing features" .claude/skills/
# Should find tdd skill
```

### Agent Model Allocation

**Strategy**: Match model capabilities to task requirements

| Model | Agents | Task Type | Rationale |
|-------|--------|-----------|-----------|
| **Haiku** | explorer, researcher, validator, documenter | Fast, structured, repetitive | - Fastest response time<br>- Lowest cost<br>- Pattern-based tasks<br>- No deep reasoning required |
| **Sonnet** | coder, tester, plan-reviewer | Balanced quality/speed | - Good reasoning<br>- Reasonable cost<br>- Complex implementation<br>- Test strategy |
| **Opus** | code-reviewer | Deep reasoning | - Best quality<br>- Highest cost<br>- Critical review<br>- Async bugs, memory leaks |

**Agent responsibilities**:

**explorer (haiku)**
- Purpose: Fast codebase exploration
- Tools: Glob, Grep, Read
- Tasks: Find files, search patterns, read structure
- Why Haiku: Simple pattern matching, no deep analysis

**researcher (haiku)**
- Purpose: External documentation research
- Tools: WebSearch, WebFetch, query-docs
- Tasks: Find external docs, extract information
- Why Haiku: Information retrieval, not synthesis

**coder (sonnet)**
- Purpose: TDD implementation
- Tools: Read, Write, Edit, Bash
- Tasks: Red-Green-Refactor, Ralph Loop
- Why Sonnet: Balanced reasoning for implementation

**tester (sonnet)**
- Purpose: Test writing and execution
- Tools: Read, Write, Bash
- Tasks: Generate tests, run coverage, debug failures
- Why Sonnet: Test strategy requires reasoning

**validator (haiku)**
- Purpose: Quality verification
- Tools: Bash, Read
- Tasks: Type check, lint, coverage extraction
- Why Haiku: Deterministic checks, no reasoning

**plan-reviewer (sonnet)**
- Purpose: Plan analysis and gap detection
- Tools: Read, Glob, Grep
- Tasks: Review plans, detect gaps, verify completeness
- Why Sonnet: Analysis requires moderate reasoning

**code-reviewer (opus)**
- Purpose: Deep code review
- Tools: Read, Glob, Grep, Bash
- Tasks: Async bugs, memory leaks, performance issues
- Why Opus: Critical issues require deepest reasoning

**documenter (haiku)**
- Purpose: Documentation generation
- Tools: Read, Write
- Tasks: Generate docs, sync files
- Why Haiku: Template-based generation

### File Size Limits

**Why size limits matter**:
- Faster context processing (LLM reads less)
- Better maintainability (focused files)
- Improved discoverability (clear purpose)

**Size limits by type**:

| Type | Target | Max | Action When Exceeded |
|------|--------|-----|----------------------|
| **Command** | 100 | 150 | Extract methodology to guides |
| **SKILL.md** | 80 | 100 | Move details to REFERENCE.md |
| **REFERENCE.md** | 250 | 300 | Split into multiple guides |
| **Guide** | 250 | 300 | Extract sections to separate guides |
| **Agent** | 150 | 200 | Simplify workflow description |
| **CONTEXT.md** | 120 | 150 | Focus on navigation only |

**Enforcement strategy**:
1. Check line count during review
2. Extract content if limit exceeded
3. Use cross-references to preserve information

### Best Practices

#### For Commands

**Keep commands focused**:
- Focus on workflow steps
- Extract methodology to guides/skills
- Use cross-references

**Example**:
```markdown
BEFORE (in command):
## TDD Methodology
[200 lines of explanation]

AFTER (in command):
> **Methodology**: @.claude/skills/tdd/SKILL.md
```

**Preserve MANDATORY ACTION sections**:
- Do NOT change wording
- Do NOT remove agent invocations
- Do NOT modify workflow logic

#### For Skills

**SKILL.md = Quick reference**:
- Quick start (when to use, quick reference)
- Core concepts (essential patterns only)
- Further reading (links to REFERENCE.md)

**REFERENCE.md = Deep dive**:
- Detailed examples
- Good/bad patterns
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
- @.claude/skills/tdd/REFERENCE.md - Detailed examples

REFERENCE.md (250 lines):
## Advanced Patterns
[Detailed explanations]

## Test Doubles
[Examples and tables]

## External Resources
[Links to books, articles]
```

#### For Agents

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

#### For CONTEXT.md

**Standard structure**:
```markdown
# {Folder} Context

## Purpose
[What this folder does]

## Key Files
| File | Purpose | Lines |
|------|---------|-------|

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

## Cross-Reference Patterns

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

## Common Patterns

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

## Version Management

### Version Types

**Project version** (lines 4, 23 in CLAUDE.md):
- Tracks this repository's version
- Format: `3.3.1` (major.minor.patch)
- Bump on releases

**Template version** (near end of CLAUDE.md):
- Tracks upstream claude-pilot template
- Format: `claude-pilot 3.3.2`
- Update when syncing from upstream

### Version Sync Strategy

**Before release**:
1. Update project version in CLAUDE.md (lines 4 and 23)
2. Ensure consistency: `grep "Version" CLAUDE.md` shows same project version
3. Template version may differ (upstream tracking)

**Example**:
```markdown
Line 4:  > **Version**: 3.3.1
Line 23: - **Version**: 3.3.1
Line ~425: **Template Version**: claude-pilot 3.3.2
```

## Further Reading

**Internal**:
- @.claude/skills/documentation-best-practices/SKILL.md - Documentation standards quick reference
- @.claude/skills/documentation-best-practices/REFERENCE.md - Detailed documentation patterns
- @.claude/guides/3tier-documentation.md - Complete 3-Tier documentation system
- @.claude/guides/parallel-execution.md - Agent orchestration patterns

**External**:
- [Claude Code: Best practices for agentic coding - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code overview - Official Docs](https://code.claude.com/docs/en/overview)
