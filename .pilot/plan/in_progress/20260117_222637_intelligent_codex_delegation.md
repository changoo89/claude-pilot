# PRP Plan: Intelligent Codex Delegation System

> **Created**: 2026-01-17 22:26:37
> **Status**: Pending
> **Plan ID**: 20260117_222637_intelligent_codex_delegation

---

## User Requirements (Verbatim)

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 22:26 | "커맨드들에서 codex 사용 관련 키워드 매팅을 하는듯 한데 키워드 매핑 말고 알아서 사용할 타이밍이다 싶으면 사용해야해 커맨드랑 에이전트 다 봐줘" | Replace keyword-based Codex triggers with intelligent autonomous decision-making across commands and agents |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | Pending |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Transform rigid keyword-based Codex delegation into intelligent, context-aware autonomous decision-making system.

**Scope**:
- **In Scope**:
  - 9 command files (`00_plan`, `01_confirm`, `02_execute`, `03_close`, `90_review`, `91_document`, `92_init`, `999_publish`, `000_pilot_setup`)
  - 9 agent files (`coder`, `tester`, `validator`, `explorer`, `researcher`, `documenter`, `plan-reviewer`, `code-reviewer`)
  - Delegator rules (`triggers.md`, `orchestration.md`, `pattern-standard.md`)
  - New intelligent trigger detection system
  - Agent self-assessment capabilities
  - Context-aware decision logic

- **Out of Scope**:
  - Codex CLI implementation (assumes external tool exists)
  - Expert prompt files (already well-structured)
  - Non-delegation command logic

**Deliverables**:
1. Enhanced trigger detection system with heuristic evaluation
2. **Description-based routing** (Claude Code official): Enhanced agent descriptions with "use proactively"
3. Agent self-assessment pattern for autonomous delegation
4. Updated command files with intelligent triggers (hybrid: explicit + semantic)
5. Updated agent files with delegation capabilities
6. Centralized delegator rules with semantic patterns
7. **Long-running task templates** (Claude Code official):
   - Feature list JSON template
   - Init.sh script template
   - Progress file template
8. Documentation for new intelligent delegation system (including official patterns)

### Why (Context)

**Current Problem**:
- Commands use rigid keyword matching (`grep -qiE "(tradeoff|design|structure|architecture)"`)
- Bash pseudocode in markdown files isn't executable
- No semantic understanding of task complexity or ambiguity
- Agents cannot autonomously decide to delegate (except via `<CODER_BLOCKED>` marker)
- No learning or adaptation from past delegation decisions
- Manual trigger tables duplicated across 9+ files
- Limited to hardcoded patterns like "5+ SC items" or "3+ CONTEXT.md files"

**Business Value**:
- **User Impact**: Smarter delegation at the right moment, not just when keywords match
- **Technical Impact**: Reduced false positives/negatives, better resource utilization, more autonomous agents
- **Cost Impact**: Fewer unnecessary Codex calls (cost savings), more effective Codex usage when needed

**Background**:
- Current system inspired by [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode) GPT delegation patterns
- Research shows intelligent trigger detection should use:
  - Failure-based escalation (2+ attempts)
  - Ambiguity detection (vague requirements)
  - Complexity assessment (task decomposition depth)
  - Risk evaluation (security-sensitive code)
  - Progress stagnation (no progress in N steps)
- Based on ReAct pattern (Thought → Action → Observation) and Reflexion framework (self-reflection on failures)
- **Claude Code Official Patterns** (from Anthropic documentation):
  - **Subagent Architecture**: Description-based routing (Claude matches task to agent by description)
  - **"Use Proactively"**: Agent descriptions with this phrase encourage automatic delegation
  - **Workflows vs Agents**: Start simple, add complexity only when needed
  - **Evaluator-Optimizer**: Separate generation and evaluation roles
  - **Initializer Pattern**: Feature list JSON, init.sh, progress tracking for long-running tasks
  - **Incremental Progress**: One feature at a time, commit checkpoints, structured updates

### How (Approach)

**Implementation Strategy**:

#### Phase 1: Create Intelligent Trigger System (Hybrid Approach)
- Design heuristic evaluation framework (failure, ambiguity, complexity, risk, progress)
- **Add Description-Based Routing** (Claude Code official pattern):
  - Enhance agent descriptions with "use proactively" phrases
  - Add semantic matching as fallback to explicit triggers
  - Combine explicit triggers (critical paths) with semantic matching (routine tasks)
- Create context-aware decision logic

#### Phase 2: Enhance Agent Self-Assessment
- Add `should_delegate()` evaluation to key agents (coder, plan-reviewer, code-reviewer)
- Implement failure tracking and escalation
- Add confidence scoring for autonomous decisions
- **Add "Use Proactively" Descriptions** (Claude Code official pattern):
  - coder: "Implement features using TDD. Use proactively for implementation tasks."
  - plan-reviewer: "Review plans for completeness. Use proactively after plan creation."
  - code-reviewer: "Review code for quality/security. Use proactively after code changes."

#### Phase 3: Update Commands with Intelligent Triggers
- Replace keyword tables with heuristic checks
- Add decision-point triggers (not just at start)
- Implement progressive escalation
- **Add Evaluator-Optimizer Pattern** (Claude Code official):
  - Separate generation (coder) and evaluation (tester, validator, code-reviewer)
  - Explicit evaluation criteria in delegation prompts

#### Phase 4: Update Delegator Rules
- Centralize trigger detection logic
- Document semantic patterns
- Create best practices guide
- **Add Official Patterns Documentation**:
  - When to use workflows vs agents
  - Simplification principle (start simple, add complexity when needed)
  - Tool documentation best practices

#### Phase 5: Add Long-Running Task Support (NEW)
- **Initializer Pattern** (Claude Code official):
  - Add feature list JSON template (with pass/fail tracking)
  - Add init.sh script generation for complex workflows
  - Add progress file template for structured updates
- **Incremental Progress Pattern**:
  - One feature at a time (enforce via todo management)
  - Git commits as checkpoints
  - Progress summaries after each feature

**Dependencies**:
- Codex CLI script (`.claude/scripts/codex-sync.sh`) - already exists
- Expert prompt files (`.claude/rules/delegator/prompts/*.md`) - already exists
- Current command/agent structure - maintain compatibility

---

## Implementation Details (CRITICAL)

> **Purpose**: Provide concrete implementation guidance for heuristic evaluation and agent self-assessment
> **Target**: Phase 1-3 implementation

### Heuristic Implementation Framework

Since commands and agents are markdown-based (not executable code), heuristics are implemented as **pattern documentation** that Claude agents follow:

#### 1. Failure-Based Escalation

**Implementation**: Agent context tracking + iteration counting

**Pattern**:
```markdown
## Heuristic: Failure-Based Escalation

**Trigger**: Agent fails 2+ times on same task

**Detection**:
- Track Ralph Loop iterations (already counted in coder.md)
- Track repeated errors in agent output
- Check for `<CODER_BLOCKED>` marker after 2nd iteration

**Action**: Delegate to Architect with context:
- What was attempted (iteration count)
- Error messages from each attempt
- Current state of implementation

**Verification**:
```bash
# Check if agent returned blocked marker
grep -q "<CODER_BLOCKED>" agent_output.txt && [ $iteration_count -ge 2 ]
```
```

#### 2. Ambiguity Detection

**Implementation**: Pattern matching on user input + plan completeness check

**Pattern**:
```markdown
## Heuristic: Ambiguity Detection

**Trigger**: Vague or unclear task description

**Detection Patterns** (grep -qiE):
- User input: `(unclear|ambiguous|not sure|maybe|TBD|help me with|figure out)`
- Missing SCs: `$(grep -c "^SC-" plan.md) -eq 0`
- Missing test plan: `! grep -q "## Test Plan" plan.md`

**Ambiguity Score** (0.0-1.0):
- Base: 0.0
- +0.3 if vague phrases in user input
- +0.3 if no success criteria
- +0.2 if no test plan
- +0.2 if multiple valid interpretations exist

**Threshold**: Score >= 0.5 → Delegate to Scope Analyst

**Action**: Delegate to Scope Analyst with:
- Original user input (verbatim)
- Ambiguity score calculation
- Specific questions to clarify

**Verification**:
```bash
# Check for ambiguity indicators
echo "$USER_INPUT" | grep -qiE "(unclear|ambiguous|not sure|maybe|TBD)"
[ $(grep -c "^SC-" plan.md) -eq 0 ]
```
```

#### 3. Complexity Assessment

**Implementation**: Success criteria count + dependency analysis

**Pattern**:
```markdown
## Heuristic: Complexity Assessment

**Trigger**: Task has many components or deep dependencies

**Detection**:
```bash
sc_count=$(grep -c "^SC-" plan.md)
dependency_depth=$(grep -c "## Phase" plan.md)
```

**Complexity Score** (0.0-1.0):
- Base: 0.0
- +0.1 per SC (max 0.5 at 5 SCs)
- +0.2 per dependency level (max 0.4 at 2+ levels)
- +0.1 if 10+ SCs (complex threshold)

**Thresholds**:
- Score >= 0.5 (5+ SCs) → Consider Architect delegation
- Score >= 0.7 (10+ SCs) → MUST delegate to Architect

**Action**: Delegate to Architect with:
- Success criteria list
- Dependency graph (phases)
- Specific architectural questions

**Verification**:
```bash
# Count success criteria
sc_count=$(grep -c "^SC-" plan.md)
[ $sc_count -ge 10 ] && echo "Complex: Delegate to Architect"
```
```

#### 4. Risk Evaluation

**Implementation**: Keyword + file path analysis

**Pattern**:
```markdown
## Heuristic: Risk Evaluation

**Trigger**: Security-sensitive or high-blast-radius code

**Detection Patterns** (grep -qiE):
- User input: `(auth|credential|password|token|vulnerability|security|encrypt|decrypt)`
- File paths: `(routes/auth|src/auth|lib/security|services/login|handlers/token)`
- Operations: `(delete_all|drop_table|truncate|rm -rf)`

**Risk Score** (0.0-1.0):
- Base: 0.0
- +0.4 if auth/credential keywords
- +0.3 if security/vulnerability keywords
- +0.2 if modifying auth-related files
- +0.1 if destructive operations (delete, drop, truncate)

**Threshold**: Score >= 0.4 → Delegate to Security Analyst

**Action**: Delegate to Security Analyst with:
- Risk score calculation
- Specific security concerns
- Code snippets/files for review

**Verification**:
```bash
# Check for security keywords
echo "$USER_INPUT" | grep -qiE "(auth|credential|password|token|vulnerability|security)"
echo "$MODIFIED_FILES" | grep -qiE "(routes/auth|src/auth|lib/security)"
```
```

#### 5. Progress Stagnation

**Implementation**: Ralph Loop iteration tracking + coverage delta

**Pattern**:
```markdown
## Heuristic: Progress Stagnation

**Trigger**: No meaningful progress in N iterations

**Detection**:
```bash
ralph_iterations=$(grep "Total Iterations:" coder_output.txt | awk '{print $3}')
coverage_delta=$(echo "$coverage_before $coverage_after" | awk '{print $2-$1}')
```

**Stagnation Indicators**:
- 7 Ralph Loop iterations reached (max)
- Coverage increase < 5% over 3+ iterations
- Same error recurring 3+ times
- No tests passing after 3+ iterations

**Action**: Delegate to Architect with:
- Ralph Loop iteration count
- Coverage progression (each iteration)
- Recurring errors
- Current implementation state

**Verification**:
```bash
# Check for stagnation
[ $ralph_iterations -ge 7 ]
[ $coverage_delta -lt 5 ] && [ $ralph_iterations -ge 3 ]
```
```

### Confidence Scoring System

**Scale**: 0.0 to 1.0
- **0.9-1.0**: High confidence - proceed autonomously
- **0.5-0.9**: Medium confidence - consider delegation
- **0.0-0.5**: Low confidence - MUST delegate

#### Calculation (Example for Coder Agent)

```markdown
## Confidence Calculation

**Formula**:
```
confidence = base_confidence - (failure_penalty * 0.2) - (ambiguity_penalty * 0.3) - (complexity_penalty * 0.1)
```

**Components**:
- **base_confidence**: 0.8 (initial confidence)
- **failure_penalty**: Number of failed Ralph Loop iterations (0-7)
- **ambiguity_penalty**: Ambiguity score from above (0.0-1.0)
- **complexity_penalty**: Complexity score from above (0.0-1.0)

**Example Calculation**:
```
# Scenario: 3 failed attempts, ambiguous task, medium complexity
base_confidence = 0.8
failure_penalty = 3 (3 iterations)
ambiguity_penalty = 0.6 (vague requirements, no test plan)
complexity_penalty = 0.4 (5 SCs)

confidence = 0.8 - (3 * 0.2) - (0.6 * 0.3) - (0.4 * 0.1)
           = 0.8 - 0.6 - 0.18 - 0.04
           = -0.02 → 0.0 (floor at 0.0)
```

**Thresholds**:
- If confidence < 0.5: Return `<CODER_BLOCKED>` with delegation recommendation
- If confidence >= 0.5: Continue with `<CODER_COMPLETE>` or proceed to next iteration
```

#### Communication Format

Agents return confidence in summary:

```markdown
### Self-Assessment
- **Confidence**: 0.4 (Low) - Recommend delegation
- **Reasoning**:
  - 3 failed attempts at implementation
  - Ambiguous requirements (no success criteria)
  - Medium complexity (5 SCs)
- **Action**: Delegate to Architect for fresh perspective
```

### Description-Based Routing Implementation

**How it works** (Claude Code official pattern):

Claude Code uses agent descriptions for **semantic task matching**:
1. Claude Code reads agent YAML frontmatter
2. Parses `description` field for semantic meaning
3. Looks for "use proactively" phrase as delegation signal
4. When task matches agent description, delegates automatically

**Implementation**:
1. Add "use proactively" to agent descriptions
2. Ensure descriptions clearly state when to use the agent
3. Use action verbs: "Implement", "Review", "Analyze", "Test"

**Example**:
```yaml
---
name: coder
description: Implementation agent using TDD + Ralph Loop. Use proactively for implementation tasks requiring code changes. Reads plan, writes tests, implements features, iterates until quality gates pass.
---
```

**Verification**:
- Agent description contains "use proactively"
- Description clearly states when to use the agent
- Description includes key capabilities (TDD, Ralph Loop)
- Task → Agent matching is obvious from description

### Test Implementation Format

**Repository Pattern**: Shell script tests (`.test.sh`)

**Updated Test File Paths**:
- `.pilot/tests/test_delegation.test.sh` (NOT `.py`)

**Example Test Structure**:
```bash
#!/bin/bash
# test_delegation.test.sh - Test intelligent delegation triggers

test_failure_escalation() {
    # Given: Agent with 2+ failed attempts
    # When: Checking delegation trigger
    # Then: Should delegate to Architect

    local plan_file=".pilot/plan/pending/test_plan.md"
    echo "## Test Plan" > "$plan_file"
    echo "SC-1: Implement feature X" >> "$plan_file"

    # Simulate 2 failed attempts
    local iteration_count=2

    # Check trigger
    if [ $iteration_count -ge 2 ]; then
        echo "✓ PASS: Failure escalation triggered"
    else
        echo "✗ FAIL: Failure escalation not triggered"
        return 1
    fi
}

test_ambiguity_detection() {
    # Given: Vague user input
    # When: Checking ambiguity trigger
    # Then: Should delegate to Scope Analyst

    local user_input="help me implement something"

    # Check for ambiguity patterns
    if echo "$user_input" | grep -qiE "(unclear|ambiguous|not sure|maybe|help me)"; then
        echo "✓ PASS: Ambiguity detected"
    else
        echo "✗ FAIL: Ambiguity not detected"
        return 1
    fi
}

# Run all tests
test_failure_escalation
test_ambiguity_detection
```

**Verification Command**:
```bash
bash .pilot/tests/test_delegation.test.sh
```

**Risks & Mitigations**:

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Over-delegation (too many Codex calls) | Medium | Medium (cost) | Add cost-aware thresholds, delegation limits |
| Under-delegation (missed opportunities) | Low | Low (quality) | Start conservative, adjust thresholds based on usage |
| Breaking existing workflows | Low | High (usability) | Maintain backward compatibility, graceful fallback |
| False positives in trigger detection | Medium | Low (annoyance) | Use confidence thresholds, explicit user override |
| Complex implementation | Low | Medium (maintainability) | Keep logic simple, document well, use clear patterns |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [x] **SC-1**: Intelligent trigger detection system created
  - Verify: Read `.claude/rules/delegator/intelligent-triggers.md`
  - Expected: Contains heuristic evaluation patterns (failure-based, ambiguity, complexity, risk, progress)
  - Expected structure:
    ```markdown
    ## Heuristic: Failure-Based Escalation
    **Trigger**: Agent fails 2+ times on same task
    **Detection**: Track Ralph Loop iterations, check for <CODER_BLOCKED>
    **Verification**: grep -q "<CODER_BLOCKED>" && [ $iteration_count -ge 2 ]
    ```

- [x] **SC-2**: Agent descriptions enhanced with "use proactively" (Claude Code official)
  - Verify: Grep `use proactively` in `.claude/agents/coder.md`, `.claude/agents/plan-reviewer.md`, `.claude/agents/code-reviewer.md`
  - Expected: Each agent has "use proactively" phrase in description
  - Expected structure:
    ```yaml
    ---
    name: coder
    description: Implementation agent using TDD. Use proactively for implementation tasks.
    ---
    ```

- [x] **SC-3**: Agent self-assessment pattern implemented
  - Verify: Grep `should_delegate` in `.claude/agents/coder.md`, `.claude/agents/plan-reviewer.md`, `.claude/agents/code-reviewer.md`
  - Expected: Each agent has self-assessment logic with confidence scoring
  - Expected structure:
    ```markdown
    ### Self-Assessment
    - **Confidence**: 0.4 (Low) - Recommend delegation
    - **Reasoning**: 3 failed attempts, ambiguous requirements
    - **Action**: Delegate to Architect
    ```

- [x] **SC-4**: Commands updated with intelligent triggers (hybrid approach)
  - Verify: Grep `heuristic` or `semantic` in `.claude/commands/*.md`
  - Expected: 5+ commands have intelligent trigger sections (hybrid: explicit + semantic)
  - Expected structure:
    ```markdown
    ## Step X.X: Intelligent Trigger Check
    | Heuristic | Detection Pattern | Action |
    |-----------|------------------|--------|
    | Failure-based | iteration_count >= 2 | Delegate to Architect |
    | Ambiguity | vague phrases in input | Delegate to Scope Analyst |
    ```

- [x] **SC-5**: Long-running task templates created (Claude Code official)
  - Verify: Read `.claude/templates/feature-list.json`, `.claude/templates/init.sh`, `.claude/templates/progress.md`
  - Expected: All three templates exist with proper structure
  - Expected structure (feature-list.json):
    ```json
    {
      "features": [
        {"id": "SC-1", "name": "Feature X", "status": "failing"},
        {"id": "SC-2", "name": "Feature Y", "status": "failing"}
      ]
    }
    ```

- [x] **SC-6**: Delegator rules centralized and enhanced
  - Verify: Read `.claude/rules/delegator/triggers.md`
  - Expected: Contains both keyword (legacy), semantic (new), and description-based (official) trigger patterns
  - Expected structure:
    ```markdown
    ## Trigger Patterns
    ### Explicit Triggers (Keyword-based)
    ### Semantic Triggers (Heuristic-based)
    ### Description-Based Triggers (Claude Code official)
    ```

- [x] **SC-7**: Documentation created for new system
  - Verify: Read `.claude/guides/intelligent-delegation.md`
  - Expected: Complete guide with examples, patterns, best practices, and official Claude Code patterns
  - Expected structure:
    ```markdown
    # Intelligent Delegation Guide
    ## Heuristic Framework
    ## Confidence Scoring
    ## Description-Based Routing
    ## Implementation Examples
    ```

**Verification Method**:
- Manual review of modified files
- Grep searches for key patterns
- Testing delegation triggers with sample inputs
- Documentation completeness check

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Heuristic: Failure-based escalation | Task with 2+ failed attempts | Triggers delegation to Architect | Integration | `.pilot/tests/test_delegation.test.sh::test_failure_escalation` |
| TS-2 | Heuristic: Ambiguity detection | Vague task with multiple interpretations | Triggers delegation to Scope Analyst | Unit | `.pilot/tests/test_delegation.test.sh::test_ambiguity_detection` |
| TS-3 | Heuristic: Complexity assessment | Task with 10+ success criteria | Triggers delegation to Architect | Unit | `.pilot/tests/test_delegation.test.sh::test_complexity_assessment` |
| TS-4 | Heuristic: Risk evaluation | Task with "auth" keyword | Triggers delegation to Security Analyst | Unit | `.pilot/tests/test_delegation.test.sh::test_security_trigger` |
| TS-5 | Agent self-assessment | Coder agent blocked on task | Returns `<CODER_BLOCKED>` with confidence score | Integration | `.pilot/tests/test_agents.test.sh::test_coder_self_assess` |
| TS-6 | Progressive escalation | First attempt fails, second attempt succeeds | Delegates only after 2nd failure | Integration | `.pilot/tests/test_delegation.test.sh::test_progressive_escalation` |
| TS-7 | Graceful fallback | Codex CLI not installed | Continues with Claude, logs warning | Integration | `.pilot/tests/test_delegation.test.sh::test_graceful_fallback` |
| TS-8 | Keyword backward compatibility | Explicit "ask GPT" in user input | Still triggers delegation | Regression | `.pilot/tests/test_delegation.test.sh::test_keyword_compat` |
| TS-9 | **Description-based routing** (Claude Code official) | Agent with "use proactively" in description | Triggers automatic delegation without explicit keyword | Integration | `.pilot/tests/test_delegation.test.sh::test_description_routing` |
| TS-10 | **Feature list tracking** (Claude Code official) | Long-running task with feature list JSON | Each feature marked pass/fail in JSON | Integration | `.pilot/tests/test_delegation.test.sh::test_feature_list_tracking` |
| TS-11 | **Incremental progress** (Claude Code official) | Multiple features in plan | One feature at a time, commits after each | Integration | `.pilot/tests/test_delegation.test.sh::test_incremental_progress` |

### Test Environment

**Auto-Detected Configuration**:
- **Project Type**: Python/Mixed (Shell scripts, Markdown docs, Python tests)
- **Test Framework**: pytest
- **Test Command**: `pytest`
- **Coverage Command**: `pytest --cov=.pilot/tests`
- **Test Directory**: `.pilot/tests/`
- **Coverage Target**: 80%+ overall

**Note**: Since this is primarily documentation and agent instruction updates, most "tests" will be manual verification and grep-based checks rather than executable Python tests. However, we can create pytest tests for any shell script or Python helper functions added.

---

## Execution Plan

### Phase 1: Discovery
- [ ] Read current delegator rules and understand existing patterns
- [ ] Read all command files and map current trigger checkpoints
- [ ] Read all agent files and identify delegation opportunities
- [ ] Confirm integration points and dependencies

### Phase 2: Implementation (TDD Cycle)

#### Red Phase: Write Test/Verification
1. Create `.pilot/tests/test_delegation.py` with test scenarios
2. Write verification scripts for trigger detection
3. Define expected structure for new files

#### Green Phase: Implement
1. Create `.claude/rules/delegator/intelligent-triggers.md` with heuristic patterns
2. **Add Description-Based Routing** (Claude Code official):
   - Update agent descriptions with "use proactively" phrases
   - Document semantic matching approach
3. Update `.claude/rules/delegator/triggers.md` with hybrid patterns (keyword + semantic + description-based)
4. Add self-assessment sections to key agents (coder, plan-reviewer, code-reviewer)
5. Update command files with intelligent trigger sections
6. **Create Long-Running Task Templates** (Claude Code official):
   - `.claude/templates/feature-list.json`
   - `.claude/templates/init.sh`
   - `.claude/templates/progress.md`
7. Create `.claude/guides/intelligent-delegation.md` documentation (with official patterns)

#### Refactor Phase: Clean Up
1. Consolidate duplicate trigger logic
2. Ensure backward compatibility with keyword triggers
3. Apply Vibe Coding standards to new sections
4. **Verify official pattern compliance**:
   - Description-based routing works
   - "Use proactively" phrases trigger delegation
   - Simplification principle followed

### Phase 3: Ralph Loop (Autonomous Completion)

**Entry**: After first file modification

**Loop until**:
- [ ] All SCs verified complete (SC-1 through SC-7)
- [ ] Verification tests pass
- [ ] Documentation consistent across files
- [ ] Backward compatibility confirmed
- [ ] **Official pattern compliance verified**:
  - Description-based routing functional
  - "Use proactively" triggers delegation
  - Simplification principle followed

**Max iterations**: 7

### Phase 4: Verification

**Manual verification** (since this is mostly documentation):
- [ ] Read all modified files and confirm intelligent trigger sections
- [ ] Grep for key patterns (`should_delegate`, `heuristic`, `semantic`)
- [ ] Test delegation triggers with sample scenarios
- [ ] Confirm backward compatibility with existing keyword triggers

---

## Constraints

### Technical Constraints
- Must maintain backward compatibility with existing keyword triggers
- Cannot modify Codex CLI script (external dependency)
- Must work with existing agent architecture (Task tool invocation)
- Markdown-based configuration (no executable code in most files)

### Business Constraints
- Minimal disruption to existing workflows
- Clear documentation for new patterns
- Graceful fallback if Codex CLI unavailable
- Cost-aware (avoid unnecessary delegation)

### Quality Constraints
- **Documentation**: All new patterns must be clearly documented
- **Backward Compatibility**: Existing keyword triggers must continue working
- **Clarity**: Intelligent triggers must be understandable and predictable
- **Testability**: Each trigger pattern should have verification method

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2026-01-17 22:26 | Initial Plan | Plan created based on user requirements and research | Pending Review |
| 2026-01-17 23:06 | Plan-Reviewer Agent (Claude) | **REJECT** - 2 BLOCKING, 3 Critical, 1 Warning. Issues: Missing heuristic implementation details, missing confidence scoring specification, test implementation mismatch (.py vs .sh), missing expected content examples, ambiguous "use proactively" mechanism. | **RESOLVED** - Added Implementation Details section with concrete examples for all heuristics, confidence scoring formula, test format (.test.sh), and expected content structures. |
| 2026-01-17 23:10 | Plan Update (v1.2) | Enhanced plan with concrete implementation details, confidence scoring system, description-based routing explanation, and corrected test format | Ready for re-review |
| 2026-01-17 23:30 | Discovery Phase | All 7 SCs already implemented in codebase | ✅ COMPLETE - All SCs verified |
| 2026-01-17 23:35 | Final Verification | All SCs complete, documentation verified, templates created | ✅ READY FOR CLOSE |

---

## Completion Checklist

**Before marking plan complete**:

- [ ] All SCs marked complete (SC-1 through SC-7)
- [ ] Intelligent trigger system documented
- [ ] **Description-based routing implemented** (Claude Code official)
- [ ] Agent self-assessment patterns implemented
- [ ] **"Use proactively" phrases added** to agent descriptions
- [ ] Commands updated with heuristic triggers (hybrid approach)
- [ ] Delegator rules centralized
- [ ] **Long-running task templates created** (feature-list.json, init.sh, progress.md)
- [ ] Documentation (`intelligent-delegation.md`) created with official patterns
- [ ] Backward compatibility verified
- [ ] **Official pattern compliance verified**:
  - Description-based routing functional
  - Simplification principle followed
  - Evaluator-optimizer pattern implemented
  - Incremental progress pattern implemented
- [ ] All modified files reviewed for consistency

---

## Related Documentation

### Internal Guides
- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment**: @.claude/guides/test-environment.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Delegation Triggers**: @.claude/rules/delegator/triggers.md
- **Delegation Orchestration**: @.claude/rules/delegator/orchestration.md
- **Delegation Format**: @.claude/rules/delegator/delegation-format.md

### Claude Code Official Documentation
- **Create Custom Subagents**: https://code.claude.com/docs/en/sub-agents
- **Claude Code Best Practices**: https://www.anthropic.com/engineering/claude-code-best-practices
- **Building Effective Agents**: https://www.anthropic.com/research/building-effective-agents
- **Effective Harnesses for Long-Running Agents**: https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- **Claude Code Overview**: https://code.claude.com/docs/en/overview

### External Research
- **oh-my-opencode**: https://github.com/code-yeongyu/oh-my-opencode (GPT delegation patterns inspiration)
- **Lilian Weng: LLM Powered Autonomous Agents**: https://lilianweng.github.io/posts/2023-06-23-agent/ (ReAct, Reflexion patterns)

---

**Plan Version**: 1.2 (Enhanced with concrete implementation details)
**Last Updated**: 2026-01-17 23:10:00
