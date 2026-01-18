# After Phase Detection

**Solution**: Phase-specific template with explicit planning phase context.

## Example Prompt (Improved Pattern)

```markdown
TASK: Review this plan document for implementation completeness.

EXPECTED OUTCOME: APPROVE/REJECT verdict based on plan clarity and completeness.

CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- Plan to review: [full plan content]
- Goals: Rename 999_publish to 999_release, fix hardcoded values

CONSTRAINTS:
- This is a PLAN review - do NOT check file system
- Focus on clarity, completeness, verifiability
- Assume implementation hasn't started

MUST DO:
- Evaluate all 4 criteria (Clarity, Verifiability, Completeness, Big Picture)
- Simulate implementing from the plan
- Provide specific improvements if rejecting

MUST NOT DO:
- Check file system for files that don't exist yet
- Expect implementation to be complete
- Rubber-stamp without real analysis

OUTPUT FORMAT:
[APPROVE / REJECT]
Justification: [explanation]
Summary: [4-criteria assessment]
[If REJECT: Top 3-5 critical improvements needed]
```

## Improvements

### 1. Explicit Phase Specification
- **Added**: "Phase: PLANNING (files don't exist yet - validate PLAN completeness)"
- **Benefit**: GPT knows this is a design document, not executed code
- **Result**: No file system checks during planning phase

### 2. Clear Constraints
- **Added**: "This is a PLAN review - do NOT check file system"
- **Benefit**: Explicit instruction prevents file system validation
- **Result**: Focus on plan quality, not file existence

### 3. Structured Evaluation Criteria
- **Added**: "Evaluate all 4 criteria (Clarity, Verifiability, Completeness, Big Picture)"
- **Benefit**: GPT knows exactly what to evaluate
- **Result**: Consistent, comprehensive reviews

### 4. Phase-Specific MUST NOT DO
- **Added**: "Check file system for files that don't exist yet"
- **Benefit**: Explicit prohibition of file system checks
- **Result**: Prevents "file not found" errors

### 5. Structured Output Format
- **Added**: "Summary: [4-criteria assessment]"
- **Added**: "[If REJECT: Top 3-5 critical improvements needed]"
- **Benefit**: Predictable, actionable feedback
- **Result**: User knows exactly what to fix

## Real-World Success Example

**User's Plan** (planning phase):
```markdown
# Plan: Create 999_release Command

## Success Criteria
SC-1: Create .claude/commands/999_release.md
SC-2: Remove .claude/commands/999_publish.md

## PRP Analysis
### What (Functionality)
**Objective**: Rename command file for consistency

### How (Approach)
- Create new 999_release.md
- Remove old 999_publish.md
```

**GPT Response** (with improved prompt):
```
[APPROVE]
Justification: Plan provides sufficient clarity for implementation.
The objectives, success criteria, and approach are clearly defined.

Summary:
- Clarity: ✅ Clear objectives and success criteria
- Verifiability: ✅ Success criteria are measurable (file existence)
- Completeness: ✅ Implementation approach is specified
- Big Picture: ✅ Purpose (consistency) is stated
```

**Why This Succeeded**:
- GPT validated plan quality, not file existence
- Understood this is planning phase (files don't exist yet)
- Evaluated against 4 specific criteria
- Provided structured assessment

## Comparison Table

| Aspect | Before | After |
|--------|--------|-------|
| **Phase Context** | None specified | "Phase: PLANNING" explicit |
| **File System Behavior** | Unclear | "do NOT check file system" |
| **Evaluation Criteria** | Generic "review" | 4 specific criteria |
| **MUST NOT DO** | "Rubber-stamp" (vague) | "Check file system" (specific) |
| **Output Format** | Basic verdict | Structured assessment |
| **Planning Behavior** | Checks files ❌ | Validates plan ✅ |

## Phase-Specific Variants

### Planning Phase (This Example)
**Use When**: Reviewing plan documents BEFORE implementation

**Key Characteristics**:
- Files don't exist yet
- Focus on plan clarity/completeness
- DO NOT check file system
- Simulate implementation mentally

### Implementation Phase (Not Shown)
**Use When**: Reviewing AFTER implementation complete

**Key Characteristics**:
- Code should exist now
- Focus on implementation verification
- DO check file system
- Compare plan vs actual

## Key Learning

**Phase context is critical for correct GPT behavior**:
- Always specify "Phase: PLANNING" or "Phase: IMPLEMENTATION"
- Include phase-specific constraints in MUST NOT DO
- Clarify file system behavior based on phase
- Use appropriate evaluation criteria for phase

**Result**: GPT provides relevant, phase-appropriate feedback without file system errors.
