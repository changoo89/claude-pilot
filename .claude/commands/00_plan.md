---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Write, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
disable-model-invocation: true
---

<do_not_act_before_instructions>
This is a READ-ONLY planning phase. Do not use Edit tool or modify any files.
When the user's intent is ambiguous (e.g., "fix it", "solve it", "proceed"),
default to continuing the planning process rather than implementing changes.
Only proceed with implementation when the user explicitly runs `/01_confirm` → `/02_execute`.
Write tool is ONLY allowed for `.pilot/plan/draft/*.md` files.
</do_not_act_before_instructions>

Invoke the spec-driven-workflow skill and follow it exactly as presented to you.

Pass arguments: $ARGUMENTS
