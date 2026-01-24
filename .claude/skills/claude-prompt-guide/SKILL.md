---
name: claude-prompt-guide
description: Anthropic official XML tag patterns and prompt engineering best practices. Document behavior control tags, system prompt internals, and the 10-Component Framework for effective Claude prompts.
---

# SKILL: Claude Prompt Guide

> **Purpose**: Document Anthropic XML tag patterns and prompt engineering best practices
> **Target**: All agents creating or modifying system prompts, commands, and skills

---

## Quick Start

### When to Use This Skill
- Creating new system prompts or agent instructions
- Modifying existing command or skill behavior
- Debugging prompt-related issues

### Quick Reference

```xml
<!-- Control tool use -->
<do_not_act_before_instructions>Defer action until conditions met</do_not_act_before_instructions>
<default_to_action>Prefer tool use over chat responses</default_to_action>

<!-- Optimize execution -->
<use_parallel_tool_calls>Execute independent tools simultaneously</use_parallel_tool_calls>
<investigate_before_answering>Research before responding</investigate_before_answering>

<!-- Control output -->
<avoid_excessive_markdown_and_bullet_points>Prefer prose over lists</avoid_excessive_markdown_and_bullet_points>
```

## What This Skill Covers

### In Scope
- Anthropic official behavior control XML patterns
- System prompt internal tag structure
- 10-Component Framework for effective prompts
- Best practices (DO/DON'T)

### Out of Scope
- Model-specific tuning → @.claude/skills/coding-standards/SKILL.md
- Agent role definitions → @.claude/agents/CONTEXT.md

---

## Core Concepts

### CRITICAL: Tag Names Are Customizable

**XML tag names are NOT magic** - the content/instructions matter, not the tag name.

Anthropic confirms:
> "There are no canonical best tags. Claude is malleable and can adapt to various tag names."

**Examples** (all equally effective):
```xml
<do_not_act_before_instructions>...</do_not_act_before_instructions>
<defer_action_until>...</defer_action_until>
<wait_for_conditions>...</wait_for_conditions>
```

**What matters**: Clear instructions within the tags, not the tag names.

---

## Official Behavior Control Tags

### 1. `<do_not_act_before_instructions>` - Control When to Defer Action

**Purpose**: Prevent premature tool use or implementation

**When to Use**: Read-only phases, planning stages, confirmation-required scenarios

**Example**:
```xml
<do_not_act_before_instructions>
This is a READ-ONLY planning phase. Do not use Edit tool or modify any files.
When the user's intent is ambiguous (e.g., "fix it", "solve it", "proceed"),
default to continuing the planning process rather than implementing changes.
Only proceed with implementation when the user explicitly runs `/01_confirm` → `/02_execute`.
Write tool is ONLY allowed for `.pilot/plan/draft/*.md` files.
</do_not_act_before_instructions>
```

**Use Cases**:
- Planning phases (`/00_plan`)
- Review phases requiring explicit approval
- Multi-step workflows with stage gates

---

### 2. `<default_to_action>` - Encourage Proactive Tool Use

**Purpose**: Prefer tool execution over chat-only responses

**When to Use**: Task execution agents, autonomous workflows

**Example**:
```xml
<default_to_action>
When the user's request can be addressed by using tools, prefer taking action
through tool use rather than providing a lengthy explanation. Use tools first,
then summarize the results concisely.
</default_to_action>
```

**Use Cases**:
- Code generation (Coder agent)
- File operations (Builder agent)
- Testing execution (Tester agent)

---

### 3. `<use_parallel_tool_calls>` - Optimize for Parallel Execution

**Purpose**: Execute independent operations simultaneously

**When to Use**: Multiple independent file reads, searches, or non-dependent operations

**Example**:
```xml
<use_parallel_tool_calls>
When multiple independent operations are needed (e.g., reading multiple files,
running several searches), execute them in parallel using separate tool calls
rather than sequentially. This significantly improves performance.
</use_parallel_tool_calls>
```

**Use Cases**:
- Discovery phases (multiple file reads)
- Multi-file searches
- Independent test runs

**Anti-Pattern** (sequential):
```xml
<!-- AVOID: Sequential calls when parallel is possible -->
<call_1>Read file A</call_1>
<call_2>Read file B</call_2>  <!-- Should be parallel with call_1 -->
```

---

### 4. `<investigate_before_answering>` - Research Before Responding

**Purpose**: Ensure thorough context gathering before response generation

**When to Use**: Complex analysis, debugging, documentation tasks

**Example**:
```xml
<investigate_before_answering>
Before providing recommendations or analysis, thoroughly investigate the codebase:
1. Read relevant source files
2. Search for related patterns
3. Check existing tests and documentation
Only then provide a comprehensive response based on gathered context.
</investigate_before_answering>
```

**Use Cases**:
- Architecture analysis
- Root cause investigation
- Documentation updates

---

### 5. `<avoid_excessive_markdown_and_bullet_points>` - Control Output Format

**Purpose**: Prefer concise prose over structured lists

**When to Use**: Chat-focused responses, natural language outputs

**Example**:
```xml
<avoid_excessive_markdown_and_bullet_points>
Prefer natural language prose over excessive bullet points and markdown formatting.
Use paragraphs and clear sentences to convey information. Reserve markdown for
code blocks and essential structure only.
</avoid_excessive_markdown_and_bullet_points>
```

**Use Cases**:
- Explanatory responses
- Summary generation
- User-facing communications

---

## System Prompt Internal Tags

### Claude Code Framework Tags

These tags appear in system prompts to structure AI behavior:

```xml
<!-- Behavior control -->
<behavior_instructions>Core behavioral guidelines</behavior_instructions>
<system-reminder>Context injection during conversation</system-reminder>

<!-- Tool use control -->
<tool_use_instructions>Guidelines for tool invocation</tool_use_instructions>

<!-- Output formatting -->
<output_format_instructions>Response structure requirements</output_format_instructions>

<!-- Error handling -->
<error_handling_instructions>Behavior when tools fail</error_handling_instructions>
```

### Context Injection Tags

```xml
<!-- Context windows -->
<context_information>Project-specific context</context_information>
<claudeMd>Codebase and user instructions</claudeMd>
<claude_background_info>Model and environment metadata</claude_background_info>

<!-- Skill/command invocation -->
<command-message>Command name</command-message>
<command-name>command_name</command-name>
<skill-format>true</skill-format>
```

---

## 10-Component Framework

Effective Claude prompts consist of these 10 components:

### 1. Role Definition
**Who** is the AI acting as?
```markdown
# SKILL: Test-Driven Development (TDD)
> **Purpose**: Execute TDD Red-Green-Refactor cycle
> **Target**: Coder Agent implementing features
```

### 2. Context & Scope
**What** is covered and excluded?
```markdown
## What This Skill Covers
### In Scope
- Red-Green-Refactor cycle execution
### Out of Scope
- Test framework selection → @REFERENCE.md
```

### 3. Quick Start
**How** to get started immediately?
```markdown
## Quick Start
### Quick Reference
```bash
# Red: pytest -k "SC-1"  # FAIL
# Green: [Implement]
# Refactor: [Refactor]
```
```

### 4. Core Concepts
**Why** does this approach work?
```markdown
## Core Concepts
### The TDD Cycle
**Phase 1: Red** - Write Failing Test
**Phase 2: Green** - Minimal Implementation
**Phase 3: Refactor** - Improve Quality
```

### 5. Behavioral Instructions
**What** should the AI do (or not do)?
```xml
<do_not_act_before_instructions>
Do not use Edit tool during planning phase.
</do_not_act_before_instructions>
```

### 6. Tool Use Guidelines
**How** should tools be invoked?
```xml
<use_parallel_tool_calls>
Execute independent operations simultaneously.
</use_parallel_tool_calls>
```

### 7. Output Format
**What** should responses look like?
```markdown
## Output Format (MANDATORY)
- Test Results (MANDATORY)
- Coverage (MANDATORY)
- Ralph Loop (MANDATORY)
```

### 8. Examples & Patterns
**What** do good implementations look like?
```markdown
### Example (Good)
✅ Parallel execution: Read all files first

### Anti-Pattern (Bad)
❌ Sequential: Read one file, then another
```

### 9. Error Handling
**What** to do when things fail?
```markdown
### When Blocked
If iteration 7 reached, delegate to GPT Architect:
```bash
echo "<CODER_BLOCKED>"
```
```

### 10. Further Reading
**Where** to find more information?
```markdown
## Further Reading
**Internal**: @.claude/skills/tdd/REFERENCE.md
**External**: [TDD by Kent Beck](url)
```

---

## Best Practices (DO/DON'T)

### DO

✅ **Use XML tags for structure** - Provides clear delimiters for instructions
✅ **Focus on content, not tag names** - Clear instructions matter more than naming
✅ **Combine complementary tags** - `<do_not_act_before_instructions>` + `<default_to_action>` for nuanced control
✅ **Provide examples** - Show good vs. bad patterns
✅ **Specify scope clearly** - In Scope vs. Out of Scope sections
✅ **Include quick reference** - One-line summaries for fast lookup

### DON'T

❌ **Rely on tag name magic** - `<custom_tag>` works as well as `<official_tag>` if content is clear
❌ **Over-specify edge cases** - Let Claude reason within guidelines
❌ **Use tags for simple formatting** - Markdown is sufficient for presentation
❌ **Nest XML tags deeply** - Keep structure flat (1-2 levels max)
❌ **Duplicate instructions** - One clear statement > multiple vague ones

---

## Common Patterns

### Pattern 1: Phase-Gated Workflow

```xml
<do_not_act_before_instructions>
Phase 1 (Planning): Read-only, no file modifications
Use Write tool ONLY for `.pilot/plan/draft/*.md`

Phase 2 (Execution): Requires `/01_confirm` command
After confirmation, tools are available for implementation
</do_not_act_before_instructions>
```

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

---

## Further Reading

**Internal**: @.claude/skills/coding-standards/SKILL.md - Code quality standards | @.claude/agents/CONTEXT.md - Agent ecosystem | @.claude/commands/CONTEXT.md - Command workflows

**External**: [Prompting best practices - Claude Docs](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices) | [Use XML tags - Claude Docs](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/use-xml-tags) | [Claude Code Best Practices - Anthropic](https://www.anthropic.com/engineering/claude-code-best-practices) | [Piebald-AI/claude-code-system-prompts](https://github.com/Piebald-AI/claude-code-system-prompts) - 40+ system prompt examples

---

**Version**: claude-pilot 4.4.39
**Line Count**: 285 lines (Target: ≤300 lines for comprehensive guide) ✅
