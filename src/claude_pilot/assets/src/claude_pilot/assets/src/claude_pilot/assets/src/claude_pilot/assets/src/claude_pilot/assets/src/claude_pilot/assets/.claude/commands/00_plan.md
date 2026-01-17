---
description: Analyze codebase and create SPEC-First execution plan through dialogue (read-only)
argument-hint: "[task_description] - required description of the work"
allowed-tools: Read, Glob, Grep, Bash(git:*), WebSearch, AskUserQuestion, mcp__plugin_serena_serena__*, mcp__plugin_context7_context7__*
---

# /00_plan

_Explore codebase, gather requirements, and design SPEC-First execution plan._

## Core Philosophy

- **Read-Only**: NO code modifications. Only exploration, analysis, and planning
- **SPEC-First**: Requirements, success criteria, test scenarios BEFORE implementation
- **Collaborative**: Dialogue with user to clarify ambiguities

> **⚠️ LANGUAGE**: All plan documents MUST be in English, regardless of conversation language
> **⚠️ CRITICAL**: /00_plan is read-only. Implementation starts ONLY after `/01_confirm` → `/02_execute`

**Full methodology**: @.claude/guides/prp-framework.md

---

## Phase Boundary Protection

**Planning Phase Rules**:
- **CAN DO**: Read, Search, Analyze, Discuss, Plan, Ask questions
- **CANNOT DO**: Edit files, Write files, Create code, Implement
- **EXIT VIA**: User explicitly runs `/01_confirm` or `/02_execute`

### MANDATORY: Ambiguous Confirmation Handling

> **🚨 MANDATORY**: At plan completion, you MUST call `AskUserQuestion` before ANY phase transition

**When to Call**: Plan discussion appears complete OR user provides ambiguous confirmation ("go ahead", "proceed")

**NEVER use Yes/No questions** - always provide explicit multi-option choices:

```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

**Valid Execution Triggers**: User types `/01_confirm` or `/02_execute`, says "start coding", or selects option C/D

---

## Step 0: Requirements & Exploration

> **Full methodology**: @.claude/guides/requirements-tracking.md | @.claude/guides/parallel-execution.md

**Requirements**: Collect verbatim input, assign UR-IDs, build table (see guide)
**Exploration**: Invoke Explorer + researcher agents in parallel (see guide)

**Reading Checklist**:
| File/Folder | Purpose |
|-------------|---------|
| `CLAUDE.md` | Project overview |
| `.claude/commands/*.md` | Existing patterns |
| `.claude/guides/*.md` | Methodology guides |
| `src/` or `lib/` | Main structure |

---

## Step 1: Design PRP (What/Why/How/Success Criteria)

> **Full methodology**: @.claude/guides/prp-framework.md

**What**: Objective, scope (in/out), deliverables
**Why**: Current problem, business value, background
**How**: Implementation strategy, dependencies, risks
**Success Criteria**: Measurable, complete, testable

---

## Step 2: Design Test Plan

> **Full methodology**: @.claude/guides/test-plan-design.md

**MANDATORY**: Test scenarios with test file paths

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | [Happy path] | [input] | [output] | [Unit/Integration] | [path] |
| TS-2 | [Edge case] | [input] | [output] | [Unit] | [path] |
| TS-3 | [Error] | [input] | [output] | [Integration] | [path] |

**Test Environment** (auto-detected): Project type, framework, commands, directory

---

## Step 3: Constraints & Risks

**Constraints**: Technical, business, quality
**Risks**: | Risk | Likelihood | Impact | Mitigation |

---

## Step 4: Generate Plan Document

> **Template**: @.claude/templates/prp-template.md

**Structure**: Requirements, PRP, Scope, Test Plan, Test Environment, Execution Plan, Constraints/Risks
**Write to**: `.pilot/plan/pending/{timestamp}_{work_title}.md`

---

## Step 6: MANDATORY Ambiguous Confirmation

> **🚨 CRITICAL**: After presenting plan, you MUST call `AskUserQuestion`

```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

**Proceed only AFTER user selects explicit option (C or D for execution)**

---

## Success Criteria

- [ ] User requirements table created (UR-1, UR-2, ...)
- [ ] Parallel exploration completed (Explorer + researcher + Test Env)
- [ ] PRP analysis complete (What/Why/How/Success Criteria)
- [ ] Test scenarios defined with test file paths
- [ ] Test environment detected and documented
- [ ] Constraints and risks identified
- [ ] Plan document written to `.pilot/plan/pending/`
- [ ] `AskUserQuestion` called for ambiguous confirmation

---

## Related Guides

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Requirements Tracking**: @.claude/guides/requirements-tracking.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment Detection**: @.claude/guides/test-environment.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **PRP Template**: @.claude/templates/prp-template.md

---

## Next Command

- `/01_confirm` - Review plan, apply feedback, save for execution
- `/02_execute` - Start implementation immediately (if user confirms)
