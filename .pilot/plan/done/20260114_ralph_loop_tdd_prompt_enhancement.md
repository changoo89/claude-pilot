# Ralph Loop TDD Prompt Enhancement

- Generated: 2026-01-14 | Work: ralph_loop_tdd_prompt_enhancement
- Location: .pilot/plan/pending/20260114_ralph_loop_tdd_prompt_enhancement.md

---

## User Requirements

1. **Ralph Loop Test Execution**: During `/02_execute`, Ralph Loop should properly iterate with test execution until all tests pass
2. **Explicit Test Todos**: Todo list must explicitly include "Run tests" items after each implementation task
3. **TDD Planning Enforcement**: Plan stage (`/00_plan`) must include concrete test scenarios and test commands
4. **Deep Project Understanding**: Before answering any user question, thoroughly read and understand the project structure (not shallow grep-based answers)
5. **Prompt-Only Solution**: No hooks or scripts - enhance through prompt instructions only

---

## PRP Analysis

### What (Functionality)

**Objective**: Enhance `/00_plan`, `/02_execute`, and `/90_review` command prompts to ensure:
- Ralph Loop properly triggers test execution after every code change
- Todo lists include mandatory test execution items
- Plans include concrete test environments and scenarios
- Deep project understanding before proposing solutions

**Scope**:
- **In Scope**: Modify `.claude/commands/00_plan.md`, `02_execute.md`, `90_review.md`
- **Out of Scope**: Hook scripts, settings.json, any runtime automation

### Why (Context)

**Current Problem**:
- Ralph Loop structure exists (Step 4 in 02_execute.md) but LLM skips test execution
- Todo generation (Step 2) doesn't mandate test todos
- `/00_plan` allows shallow answers without deep project exploration
- Test commands hardcoded as `npm run test` (fails for Python projects)

**Desired State**:
- Every code change triggers test execution (Ralph micro-cycle)
- Todo lists always include "Run tests" after implementation items
- Plans include detected test commands for project type
- LLM reads all related files before proposing solutions

**Root Cause Analysis**:
| Gap | Location | Issue |
|-----|----------|-------|
| No mandatory test todos | 02_execute.md Step 2 | "Create todo list" is generic |
| TDD-Ralph disconnect | 02_execute.md Step 3→4 | Transition is ambiguous |
| Hardcoded test command | 02_execute.md 4.3 | `npm run test` only |
| Shallow exploration | 00_plan.md Step 0 | Quick search, not deep read |
| Test Plan not enforced | 90_review.md | Warning level, not BLOCKING |

### How (Approach)

- **Phase 1**: Enhance 00_plan.md - Deep Project Understanding + Test Environment Detection
- **Phase 2**: Enhance 02_execute.md - Mandatory Test Todos + TDD-Ralph Integration
- **Phase 3**: Enhance 90_review.md - Test Plan Verification as BLOCKING

### Success Criteria

```
SC-1: Deep Project Understanding
- Verify: 00_plan.md requires reading all related files before answering
- Expected: "Mandatory Reading" section with checklist

SC-2: Test Environment Detection
- Verify: Plan includes detected test command for project type
- Expected: "Test Command: pytest" or "npm run test" in plan output

SC-3: Mandatory Test Todos
- Verify: 02_execute.md Step 2 explicitly requires "Run tests" todo
- Expected: Clear instruction with pattern example

SC-4: TDD-Ralph Integration
- Verify: Every implementation task followed by test execution
- Expected: "After EVERY Edit/Write, run tests" directive

SC-5: Test Plan Enforcement
- Verify: Missing Test Scenarios triggers BLOCKING in review
- Expected: Gap Detection includes test verification as 9.7
```

### Constraints

- Prompt-only modifications (no hooks, scripts, or settings changes)
- Preserve existing document structure
- Must work for Python, Node.js, Go, Rust projects (auto-detect)

---

## Scope

### In Scope
- Modify `.claude/commands/00_plan.md`
- Modify `.claude/commands/02_execute.md`
- Modify `.claude/commands/90_review.md`

### Out of Scope
- Hook scripts (`.claude/scripts/hooks/`)
- Settings file (`.claude/settings.json`)
- Any external automation tools
- Template files sync (`src/claude_pilot/templates/.claude/commands/`) - consider for future
- CLAUDE.md updates - review after implementation if needed

---

## Architecture

### Files to Modify

| File | Section | Change Type |
|------|---------|-------------|
| 00_plan.md | Step 0 | ADD: Deep Project Understanding |
| 00_plan.md | Step 0 | ADD: Test Environment Detection |
| 00_plan.md | Step 2 | MODIFY: Test Scenarios table |
| 00_plan.md | Step 4 | ADD: Test Environment to Plan Structure |
| 02_execute.md | Step 2 | ADD: Mandatory Test Todo rules |
| 02_execute.md | Step 3 | ADD: TDD-Ralph Integration section |
| 02_execute.md | Step 4.3 | MODIFY: Auto-detect test command |
| 02_execute.md | Step 4 | ADD: Ralph Loop Entry clarification |
| 90_review.md | Step 7.5 | ADD: 9.7 Test Plan Verification (BLOCKING) |
| 90_review.md | Step 8 | UPDATE: Results Summary table |

### Module Boundaries

```
00_plan.md (Planning Phase)
├── Step 0: Deep Project Understanding (NEW)
│   ├── Mandatory Reading checklist
│   ├── Existing Solution Check
│   └── Test Environment Detection
└── Step 2/4: Test Scenarios + Plan Structure

02_execute.md (Execution Phase)
├── Step 2: Todo Generation
│   └── MANDATORY Test Todo rules (NEW)
├── Step 3: TDD Cycle
│   └── TDD-Ralph Integration (NEW)
└── Step 4: Ralph Loop
    ├── Entry Condition clarification (NEW)
    └── Auto-detect test command (MODIFIED)

90_review.md (Review Phase)
└── Step 7.5: Gap Detection
    └── 9.7 Test Plan Verification (NEW - BLOCKING)
```

---

## Vibe Coding Compliance

> Changes are documentation/prompt edits only - no code generation required.
> All modifications follow existing document structure patterns.

---

## Execution Plan

### Phase 1: 00_plan.md Enhancement

- [ ] **1.0** Add "Deep Project Understanding" section before Step 0
  - Mandatory Reading table (CLAUDE.md, commands/, etc.)
  - Structure Mapping requirements
  - Anti-Pattern Warning box
  - Output format for exploration results

- [ ] **1.0.1** Add "Existing Solution Check" after exploration
  - Checklist for verifying solution doesn't already exist
  - Decision logic: enhance vs replace

- [ ] **1.1** Add "Test Environment Detection" to Step 0 Parallel Exploration
  - Project type detection (pyproject.toml, package.json, etc.)
  - Test command output format

- [ ] **1.2** Modify Test Scenarios table in Step 2
  - Add "Test File" column
  - Add example with concrete file path

- [ ] **1.3** Add "Test Environment" section to Plan Structure in Step 4
  - Detected Command field
  - Test Directory field
  - Coverage Command field

### Phase 2: 02_execute.md Enhancement

- [ ] **2.1** Add "MANDATORY: Test Execution Todos" to Step 2
  - Pattern: Implement X → Run tests for X
  - Anti-pattern warning
  - Clear example

- [ ] **2.2** Add "TDD-Ralph Integration" section after Step 3.6
  - "After EVERY Edit/Write, run tests" rule
  - Correct vs incorrect pattern examples
  - Ralph micro-cycle explanation

- [ ] **2.3** Modify Step 4.3 Verification Commands
  - Add project type detection logic
  - Priority order: pyproject.toml → package.json → go.mod → etc.
  - Fallback handling

- [ ] **2.4** Add "Ralph Loop Entry" section before 4.1
  - Clarify: Ralph starts IMMEDIATELY after code change
  - Not just at end of implementation

### Phase 3: 90_review.md Enhancement

- [ ] **3.1** Add "9.7 Test Plan Verification" to Gap Detection (Step 7.5)
  - Checklist items (scenarios defined, command specified, etc.)
  - BLOCKING condition definition
  - Example finding format

- [ ] **3.2** Update Results Summary table in Step 8
  - Add row for 9.7 Test Plan Verification

---

## Acceptance Criteria

- [x] AC-1: 00_plan.md includes "Deep Project Understanding" mandatory step with reading checklist
- [x] AC-2: 00_plan.md includes "Existing Solution Check" before proposing new solutions
- [x] AC-3: 00_plan.md includes "Test Environment Detection" with project type auto-detection
- [x] AC-4: 00_plan.md Test Scenarios table has "Test File" column
- [x] AC-5: 00_plan.md Plan Structure includes Test Environment section
- [x] AC-6: 02_execute.md Step 2 mandates test todos with clear pattern example
- [x] AC-7: 02_execute.md includes TDD-Ralph Integration (test after EVERY edit)
- [x] AC-8: 02_execute.md includes project-type test command auto-detection
- [x] AC-9: 02_execute.md clarifies Ralph Loop entry condition (immediate, not final)
- [x] AC-10: 90_review.md makes missing Test Plan a BLOCKING finding (9.7)

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | Deep understanding check | User asks about feature | LLM reads all related files first | Manual |
| TS-2 | Test env detection (Python) | pyproject.toml exists | Plan shows "pytest" | Manual |
| TS-3 | Test env detection (Node) | package.json with test script | Plan shows "npm run test" | Manual |
| TS-4 | Mandatory test todos | Run /02_execute | Todo list includes "Run tests" items | Manual |
| TS-5 | TDD-Ralph cycle | Edit a file | Tests run immediately after | Manual |
| TS-6 | Missing Test Plan review | Plan without Test Scenarios | 90_review reports BLOCKING | Manual |

> **Verification Note**: After implementation, verify changes by running actual `/00_plan`, `/02_execute` commands on a test task.

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| LLM skips mandatory reading | Medium | High | Add bold warnings, repeat in multiple sections |
| Test command detection fails | Low | Low | Provide fallback: ask user for command |
| Too much reading slows response | Medium | Low | Parallelize exploration, focus on relevant files |
| Existing prompts too long | Low | Medium | Keep additions concise, use tables |

---

## Open Questions

*None - requirements clarified in conversation*

---

## Review History

### Review #1 (2026-01-14)

**Assessment**: ✅ Pass

**Findings Summary**:
| Type | Count | Applied |
|------|-------|---------|
| BLOCKING | 0 | - |
| Critical | 0 | - |
| Warning | 2 | 2 |
| Suggestion | 1 | 1 |

**Changes Made**:

1. **[Warning] Test Plan - Manual Testing Note**
   - Issue: All tests are Manual type with no automated verification
   - Applied: Added note to verify by running actual commands after implementation

2. **[Warning] Scope - CLAUDE.md Update**
   - Issue: Command changes may require CLAUDE.md update
   - Applied: Added follow-up task consideration

3. **[Suggestion] Scope - Template Sync**
   - Issue: Template files in `src/claude_pilot/templates/` should stay in sync
   - Applied: Added to Out of Scope with note for future consideration

---

## Execution Summary

### Changes Made

**Phase 1: 00_plan.md Enhancements**
1. Added "Deep Project Understanding" section before Step 0
   - Mandatory Reading Checklist (CLAUDE.md, commands/, guides/, templates/, src/, tests/)
   - Structure Mapping Requirements with output format
   - Anti-Pattern Warning box
   - Existing Solution Check with decision logic
   - Output Format for Exploration Results

2. Added "Test Environment Detection" to Step 0
   - Project type detection (pyproject.toml, package.json, go.mod, Cargo.toml, etc.)
   - Test command matrix (pytest, npm test, go test, cargo test, etc.)
   - Test directory detection
   - Fallback handling

3. Modified Test Scenarios table in Step 2
   - Added "Test File" column
   - Added note explaining concrete file paths

4. Added "Test Environment" section to Plan Structure in Step 4
   - Project Type, Test Framework, Test Command, Coverage Command, Test Directory

**Phase 2: 02_execute.md Enhancements**
1. Added "MANDATORY: Test Execution Todos" to Step 2
   - Pattern: Implement X → Run tests for X
   - Correct/incorrect examples
   - Anti-pattern warning

2. Added "TDD-Ralph Integration" section after Step 3.6
   - "After EVERY Edit/Write, run tests" rule
   - Ralph Micro-Cycle Pattern
   - Correct workflow vs anti-pattern examples
   - Test command auto-detection
   - Why this matters explanation

3. Modified Step 4.3 Verification Commands
   - Auto-detect test command based on project type
   - DETECT_TEST_CMD() function with priority order
   - Language-specific type check and lint commands
   - Quick reference table for all project types

4. Added "Ralph Loop Entry Condition" section before 4.1
   - Clarifies Ralph starts IMMEDIATELY after first code change
   - Correct vs wrong entry points
   - Workflow diagram
   - Why immediate entry explanation

**Phase 3: 90_review.md Enhancements**
1. Added "9.7 Test Plan Verification (BLOCKING)" to Gap Detection
   - Test Scenarios Defined check
   - Test File Specified check
   - Test Command Detected check
   - Coverage Command Specified check
   - Test Environment Section check
   - BLOCKING conditions defined
   - Verification commands
   - Example of correct Test Plan

2. Updated Results Summary table in Step 8
   - Added row 9.7 Test Plan Verification

### Verification

- ✅ Files modified: `.claude/commands/00_plan.md`, `02_execute.md`, `90_review.md`
- ✅ All 10 acceptance criteria met
- ✅ No type check errors (markdown files)
- ✅ All files exist and are readable

### Follow-ups

1. Consider syncing changes to `src/claude_pilot/templates/.claude/commands/` (noted in plan as Out of Scope)
2. Consider updating CLAUDE.md if workflow changes need documentation (noted in Review History)
3. Test the enhanced commands with a real development task to verify effectiveness

