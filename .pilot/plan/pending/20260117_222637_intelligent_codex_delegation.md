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
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4, SC-5 | Pending |
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
2. Agent self-assessment pattern for autonomous delegation
3. Updated command files with intelligent triggers
4. Updated agent files with delegation capabilities
5. Centralized delegator rules with semantic patterns
6. Documentation for new intelligent delegation system

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

### How (Approach)

**Implementation Strategy**:

#### Phase 1: Create Intelligent Trigger System
- Design heuristic evaluation framework
- Implement semantic trigger patterns (beyond keywords)
- Create context-aware decision logic

#### Phase 2: Enhance Agent Self-Assessment
- Add `should_delegate()` evaluation to key agents
- Implement failure tracking and escalation
- Add confidence scoring for autonomous decisions

#### Phase 3: Update Commands with Intelligent Triggers
- Replace keyword tables with heuristic checks
- Add decision-point triggers (not just at start)
- Implement progressive escalation

#### Phase 4: Update Delegator Rules
- Centralize trigger detection logic
- Document semantic patterns
- Create best practices guide

**Dependencies**:
- Codex CLI script (`.claude/scripts/codex-sync.sh`) - already exists
- Expert prompt files (`.claude/rules/delegator/prompts/*.md`) - already exists
- Current command/agent structure - maintain compatibility

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

- [ ] **SC-1**: Intelligent trigger detection system created
  - Verify: Read `.claude/rules/delegator/intelligent-triggers.md`
  - Expected: Contains heuristic evaluation patterns (failure-based, ambiguity, complexity, risk, progress)

- [ ] **SC-2**: Agent self-assessment pattern implemented
  - Verify: Grep `should_delegate` in `.claude/agents/coder.md`, `.claude/agents/plan-reviewer.md`, `.claude/agents/code-reviewer.md`
  - Expected: Each agent has self-assessment logic with confidence scoring

- [ ] **SC-3**: Commands updated with intelligent triggers
  - Verify: Grep `heuristic` or `semantic` in `.claude/commands/*.md`
  - Expected: 5+ commands have intelligent trigger sections (not just keyword tables)

- [ ] **SC-4**: Delegator rules centralized and enhanced
  - Verify: Read `.claude/rules/delegator/triggers.md`
  - Expected: Contains both keyword (legacy) and semantic (new) trigger patterns

- [ ] **SC-5**: Documentation created for new system
  - Verify: Read `.claude/guides/intelligent-delegation.md`
  - Expected: Complete guide with examples, patterns, best practices

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
| TS-1 | Heuristic: Failure-based escalation | Task with 2+ failed attempts | Triggers delegation to Architect | Integration | `.pilot/tests/test_delegation.py::test_failure_escalation` |
| TS-2 | Heuristic: Ambiguity detection | Vague task with multiple interpretations | Triggers delegation to Scope Analyst | Unit | `.pilot/tests/test_delegation.py::test_ambiguity_detection` |
| TS-3 | Heuristic: Complexity assessment | Task with 10+ success criteria | Triggers delegation to Architect | Unit | `.pilot/tests/test_delegation.py::test_complexity_assessment` |
| TS-4 | Heuristic: Risk evaluation | Task with "auth" keyword | Triggers delegation to Security Analyst | Unit | `.pilot/tests/test_delegation.py::test_security_trigger` |
| TS-5 | Agent self-assessment | Coder agent blocked on task | Returns `<CODER_BLOCKED>` with confidence score | Integration | `.pilot/tests/test_agents.py::test_coder_self_assess` |
| TS-6 | Progressive escalation | First attempt fails, second attempt succeeds | Delegates only after 2nd failure | Integration | `.pilot/tests/test_delegation.py::test_progressive_escalation` |
| TS-7 | Graceful fallback | Codex CLI not installed | Continues with Claude, logs warning | Integration | `.pilot/tests/test_delegation.py::test_graceful_fallback` |
| TS-8 | Keyword backward compatibility | Explicit "ask GPT" in user input | Still triggers delegation | Regression | `.pilot/tests/test_delegation.py::test_keyword_compat` |

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
2. Update `.claude/rules/delegator/triggers.md` with semantic patterns
3. Add self-assessment sections to key agents (coder, plan-reviewer, code-reviewer)
4. Update command files with intelligent trigger sections
5. Create `.claude/guides/intelligent-delegation.md` documentation

#### Refactor Phase: Clean Up
1. Consolidate duplicate trigger logic
2. Ensure backward compatibility with keyword triggers
3. Apply Vibe Coding standards to new sections

### Phase 3: Ralph Loop (Autonomous Completion)

**Entry**: After first file modification

**Loop until**:
- [ ] All SCs verified complete
- [ ] Verification tests pass
- [ ] Documentation consistent across files
- [ ] Backward compatibility confirmed

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

---

## Completion Checklist

**Before marking plan complete**:

- [ ] All SCs marked complete
- [ ] Intelligent trigger system documented
- [ ] Agent self-assessment patterns implemented
- [ ] Commands updated with heuristic triggers
- [ ] Delegator rules centralized
- [ ] Documentation (`intelligent-delegation.md`) created
- [ ] Backward compatibility verified
- [ ] All modified files reviewed for consistency

---

## Related Documentation

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment**: @.claude/guides/test-environment.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **Delegation Triggers**: @.claude/rules/delegator/triggers.md
- **Delegation Orchestration**: @.claude/rules/delegator/orchestration.md
- **Delegation Format**: @.claude/rules/delegator/delegation-format.md

---

**Plan Version**: 1.0
**Last Updated**: 2026-01-17 22:26:37
