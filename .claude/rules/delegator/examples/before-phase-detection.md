# Before Phase Detection

**Problem**: Generic prompt without phase context leads to GPT checking file system during planning phase.

## Example Prompt (Current Problematic Pattern)

```markdown
TASK: Review this plan for completeness.

EXPECTED OUTCOME: APPROVE or REJECT

CONTEXT:
- Plan: [plan content]

MUST DO:
- Review the plan
- Provide feedback

MUST NOT DO:
- Rubber-stamp

OUTPUT FORMAT:
[APPROVE / REJECT]
Justification: [explanation]
```

## Issues Identified

### 1. No Phase Specification
- **Problem**: No indication whether this is planning or implementation phase
- **Impact**: GPT doesn't know if files should exist yet
- **Result**: GPT checks file system and rejects for missing files

### 2. Generic Instructions
- **Problem**: Vague "review the plan" instruction
- **Impact**: GPT doesn't know what to focus on
- **Result**: Inconsistent review quality

### 3. Missing Constraints
- **Problem**: No explicit constraints about file system checks
- **Impact**: GPT may assume it should verify file existence
- **Result**: "File not found" errors during planning

### 4. Unclear Success Criteria
- **Problem**: "APPROVE or REJECT" without criteria
- **Impact**: GPT uses its own interpretation
- **Result**: Unpredictable review outcomes

## Real-World Failure Example

**User's Plan** (planning phase):
```markdown
# Plan: Create 999_release Command

SC-1: Create .claude/commands/999_release.md
SC-2: Remove .claude/commands/999_publish.md
```

**GPT Response** (with problematic prompt):
```
[REJECT]
Justification: `.claude/commands/999_release.md` is missing and
`.claude/commands/999_publish.md` still contains `$NEW_VERSION`
```

**Why This Failed**:
- GPT checked file system during planning phase
- Files don't exist yet (this is a plan, not implementation)
- Review focused on file existence instead of plan quality
- User wasted delegation call on incorrect phase assumptions

## Root Cause Analysis

**Missing Phase Context**:
- No "Phase: PLANNING" specification
- No "files don't exist yet" constraint
- No instruction to validate plan vs implementation

**Consequences**:
- GPT behaves as if in implementation phase
- Checks file system for non-existent files
- Rejects valid plans for wrong reasons
- Wasted tokens and user frustration

## Key Learning

**Always specify phase explicitly**:
- Planning phase: Validate plan completeness, NOT file existence
- Implementation phase: Verify implementation exists, DOES check files
- Phase context determines GPT behavior

**See**: `after-phase-detection.md` for the corrected version.
