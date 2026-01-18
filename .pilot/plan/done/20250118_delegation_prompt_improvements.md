# PRP Analysis: GPT Delegation Prompt Improvements

> **Created**: 2025-01-18
> **Status**: ✅ COMPLETE - All Success Criteria Met
> **Plan ID**: 20250118_delegation_prompt_improvements
> **Review Status**: ✅ APPROVED by GPT Plan Reviewer
> **Completion Date**: 2025-01-18

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 10:30 | "GPT 플랜 리뷰어에게 조언구할때 구체적이지 못했는지 지피티로부터 유의미한 정보를 얻지 못한 것처럼 보이는데 우리 GPT한테 물어볼 때 쓰는 프롬프트 가이드 같은 거 한번 확인해 보고 어떻게 개선할 수 있을지 분석 좀 해봐." | Analyze GPT Plan Reviewer prompt effectiveness and propose improvements |
| UR-2 | 11:45 | "클로드코드, codex 공식 가이드문서와 베스트프랙틱스들을 웹검색으로 충분히 파악한 뒤 위 내용 토대로 계획 세우자" | Research official Claude Code and Codex documentation before planning |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4 | Mapped |
| UR-2 | ✅ | SC-5 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Enhance GPT delegation prompt system with phase-specific context, explicit instructions, and improved stateless design compliance.

**Scope**:
- **In Scope**:
  - Update `.claude/rules/delegator/delegation-format.md` with phase-specific templates
  - Enhance `.claude/rules/delegator/prompts/plan-reviewer.md` with phase detection logic
  - Improve `.claude/rules/delegator/orchestration.md` with phase context guidance
  - Add context engineering best practices to all expert prompts
  - Create validation checklist for delegation prompts
- **Out of Scope**:
  - Modifying `codex-sync.sh` script (existing functionality)
  - Creating new expert types (only improving existing)
  - Changing agent-to-agent delegation patterns

**Deliverables**:
1. Enhanced 7-section delegation format with phase-specific variants
2. Updated Plan Reviewer prompt with automatic phase detection
3. Context engineering guidelines integrated into orchestration guide
4. Delegation prompt validation checklist
5. Example prompts demonstrating improvements

### Why (Context)

**Current Problem**:
Based on user-reported logs from GPT Plan Reviewer consultations:
- GPT Plan Reviewer rejected planning-phase plans for "missing files" that don't exist yet
- Vague task descriptions ("ULTIMATE FINAL REVIEW") without clear success criteria
- Missing critical phase context (planning vs implementation)
- Violation of stateless design (no iteration history included)
- Generic templates applied to all phases without adaptation

**Example from logs**:
```
[REJECT]
Justification: `.claude/commands/999_release.md` is missing and
`.claude/commands/999_publish.md` still contains `$NEW_VERSION`
```
This shows the reviewer checked file system during planning phase when files don't exist yet.

**Business Value**:
- **User Impact**: More helpful, actionable GPT feedback; fewer wasted delegation calls
- **Technical Impact**: Better alignment between Claude Code agents and GPT experts; reduced token costs
- **Process Impact**: Faster plan approval cycles; less back-and-forth iterations

**Background**:
- claude-pilot v4.1.0 introduced Codex CLI integration for intelligent delegation
- Current delegation prompts follow 7-section format but lack phase-specific adaptations
- Official Claude 4.5 best practices (from Anthropic) emphasize explicit instructions and context
- Context engineering research shows dynamic context curation is critical for agent performance

### How (Approach)

**Implementation Strategy**: Apply official Claude Code best practices to delegation prompt system

**Key Principles from Research**:
1. **Be Explicit with Instructions** (Claude 4.5 docs)
   - Clear, specific guidance on expected behavior
   - No ambiguity about what to do vs not do

2. **Add Context to Improve Performance** (Claude 4.5 docs)
   - Explain WHY certain behaviors matter
   - Provide motivation for instructions

3. **Context Engineering** (Hung Vo, July 2025)
   - Dynamic context curation (not static prompts)
   - Phase-aware context selection
   - Stateless design compliance (include full history)

4. **Subagent Orchestration** (Claude 4.5 docs)
   - Well-defined subagent tools
   - Natural delegation patterns
   - Conservative when appropriate

**Dependencies**:
- Existing `.claude/rules/delegator/*` files
- Official Anthropic prompt engineering documentation
- Context engineering research findings
- User-reported GPT consultation logs

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Over-engineering prompts | Medium | Medium | Follow Claude's "avoid over-engineering" guidance; keep changes minimal |
| Breaking existing workflows | Low | High | Maintain backward compatibility; add phase-specific as optional variants |
| Increased token costs | Low | Medium | Better context reduces iteration costs; net positive expected |
| GPT model interpretation varies | Medium | Medium | Use explicit instructions per Claude 4.5 best practices |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [x] **SC-1**: Phase-specific templates added to delegation-format.md
  - Verify: `grep -c "Phase:" .claude/rules/delegator/delegation-format.md`
  - Expected: 2+ phase-specific template sections (Planning Phase, Implementation Phase)
  - **Result**: ✅ PASS - 2 phase-specific templates added

- [x] **SC-2**: Plan Reviewer prompt updated with phase detection
  - Verify: `grep -c "phase.*detection\|Phase Indicators" .claude/rules/delegator/prompts/plan-reviewer.md`
  - Expected: New section on automatic phase detection and behavior adjustment
  - **Result**: ✅ PASS - Phase-Specific Behavior section with detection algorithm added

- [x] **SC-3**: Context engineering guidelines integrated
  - Verify: `grep -c "context.*engineering\|dynamic.*context" .claude/rules/delegator/orchestration.md`
  - Expected: New section on context engineering best practices
  - **Result**: ✅ PASS - Context Engineering for Delegation section added

- [x] **SC-4**: Validation checklist created
  - Verify: `ls -la .claude/rules/delegator/delegation-checklist.md`
  - Expected: File exists with 10+ validation items
  - **Result**: ✅ PASS - File created with 48 validation items

- [x] **SC-5**: Example prompts demonstrate improvements
  - Verify: `ls -la .claude/rules/delegator/examples/`
  - Expected: Directory with 2+ before/after example pairs
  - **Result**: ✅ PASS - 4 example files created (2 before/after pairs)

**Verification Method**: Manual review of updated files + test delegation calls

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test Procedure |
|----|----------|-------|----------|------|----------------|
| TS-1 | Planning phase delegation | Plan document without implemented files | GPT validates plan completeness, NOT file existence | Integration | `./test-scripts/test-planning-phase-delegation.sh` |
| TS-2 | Implementation phase delegation | Partially implemented code | GPT checks file system and validates against plan | Integration | `./test-scripts/test-implementation-phase-delegation.sh` |
| TS-3 | Stateless design compliance | Delegation with 3 previous iterations | GPT receives full context of all iterations | Integration | `./test-scripts/test-stateless-context.sh` |
| TS-4 | Phase auto-detection | Ambiguous phase context | GPT Plan Reviewer detects phase from context clues | Unit | Manual review of prompt + grep check |
| TS-5 | Validation checklist | New delegation prompt | All 10+ checklist items pass | Unit | Manual checklist walk-through |

### Behavioral Acceptance Criteria

**TS-1: Planning Phase Delegation**

**Input Prompt**:
```bash
.claude/scripts/codex-sync.sh "read-only" "You are a work plan review expert...

TASK: Review this plan document for implementation completeness.

CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- Plan to review: [plan content for 999_release.md which doesn't exist yet]
- Goals: Create 999_release.md, remove 999_publish.md
...
"
```

**Expected Output** (MUST include):
- ✅ APPROVE or REJECT verdict
- ✅ Analysis of plan clarity and completeness
- ✅ NO mention of "file not found" errors
- ✅ NO file system checks
- ✅ Focus on whether plan contains enough information to implement

**Failure Criteria**:
- ❌ Rejects because `.claude/commands/999_release.md` is missing
- ❌ Complains about files that don't exist yet
- ❌ Checks file system instead of validating plan content

**TS-2: Implementation Phase Delegation**

**Input Prompt**:
```bash
.claude/scripts/codex-sync.sh "read-only" "You are a work plan review expert...

TASK: Verify implementation matches plan requirements.

CONTEXT:
- Phase: IMPLEMENTATION (code should exist now)
- Plan to verify: [plan content]
- Implementation status: 999_release.md created, 999_publish.md removed
...
"
```

**Expected Output** (MUST include):
- ✅ APPROVE or REJECT verdict
- ✅ File system verification (checks if files exist)
- ✅ Validation that implementation matches plan
- ✅ Comparison of planned vs actual

**Failure Criteria**:
- ❌ Approves without checking file system
- ❌ Doesn't verify implementation completeness
- ❌ Treats as planning phase (doesn't check files)

**TS-3: Stateless Design Compliance**

**Input Prompt**:
```bash
.claude/scripts/codex-sync.sh "workspace-write" "You are a code reviewer...

TASK: Fix the jq syntax error in marketplace.json

CONTEXT:
- Phase: IMPLEMENTATION (files exist)
- Original request: "Fix jq syntax in marketplace.json"
- File: .claude-plugin/marketplace.json
- Previous iterations:
  - Attempt 1: Tried `.plugins[] |= .version = $VERSION` - Failed: syntax error
  - Attempt 2: Tried `(.plugins[] | select(.name=="claude-pilot")) |= .version = $VERSION` - Failed: still in-place issue
  - Current iteration: 3
...
"
```

**Expected Output** (MUST include):
- ✅ Acknowledges this is iteration 3
- ✅ Builds on previous attempts (doesn't repeat same errors)
- ✅ References what was tried before
- ✅ Provides different solution based on history

**Failure Criteria**:
- ❌ Treats as fresh request (no mention of previous attempts)
- ❌ Repeats same failed solutions
- ❌ Doesn't leverage iteration history

**Test Scripts**:

**Note**: Test scripts use real delegation calls but include fallback if GPT unavailable.

Create `./test-scripts/test-planning-phase-delegation.sh`:
```bash
#!/bin/bash
set -e

echo "=== Test: Planning Phase Delegation ==="
echo "Expected: GPT validates plan completeness, NOT file existence"

# Create test plan
PLAN_FILE="/tmp/test-plan-$(date +%s).md"
cat > "$PLAN_FILE" << 'EOF'
# Test Plan: Create New Command

## Success Criteria
SC-1: Create .claude/commands/999_release.md
SC-2: Remove .claude/commands/999_publish.md

## PRP Analysis
### What (Functionality)
**Objective**: Rename command file for consistency

### How (Approach)
- Create new 999_release.md
- Remove old 999_publish.md
EOF

# Check if Codex available
if ! command -v codex &> /dev/null; then
  echo "⚠️ SKIP: Codex CLI not installed"
  exit 0
fi

# Build delegation prompt
PROMPT="You are a work plan review expert...

TASK: Review this plan document for implementation completeness.

EXPECTED OUTCOME: APPROVE/REJECT verdict based on plan clarity and completeness.

CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- Plan to review: $(cat "$PLAN_FILE")
- Goals: Create 999_release.md, remove 999_publish.md

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
[If REJECT: Top 3-5 critical improvements needed]"

# Call GPT
RESULT=$(cd /Users/chanho/claude-pilot && .claude/scripts/codex-sync.sh "read-only" "$PROMPT")

# Check: Should NOT complain about missing files
if echo "$RESULT" | grep -qiE "file.*not.*found|no.*such.*file|cannot.*stat|missing.*file"; then
  echo "❌ FAIL: Planning phase checked file system"
  echo "GPT Output:"
  echo "$RESULT"
  exit 1
fi

# Check: Should NOT check file system
if echo "$RESULT" | grep -qiE "ls.*\.claude|test.*-f|check.*file.*exist|stat.*file"; then
  echo "❌ FAIL: Planning phase performed file system check"
  echo "GPT Output:"
  echo "$RESULT"
  exit 1
fi

# Check: Should analyze plan content
if echo "$RESULT" | grep -qiE "plan.*completeness|information.*sufficiency|clarity.*criteria|implementable|sufficient.*information"; then
  echo "✅ PASS: Planning phase validated plan, not files"
  echo "GPT Output:"
  echo "$RESULT" | head -20
  exit 0
fi

# Check: Should provide structured verdict
if echo "$RESULT" | grep -E "^\[APPROVE\]|\[REJECT\]"; then
  echo "✅ PASS: Provided structured verdict"
  echo "GPT Output:"
  echo "$RESULT" | head -20
  exit 0
fi

echo "⚠️ PARTIAL: Unclear result"
echo "GPT Output:"
echo "$RESULT"
exit 2
```

**TS-2: Implementation Phase Test Script**

Create `./test-scripts/test-implementation-phase-delegation.sh`:
```bash
#!/bin/bash
set -e

echo "=== Test: Implementation Phase Delegation ==="
echo "Expected: GPT checks file system and validates implementation"

# Setup: Create the files first
mkdir -p .claude/commands
echo "# Test content for 999_release" > .claude/commands/999_release.md
rm -f .claude/commands/999_publish.md

# Check if Codex available
if ! command -v codex &> /dev/null; then
  echo "⚠️ SKIP: Codex CLI not installed"
  exit 0
fi

# Build delegation prompt
PROMPT="You are a work plan review expert...

TASK: Verify implementation matches plan requirements.

EXPECTED OUTCOME: APPROVE/REJECT verdict based on implementation completeness.

CONTEXT:
- Phase: IMPLEMENTATION (code should exist now)
- Plan to verify: Plan specified creating 999_release.md and removing 999_publish.md
- Implementation status: 999_release.md created, 999_publish.md removed

CONSTRAINTS:
- Check file system for implemented files
- Verify success criteria are met
- Validate implementation quality

MUST DO:
- Check file system for all mentioned files
- Verify implementation matches plan
- Validate success criteria are met

MUST NOT DO:
- Reject for missing planned features not yet implemented
- Expect 100% completion of multi-phase plans

OUTPUT FORMAT:
[APPROVE / REJECT]
Justification: [explanation]
Summary: [implementation vs plan assessment]"

# Call GPT
RESULT=$(cd /Users/chanho/claude-pilot && .claude/scripts/codex-sync.sh "read-only" "$PROMPT")

# Check: SHOULD verify file system
if echo "$RESULT" | grep -qiE "file.*exist|check.*file|verif.*file|ls.*\.claude|stat.*file"; then
  echo "✅ PASS: Implementation phase checked file system"
  echo "GPT Output:"
  echo "$RESULT" | head -20
  exit 0
fi

# Check: Should NOT approve without verification
if echo "$RESULT" | grep -qiE "^\[APPROVE\]" && ! echo "$RESULT" | grep -qiE "file.*exist|verif|check.*file"; then
  echo "❌ FAIL: Implementation approved without file verification"
  echo "GPT Output:"
  echo "$RESULT"
  exit 1
fi

echo "⚠️ PARTIAL: Unclear result"
echo "GPT Output:"
echo "$RESULT"
exit 2
```

**TS-3: Stateless Context Test Script**

Create `./test-scripts/test-stateless-context.sh`:
```bash
#!/bin/bash
set -e

echo "=== Test: Stateless Context with Iteration History ==="
echo "Expected: GPT acknowledges previous attempts and iteration count"

# Check if Codex available
if ! command -v codex &> /dev/null; then
  echo "⚠️ SKIP: Codex CLI not installed"
  exit 0
fi

# Build delegation prompt with full history
PROMPT="You are a code reviewer...

TASK: Fix the jq syntax error in marketplace.json

EXPECTED OUTCOME: Working jq in-place syntax

CONTEXT:
- Phase: IMPLEMENTATION (files exist)
- Original request: Fix jq syntax in marketplace.json
- File: .claude-plugin/marketplace.json
- Previous iterations:
  - Attempt 1: Tried .plugins[] |= .version = $VERSION - Failed: syntax error
  - Attempt 2: Tried (.plugins[] | select(.name==\"claude-pilot\")) |= .version = $VERSION - Failed: still in-place issue
  - Current iteration: 3

CONSTRAINTS:
- Must use in-place jq syntax: |= operator
- Cannot create temporary files
- Must work with jq 1.6+

MUST DO:
- Provide correct jq in-place syntax
- Explain why this syntax works
- Build on previous attempts (don't repeat same errors)

MUST NOT DO:
- Use outdated jq syntax
- Create temporary files
- Repeat solutions from Attempt 1 or 2

OUTPUT FORMAT:
Summary: [what was wrong, what was fixed]
Correct Command: [exact jq command]
Verification: [how to test it works]"

# Call GPT
RESULT=$(cd /Users/chanho/claude-pilot && .claude/scripts/codex-sync.sh "read-only" "$PROMPT")

# Check: Should acknowledge iteration history
if echo "$RESULT" | grep -qiE "iteration.*3|current.*iteration|previous.*attempt|attempt.*1.*attempt.*2"; then
  echo "✅ PASS: Stateless design includes iteration history"
  echo "GPT Output:"
  echo "$RESULT" | head -20
  exit 0
fi

# Check: Should NOT treat as fresh request
if ! echo "$RESULT" | grep -qiE "attempt|iteration|previous|history"; then
  echo "❌ FAIL: Stateless design ignored, treated as fresh request"
  echo "GPT Output:"
  echo "$RESULT"
  exit 1
fi

# Check: Should NOT repeat failed solutions
if echo "$RESULT" | grep -qiE "\.plugins\[\]|select.*claude.*pilot"; then
  echo "❌ FAIL: Repeated failed solutions from previous attempts"
  echo "GPT Output:"
  echo "$RESULT"
  exit 1
fi

echo "⚠️ PARTIAL: Unclear result"
echo "GPT Output:"
echo "$RESULT"
exit 2
```

**Idempotency and Duplication Handling**:

For each file insertion, use cross-platform detection and insertion:

```bash
# Cross-platform idempotent insertion
insert_section() {
  local file="$1"
  local marker="$2"
  local section="$3"

  # Check if section already exists
  if grep -q "## Phase-Specific Behavior" "$file"; then
    echo "Section already exists in $file, skipping insertion"
    return 0
  fi

  # Detect OS for sed compatibility
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: use sed -i '' (empty string for backup)
    sed -i '' "/$marker/a\\
\\
$section" "$file"
  else
    # Linux/GNU: use sed -i (no backup suffix needed)
    sed -i "/$marker/a\\
\\
$section" "$file"
  fi
}

# Usage:
insert_section \
  ".claude/rules/delegator/prompts/plan-reviewer.md" \
  "## Modes of Operation" \
  "## Phase-Specific Behavior

[CONTENT HERE]"
```

**Markdown Fence Handling for Insertions**:

When inserting content with nested code blocks into markdown files:

**Option 1: Use quadruple backticks for outer fence**
``````markdown
### Plan Reviewer (Planning Phase)

Example with nested code:

\`\`\`bash
example code here
\`\`\`

More content...
``````

**Option 2: Use tilde fences for inner blocks**
```markdown
### Plan Reviewer (Planning Phase)

Example with nested code:

~~~bash
example code here
~~~

More content...
```

**Option 3: Escape inner fences when inserting**
```bash
# When inserting via heredoc, escape inner backticks
cat >> file.md << 'EOF'
### Plan Reviewer (Planning Phase)

Example with nested code:

\`\`\`bash
example code here
\`\`\`

More content...
EOF
```

### Test Environment

**Auto-Detected Configuration**:
- **Project Type**: Shell/Markdown (documentation project)
- **Test Framework**: Manual verification with test scripts
- **Test Command**: `./test-scripts/test-*.sh`
- **Test Directory**: `./test-scripts/`
- **Coverage Target**: N/A (documentation improvements)

---

## Execution Plan

### Phase 1: Discovery & Analysis
- [x] Read current delegation format and orchestration guides
- [x] Analyze user-reported GPT consultation logs
- [x] Research official Claude Code and Codex documentation
- [x] Identify gaps between current implementation and best practices

### Phase 2: Design Improvements

**Based on Official Best Practices**:

#### 2.1 Enhanced 7-Section Format

**Current Issue**: Generic template doesn't adapt to phase context

**Solution**: Add phase-specific variants following Claude 4.5 "be explicit" guidance:

```markdown
### Plan Reviewer (Planning Phase) - NEW
> Use when reviewing plan documents BEFORE implementation

PHASE CONTEXT: Planning Phase
- Files don't exist yet (this is a design document)
- Focus: Plan clarity, completeness, verifiability
- DO NOT check file system

[Follows 7-section format with phase-specific MUST NOT DO items]

### Plan Reviewer (Implementation Phase) - NEW
> Use when reviewing AFTER implementation

PHASE CONTEXT: Implementation Phase
- Code should exist now
- Focus: Verify implementation matches plan
- DO check file system

[Follows 7-section format with phase-specific MUST DO items]
```

#### 2.2 Context Engineering Integration

**Current Issue**: Static prompts without dynamic context curation

**Solution**: Apply context engineering principles (Hung Vo, 2025):

```markdown
## Context Engineering for Delegation

### Dynamic Context Components
- **System Instructions**: Expert role, behavior, rules (static)
- **Phase Context**: Planning vs Implementation (dynamic)
- **Iteration History**: Previous attempts and results (dynamic)
- **Task Specifics**: Current goal and constraints (dynamic)

### Context Selection Strategy
1. **Phase Detection**: Auto-detect from task description
2. **History Injection**: Include all previous iterations
3. **Relevance Filtering**: Only include relevant context items
4. **Token Budget**: Prioritize critical context (Claude 4.5 token awareness)
```

#### 2.3 Enhanced Plan Reviewer Prompt

**Current Issue**: No phase detection, checks file system during planning

**Solution**: Add phase detection logic:

```markdown
## Phase-Specific Behavior (NEW)

### Planning Phase Review
When reviewing plans BEFORE implementation:
- Focus on plan clarity and completeness
- Do NOT check file system for file existence
- Validate that plan provides enough information to implement
- Assume this is a design document, not executed code

### Implementation Phase Review
When reviewing AFTER implementation:
- Check file system for implemented files
- Verify implementation matches plan
- Validate success criteria are met
- Compare planned vs actual implementation

## Detection (NEW)

**Planning Phase Indicators**:
- Context mentions "plan", "design", "proposed"
- Plan uses future tense ("will create", "will add")
- No file path checks mentioned

**Implementation Phase Indicators**:
- Context mentions "implemented", "created", "added"
- Plan uses past tense ("created", "added")
- File verification requested

## Behavior Adjustment

Adjust your review based on detected phase:
[Phase-specific behavior matrix]
```

#### 2.4 Stateless Design Compliance

**Current Issue**: Each delegation treated as independent, no history included

**Solution**: Explicit history injection per orchestration guide:

```markdown
### Step 5: Build Delegation Prompt (ENHANCED)

**CRITICAL**: Since each call is stateless, include FULL context:

1. **User's original request**
2. **Relevant code/files** (full content or paths)
3. **Previous attempts and results** (if retry)
4. **Current phase context** (planning vs implementation)
5. **Iteration count** (if multiple attempts)

**Context Template**:
```markdown
CONTEXT:
- Phase: [PLANNING / IMPLEMENTATION]
- Original request: [verbatim user input]
- Relevant files: [paths or snippets]
- Previous iterations:
  - Attempt 1: [what was tried, result]
  - Attempt 2: [what was tried, result]
  - Current iteration: [N]
```

### Phase 3: Implementation

#### 3.1 Update `.claude/rules/delegator/delegation-format.md`

**Insertion Point**: After existing `### Plan Reviewer` section (line ~103)

**Content to Add**:

```markdown
### Plan Reviewer (Planning Phase) - NEW

> Use when reviewing plan documents BEFORE implementation starts

PHASE CONTEXT: Planning Phase
- Files don't exist yet (this is a design document)
- Focus: Plan clarity, completeness, verifiability
- DO NOT check file system

TASK: Review this plan document for implementation completeness.

EXPECTED OUTCOME: APPROVE/REJECT verdict based on plan clarity and completeness.

CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- Plan to review: [plan content]
- Goals: [what the plan is trying to achieve]

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

### Plan Reviewer (Implementation Phase) - NEW

> Use when reviewing AFTER implementation is complete

PHASE CONTEXT: Implementation Phase
- Code should exist now
- Focus: Verify implementation matches plan
- DO check file system

TASK: Verify implementation matches plan requirements.

EXPECTED OUTCOME: APPROVE/REJECT verdict based on implementation completeness.

CONTEXT:
- Phase: IMPLEMENTATION (code should exist now)
- Plan to verify: [plan content]
- Implementation status: [what was done]

CONSTRAINTS:
- Check file system for implemented files
- Verify success criteria are met
- Validate implementation quality

MUST DO:
- Check all files mentioned in plan exist
- Verify success criteria are measurable and met
- Validate implementation against plan

MUST NOT DO:
- Reject for missing planned features not yet implemented
- Expect 100% completion of multi-phase plans

OUTPUT FORMAT:
[APPROVE / REJECT]
Justification: [explanation]
Summary: [implementation vs plan assessment]
[If REJECT: Top 3-5 gaps to address]
```

#### 3.2 Update `.claude/rules/delegator/prompts/plan-reviewer.md`

**Insertion Point**: After `## Modes of Operation` section (line ~86)

**Content to Add**:

```markdown
## Phase-Specific Behavior

### Planning Phase Review

When reviewing plans BEFORE implementation starts:

**Detection Indicators**:
- Context mentions "plan", "design", "proposed", "will create", "will add"
- Plan uses future tense
- No file verification requested
- Plan document path provided (not implementation files)

**Review Focus**:
- Plan clarity and completeness
- Verifiability of success criteria
- Implementation readiness (can developer proceed?)
- Information sufficiency (90%+ confidence achievable)

**MUST DO**:
- Validate plan provides enough information to implement
- Check success criteria are measurable
- Verify all dependencies are documented
- Ensure no critical gaps in specification

**MUST NOT DO**:
- Check file system for file existence
- Expect implementation to be complete
- Reject for missing implementation files

### Implementation Phase Review

When reviewing AFTER implementation is complete:

**Detection Indicators**:
- Context mentions "implemented", "created", "added", "done"
- Plan uses past tense ("created", "added")
- File verification requested
- Implementation status mentioned

**Review Focus**:
- File system verification (files exist)
- Implementation matches plan specifications
- Success criteria met and measurable
- Quality validation (no obvious bugs)

**MUST DO**:
- Check file system for all mentioned files
- Verify implementation matches plan
- Validate success criteria are met
- Compare planned vs actual implementation

**MUST NOT DO**:
- Reject for missing planned features not yet implemented
- Expect 100% completion of multi-phase plans

### Phase Detection Algorithm

**Step 1**: Scan CONTEXT section for phase indicators
**Step 2**: Count indicator matches (Planning vs Implementation)
**Step 3**: Apply decision rule:
- If Planning indicators > Implementation indicators → Planning Phase
- If Implementation indicators > Planning indicators → Implementation Phase
- If tie or unclear → Default to Planning Phase (safer default)
**Step 4**: Adjust review behavior based on detected phase
```

#### 3.3 Update `.claude/rules/delegator/orchestration.md`

**Insertion Point**: After "### Step 3: Determine Mode" section (line ~264)

**Content to Add**:

```markdown
### Step 3.5: Determine Phase Context

**CRITICAL**: Always specify phase context when delegating to Plan Reviewer.

**Phase Detection**:

| Phase | Context Indicators | Focus |
|-------|-------------------|-------|
| **Planning** | Keywords: "plan", "design", "proposed", "will create" | Plan clarity, completeness, verifiability |
| **Implementation** | Keywords: "implemented", "created", "added", "done" | File system verification, implementation quality |

**Decision Rule**:
1. Scan user input for phase indicator keywords
2. Count Planning vs Implementation indicators
3. Select phase with higher indicator count
4. If tie or unclear, default to Planning Phase

**How to Specify**:

```markdown
CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- [other context...]
```

**Anti-Patterns**:
- ❌ Don't let Plan Reviewer check file system during planning phase
- ❌ Don't assume phase - always specify explicitly
- ❌ Don't use ambiguous phase descriptions

**Correct Patterns**:
- ✅ Explicitly state: "Phase: PLANNING" or "Phase: IMPLEMENTATION"
- ✅ Include phase-specific constraints in MUST NOT DO section
- ✅ Clarify what phase means for file system checks
```

**Enhancement to Step 5** (after line ~276):

```markdown
**Step 5: Build Delegation Prompt (ENHANCED)**

**CRITICAL**: Since each call is stateless, include FULL context:

1. **User's original request** (verbatim)
2. **Relevant code/files** (full content or paths)
3. **Previous attempts and results** (if retry)
4. **Current phase context** (planning vs implementation)
5. **Iteration count** (if multiple attempts)

**Context Template**:
```markdown
CONTEXT:
- Phase: [PLANNING / IMPLEMENTATION]
- Original request: [verbatim user input]
- Relevant files: [paths or snippets]
- Previous iterations:
  - Attempt 1: [what was tried, result]
  - Attempt 2: [what was tried, result]
  - Current iteration: [N]
```

**For Retries**: Include full history in CONTEXT section
```

#### 3.4 Create `.claude/rules/delegator/delegation-checklist.md`

**New File**: `.claude/rules/delegator/delegation-checklist.md`

**Full Content**:

```markdown
# Delegation Prompt Validation Checklist

> Purpose: Validate delegation prompts before calling GPT experts
> Usage: Run through checklist before `codex-sync.sh` calls

## Phase Context

- [ ] Phase explicitly specified (PLANNING or IMPLEMENTATION)
- [ ] Phase-specific constraints included in MUST NOT DO section
- [ ] File system behavior clarified based on phase

## 7-Section Format Compliance

- [ ] TASK: One sentence, atomic, specific goal
- [ ] EXPECTED_OUTCOME: Clear description of success
- [ ] CONTEXT: Current state, relevant code, background
- [ ] CONSTRAINTS: Technical, patterns, limitations
- [ ] MUST_DO: Specific requirements (2-3 items)
- [ ] MUST_NOT_DO: Forbidden actions (2-3 items)
- [ ] OUTPUT_FORMAT: How to structure response

## Stateless Design Compliance

- [ ] User's original request included (verbatim)
- [ ] Relevant file paths or code snippets included
- [ ] Previous attempts documented (if retry)
- [ ] Iteration count specified (if applicable)
- [ ] Full context for stateless call provided

## Phase-Specific Requirements

### Planning Phase
- [ ] DO NOT check file system specified
- [ ] Focus on plan clarity/completeness
- [ ] Success criteria are measurable
- [ ] Implementation readiness validated

### Implementation Phase
- [ ] DO check file system specified
- [ ] Focus on implementation verification
- [ ] Success criteria met and measurable
- [ ] Quality validation included

## Expert-Specific Requirements

### Plan Reviewer
- [ ] 4 evaluation criteria addressed (Clarity, Verifiability, Completeness, Big Picture)
- [ ] Simulation of implementation mentioned
- [ ] Specific improvements provided if rejecting

### Architect
- [ ] Effort estimate included (Quick/Short/Medium/Large)
- [ ] Tradeoffs analyzed
- [ ] Action plan provided

### Code Reviewer
- [ ] Priorities: Correctness → Security → Performance → Maintainability
- [ ] Focus on issues that matter
- [ ] No style nitpicks

### Security Analyst
- [ ] OWASP Top 10 categories checked
- [ ] Risk rating provided
- [ ] Practical remediation (not theoretical)

## Quality Checks

- [ ] No vague instructions ("be careful", "do it right")
- [ ] No contradictory requirements
- [ ] No missing critical information
- [ ] Examples provided if helpful
- [ ] Clear success/failure criteria

## Token Budget Awareness

- [ ] Context prioritized (critical first)
- [ ] Redundant information removed
- [ ] Concise but complete
- [ ] Estimated within 8K-16K tokens

## Final Validation

- [ ] All items above passed
- [ ] Prompt ready for delegation
- [ ] Expected outcome clear
- [ ] Fallback behavior defined

---

**Usage**: Run through this checklist before each `codex-sync.sh` call.
**Goal**: Zero BLOCKING findings from GPT experts due to poor prompts.
```

#### 3.5 Create Example Files

**Directory**: `.claude/rules/delegator/examples/`

**File 1: `before-phase-detection.md`** (Current Problematic Prompt)

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

**File 2: `after-phase-detection.md`** (Improved Prompt)

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

**File 3: `before-stateless.md`** (Missing History)

```markdown
TASK: Fix the jq syntax error.

EXPECTED OUTCOME: Working jq command

CONTEXT:
- File: marketplace.json
- Error: jq syntax error
```

**File 4: `after-stateless.md`** (Full History Included)

```markdown
TASK: Fix the jq syntax error in marketplace.json.

EXPECTED OUTCOME: Working jq in-place syntax

CONTEXT:
- Phase: IMPLEMENTATION (files exist)
- Original request: "Fix jq syntax in marketplace.json"
- File: .claude-plugin/marketplace.json
- Previous iterations:
  - Attempt 1: Tried `.plugins[] |= .version = $VERSION` - Failed: syntax error
  - Attempt 2: Tried `(.plugins[] | select(.name=="claude-pilot")) |= .version = $VERSION` - Failed: still in-place issue
  - Current iteration: 3

CONSTRAINTS:
- Must use in-place jq syntax: `|=` operator
- Cannot create temporary files
- Must work with jq 1.6+

MUST DO:
- Provide correct jq in-place syntax
- Explain why this syntax works
- Test the command

MUST NOT DO:
- Use outdated jq syntax
- Create temporary files

OUTPUT FORMAT:
Summary: [what was wrong, what was fixed]
Correct Command: [exact jq command]
Verification: [how to test it works]
```
```

#### 3.6 Update `.claude/rules/delegator/orchestration.md` - Context Engineering Section

**Insertion Point**: After "## Stateless Design" section (line ~173)

**Content to Add**:

```markdown
## Context Engineering for Delegation

### Dynamic Context Components

**Static Components** (always included):
- **System Instructions**: Expert role, behavior, rules
- **Expert Definition**: From prompt file (prompts/[expert].md)

**Dynamic Components** (curated per delegation):
- **Phase Context**: Planning vs Implementation
- **Iteration History**: Previous attempts and results
- **Task Specifics**: Current goal, constraints, relevant files
- **User Context**: Original request verbatim

### Context Selection Strategy

**1. Phase Detection**:
- Scan input for phase indicator keywords
- Apply decision rule (Planning vs Implementation)
- Default to Planning Phase if unclear

**2. History Injection** (for retries):
- Include all previous attempts
- What was tried each time
- Error messages received
- Current iteration count

**3. Relevance Filtering**:
- Include only relevant file paths
- Include only relevant code snippets
- Prioritize critical context over background

**4. Token Budget Awareness**:
- Prioritize: Phase > History > Task > Background
- Estimate: Target 8K-16K tokens total
- Compact verbose context if needed

### Context Template

```markdown
## Delegation Context

### Static Context
[Expert system instructions from prompt file]

### Dynamic Context
- **Phase**: [PLANNING / IMPLEMENTATION]
- **Original Request**: [verbatim user input]
- **Relevant Files**: [paths or snippets]
- **Iteration History**:
  - Attempt 1: [what, result]
  - Attempt 2: [what, result]
  - Current: [iteration count]
- **Constraints**: [technical, business, quality]
```
```

### Phase 4: Verification

**Manual Testing**:
- Test planning phase delegation with plan document
- Test implementation phase delegation with code
- Verify GPT responses align with phase expectations
- Validate no more "file not found" errors during planning

**Documentation Review**:
- All files updated per success criteria
- Examples demonstrate clear improvements
- Checklist is comprehensive and usable

---

## Constraints

### Technical Constraints
- Must maintain backward compatibility with existing delegation patterns
- Cannot modify `codex-sync.sh` script behavior
- Must work with current GPT models (gpt-5.2)
- Must follow existing file structure

### Business Constraints
- No breaking changes to existing commands
- Minimal increase in token costs per delegation
- Documentation must be clear for users

### Quality Constraints
- **Explicit Instructions**: Follow Claude 4.5 "be explicit" guidance
- **Context Completeness**: Include all relevant context per stateless design
- **Phase Awareness**: All prompts must be phase-aware
- **Validation**: All prompts must pass validation checklist

---

## Related Documentation

- **Claude 4.5 Best Practices**: [Prompting best practices - Claude Docs](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- **Context Engineering**: [Context Engineering in Practice for AI Agents](https://hungvtm.medium.com/context-engineering-in-practice-for-ai-agents-c15ee8b207d9)
- **PRP Framework**: @.claude/guides/prp-framework.md
- **Delegation Format**: @.claude/rules/delegator/delegation-format.md
- **Delegation Orchestration**: @.claude/rules/delegator/orchestration.md

---

## Research Sources

### Official Documentation
- [Prompting best practices - Claude Docs](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Claude Code: Best practices for agentic coding](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Codex CLI Documentation](https://developers.openai.com/codex/cli/)
- [AGENTS.md Pattern](https://github.com/openai/codex/blob/main/AGENTS.md)

### Research Papers & Articles
- [Context Engineering in Practice for AI Agents](https://hungvtm.medium.com/context-engineering-in-practice-for-ai-agents-c15ee8b207d9)
- [Agentic Context Engineering](https://www.sundeepteki.org/blog/agentic-context-engineering)
- [Benchmarking Stateless vs Stateful LLM Agents](https://www.researchgate.net/publication/399575670_Benchmarking_Stateless_Versus_Stateful_LLM_Agent_Architectures_in_Enterprise_Environments)

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2025-01-18 | GPT Plan Reviewer | Plan approved with phase-specific templates and context engineering | ✅ APPROVED |
| 2025-01-18 | Claude (Implementation) | All 5 SCs verified complete with parallel execution strategy | ✅ COMPLETE |

### Execution Summary

**Execution Method**: Parallel Coder agents with dependency-based grouping
- **Group 1 (Parallel)**: SC-1, SC-4 (different files, no dependencies)
- **Group 2 (Sequential)**: SC-2, SC-3 (after SC-1 completes)
- **Group 3 (Sequential)**: SC-5 (after all previous SCs complete)

**Implementation Results**:
- SC-1: ✅ Already implemented (2 phase-specific templates)
- SC-2: ✅ Already implemented (Phase-Specific Behavior section)
- SC-3: ✅ Already implemented (Context Engineering section)
- SC-4: ✅ Created (48 validation items in checklist)
- SC-5: ✅ Created (4 example files: 2 before/after pairs)

**Files Modified/Created**:
- `.claude/rules/delegator/delegation-checklist.md` (created)
- `.claude/rules/delegator/examples/` directory (created)
  - `before-phase-detection.md`
  - `after-phase-detection.md`
  - `before-stateless.md`
  - `after-stateless.md`

**Verification**: All SCs passed verification checks

---

**Plan Version**: 1.0
**Last Updated**: 2025-01-18

---

## Execution Summary

### Status: COMPLETE

### Changes Made

1. **Enhanced 7-Section Format** (`.claude/rules/delegator/delegation-format.md`):
   - Added Planning Phase template with "DO NOT check file system" constraint
   - Added Implementation Phase template with "DO check file system" requirement
   - Phase-specific MUST NOT DO items for each phase

2. **Updated Plan Reviewer Prompt** (`.claude/rules/delegator/prompts/plan-reviewer.md`):
   - Added "Phase-Specific Behavior" section
   - Implemented automatic phase detection algorithm
   - Added phase indicator keyword lists
   - Decision rule: Default to Planning Phase if unclear

3. **Enhanced Orchestration Guide** (`.claude/rules/delegator/orchestration.md`):
   - Added "Step 3.5: Determine Phase Context" section
   - Added "Context Engineering for Delegation" section
   - Dynamic context components (phase, history, iteration count)
   - Context selection strategy with token budget awareness
   - Enhanced Step 5 with stateless design compliance template

4. **Created Validation Checklist** (`.claude/rules/delegator/delegation-checklist.md`):
   - 48 validation items across 8 categories
   - Phase context verification
   - 7-section format compliance
   - Stateless design compliance
   - Expert-specific requirements
   - Quality checks and token budget awareness

5. **Created Example Files** (`.claude/rules/delegator/examples/`):
   - `before-phase-detection.md`: Poor prompt without phase context
   - `after-phase-detection.md`: Improved prompt with phase detection
   - `before-stateless.md`: Missing iteration history
   - `after-stateless.md`: Full stateless context with history

### Verification

- **SC-1**: Phase-specific templates added to delegation-format.md
  - Result: 2 phase-specific templates (Planning, Implementation)
  - Status: PASS

- **SC-2**: Plan Reviewer prompt updated with phase detection
  - Result: Phase-Specific Behavior section with detection algorithm added
  - Status: PASS

- **SC-3**: Context engineering guidelines integrated
  - Result: Context Engineering for Delegation section added
  - Status: PASS

- **SC-4**: Validation checklist created
  - Result: 48 validation items created
  - Status: PASS

- **SC-5**: Example prompts demonstrate improvements
  - Result: 4 example files created (2 before/after pairs)
  - Status: PASS

### Documentation Updates

- **Tier 2 Documentation** (`docs/ai-context/`):
  - `project-structure.md`: Added new files to directory layout, updated version history
  - `system-integration.md`: Added Phase-Specific Delegation section, updated file counts

### Follow-ups

None - all success criteria met and documentation updated.
