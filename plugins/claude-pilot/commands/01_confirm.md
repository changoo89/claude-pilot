---
description: Extract plan from conversation, create file in draft/, auto-apply non-BLOCKING improvements, move to pending
argument-hint: "[work_name] [--lenient] [--no-review] - work name optional; --lenient bypasses BLOCKING; --no-review skips all review"
allowed-tools: Read, Glob, Grep, Write, Bash(*), AskUserQuestion, Skill
disable-model-invocation: true
---

# /01_confirm

Invoke the confirm-plan skill and follow it exactly as presented to you.

Pass arguments: $ARGUMENTS
