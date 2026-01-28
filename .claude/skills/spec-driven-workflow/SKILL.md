---
name: spec-driven-workflow
description: SPEC-First planning workflow - explore codebase, gather requirements, create execution plan through dialogue (read-only)
---

# SKILL: Spec-Driven Workflow (Planning)

> **Purpose**: Analyze codebase and create SPEC-First execution plan through dialogue (read-only phase)
> **Target**: Planner Agent executing /00_plan command

---

## Quick Start

### When to Use This Skill
- Create new implementation plan
- Explore codebase for task requirements
- Gather user requirements through dialogue

### Quick Reference
```bash
# Invoked by: /00_plan "task description"
# Output: Complete plan in .pilot/plan/draft/ + user decision
```

---

## Core Philosophy

**Read-Only**: NO code modifications. Only exploration, analysis, and planning
**SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
**Efficient Dialogue**: Ask user only for business/intent clarification; handle technical details autonomously or via GPT

---

## What This Skill Covers

### In Scope
- Codebase exploration (parallel: explorer + researcher agents)
- Requirement gathering with verbatim capture
- SPEC-First plan creation (PRP framework)
- Decision tracking in real-time
- Dialogue-based user interaction with question filtering

### Out of Scope
- Code implementation → @.claude/skills/execute-plan/SKILL.md
- Plan confirmation → @.claude/skills/confirm-plan/SKILL.md
- Plan execution → @.claude/skills/execute-plan/SKILL.md

---

## EXECUTION DIRECTIVE

**THIS IS A DIALOGUE PHASE - NOT AN EXECUTION PHASE**

1. **ASK only when necessary**: Filter questions before asking user
2. **WAIT for response**: Do not proceed until user responds to actual questions
3. **NEVER auto-execute**: Do not run /01_confirm or /02_execute without explicit user request
4. **Selection ≠ Execution**: When user chooses an approach, **continue planning with that approach**, do NOT start implementation

---

## Question Filtering (CRITICAL)

### Self-Decide (Do NOT ask user):
- Technical implementation details (file naming, folder structure)
- Obvious patterns already in codebase
- Standard best practices
- Minor trade-offs with clear winner

### Consult GPT First (Ask GPT before user):
- Architecture decisions with multiple valid approaches
- Security considerations
- Complex trade-offs requiring expert analysis

**GPT Consultation**: Use gpt-delegation skill → "read-only" mode for advisory

### MUST Consult GPT (Proactive Pattern)
**Trigger**: Architecture keywords OR confidence < 0.5. **Threshold**: < 0.5 → MUST consult GPT before AskUserQuestion. **Details**: REFERENCE.md, @.claude/skills/gpt-delegation/SKILL.md

### Ask User (ONLY these):
- **Business requirements**: What the user actually wants
- **Direction choices**: When 2+ approaches have genuinely different outcomes
- **Scope clarification**: What's in/out of scope
- **User intent**: When user's request is ambiguous

---

## Execution Steps

### Step 0: Initialize Progress Tracking
Create TaskCreate entry for planning phase:
```bash
# TaskCreate (analyzing) - marks /00_plan start
```

### Step 1: Explore Codebase (Parallel)
Launch explorer and researcher in parallel for comprehensive discovery.

### Step 1.5: Scope Clarity Check (MANDATORY)
**Triggers**: Completeness keywords, reference-based requests, ambiguous scope, multi-layer architecture. **Action**: Ask user to select scope. **Details**: REFERENCE.md

### Step 1.6: Design Direction Check (SMART DETECTION)
**Triggers**: landing, marketing, redesign, beautiful, modern, premium, hero, pricing. **Action**: Ask aesthetic direction (Minimal/Warm/Bold) or use defaults. **Details**: REFERENCE.md

### Step 1.8: External Context Detection (MANDATORY)
**Triggers**: "Like X", external links, "Use API/library", refactor references. **Action**: Capture context, create Context Pack. **Details**: REFERENCE.md

### Step 1.8.5: Context Manifest Generation
Generate Context Manifest with Collected Context, Related Files, Missing Context tables. **Details**: REFERENCE.md

### Step 1.9: Absolute Certainty Gate
**Checklist**: Codebase understanding, Dependencies, Impact scope, Test strategy, Edge cases, Rollback plan. **Loop**: Max 30min timebox. **Blocking**: Escalate to user. **Details**: REFERENCE.md

### Step 1.10: Readiness Gate
**Checklist**: Unknowns Enumerated, Assumptions Verified, Dependencies Clear, Acceptance Criteria Measurable, Verification Plan Defined, Rollback Plan Defined. **Loop**: Max 3 retries. **Blocking**: Incomplete after MAX_RETRIES. **Details**: REFERENCE.md

### Step 2: Gather Requirements
Create User Requirements table with ID, Timestamp, User Input (Original), Summary.

### Step 3: Create SPEC-First Plan
**PRP Framework**: What (Functionality), Why (Context), How (Approach), Success Criteria

**Approach Selection**: Apply question filter - one clear approach → present directly; multiple approaches → ask user; technical trade-offs → consult GPT.

### Step 3.5: Mandatory Oracle Consultation (NEW)
GPT consultation at 3 points: start (Analyst), mid (Architect), end (Reviewer). Fallback: WebSearch/Context7. **Details**: REFERENCE.md

### Step 4: Final User Decision (MANDATORY)
**NEVER auto-proceed to /01_confirm or /02_execute.**

Ask user to choose: A) Continue editing, B) Explore different approach, C) Run /01_confirm, D) Run /02_execute

---

## Core Concepts

### Context Pack Structure
Goal, Inputs (Embedded), Derived Requirements, Assumptions & Unknowns, Traceability Map. **Details**: REFERENCE.md

### Decision Tracking (Real-time)
Draft file contains: User Requirements table, Decisions Log, Success Criteria with checkboxes. **Details**: REFERENCE.md

### Atomic SC Principle
"One SC = One File OR One Concern" - enables parallel execution, clear ownership. **Details**: REFERENCE.md

### Selection vs Execution (CRITICAL)
**When user says "Go with B"**: ✅ Continue planning (refine plan) | ❌ Start implementing. **Implementation starts**: Only when user runs `/01_confirm` → `/02_execute`. **Details**: REFERENCE.md

### Operational Certainty Definition

**Binary**: **Verified** (with evidence) OR **Cannot Verify** (with artifact). **Evidence**: Code reference (file + lines), Test output (cmd + results), GPT log (ID + summary), User confirmation (timestamp + response). **Cannot Verify**: Create artifact (what, why, needs) + notify user. **Details**: REFERENCE.md

### False Certainty Anti-Patterns

**BLOCKED Phrases** (never declare certainty with these):

| Anti-Pattern | Example | Remedy |
|--------------|---------|--------|
| **Vague language** | "I think", "probably", "should work" | Use "Verified" OR "Cannot Verify" |
| **Uncited claims** | "Tests will pass" (no test run) | Run command, cite output |
| **Assumption as fact** | "File exists" (not checked) | Verify with Read/Glob, cite result |
| **Missing verification** | "Pattern found" (no grep output) | Execute verification command, show output |
| **Skipped exploration** | "Didn't check X but confident" | Mark as "Cannot Verify", create artifact |
| **Implicit unknowns** | Proceeding without stating gaps | Enumerate unknowns explicitly |

**Enforcement**: Certainty Gate (Step 1.9) blocks completion if any anti-pattern detected. **Details**: REFERENCE.md

---

## PROHIBITED Actions

### ⛔ TOOL RESTRICTIONS (ABSOLUTE)
- Edit tool: FORBIDDEN on any file
- Write tool: ONLY `.pilot/plan/draft/*.md`
- Creating plan files without user approval
- Running /01_confirm or /02_execute automatically
- **Starting implementation after user selects an approach**
- **Interpreting ANY natural language as phase transition trigger**

**EXPLICIT COMMAND REQUIRED**: User must type exactly `/01_confirm` or `/02_execute` to move phases.

---

## Further Reading

**Internal**: @.claude/skills/spec-driven-workflow/REFERENCE.md - Advanced planning patterns, detailed step implementation, context pack formats, decision tracking examples | @.claude/skills/parallel-subagents/SKILL.md - Parallel agent execution | @.claude/skills/gpt-delegation/SKILL.md - GPT consultation | @.claude/skills/confirm-plan/SKILL.md - Plan confirmation | @.claude/skills/execute-plan/SKILL.md - Plan execution

**External**: [SPEC-First Development](https://en.wikipedia.org/wiki/Specification_by_example) | [PRP Framework](https://pragprog.com/)

---

**⚠️ CRITICAL**: /00_plan is **read-only** - NO code modifications. **Filter questions**: Self-decide technical details, consult GPT for complex trade-offs, ask user only for business/intent. **Selection ≠ Execution**: When user chooses approach → continue planning, NOT implement. Implementation starts ONLY when user explicitly runs `/01_confirm` → `/02_execute`.

---

**Version**: claude-pilot 4.4.40
