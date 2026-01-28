# EXAMPLES: Claude Prompt Guide - Common Patterns

> **Companion**: SKILL.md, REFERENCE.md | **Purpose**: Detailed implementation patterns for XML tags and prompt engineering

---

## Common Patterns - Detailed Examples

### Pattern 1: Phase-Gated Workflow

```xml
<do_not_act_before_instructions>
Phase 1 (Planning): Read-only, no file modifications
Use Write tool ONLY for `.pilot/plan/draft/*.md`

Phase 2 (Execution): Requires `/01_confirm` command
After confirmation, tools are available for implementation
</do_not_act_before_instructions>
```

**Use Cases**:
- Planning workflows (/00_plan)
- Review processes requiring approval
- Multi-stage deployments

**Implementation Tips**:
- Clearly mark each phase's permissions
- Specify exact commands for phase transitions
- List tool restrictions per phase

---

### Pattern 2: Autonomous Execution

```xml
<default_to_action>
When user request maps to clear tool usage, execute immediately.
Summarize results after completion.
</default_to_action>

<use_parallel_tool_calls>
When multiple independent operations are available,
execute them simultaneously for efficiency.
</use_parallel_tool_calls>
```

**Use Cases**:
- Code generation (Coder agent)
- File operations (Builder agent)
- Testing execution (Tester agent)

**Implementation Tips**:
- Prioritize action over explanation
- Use parallel calls for independent operations
- Provide concise summary after completion

---

### Pattern 3: Quality Assurance

```xml
<investigate_before_answering>
Before analysis:
1. Read all relevant source files
2. Search for related patterns
3. Check existing documentation
4. Verify against requirements
</investigate_before_answering>
```

**Use Cases**:
- Architecture analysis
- Root cause investigation
- Documentation updates

**Implementation Tips**:
- Create numbered checklist
- Specify order of operations
- Require verification before response

---

## 10-Component Framework - Detailed Examples

### Component 1: Role Definition

**Who** is the AI acting as?

```markdown
# SKILL: Test-Driven Development (TDD)
> **Purpose**: Execute TDD Red-Green-Refactor cycle
> **Target**: Coder Agent implementing features
```

**Best Practices**:
- Use "SKILL:" prefix for skill files
- State purpose clearly (what does it do?)
- Specify target agent (who uses it?)
- Keep to 1-3 lines

**Examples**:
```markdown
# COMMAND: /00_plan
> **Purpose**: Create SPEC-First execution plan
> **Target**: Planner Agent

# AGENT: Coder
> **Purpose**: Implement features with TDD + Ralph Loop
> **Target**: Feature implementation tasks
```

---

### Component 2: Context & Scope

**What** is covered and excluded?

```markdown
## What This Skill Covers

### In Scope
- Red-Green-Refactor cycle execution
- Test-first development methodology
- Minimal implementation for Green phase

### Out of Scope
- Test framework selection → @REFERENCE.md
- Coverage thresholds → @ralph-loop/SKILL.md
- Code quality standards → @vibe-coding/SKILL.md
```

**Best Practices**:
- Use "In Scope" for what's included
- Use "Out of Scope" for what's excluded + where to find it
- Use `@path/to/file.md` for references
- Keep each line concise (bullet points)

---

### Component 3: Quick Start

**How** to get started immediately?

```markdown
## Quick Start

### When to Use This Skill
- Implement new feature with test coverage
- Fix bug with regression tests
- Refactor code with test safety net

### Quick Reference
```bash
# Red: pytest -k "SC-1"  # FAIL
# Green: [Implement]
# Refactor: [Refactor]
# Verify: pytest  # ALL PASS
```
```

**Best Practices**:
- List 3-5 common use cases
- Provide copy-pasteable quick reference
- Include inline comments for context
- Keep to ~10 lines total

---

### Component 4: Core Concepts

**Why** does this approach work?

```markdown
## Core Concepts

### The TDD Cycle
**Phase 1: Red** - Write Failing Test
**Phase 2: Green** - Minimal Implementation
**Phase 3: Refactor** - Improve Quality

### Why TDD Matters
- **Tests drive design**: API designed from usage perspective
- **Regression safety**: Refactor without fear
- **Living documentation**: Tests show intended behavior
```

**Best Practices**:
- Explain underlying principles
- Connect concepts to benefits
- Use emphasis for key terms
- Keep explanations concise (2-3 sentences each)

---

### Component 5: Behavioral Instructions

**What** should the AI do (or not do)?

```xml
<do_not_act_before_instructions>
Do not use Edit tool during planning phase.
Only Write tool is allowed for `.pilot/plan/draft/*.md` files.
</do_not_act_before_instructions>

<default_to_action>
Prefer tool execution over lengthy explanations.
</default_to_action>
```

**Best Practices**:
- Use XML tags for behavior control
- Be specific about restrictions
- Provide clear examples
- Combine complementary tags

---

### Component 6: Tool Use Guidelines

**How** should tools be invoked?

```xml
<use_parallel_tool_calls>
Execute independent operations simultaneously.
</use_parallel_tool_calls>

<investigate_before_answering>
Before analysis, read all relevant files and check documentation.
</investigate_before_answering>
```

**Best Practices**:
- Specify when to use specific tools
- Mention performance considerations
- Provide tool ordering when dependencies exist
- Include anti-patterns to avoid

---

### Component 7: Output Format

**What** should responses look like?

```markdown
## Output Format (MANDATORY)

### Test Results (MANDATORY)
- PASS: 15 | FAIL: 0 | SKIP: 0

### Coverage (MANDATORY)
- Overall: 85% (target: 80%) | Core: 92% (target: 90%)

### Ralph Loop (MANDATORY)
- Total Iterations: 3 | Final Status: <CODER_COMPLETE>
```

**Best Practices**:
- Mark required fields with "(MANDATORY)"
- Provide clear structure/table format
- Include targets for comparison
- Use completion markers (<COMPLETE>/<BLOCKED>)

---

### Component 8: Examples & Patterns

**What** do good implementations look like?

```markdown
### Example (Good)
✅ Parallel execution: Read all files first

### Anti-Pattern (Bad)
❌ Sequential: Read one file, then another

### Pattern: Phase-Gated Workflow
```xml
<do_not_act_before_instructions>
Phase 1 (Planning): Read-only
Phase 2 (Execution): Requires `/01_confirm` command
</do_not_act_before_instructions>
```
```

**Best Practices**:
- Use checkmarks (✅) for good patterns
- Use X marks (❌) for anti-patterns
- Provide copy-pasteable examples
- Explain why each pattern is good/bad

---

### Component 9: Error Handling

**What** to do when things fail?

```markdown
### When Blocked
If iteration 7 reached, delegate to GPT Architect:
```bash
echo "<CODER_BLOCKED>"
```

### Error Recovery
1. Check last error message
2. Fix immediate failure
3. Re-run verification
4. If still failing, escalate
```

**Best Practices**:
- Specify blocking conditions clearly
- Provide escalation paths
- Include recovery strategies
- Use completion markers

---

### Component 10: Further Reading

**Where** to find more information?

```markdown
## Further Reading

**Internal**: @.claude/skills/tdd/REFERENCE.md - Advanced TDD concepts | @.claude/skills/ralph-loop/SKILL.md - Autonomous completion loop

**External**: [TDD by Kent Beck](url) | [Growing Object-Oriented Software](url)
```

**Best Practices**:
- Prioritize internal references (@import)
- Group by type (Internal/External)
- Provide brief descriptions
- Include authoritative external sources

---

**Examples Version**: claude-pilot 4.4.43
**Last Updated**: 2026-01-25
