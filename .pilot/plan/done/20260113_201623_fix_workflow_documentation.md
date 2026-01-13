# Fix Workflow Documentation

- Generated: 2026-01-13 20:16:23 | Work: fix_workflow_documentation
- Location: .pilot/plan/pending/20260113_201623_fix_workflow_documentation.md

---

## User Requirements

Fix documentation inconsistencies that cause LLM to incorrectly advise users to run `/01_confirm` before `/02_execute` when a pending plan exists. The `/02_execute` command should automatically pick up plans from pending/ and execute them without requiring explicit confirmation.

**Root Cause**: Multiple documents contain misleading descriptions suggesting `/01_confirm` is mandatory before `/02_execute`.

---

## PRP Analysis

### What (Functionality)

**Objective**: Update all documentation to accurately reflect the workflow where `/02_execute` auto-detects and processes pending plans.

**Scope**:
- In: GETTING_STARTED.md, examples/minimal-typescript/CLAUDE.md, 00_plan.md, 02_execute.md
- Out: Command logic changes (already correct)

### Why (Context)

**Current State**: Documentation suggests `/01_confirm` is required before `/02_execute`, causing LLM confusion.

**Desired State**: Documentation clearly indicates `/02_execute` can automatically process pending plans.

**Business Value**: Smoother user experience, fewer unnecessary prompts.

### How (Approach)

- **Phase 1**: Fix GETTING_STARTED.md
- **Phase 2**: Fix examples/minimal-typescript/CLAUDE.md
- **Phase 3**: Fix 00_plan.md
- **Phase 4**: Fix 02_execute.md
- **Phase 5**: Verification

### Success Criteria

```
SC-1: GETTING_STARTED.md Line 145 corrected
- Verify: Read GETTING_STARTED.md line 145
- Expected: "/01_confirm → Save plan to pending/" (NOT "move to in-progress")

SC-2: examples/.../CLAUDE.md Line 47 corrected
- Verify: Read examples/minimal-typescript/CLAUDE.md line 47
- Expected: No "start execution" for /01_confirm

SC-3: 00_plan.md Lines 22, 155 clarified
- Verify: Grep "01_confirm" in 00_plan.md
- Expected: Clear that /01_confirm is optional for saving plan

SC-4: 02_execute.md Line 69 error message updated
- Verify: Read 02_execute.md line 69
- Expected: Message indicates /02_execute can auto-find pending plans
```

### Constraints

- Minimal changes to preserve document structure
- Must not change actual command behavior (already correct)

---

## Scope

### In Scope
- `GETTING_STARTED.md` - Line 145 workflow description
- `examples/minimal-typescript/CLAUDE.md` - Line 47 command description
- `.claude/commands/00_plan.md` - Lines 22, 155 confirmation language
- `.claude/commands/02_execute.md` - Line 69 error message
- `README.md` - Lines 301, 305 workflow diagram (Added via Review)

### Out of Scope
- Command implementation files (already correct)
- CLAUDE.md root file (already correct per agent analysis)

---

## Architecture

### Files to Modify

| File | Line | Current | Change To |
|------|------|---------|-----------|
| GETTING_STARTED.md | 145 | `/01_confirm → Approve plan and move to in-progress` | `/01_confirm → Save plan to pending/ (optional)` |
| examples/.../CLAUDE.md | 47 | `approve and start execution` | `save plan to pending/` |
| 00_plan.md | 22 | `ONLY after /01_confirm` | `after plan is saved (via /01_confirm or direct to /02_execute)` |
| 00_plan.md | 155 | `DO NOT proceed until: /01_confirm → /02_execute` | `To execute: /01_confirm then /02_execute, OR /02_execute directly if plan in pending/` |
| 02_execute.md | 69 | `Run /00_plan then /01_confirm` | `Run /00_plan then /01_confirm, or provide plan path` |
| README.md | 301 | `/00_plan → Creates PRP in .pilot/plan/pending/` | `/00_plan → Designs plan in conversation (no file)` |
| README.md | 305 | `/01_confirm → Moves to .pilot/plan/in_progress/` | `/01_confirm → Saves plan to .pilot/plan/pending/` |

### Vibe Coding Compliance
> N/A - Documentation changes only

---

## Execution Plan

- [ ] **Phase 1**: Fix GETTING_STARTED.md
  - [ ] Update Line 145: Change "move to in-progress" to "Save to pending/"
  - [ ] Add note that /02_execute auto-moves

- [ ] **Phase 2**: Fix examples/minimal-typescript/CLAUDE.md
  - [ ] Update Line 47: Remove "start execution" from /01_confirm description

- [ ] **Phase 3**: Fix 00_plan.md
  - [ ] Update Line 22: Clarify /01_confirm is for saving, not required
  - [ ] Update Line 155: Clarify /02_execute can work with pending plans directly

- [ ] **Phase 4**: Fix 02_execute.md
  - [ ] Update Line 69: Improve error message to be less prescriptive

- [ ] **Phase 5**: Fix README.md (Added via Review)
  - [ ] Update Line 301: Change to show 00_plan designs in conversation
  - [ ] Update Line 305: Change to show 01_confirm saves to pending/

- [ ] **Phase 6**: Verification
  - [ ] Grep all files for misleading "confirm" language
  - [ ] Verify all SC pass

---

## Acceptance Criteria

- [ ] GETTING_STARTED.md correctly describes /01_confirm as saving to pending/
- [ ] examples/.../CLAUDE.md does not suggest /01_confirm starts execution
- [ ] 00_plan.md clarifies /01_confirm is optional for plan saving
- [ ] 02_execute.md error message is accurate
- [ ] No remaining misleading "confirmation required" language

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | GETTING_STARTED workflow | Read Line 145 | "Save plan to pending/" | Manual |
| TS-2 | Example CLAUDE.md | Read Line 47 | No "start execution" | Manual |
| TS-3 | 00_plan.md clarity | Grep "/01_confirm" | Optional language | Manual |
| TS-4 | 02_execute.md error | Read Line 69 | Accurate message | Manual |
| TS-5 | Full grep check | Grep "confirm.*first\|confirm.*required" | 0 misleading matches | Manual |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Other docs have same issue | Medium | Low | Full grep search in Phase 5 |
| Change breaks understanding | Low | Medium | Keep changes minimal and clear |

---

## Open Questions

None - All issues identified and solutions clear.

---

## Review History

### Review #1 (2026-01-13 20:17)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | 1 | 1 |
| Warning | 0 | 0 |
| Suggestion | 0 | 0 |

**Changes Made**:
1. **[Critical] Scope - README.md missing**
   - Issue: README.md Lines 301, 305 have incorrect workflow descriptions
   - Applied: Added README.md to In Scope, added to Architecture table, added Phase 5 for README.md fixes

---

## Execution Summary

### Ralph Loop Log

| Iteration | SC Checks | Result |
|-----------|-----------|--------|
| 1 | All 5 SC verified | ✅ Pass |

### Changes Made

**Phase 1 - GETTING_STARTED.md**:
- Line 145: Changed `/01_confirm → Approve plan and move to in-progress` to `/01_confirm → Save plan to pending/ (optional, /02_execute can auto-detect)`

**Phase 2 - examples/minimal-typescript/CLAUDE.md**:
- Line 47: Changed `approve and start execution` to `save plan to pending/ (optional)`

**Phase 3 - 00_plan.md**:
- Line 22: Changed `Implementation starts ONLY after /01_confirm → /02_execute` to `Implementation starts ONLY after plan is saved (via /01_confirm → /02_execute or /02_execute directly from pending/)`
- Line 155: Changed `DO NOT proceed until: /01_confirm → /02_execute` to `To execute: /01_confirm then /02_execute, OR /02_execute directly if plan in pending/`

**Phase 4 - 02_execute.md**:
- Line 69: Changed error message from `No plan found. Run /00_plan then /01_confirm` to `No plan found. Run /00_plan, then /01_confirm or /02_execute (auto-detects pending plans)`

**Phase 5 - README.md**:
- Line 301: Changed `/00_plan → Creates PRP in .pilot/plan/pending/` to `/00_plan → Designs plan in conversation (no file)`
- Line 305: Changed `/01_confirm → Moves to .pilot/plan/in_progress/` to `/01_confirm → Saves plan to .pilot/plan/pending/`

### Verification

| SC | Description | Status |
|----|-------------|--------|
| SC-1 | GETTING_STARTED.md Line 145 | ✅ Pass |
| SC-2 | examples/minimal-typescript/CLAUDE.md Line 47 | ✅ Pass |
| SC-3 | 00_plan.md Lines 22, 155 | ✅ Pass |
| SC-4 | 02_execute.md Line 69 | ✅ Pass |
| SC-5 | Grep for misleading confirm language | ✅ Pass (0 matches) |

### Acceptance Criteria

- [x] GETTING_STARTED.md correctly describes /01_confirm as saving to pending/
- [x] examples/.../CLAUDE.md does not suggest /01_confirm starts execution
- [x] 00_plan.md clarifies /01_confirm is optional for plan saving
- [x] 02_execute.md error message is accurate
- [x] No remaining misleading "confirmation required" language

### Type Check / Lint / Tests

N/A - This is a template repository with no compilation or tests. All verification done through manual inspection and grep.

### Follow-ups

None - All documentation inconsistencies have been resolved.

