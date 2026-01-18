# /90_review - Detailed Reference

> **Companion**: `90_review.md` | **Purpose**: Detailed implementation reference for plan review workflow

---

## Detailed Step Implementation

### Step 0.5: GPT Delegation Trigger Check (Detailed)

> **Purpose**: Determine if GPT expert review is needed before starting review
> **Decision**: Based on plan complexity, security sensitivity, and success criteria count

#### When to Delegate to GPT Plan Reviewer

| Condition | Threshold | Action |
|-----------|-----------|--------|
| Success criteria count | 5+ SCs | Delegate to GPT Plan Reviewer |
| Architecture decisions | Keywords: architecture, tradeoffs, design | Delegate to GPT Architect |
| Security-sensitive changes | Keywords: auth, credential, security, API | Delegate to GPT Security Analyst |
| Simple plan | < 5 SCs | Use Claude plan-reviewer agent |

#### Implementation

**Check Plan SC Count**:
```bash
# Extract success criteria from plan
PLAN_SC_COUNT=$(grep -c "^SC-" "$PLAN_PATH" 2>/dev/null || echo 0)

# Check for architecture keywords
HAS_ARCHITECTURE=$(grep -qiE "architecture|tradeoff|design" "$PLAN_PATH" && echo "true" || echo "false")

# Check for security keywords
HAS_SECURITY=$(grep -qiE "auth|credential|security|token" "$PLAN_PATH" && echo "true" || echo "false")
```

**Codex CLI Availability Check**:
```bash
# Check Codex CLI availability
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only review"
    USE_GPT_DELEGATION="false"
else
    USE_GPT_DELEGATION="true"
fi

# Decision logic
if [ "$USE_GPT_DELEGATION" = "true" ] && [ "$PLAN_SC_COUNT" -ge 5 ]; then
    # Delegate to GPT Plan Reviewer
    .claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/plan-reviewer.md)"
elif [ "$USE_GPT_DELEGATION" = "true" ] && [ "$HAS_ARCHITECTURE" = "true" ]; then
    # Delegate to GPT Architect
    .claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/architect.md)"
elif [ "$USE_GPT_DELEGATION" = "true" ] && [ "$HAS_SECURITY" = "true" ]; then
    # Delegate to GPT Security Analyst
    .claude/scripts/codex-sync.sh "read-only" "$(cat .claude/rules/delegator/prompts/security-analyst.md)"
else
    # Continue with Claude plan-reviewer agent (Step 4)
    USE_CLAUDE_AGENT="true"
fi
```

**Graceful Fallback**:
- If Codex CLI not installed → Use Claude plan-reviewer agent
- If delegation fails → Continue with Claude plan-reviewer agent
- Log warning message for debugging

#### Delegation Prompt Template

**For GPT Plan Reviewer**:
```markdown
You are a plan review expert. Review this plan for completeness and clarity.

TASK: Review plan document for implementation completeness.

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
```

---

### Step 1: Proactive Investigation (Detailed)

> **Purpose**: Investigate all "needs investigation/confirmation/review" items upfront
> **Principle**: Don't wait for execution phase to discover unknowns

#### Investigation Targets

| Target | Investigation Method | Tools | Examples |
|--------|---------------------|-------|----------|
| **Existing code/patterns** | Search similar implementations | Glob, Grep, Read | Find utils/, hooks/, common/ |
| **API documentation** | Check official docs | WebSearch, WebFetch | API endpoints, SDKs |
| **Dependencies** | Check package registries | Bash(npm info, pip show) | Version compatibility |

#### Keyword Detection

**Keywords to search for**:
- "need to investigate"
- "confirm"
- "TODO"
- "check"
- "verify"
- "unclear"
- "TBD"

**Implementation**:
```bash
# Search for investigation markers
grep -rn "need to investigate\|TODO\|confirm\|check" "$PLAN_PATH"

# For each marker, determine investigation strategy
# Example: "TODO: Check if utils/validate.ts exists"
# Action: Run "find . -name 'validate.ts' -path '*/utils/*'"
```

#### Investigation Results Format

```markdown
## Investigation Results

### Existing Code Patterns
- [Found/Not Found] [pattern name]
- Location: [file path]
- Reusability: [Can reuse / Need adaptation]

### API Documentation
- [API Name]: [Version / Status]
- Documentation: [Link]
- Breaking Changes: [Yes/No]

### Dependencies
- [Package]: [Current version / Latest version]
- Compatibility: [Compatible / Update needed]
```

---

### Step 2: Type Detection (Detailed)

> **Purpose**: Auto-detect plan type to activate appropriate extended reviews
> **Full activation matrix**: See @.claude/guides/review-checklist.md - Extended Reviews

#### Type Detection Matrix

| Type | Keywords (Trigger) | Test File Requirement | Extended Reviews |
|------|-------------------|----------------------|------------------|
| **Code** | function, component, API, bug fix, src/, lib/ | **Required** | A (API compat), B (Types), D (Tests) |
| **Config** | .claude/, settings, rules, template, workflow | **Optional** (N/A allowed) | None |
| **Documentation** | CLAUDE.md, README, guide, docs/, CONTEXT.md | **Optional** (N/A allowed) | C (Consistency) |
| **Scenario** | test, validation, edge cases | **Required** | H (Coverage) |
| **Infra** | Vercel, env, deploy, CI/CD | **Required** | F (Deployment) |
| **DB** | migration, table, schema | **Required** | E (Migration) |
| **AI** | LLM, prompts, AI | **Required** | G (Prompts) |

#### Auto-Detection Implementation

```bash
# Detect plan type from keywords
PLAN_TYPE="unknown"

if grep -qiE "function|component|API|bug fix|src/|lib/" "$PLAN_PATH"; then
    PLAN_TYPE="code"
elif grep -qiE "\.claude/|settings|rules|template|workflow" "$PLAN_PATH"; then
    PLAN_TYPE="config"
elif grep -qiE "CLAUDE\.md|README|guide|docs/|CONTEXT\.md" "$PLAN_PATH"; then
    PLAN_TYPE="documentation"
elif grep -qiE "test|validation|edge cases" "$PLAN_PATH"; then
    PLAN_TYPE="scenario"
elif grep -qiE "Vercel|env|deploy|CI/CD" "$PLAN_PATH"; then
    PLAN_TYPE="infra"
elif grep -qiE "migration|table|schema" "$PLAN_PATH"; then
    PLAN_TYPE="db"
elif grep -qiE "LLM|prompts|AI|GPT" "$PLAN_PATH"; then
    PLAN_TYPE="ai"
fi

echo "Detected plan type: $PLAN_TYPE"
```

#### Test File Conditional Logic

**For Code/Scenario/Infra/DB/AI**:
- Test file path: **Required** (BLOCKING if missing)
- Test scenarios: **Required**
- Coverage command: **Required**

**For Config/Documentation**:
- Test file path: **Optional** (N/A allowed)
- Manual testing: **Acceptable**

---

### Step 3: Mandatory Reviews (Detailed)

> **Purpose**: Execute 8 mandatory reviews for every plan
> **Full checklist**: See @.claude/guides/review-checklist.md

#### 1. Development Principles Review

**Checks**:
- **SOLID**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion
- **DRY**: Don't Repeat Yourself - code reuse patterns
- **KISS**: Keep It Simple, Stupid - avoid over-engineering
- **YAGNI**: You Aren't Gonna Need It - avoid hypothetical features

**Assessment**: ✅ Pass / ⚠️ Warning / ❌ Fail

**Example Findings**:
- ✅ Plan follows SOLID principles
- ⚠️ Consider extracting shared logic to utils/
- ❌ Over-engineering detected - simplify approach

#### 2. Project Structure Review

**Checks**:
- File locations match project conventions
- Naming follows established patterns
- Module boundaries respected

**Assessment**: ✅ Pass / ⚠️ Warning / ❌ Fail

**Example Findings**:
- ✅ Files placed in correct directories
- ⚠️ Consider renaming for consistency
- ❌ New file violates module structure

#### 3. Requirement Completeness Review

**Checks**:
- **Explicit requirements**: Clearly stated in plan
- **Implicit requirements**: Inferred from context
- Missing requirements: Gaps in specification

**Assessment**: ✅ Complete / ⚠️ Minor gaps / ❌ Major gaps

**Example Findings**:
- ✅ All requirements explicitly stated
- ⚠️ Add error handling requirements
- ❌ Missing authentication requirements

#### 4. Logic Errors Review

**Checks**:
- Order of operations correct
- Dependencies properly sequenced
- Edge cases considered
- Async operations handled correctly

**Assessment**: ✅ No issues / ⚠️ Potential issues / ❌ Logic errors found

**Example Findings**:
- ✅ Logic flow is correct
- ⚠️ Consider race condition in parallel operations
- ❌ Missing error handling for API failures

#### 5. Existing Code Reuse Review

**Checks**:
- Search existing utilities, hooks, common patterns
- Identify reusable components
- Avoid duplication

**Assessment**: ✅ Reuses existing / ⚠️ Some duplication / ❌ Duplicate code

**Example Findings**:
- ✅ Leverages existing utils/
- ⚠️ Similar to hooks/useAuth.ts - consider consolidating
- ❌ Duplicates existing validation logic

#### 6. Better Alternatives Review

**Checks**:
- Simpler approaches available
- More scalable solutions exist
- More testable patterns possible

**Assessment**: ✅ Optimal / ⚠️ Consider alternatives / ❌ Better approach exists

**Example Findings**:
- ✅ Chosen approach is optimal
- ⚠️ Consider using established library instead of custom
- ❌ React Query would be simpler than useState

#### 7. Project Alignment Review

**Checks**:
- Type checking compliance
- API documentation consistency
- Affected areas identified

**Assessment**: ✅ Aligned / ⚠️ Minor issues / ❌ Misaligned

**Example Findings**:
- ✅ Follows project type-check standards
- ⚠️ Update API docs for new endpoints
- ❌ Violates project coding conventions

#### 8. Long-term Impact Review

**Checks**:
- Future consequences considered
- Technical debt implications
- Scalability concerns
- Rollback feasibility

**Assessment**: ✅ Sustainable / ⚠️ Some debt / ❌ High risk

**Example Findings**:
- ✅ Sustainable long-term solution
- ⚠️ Introduces minor technical debt
- ❌ Scalability concerns - reconsider approach

---

### Step 5: Extended Reviews (Detailed)

> **Purpose**: Type-specific reviews beyond mandatory 8 items
> **Activation Matrix**: See @.claude/guides/review-checklist.md

#### Extended Review by Type

| Type | Reviews | Description |
|------|---------|-------------|
| **Code Mod** | A (API compat), B (Types), D (Tests) | API compatibility, Type safety, Test coverage |
| **Documentation** | C (Consistency) | Documentation consistency |
| **Scenario** | H (Coverage) | Test coverage scenarios |
| **Infrastructure** | F (Deployment) | Deployment verification |
| **DB Schema** | E (Migration) | Migration strategy |
| **AI/Prompts** | G (Prompts) | Prompt engineering review |

#### A: API Compatibility Review

**Checks**:
- Breaking changes identified
- Version compatibility verified
- Deprecation warnings handled

**Assessment**: ✅ Compatible / ⚠️ Minor issues / ❌ Breaking changes

#### B: Type Safety Review

**Checks**:
- TypeScript types defined
- Interface contracts clear
- Type coverage adequate

**Assessment**: ✅ Typed / ⚠️ Partial types / ❌ Untyped

#### D: Test Coverage Review

**Checks**:
- Unit tests planned
- Integration tests planned
- Edge cases covered

**Assessment**: ✅ Adequate / ⚠️ Gaps / ❌ Insufficient

#### C: Documentation Consistency Review

**Checks**:
- Terminology consistent
- Formatting matches standards
- Cross-references accurate

**Assessment**: ✅ Consistent / ⚠️ Minor issues / ❌ Inconsistent

#### H: Coverage Scenarios Review

**Checks**:
- Happy path covered
- Error paths covered
- Edge cases identified

**Assessment**: ✅ Complete / ⚠️ Missing scenarios / ❌ Incomplete

#### F: Deployment Review

**Checks**:
- Deployment steps defined
- Environment variables documented
- Rollback plan included

**Assessment**: ✅ Ready / ⚠️ Needs clarification / ❌ Not ready

#### E: Migration Strategy Review

**Checks**:
- Migration path defined
- Data preservation strategy
- Rollback plan included

**Assessment**: ✅ Safe / ⚠️ Risks / ❌ Unsafe

#### G: Prompt Engineering Review

**Checks**:
- Prompt clarity verified
- Context boundaries defined
- Output format specified

**Assessment**: ✅ Clear / ⚠️ Ambiguous / ❌ Unclear

---

### Step 6: Autonomous Review (Detailed)

> **Purpose**: Self-judged review beyond mandatory/extended items
> **Perspectives**: Security, Performance, UX, Maintainability, Concurrency, Error Recovery

#### Security Perspective

**Checks**:
- Input validation planned
- Authentication/authorization covered
- Secret management strategy
- OWASP Top 10 considered

**Assessment**: ✅ Secure / ⚠️ Hardening needed / ❌ Security risks

#### Performance Perspective

**Checks**:
- Performance expectations defined
- Bottlenecks identified
- Optimization strategy included

**Assessment**: ✅ Performant / ⚠️ Optimization needed / ❌ Performance risks

#### UX Perspective

**Checks**:
- User experience considered
- Error messages user-friendly
- Edge cases handled gracefully

**Assessment**: ✅ Good UX / ⚠️ UX improvements / ❌ Poor UX

#### Maintainability Perspective

**Checks**:
- Code organization clear
- Documentation adequate
- Future maintenance considered

**Assessment**: ✅ Maintainable / ⚠️ Maintenance concerns / ❌ Unmaintainable

#### Concurrency Perspective

**Checks**:
- Race conditions considered
- Parallel operations safe
- Locking strategy defined

**Assessment**: ✅ Safe / ⚠️ Concurrency risks / ❌ Unsafe

#### Error Recovery Perspective

**Checks**:
- Error handling comprehensive
- Recovery strategies defined
- Graceful degradation planned

**Assessment**: ✅ Resilient / ⚠️ Recovery gaps / ❌ Fragile

---

### Step 7: Gap Detection Review (Detailed)

> **Purpose**: Identify gaps in external service integration
> **Full gap detection**: See @.claude/guides/gap-detection.md

#### Severity Levels

| Level | Symbol | Description | Action |
|-------|--------|-------------|--------|
| **BLOCKING** | 🛑 | Cannot proceed without addressing | Interactive Recovery |
| **Critical** | 🚨 | Must fix before execution | Fix required |
| **Warning** | ⚠️ | Should fix before execution | Recommend fix |
| **Suggestion** | 💡 | Nice to have | Optional improvement |

#### Gap Detection Categories

**9.1 External API**:
- SDK vs HTTP decision
- Endpoint verification
- Error handling strategy
- Rate limiting considered

**9.2 Database Operations**:
- Migration files required
- Rollback strategy
- Connection management
- Data consistency

**9.3 Async Operations**:
- Timeout configuration
- Concurrent request limits
- Race condition prevention
- Promise rejection handling

**9.4 File Operations**:
- Path resolution (absolute vs relative)
- Existence checks before operations
- Cleanup strategy for temporary files
- File permission handling

**9.5 Environment Variables**:
- Documentation in plan
- Existence verification
- No secrets in plan
- Default values specified

**9.6 Error Handling**:
- No silent catches
- User notification strategy
- Graceful degradation
- Error logging strategy

**9.7 Test Plan Verification** (BLOCKING):
- Scenarios defined
- Test files specified (or N/A for config/doc)
- Test commands detected
- Coverage command included
- Test environment specified

#### Gap Detection Output Format

```markdown
## Gap Detection Results

### 9.1 External API
- [API Name]: [Status]
  - SDK vs HTTP: [Decision]
  - Endpoint: [URL/Path]
  - Error Handling: [Strategy]
  - Severity: [🛑/🚨/⚠️/💡]

### 9.7 Test Plan
- Scenarios: [Defined/Missing] 🛑
- Test Files: [Specified/N/A]
- Test Command: [Detected/Missing]
- Coverage: [Included/Missing]
```

---

### Step 9: Apply Findings to Plan (Detailed)

> **Purpose**: Apply review findings to improve plan
> **Principle**: Review completion = Plan file improved with findings applied

#### Issue Type Mapping

| Issue Type | Target Section | Method | Example |
|------------|----------------|--------|---------|
| Missing step | Execution Plan | Add checkbox | "- [ ] Add input validation" |
| Unclear requirement | User Requirements | Clarify wording | "Fix" → "Fix null pointer in auth.ts:45" |
| Test gap | Test Plan | Add scenario | "+ TS-4: Handle edge case where user is null" |
| Risk identified | Risks | Add item | "- API rate limits may affect performance" |
| Missing dependency | Scope | Add requirement | "- [ ] Install lodash for utility functions" |

#### Application Process

1. **Read plan file**: Load current plan content
2. **Apply modifications**:
   - Add missing items to appropriate sections
   - Clarify ambiguous requirements
   - Add test scenarios
   - Document risks
3. **Write plan file**: Save updated plan
4. **Update Review History**: Append findings summary

```bash
# Apply findings to plan
PLAN_CONTENT=$(cat "$PLAN_PATH")

# Apply each finding
for finding in "${FINDINGS[@]}"; do
    case "$finding" in
        "missing_step")
            # Add step to Execution Plan
            PLAN_CONTENT=$(echo "$PLAN_CONTENT" | sed '/## Execution Plan/a\  - [ ] New step')
            ;;
        "unclear_requirement")
            # Clarify requirement wording
            PLAN_CONTENT=$(echo "$PLAN_CONTENT" | sed 's/Fix/Fix null pointer in auth.ts:45/')
            ;;
        "test_gap")
            # Add test scenario to Test Plan
            PLAN_CONTENT=$(echo "$PLAN_CONTENT" | sed '/## Test Plan/a\+ TS-N: New test scenario')
            ;;
        "risk")
            # Add risk to Risks section
            PLAN_CONTENT=$(echo "$PLAN_CONTENT" | sed '/## Risks/a\- New risk identified')
            ;;
    esac
done

# Write updated plan
echo "$PLAN_CONTENT" > "$PLAN_PATH"

# Append to Review History
echo "## Review $(date)" >> "$PLAN_PATH"
echo "- BLOCKING: $BLOCKING_COUNT" >> "$PLAN_PATH"
echo "- Critical: $CRITICAL_COUNT" >> "$PLAN_PATH"
echo "- Warning: $WARNING_COUNT" >> "$PLAN_PATH"
echo "- Suggestion: $SUGGESTION_COUNT" >> "$PLAN_PATH"
```

---

### Step 9.5: Parallel Multi-Angle Review (Detailed)

> **Purpose**: Leverage multiple Claude plan-reviewer agents concurrently for comprehensive analysis
> **Trigger**: Complex plans (5+ SCs), high-stakes features, system-wide changes

#### When to Use Parallel Review

**Use Parallel Review When**:
- Plan has 5+ success criteria
- High-stakes features (security, payments, auth)
- System-wide architectural changes
- Multiple expert perspectives needed

**Do NOT Use Parallel Review When**:
- Simple plans (< 5 SCs)
- Cost constraints (3x token cost)
- Time-sensitive review (sequential faster)

#### Parallel Review Implementation

**Invoke 3 plan-reviewer agents concurrently**:

```markdown
Task:
  subagent_type: plan-reviewer
  description: "Security angle review"
  prompt: |
    Review plan from SECURITY angle:
    - External API security
    - Input validation
    - Authentication/authorization
    - Secret management

    Plan Path: {PLAN_PATH}

    Focus on identifying security vulnerabilities, auth gaps, and input validation issues.

Task:
  subagent_type: plan-reviewer
  description: "Quality angle review"
  prompt: |
    Review plan from QUALITY angle:
    - Vibe Coding compliance
    - Code quality standards
    - Testing coverage
    - Documentation completeness

    Plan Path: {PLAN_PATH}

    Focus on code quality, testing gaps, and documentation completeness.

Task:
  subagent_type: plan-reviewer
  description: "Architecture angle review"
  prompt: |
    Review plan from ARCHITECTURE angle:
    - System design
    - Component relationships
    - Scalability considerations
    - Integration points

    Plan Path: {PLAN_PATH}

    Focus on system design, scalability, and architectural soundness.
```

#### Process Parallel Results

**Wait for ALL agents to complete** before proceeding.

**Merge Strategy**:
1. Collect all findings from 3 agents
2. Deduplicate overlapping findings
3. Prioritize by severity (BLOCKING > Critical > Warning > Suggestion)
4. Apply to plan (Step 9)
5. Update review history

**Output Format**:
```markdown
## Parallel Multi-Angle Review Results

### Security Reviewer
- [Findings...]

### Quality Reviewer
- [Findings...]

### Architecture Reviewer
- [Findings...]

### Merged Findings
- BLOCKING: [N items]
- Critical: [N items]
- Warning: [N items]
- Suggestion: [N items]
```

---

### Step 10: GPT Expert Review (Detailed)

> **Purpose**: Leverage GPT experts for high-difficulty analysis beyond standard review
> **Full delegation guide**: See @.claude/rules/delegator/orchestration.md

#### GPT Expert Selection

| Scenario | GPT Expert | Trigger | Expert Prompt File |
|----------|------------|---------|-------------------|
| **Architecture review** | Architect | System design, tradeoffs, scalability | `prompts/architect.md` |
| **Security review** | Security Analyst | Auth, sensitive data, external APIs | `prompts/security-analyst.md` |
| **Large plan validation** | Plan Reviewer | 5+ success criteria, complex dependencies | `prompts/plan-reviewer.md` |
| **Scope ambiguity** | Scope Analyst | Unclear requirements, multiple interpretations | `prompts/scope-analyst.md` |

#### Delegation Implementation

**Check Codex CLI availability**:
```bash
if ! command -v codex &> /dev/null; then
    echo "Warning: Codex CLI not installed - falling back to Claude-only review"
    return 0
fi
```

**Read expert prompt**:
```bash
EXPERT_PROMPT="$(cat .claude/rules/delegator/prompts/[expert].md)"
```

**Build delegation prompt**:
```bash
DELEGATION_PROMPT="${EXPERT_PROMPT}

TASK: Review plan from [EXPERT PERSPECTIVE] angle.

EXPECTED OUTCOME: Comprehensive [EXPERT TYPE] analysis with findings.

CONTEXT:
- Phase: PLANNING (files don't exist yet - validate PLAN completeness)
- Plan to review: $(cat "$PLAN_PATH")
- Goals: [extracted from plan]

CONSTRAINTS:
- This is a PLAN review - do NOT check file system
- Focus on [EXPERT-SPECIFIC FOCUS AREAS]
- Assume implementation hasn't started

MUST DO:
- Evaluate all [EXPERT-SPECIFIC] criteria
- Provide specific findings with severity levels
- Suggest concrete improvements if rejecting

MUST NOT DO:
- Check file system for files that don't exist yet
- Expect implementation to be complete
- Rubber-stamp without real analysis

OUTPUT FORMAT:
Findings by severity:
- BLOCKING: [critical issues that prevent execution]
- Critical: [must fix before execution]
- Warning: [should fix before execution]
- Suggestion: [nice to have improvements]
"

# Call delegation
.claude/scripts/codex-sync.sh "read-only" "$DELEGATION_PROMPT"
```

**Cost Awareness**:
- GPT calls cost money (~$0.10-$0.50 per call)
- Use for high-value analysis only
- Prefer Claude agents for standard reviews

---

## Testing

### Manual Testing

**Test Standard Review**:
```bash
/90_review .pilot/plan/pending/test_plan.md
```
Expected: Comprehensive review with findings applied to plan

**Test Complex Plan (Parallel Review)**:
```bash
/90_review .pilot/plan/pending/complex_plan.md
```
Expected: Triggers parallel multi-angle review (3 agents)

**Test GPT Delegation**:
```bash
PLAN_SC_COUNT=$(grep -c "^SC-" "$PLAN_PATH")
if [ "$PLAN_SC_COUNT" -ge 5 ]; then
    # Should trigger GPT Plan Reviewer delegation
fi
```
Expected: GPT expert review triggered

### Verification Checklist

After running `/90_review`:
- [ ] Plan file loaded successfully
- [ ] Plan type detected correctly
- [ ] All 8 mandatory reviews completed
- [ ] Extended reviews activated by type
- [ ] Gap detection run (BLOCKING triggers Interactive Recovery)
- [ ] Findings applied to plan
- [ ] Review history updated
- [ ] Parallel review invoked for complex plans (if applicable)
- [ ] GPT expert review invoked for large plans (if applicable)

---

**Reference Version**: claude-pilot 4.2.0
**Last Updated**: 2026-01-19
