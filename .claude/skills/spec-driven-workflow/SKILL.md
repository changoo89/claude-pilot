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
**Trigger**: Architecture keywords detected OR confidence < 0.5

**Keywords**: architecture, tradeoff, design, scalability, pattern

**Confidence Formula** (from gpt-delegation/SKILL.md):
```
confidence = 1.0 - (architecture_keywords * 0.3) - (multiple_approaches * 0.2) - (uncertainty * 0.2)
```

**Threshold**: < 0.5 → MUST consult GPT before AskUserQuestion

**Pattern**: IF triggered → consult GPT Architect (read-only) → apply recommendation OR present to user → THEN AskUserQuestion if still ambiguous

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
**Triggers**: Completeness keywords ("full", "complete"), reference-based requests ("like X"), ambiguous scope, multi-layer architecture.

When triggered: Ask user to select scope from discovered layers.

### Step 1.6: Design Direction Check (SMART DETECTION)
**Trigger Keywords**: landing, marketing, redesign, beautiful, modern, premium, hero, pricing, portfolio, homepage, brand, client-facing, polish, revamp

When triggered: Ask user for aesthetic direction (Minimal/Warm/Bold).
When not triggered: Use "house style" defaults (Minimalist).

### Step 1.8: External Context Detection (MANDATORY)
**Detection Patterns**: "Like X/similar to Y", external links, "Use API/docs", "Use library X", refactor references, implicit knowledge

**Context Types**: Design, API, Library, Refactor, Domain

**Action**: Capture context using appropriate tools, create Context Pack with Goal, Inputs, Derived Requirements, Assumptions, Traceability Map.

### Step 1.8.5: Context Manifest Generation
Generate Context Manifest with Collected Context, Related Files, and Missing Context tables.

### Step 1.9: Absolute Certainty Gate
**Purpose**: Ensure 100% certainty before proceeding to requirements gathering.

**Certainty Checklist** (ALL MUST PASS): Codebase understanding, Dependency tracking, Impact scope, Test strategy, Edge cases, Rollback plan

**Enforcement Loop**: Iterate until 100% certainty achieved (max 30min timebox)

**BLOCKING if incomplete**: Escalate to user after timebox

**Details**: See REFERENCE.md for full checklist and implementation

### Step 1.10: Readiness Gate
**Purpose**: Final readiness check before proceeding to plan creation.

**Readiness Checklist** (ALL MUST PASS): Unknowns Enumerated, Assumptions Verified, Dependencies Clear, Acceptance Criteria Measurable, Verification Plan Defined, Rollback Plan Defined

**Uncertainty Loop**: Max 3 retries with parallel exploration + GPT consultation

**BLOCKING if incomplete**: Checklist incomplete after MAX_RETRIES

**Details**: See REFERENCE.md for full implementation

### Step 2: Gather Requirements
Create User Requirements table with ID, Timestamp, User Input (Original), Summary.

### Step 3: Create SPEC-First Plan
**PRP Framework**: What (Functionality), Why (Context), How (Approach), Success Criteria

**Approach Selection**: Apply question filter - one clear approach → present directly; multiple approaches → ask user; technical trade-offs → consult GPT.

### Step 3.5: Mandatory Oracle Consultation (NEW)
**mandatory_oracle_consultation** - GPT consultation at 3 points during /00_plan:

| Phase | GPT Role | Purpose |
|-------|----------|---------|
| /00_plan start | Analyst | Requirements interpretation |
| /00_plan mid | Architect | Architecture direction |
| /00_plan end | Reviewer | Plan completeness |

**Graceful Fallback**: WebSearch/Context7 if Codex unavailable

### Step 4: Final User Decision (MANDATORY)
**NEVER auto-proceed to /01_confirm or /02_execute.**

Ask user to choose: A) Continue editing, B) Explore different approach, C) Run /01_confirm, D) Run /02_execute

---

## Core Concepts

### Context Pack Structure
**Goal**: User-facing outcome
**Inputs (Embedded)**: Per context type
**Derived Requirements**: Measurable bullets
**Assumptions & Unknowns**: Table with Item, Status, Resolution
**Traceability Map**: Requirement → Source

### Decision Tracking (Real-time)
**Draft file** (.pilot/plan/draft/{TIMESTAMP}_draft.md) contains:
- User Requirements (Verbatim) table
- Decisions Log table (ID, Time, Decision, Context)
- Success Criteria with checkboxes

### Atomic SC Principle
**"One SC = One File OR One Concern"**
Each SC touches one file/location OR single technical aspect. Enables parallel execution, clear ownership. Anti-pattern: "Update frontend AND backend" → Split.

### Selection vs Execution (CRITICAL)
**When user says "Go with B"**:
- ✅ CORRECT: Continue planning with approach B → refine plan
- ❌ WRONG: Start implementing approach B

**Implementation ONLY starts when**: User explicitly runs `/01_confirm` → `/02_execute`

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
