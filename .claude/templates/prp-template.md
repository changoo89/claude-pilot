# PRP Template: Problem-Requirements-Plan

> **Purpose**: Standardized structure for SPEC-First planning documents
> **Usage**: Template for /00_plan output

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
| TS-1 | {Happy path scenario} | {Test input} | {Expected output} | {Unit/Integration/E2E} | {test/file/path.test.ts} |
| TS-2 | {Edge case scenario} | {Test input} | {Expected output} | {Unit} | {test/file/path.test.ts} |
| TS-3 | {Error scenario} | {Test input} | {Expected output} | {Integration} | {test/file/path.test.ts} |
| TS-4 | {Additional scenario} | {Test input} | {Expected output} | {E2E} | {test/file/path.test.ts} |

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

**For each Success Criterion**:

#### Red Phase: Write Failing Test
1. Generate test stub
2. Write assertions
3. Run tests → confirm RED (failing)
4. Mark test todo as in_progress

#### Green Phase: Minimal Implementation
1. Write ONLY enough code to pass the test
2. Run tests → confirm GREEN (passing)
3. Mark test todo as complete

#### Refactor Phase: Clean Up
1. Apply Vibe Coding standards (SRP, DRY, KISS, Early Return)
2. Run ALL tests → confirm still GREEN

### Phase 3: Ralph Loop (Autonomous Completion)

**Entry**: Immediately after first code change

**Loop until**:
- [ ] All tests pass
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean
- [ ] Lint clean
- [ ] All todos completed

**Max iterations**: 7

### Phase 4: Verification

**Parallel verification** (3 agents):
- [ ] Tester: Run tests, verify coverage
- [ ] Validator: Type check, lint
- [ ] Code-Reviewer: Review code quality

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
- **Coverage**: ≥80% overall, ≥90% core modules
- **Type Safety**: Type check must pass
- **Code Quality**: Lint must pass
- **Standards**: Vibe Coding (functions ≤50 lines, files ≤200 lines, nesting ≤3 levels)

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| {Timestamp} | {Agent/User} | {Review findings} | {Approved/Changes Needed} |

---

## Completion Checklist

**Before marking plan complete**:

- [ ] All SCs marked complete
- [ ] All tests pass
- [ ] Coverage targets met (80%+ overall, 90%+ core)
- [ ] Type check clean
- [ ] Lint clean
- [ ] Code review passed
- [ ] Documentation updated
- [ ] Plan archived to `.pilot/plan/done/`

---

## Related Documentation

- **PRP Framework**: @.claude/guides/prp-framework.md
- **Test Plan Design**: @.claude/guides/test-plan-design.md
- **Test Environment**: @.claude/guides/test-environment.md
- **Parallel Execution**: @.claude/guides/parallel-execution.md
- **TDD Methodology**: @.claude/skills/tdd/SKILL.md
- **Ralph Loop**: @.claude/skills/ralph-loop/SKILL.md
- **Vibe Coding**: @.claude/skills/vibe-coding/SKILL.md

---

**Template Version**: 1.0
**Last Updated**: 2026-01-17
