# Researcher Agent Case-Sensitivity Fix

- **Generated**: 2026-01-17
- **Work**: `researcher-agent-case-sensitivity-fix`

---

## User Requirements (Verbatim)

> **Purpose**: Track ALL user requests verbatim to prevent omissions

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 2026-01-17 | "이런 일이 발생하던데 researcher 에이전트에 문제있나? [Researcher agent 0 tool uses output]" | Researcher agent shows 0 tool uses with capital R |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1: All Task invocations use lowercase | Mapped |
| **Coverage** | **100%** | **All requirements mapped** | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Fix researcher agent invocation case-sensitivity inconsistency in `/00_plan` command

**Scope**:
- **In scope**: `.claude/commands/00_plan.md`, `.claude/guides/parallel-execution.md`
- **Out of scope**: Other commands (unless same issue found), agent configuration files

### Why (Context)

**Current Problem**:
```
└─ Researcher (Research documentation best practices) · 0 tool uses · 0 tokens
   ⎿ Done

⏺ Researcher agent 이름이 잘못되었습니다. researcher (소문자)로 다시 시도하겠습니다.
⏺ researcher(Research documentation best practices)
   ⎿ Done (12 tool uses · 0 tokens · 1m 23s)
```

- Agent name case mismatch causes first invocation to fail silently (0 tool uses)
- Forces retry with lowercase, wasting time and tokens
- Confusing error message in Korean

**Desired State**:
- Consistent lowercase agent naming throughout documentation
- Clear case-sensitivity guidance in guides
- No silent failures on agent invocation

**Business Value**:
- Faster plan creation (no retry needed)
- Better user experience (no confusing error messages)
- Reduced token waste (failed attempts consume 0 tokens but waste time)

### How (Approach)

- **Phase 1**: Discovery & Alignment
  - Verify all agent name references across guides
  - Identify case-sensitivity patterns

- **Phase 2**: Design
  - Document lowercase naming convention
  - Add case-sensitivity warnings

- **Phase 3**: Implementation (TDD: Red → Green → Refactor, Ralph Loop)
  - Update `.claude/commands/00_plan.md` Agent Coordination table
  - Add warning to `.claude/guides/parallel-execution.md`
  - Search for other affected commands

- **Phase 4**: Verification (type check + lint + tests + coverage)
  - Verify all `subagent_type:` references are lowercase
  - Test agent invocation with correct case

- **Phase 5**: Handoff (docs + summary)
  - Update CHANGELOG
  - Commit changes

### Success Criteria

SC-1: All Task tool invocations use lowercase agent names
- **Verify**: `grep -r "subagent_type: [A-Z]" .claude/`
- **Expected**: No results (all lowercase)

SC-2: Parallel execution guide includes case-sensitivity warning
- **Verify**: `grep -A 5 "### Agent Reference" .claude/guides/parallel-execution.md`
- **Expected**: Warning text about case-sensitivity

SC-3: /00_plan command documentation uses lowercase in Agent Coordination table
- **Verify**: `grep -A 10 "### Agent Coordination" .claude/commands/00_plan.md`
- **Expected**: `| Research | ... | **Researcher Agent** |` → `| Research | ... | **researcher Agent** |`

### Constraints

- Must not break existing functionality
- Documentation only changes (no code modifications)
- English documentation, Korean conversation support

---

## Scope

### In Scope

| Component | Changes |
|-----------|---------|
| `.claude/commands/00_plan.md` | Agent Coordination table: `Researcher` → `researcher` |
| `.claude/guides/parallel-execution.md` | Add case-sensitivity warning after Agent Reference table |
| `.claude/commands/*.md` (scan) | Check for similar issues in other commands |

### Out of Scope

- Agent configuration files (`.claude/agents/*.md`) - already correct
- Agent behavior modification
- Core functionality changes

---

## Test Environment (Detected)

- **Project Type**: Markdown/Documentation
- **Test Framework**: Bash scripts (grep, find)
- **Test Command**: `bash .claude/scripts/test-agent-names.sh` (to be created)
- **Coverage Command**: N/A (documentation-only changes)
- **Test Directory**: `.claude/scripts/`

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/agents/researcher.md` | Agent config | Line 2: `name: researcher` | Lowercase name definition |
| `.claude/commands/00_plan.md` | Plan command | Line 138-140: Agent Coordination table | Uses `Researcher` (capital R) - **NEEDS FIX** |
| `.claude/guides/parallel-execution.md` | Parallel patterns | Line 124: Agent reference table | Uses `researcher` (lowercase) - **CORRECT** |

### Research Findings

| Source | Topic | Key Insight | URL |
|--------|-------|-------------|-----|
| Agent configuration | Agent naming | `name: researcher` (lowercase) | `.claude/agents/researcher.md` |
| Task tool documentation | subagent_type parameter | Case-sensitive matching required | N/A (observed behavior) |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Standardize on lowercase `researcher` | Matches agent file name and definition | Capitalize everything (breaks existing) |
| Add warning to guide | Prevents future confusion | Silent fix (may not help users) |

### Warnings & Gotchas

| Issue | Location | Recommendation |
|-------|----------|----------------|
| Case-sensitive subagent_type | All Task tool invocations | Always use lowercase: `researcher`, `explorer`, `coder`, `tester`, `validator`, etc. |
| Other commands may have same issue | `.claude/commands/*.md` | Search all command files for `subagent_type:` references |

---

## Architecture

### Module Boundaries

```
/00_plan.md
  └── Step 1: Parallel Exploration
      ├── subagent_type: explorer (lowercase) ✅
      ├── subagent_type: researcher (lowercase) ⚠️ CURRENTLY: Researcher
      └── Main: Test environment detection
```

### Data Structures

No code changes - documentation only.

### Dependencies

```
Task Tool
  └── subagent_type parameter (case-sensitive)
      └── Agent definition files (.claude/agents/*.md)
          └── name field (must match exactly)
```

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Other commands have same issue | Medium | Medium | Search all `.md` files for `subagent_type:` |
| Case sensitivity varies by platform | Low | Low | Document explicitly |
| Users may not notice the fix | Low | Low | Clear warning in guide |

### Alternatives

| Option | Pros | Cons | Chosen |
|--------|------|-------|--------|
| A) Standardize on lowercase | Matches existing files, consistent | Requires documentation updates | ✅ Yes |
| B) Capitalize agent names | More "proper" English | Breaks existing files, requires file renames | ❌ No |
| C) Case-insensitive matching | More forgiving | Not supported by Task tool | ❌ No |

---

## Execution Plan

### Step 1: Scan All Commands for Case Issues

```bash
# Find all subagent_type references
grep -rn "subagent_type:" .claude/commands/
```

**Expected Output**: List of all agent invocations across commands

### Step 2: Update /00_plan.md

**File**: `.claude/commands/00_plan.md`

**Location**: Line 138-140 (Agent Coordination table)

**Change**:
```markdown
| Research | External docs | WebSearch, query-docs | **Researcher Agent** |
```

To:
```markdown
| Research | External docs | WebSearch, query-docs | **researcher Agent** |
```

### Step 3: Add Warning to Parallel Execution Guide

**File**: `.claude/guides/parallel-execution.md`

**Location**: After line 131 (Agent Reference table)

**Add**:
```markdown
> **⚠️ CRITICAL**: Agent names are case-sensitive. Always use lowercase:
> - `explorer`, `researcher`, `coder`, `tester`, `validator`, `plan-reviewer`, `code-reviewer`, `documenter`
```

### Step 4: Verify Changes

```bash
# Verify no uppercase subagent_type
grep -rn "subagent_type: [A-Z]" .claude/

# Verify warning added
grep -A 2 "case-sensitive" .claude/guides/parallel-execution.md
```

### Step 5: Create Test Script (Optional)

**File**: `.claude/scripts/test-agent-names.sh`

**Content**:
```bash
#!/bin/bash
# Test script to verify agent name case-sensitivity

echo "Checking agent name case-sensitivity..."

# Find all subagent_type references
UPPERCASE=$(grep -rn "subagent_type: [A-Z]" .claude/commands/ .claude/guides/ || true)

if [ -n "$UPPERCASE" ]; then
    echo "❌ Found uppercase agent names:"
    echo "$UPPERCASE"
    exit 1
else
    echo "✅ All agent names are lowercase"
    exit 0
fi
```

---

## Acceptance Criteria

- [x] All `subagent_type:` references use lowercase agent names
- [x] Parallel execution guide includes case-sensitivity warning
- [x] Test script created and passing
- [x] CHANGELOG updated

## Execution Summary

### Changes Made
1. **`.claude/commands/00_plan.md`**: Updated "Researcher Agent" → "researcher Agent" in:
   - Agent invocation instructions (line 131)
   - Agent Coordination table (line 139)
   - Result Merge section (line 146)
   - Checklist items (line 305)

2. **`.claude/guides/parallel-execution.md`**: Added case-sensitivity warning:
   - Added critical warning after Agent Reference table (lines 133-134)
   - Lists all agent names in lowercase for reference

3. **`.claude/scripts/test-agent-names.sh`**: Created test script to verify lowercase agent names

4. **`CHANGELOG.md`**: Created changelog documenting the fix

### Verification Results
- **Test Script**: ✅ Passing - All agent names are lowercase
- **Warning Present**: ✅ Confirmed in parallel-execution.md
- **Agent References**: ✅ All `subagent_type:` use lowercase
- **Git Status**: 2 modified files, 2 new files

### Follow-ups
- Consider running `test-agent-names.sh` in CI/CD pipeline
- Monitor for similar case-sensitivity issues in other agent invocations

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Verify lowercase agent names | `grep -rn "subagent_type: [A-Z]" .claude/` | No results | Script | `.claude/scripts/test-agent-names.sh` |
| TS-2 | Verify warning present | `grep "case-sensitive" .claude/guides/parallel-execution.md` | Warning text found | Script | Inline grep |
| TS-3 | Researcher invocation | `subagent_type: researcher` | Agent executes with tools > 0 | Manual | Run /00_plan |
| TS-4 | Case mismatch (negative test) | `subagent_type: Researcher` | Error or 0 tools uses | Manual | (Optional - don't test) |

---

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Other commands have same issue | Scan all command files in Step 1 |
| Users confused by case-sensitivity | Clear warning in guide |
| Documentation update incomplete | Verification script catches issues |

---

## Open Questions

None identified.

---

## Next Steps

Run `/01_confirm` to save this plan, then `/02_execute` to implement the fixes.

## Worktree Metadata
- Branch: researcher-agent-case-sensitivity-fix
- Worktree Directory: /Users/chanho/worktree/claude-pilot-researcher-agent-case-sensitivity-fix
- Main Branch: main
- Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
