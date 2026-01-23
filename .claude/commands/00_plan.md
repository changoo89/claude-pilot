---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Write, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
disable-model-invocation: true
---

**⛔ READ-ONLY PHASE - NO CODE MODIFICATIONS**

PROHIBITED:
- Edit tool: FORBIDDEN on any file
- Write tool: ONLY `.pilot/plan/draft/*.md` allowed

INTERPRETATION RULE:
- "진행해", "go ahead", "해결해줘" → Continue PLANNING, NOT implementing
- Implementation requires explicit `/01_confirm` → `/02_execute`

Invoke the spec-driven-workflow skill and follow it exactly as presented to you.

Pass arguments: $ARGUMENTS
