# REFERENCE: Claude Prompt Guide (Detailed Reference)

> **Companion**: SKILL.md | **Purpose**: Detailed reference for Anthropic XML tag patterns and prompt engineering best practices

---

## Detailed Tag Documentation

### 1. `<do_not_act_before_instructions>` - Detailed Usage

**Purpose**: Prevent premature tool use or implementation

**When to Use**:
- Planning phases requiring read-only exploration
- Multi-step workflows with stage gates
- Confirmation-required scenarios
- Review phases where changes need explicit approval

**Example - Planning Phase**:
```xml
<do_not_act_before_instructions>
This is a READ-ONLY planning phase. Do not use Edit tool or modify any files.
When the user's intent is ambiguous (e.g., "fix it", "solve it", "proceed"),
default to continuing the planning process rather than implementing changes.
Only proceed with implementation when the user explicitly runs `/01_confirm` → `/02_execute`.
Write tool is ONLY allowed for `.pilot/plan/draft/*.md` files.
</do_not_act_before_instructions>
```

**Example - Approval Required**:
```xml
<do_not_act_before_instructions>
Before making any destructive changes (deletions, refactors), present the plan
to the user and wait for explicit approval. Do NOT proceed until user confirms
with "yes", "approved", or "proceed".
</do_not_act_before_instructions>
```

**Best Practices**:
- Specify exact conditions that must be met before action
- List allowed tool exceptions (e.g., "Write tool ONLY for draft files")
- Provide examples of ambiguous language to handle conservatively

---

### 2. `<default_to_action>` - Detailed Usage

**Purpose**: Prefer tool execution over chat-only responses

**When to Use**:
- Task execution agents (Coder, Builder, Tester)
- Autonomous workflows where user expects results
- File operation scenarios

**Example - Coder Agent**:
```xml
<default_to_action>
When the user's request can be addressed by using tools, prefer taking action
through tool use rather than providing a lengthy explanation. Use tools first,
then summarize the results concisely.
</default_to_action>
```

**Example - File Operations**:
```xml
<default_to_action>
When user asks to "organize files" or "clean up directory", use appropriate
file operations immediately rather than asking for confirmation on each file.
Summarize changes after completion.
</default_to_action>
```

**Combination Pattern** (with `<do_not_act_before_instructions>`):
```xml
<do_not_act_before_instructions>
Do NOT start implementation until user explicitly confirms the plan.
</do_not_act_before_instructions>

<default_to_action>
After confirmation, execute all implementation steps autonomously.
Prefer tool use over lengthy explanations.
</default_to_action>
```

---

### 3. `<use_parallel_tool_calls>` - Detailed Usage

**Purpose**: Execute independent operations simultaneously

**When to Use**:
- Multiple independent file reads
- Multiple searches across different directories
- Independent test runs
- Non-dependent API calls

**Example - Discovery Phase**:
```xml
<use_parallel_tool_calls>
When multiple independent operations are needed (e.g., reading multiple files,
running several searches), execute them in parallel using separate tool calls
rather than sequentially. This significantly improves performance.
</use_parallel_tool_calls>
```

**Example - Anti-Pattern to Avoid**:
```xml
<!-- AVOID: Sequential calls when parallel is possible -->
<!-- Instead of: -->
1. Read file A
2. Wait for result
3. Read file B
4. Wait for result

<!-- Do: -->
1. Read file A (parallel)
2. Read file B (parallel)
3. Process both results together
```

**Performance Impact**:
- Sequential 4 file reads: ~4 seconds
- Parallel 4 file reads: ~1 second
- **4x improvement** for independent operations

**When NOT to Use**:
- When operations have dependencies (output of one is input to another)
- When order matters for correctness
- When operations share mutable state

---

### 4. `<investigate_before_answering>` - Detailed Usage

**Purpose**: Ensure thorough context gathering before response generation

**When to Use**:
- Architecture analysis tasks
- Root cause investigation
- Documentation updates requiring verification
- Debugging complex issues

**Example - Architecture Analysis**:
```xml
<investigate_before_answering>
Before providing recommendations or analysis, thoroughly investigate the codebase:
1. Read relevant source files
2. Search for related patterns
3. Check existing tests and documentation
4. Verify against requirements
Only then provide a comprehensive response based on gathered context.
</investigate_before_answering>
```

**Example - Debugging**:
```xml
<investigate_before_answering>
Before suggesting fixes for the error:
1. Read the full error message and stack trace
2. Examine the file where error occurred
3. Search for similar patterns in codebase
4. Check test files for expected behavior
5. Review related documentation
Then provide diagnosis and solution.
</investigate_before_answering>
```

**Investigation Checklist**:
- [ ] Read primary source files
- [ ] Search for related patterns
- [ ] Check tests and documentation
- [ ] Verify against requirements
- [ ] Cross-reference with similar implementations

---

### 5. `<avoid_excessive_markdown_and_bullet_points>` - Detailed Usage

**Purpose**: Prefer concise prose over structured lists

**When to Use**:
- Explanatory responses to user questions
- Summary generation
- User-facing communications
- Natural language outputs

**Example - Chat-Focused Response**:
```xml
<avoid_excessive_markdown_and_bullet_points>
Prefer natural language prose over excessive bullet points and markdown formatting.
Use paragraphs and clear sentences to convey information. Reserve markdown for
code blocks and essential structure only.
</avoid_excessive_markdown_and_bullet_points>
```

**Before (Excessive Markdown)**:
```markdown
## Analysis Results

### File Structure
- `src/main.ts` - Entry point
- `src/utils/` - Utilities
  - `helpers.ts` - Helper functions
  - `validators.ts` - Validation logic

### Issues Found
1. Missing error handling
2. Inconsistent naming
3. No tests

### Recommendations
- Add try-catch blocks
- Rename variables
- Write unit tests
```

**After (Natural Prose)**:
```
Analysis reveals three main issues in the codebase. First, the main.ts
file lacks proper error handling for API calls. Second, naming conventions
are inconsistent between modules. Third, the utils directory has no test
coverage. I recommend adding try-catch blocks for error handling,
standardizing variable names, and writing unit tests for the validators.
```

**When Markdown IS Appropriate**:
- Code blocks (syntax highlighting)
- Data tables (structured information)
- Document headers (hierarchy)
- Essential emphasis (bold/italic for key points)

---

## 10-Component Framework - Quick Reference

**Full examples**: @.claude/skills/claude-prompt-guide/EXAMPLES.md

1. **Role Definition**: Who is the AI acting as?
2. **Context & Scope**: What is covered and excluded?
3. **Quick Start**: How to get started immediately?
4. **Core Concepts**: Why does this approach work?
5. **Behavioral Instructions**: What should the AI do (or not do)?
6. **Tool Use Guidelines**: How should tools be invoked?
7. **Output Format**: What should responses look like?
8. **Examples & Patterns**: What do good implementations look like?
9. **Error Handling**: What to do when things fail?
10. **Further Reading**: Where to find more information?

**Key Principles**:
- Use structured sections for clarity
- Provide concrete examples over abstract descriptions
- Specify scope boundaries (In/Out of scope)
- Include quick start code snippets
- Add completion markers for autonomous workflows

---

## Tag Customization - Beyond Official Names

**XML tag names are NOT magic** - the content/instructions matter, not the tag name.

Anthropic confirms:
> "There are no canonical best tags. Claude is malleable and can adapt to various tag names."

**Examples** (all equally effective):
```xml
<do_not_act_before_instructions>...</do_not_act_before_instructions>
<defer_action_until>...</defer_action_until>
<wait_for_conditions>...</wait_for_conditions>
```

**Custom Tag Examples**:
```xml
<!-- Custom phase control -->
<phase_1_read_only>
  No file modifications during exploration
</phase_1_read_only>

<!-- Custom action preference -->
<prefer_direct_action>
  Execute tools immediately, summarize results
</prefer_direct_action>

<!-- Custom optimization -->
<optimize_for_speed>
  Use parallel tool calls for independent operations
</optimize_for_speed>
```

**Best Practices for Custom Tags**:
1. **Descriptive names**: Tag name should hint at content
2. **Clear instructions**: Content is what matters most
3. **Consistent style**: Use similar naming convention within file
4. **Documentation**: Comment non-standard tags

---

## Testing Your Prompts

### Verification Checklist

After creating or modifying a prompt, verify:

- [ ] Role definition is clear (Who is this for?)
- [ ] Scope is well-defined (In/Out of scope)
- [ ] Quick start is actionable (Can use immediately?)
- [ ] Core concepts explain why (Not just what/how)
- [ ] Behavioral instructions are specific (Not vague)
- [ ] Tool guidelines are practical (Can follow?)
- [ ] Output format is structured (Easy to parse)
- [ ] Examples show good/bad patterns (Clear contrast)
- [ ] Error handling is specified (What to do when failed?)
- [ ] Further reading links work (@import paths valid?)

### Common Pitfalls

1. **Too verbose**: >200 lines for SKILL.md (move details to REFERENCE.md)
2. **Vague instructions**: "Try to be efficient" → "Use parallel tool calls"
3. **Missing scope**: No "Out of Scope" section
4. **No examples**: Abstract concepts without concrete examples
5. **Circular references**: File A references B, B references A
6. **Broken @import**: Paths don't exist or are incorrect
7. **Missing completion markers**: No <COMPLETE>/<BLOCKED> indicators
8. **Over-specified**: Too many edge cases covered (let Claude reason)

---

## Claude Code Framework Tags - Reference

### System Prompt Structure

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

**Reference Version**: claude-pilot 4.4.43
**Last Updated**: 2026-01-25
