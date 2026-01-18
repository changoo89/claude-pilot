# PRP Template: Problem-Requirements-Plan

> **Purpose**: Standardized structure for SPEC-First planning documents
> **Usage**: Template for /00_plan output
> **Full Reference**: @.claude/guides/prp-framework.md

---

## Plan Metadata

**Created**: {TIMESTAMP}
**Status**: Pending → In Progress → Done
**Branch**: {GIT_BRANCH}
**Plan ID**: {PLAN_FILENAME}

---

## User Requirements

| ID | Requirement | Source |
|----|-------------|--------|
| UR-1 | {Verbatim user input} | User input |
| UR-2 | {Clarified requirement} | Dialogue |
| UR-3 | {Derived requirement} | Analysis |

---

## PRP Analysis

### What (Functionality)

**Objective**: {Clear statement of what will be built}

**Scope**:
- **In Scope**: {Included features, components, changes}
- **Out of Scope**: {Explicitly excluded items}

**Deliverables**:
1. {Deliverable 1}
2. {Deliverable 2}
3. {Deliverable 3}

### Why (Context)

**Current Problem**: {What is broken or missing}

**Business Value**: {Why this matters, impact, ROI}

**Background**: {Relevant history, constraints, dependencies}

### How (Approach)

**Implementation Strategy**: {High-level approach, architecture, patterns}

**Dependencies**:
- {External dependency 1}
- {Internal dependency 2}
- {Prerequisite 3}

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {Risk 1} | {High/Med/Low} | {High/Med/Low} | {Mitigation strategy} |
| {Risk 2} | {High/Med/Low} | {High/Med/Low} | {Mitigation strategy} |

### Success Criteria

**Measurable, testable, verifiable outcomes**:

- [ ] **SC-1**: {Specific success criterion with measurable outcome}
- [ ] **SC-2**: {Specific success criterion with measurable outcome}
- [ ] **SC-3**: {Specific success criterion with measurable outcome}

**Verification Method**: {How to verify each SC (test, demo, metric)}

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | {Happy path} | {Input} | {Output} | {Unit/Integration} | {test/file/path.test.ts} |
| TS-2 | {Edge case} | {Input} | {Output} | {Unit} | {test/file/path.test.ts} |

**Additional scenarios**: Add TS-3, TS-4... as needed

### Test Environment

**Auto-Detected Configuration**:
- **Project Type**: {Python/Node.js/Go/Rust}
- **Test Framework**: {pytest/jest/go test/cargo test}
- **Test Command**: {pytest/npm test/go test/cargo test}
- **Test Directory**: {tests/}
- **Coverage Target**: 80%+ overall, 90%+ core modules

---

## Execution Plan

### Phase 1: Discovery
- [ ] Read plan file and understand requirements
- [ ] Use Glob/Grep to find related files
- [ ] Confirm integration points
- [ ] Update plan if reality differs from assumptions

### Phase 2: Implementation (TDD Cycle)

> **Methodology**: @.claude/skills/tdd/SKILL.md

**For each SC**:
1. **Red**: Write failing test → confirm RED
2. **Green**: Minimal implementation → confirm GREEN
3. **Refactor**: Apply Vibe Coding → confirm still GREEN

### Phase 3: Ralph Loop (Autonomous Completion)

> **Methodology**: @.claude/skills/ralph-loop/SKILL.md

**Entry**: After first code change
**Max iterations**: 7

**Verify**:
- [ ] Tests pass
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean
- [ ] Lint clean

### Phase 4: Parallel Verification

**3 agents** (@.claude/guides/parallel-execution.md):
- [ ] Tester: Tests, coverage
- [ ] Validator: Type check, lint
- [ ] Code-Reviewer: Code quality

---

## Constraints

### Technical Constraints
- {Version requirements}
- {Dependency limitations}
- {Platform restrictions}

### Business Constraints
- {Timeline}
- {Budget}
- {Resources}

### Quality Constraints
- **Coverage**: ≥80% overall, ≥90% core
- **Type Safety**: Type check pass
- **Code Quality**: Lint pass
- **Standards**: Vibe Coding (≤50 lines/function, ≤200 lines/file, ≤3 nesting)

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| {Timestamp} | {Agent/User} | {Review findings} | {Approved/Changes Needed} |

---

## Completion Checklist

- [ ] All SCs complete
- [ ] Tests pass, coverage ≥80% (core ≥90%)
- [ ] Type check clean, lint clean
- [ ] Code review passed
- [ ] Documentation updated
- [ ] Plan archived to `.pilot/plan/done/`

---

## Related Documentation

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment**: @.claude/guides/test-environment.md
- **TDD**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

**Template Version**: 1.0
**Last Updated**: 2026-01-19
