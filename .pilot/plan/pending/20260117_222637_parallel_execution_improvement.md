# Parallel Execution Improvement Plan
- Generated: 2026-01-17 22:26:37 | Work: parallel_execution_improvement | Location: /Users/chanho/claude-pilot/.pilot/plan/pending/20260117_222637_parallel_execution_improvement.md

## User Requirements (Verbatim)

> **Purpose**: Track ALL user requests verbatim to prevent omissions

| ID | Timestamp | User Input (Original) | Summary |
|----|-----------|----------------------|---------|
| UR-1 | 22:15 | "우리 프로젝트에서 커맨드들에 병렬실행이 적혀있는데 더 병렬로 할 수 있는데 안하는거같아 예를들면 독립적인 파일 2개를 생성 혹은 수정하는데 coder 를 하나만 서브에이전트 배치헤서 이걸 쭉 얘가 다 하게 만드는 듯 한데, 태스크 단위로 동일 에이전트 인스턴스를 여러개 호출해서 병렬 가능할 것 같은데 확인해줘" | Parallel execution enhancement request |
| UR-2 | 22:20 | "병렬 실행 개선 계획을 세워줘 마찬가지로 00부터 03까지 커맨드들을 다 봐야하고 문서작성에이전트 리서치 에이전트 익스플로러 에이전트등 모든 경우 다 해당되니 확인해줘" | Comprehensive parallel execution plan for all commands (00-03) and all agent types (documenter, researcher, explorer) |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | ✅ | SC-1, SC-2, SC-3, SC-4 | Mapped |
| UR-2 | ✅ | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | Mapped |
| **Coverage** | 100% | All requirements mapped | ✅ |

---

## PRP Analysis

### What (Functionality)

**Objective**: Enhance parallel execution capabilities across all claude-pilot commands (00-03) and agent types (explorer, researcher, coder, tester, validator, code-reviewer, documenter, plan-reviewer) to leverage Task tool's ability to invoke multiple agent instances concurrently.

**Scope**:
- **In Scope**:
  - Commands: 00_plan, 01_confirm, 02_execute, 03_close, 90_review, 91_document
  - Agents: explorer, researcher, coder, tester, validator, code-reviewer, documenter, plan-reviewer
  - Documentation: Update command files to reflect actual parallel execution patterns
  - Implementation: Add dependency analysis, parallel invocation logic, result integration

- **Out of Scope**:
  - Agent configuration changes (.claude/agents/*.md)
  - New agent types
  - Parallel execution for external service calls (GPT delegation)

**Deliverables**:
1. Updated 00_plan.md - Parallel exploration (Explorer + Researcher + Test Env)
2. Updated 01_confirm.md - Single plan-reviewer (already optimal)
3. Updated 02_execute.md - Parallel SC execution (multiple Coders) + Parallel verification (Tester + Validator + Code-Reviewer)
4. Updated 03_close.md - Single documenter (already optimal)
5. Updated 90_review.md - Parallel multi-angle review (multiple plan-reviewers for complex plans)
6. Updated 91_document.md - Single documenter (already optimal)
7. Dependency analysis algorithm for SC grouping
8. Result integration pattern for parallel agents

### Why (Context)

**Current Problem**:
- **Documentation vs Implementation Gap**: `parallel-execution-REFERENCE.md` documents parallel patterns, but actual commands (02_execute.md) only invoke single Coder agent
- **Underutilization**: Task tool supports multiple concurrent agent invocations, but commands use sequential single-agent pattern
- **Example Issue**: Creating/modifying 2 independent files could be done by 2 Coder agents in parallel, but current implementation uses 1 Coder agent sequentially

**Current State Analysis**:
| Command | Current Parallel Support | Gap |
|---------|------------------------|-----|
| 00_plan | ✅ Explorer + Researcher documented | None (already parallel) |
| 01_confirm | ⚠️ Single plan-reviewer | None (optimal for review) |
| 02_execute | ❌ Single Coder, then parallel verify | **Major**: Should parallelize independent SCs |
| 03_close | ✅ Single documenter | None (optimal for single task) |
| 90_review | ⚠️ Single plan-reviewer | **Medium**: Complex plans need multi-angle parallel review |
| 91_document | ✅ Single documenter | None (optimal for single task) |

**Business Value**:
- **Performance**: 50-70% execution time reduction for independent tasks
- **Token Efficiency**: 8x improvement through context isolation
- **Scalability**: Handle complex plans with multiple independent SCs efficiently

### How (Approach)

**Implementation Strategy**:
1. **Phase 1**: Dependency Analysis Algorithm
   - Analyze SC dependencies (file conflicts, order requirements)
   - Group independent SCs for parallel execution
   - Identify integration points

2. **Phase 2**: Command Updates
   - Update 02_execute.md: Add parallel Coder invocation for independent SCs
   - Update 90_review.md: Add optional parallel multi-angle review
   - Keep 00_plan.md unchanged (already parallel)
   - Keep 01_confirm, 03_close, 91_document unchanged (already optimal)

3. **Phase 3**: Result Integration Pattern
   - Define merge order for parallel agent results
   - Handle partial failures (retry failed agents only)
   - Update todo management for parallel groups

**Dependencies**:
- Task tool parallel invocation support (already exists)
- Agent configuration files (already exist)
- Parallel execution guides (already documented)

**Risks & Mitigations**:
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| File conflicts in parallel execution | Medium | High | Dependency analysis before parallel execution |
| Increased token costs | Low | Medium | Use Haiku for cost-sensitive agents, optional parallel review |
| Complex integration logic | Medium | Medium | Clear merge patterns, comprehensive testing |

---

## Success Criteria

- [ ] **SC-1**: Dependency analysis algorithm implemented
  - Verify: SC dependency table in plan output
  - Expected: Independent SCs grouped, dependent SCs sequential

- [ ] **SC-2**: 02_execute.md updated with parallel Coder invocation
  - Verify: `grep -A 10 "Parallel.*Coder" .claude/commands/02_execute.md`
  - Expected: Multiple Task tool calls for independent SCs

- [ ] **SC-3**: 90_review.md updated with optional parallel multi-angle review
  - Verify: `grep -A 10 "Parallel.*Review" .claude/commands/90_review.md`
  - Expected: Multiple plan-reviewer agents for complex plans

- [ ] **SC-4**: Result integration pattern documented
  - Verify: Merge order, error handling in updated commands
  - Expected: Clear integration steps after parallel execution

- [ ] **SC-5**: Todo management pattern updated for parallel groups
  - Verify: Parallel group marking in todo examples
  - Expected: `[Parallel Group N]` with multiple `in_progress` todos

- [ ] **SC-6**: No changes to already-optimal commands
  - Verify: 00_plan, 01_confirm, 03_close, 91_document unchanged or minimally updated
  - Expected: Git diff shows no major changes to these files

- [ ] **SC-7**: Documentation aligned with implementation
  - Verify: parallel-execution-REFERENCE.md examples match actual command behavior
  - Expected: All documented patterns reflected in commands

---

## Test Plan

### Test Scenarios

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Parallel SC execution | Plan with 3 independent SCs | 3 Coder agents invoked concurrently | Integration | tests/commands/test_02_execute.py::test_parallel_sc_execution |
| TS-2 | Dependency analysis | Plan with 2 independent + 1 dependent SC | Group 1 (parallel) → Group 2 (sequential) | Unit | tests/commands/test_dependency_analysis.py::test_sc_grouping |
| TS-3 | Parallel verification | Completed implementation | Tester + Validator + Code-Reviewer concurrent | Integration | tests/commands/test_parallel_verification.py::test_verify_parallel |
| TS-4 | Parallel multi-angle review | Complex plan (5+ SCs) | Multiple plan-reviewers for different angles | Integration | tests/commands/test_90_review.py::test_parallel_review |
| TS-5 | Partial failure handling | 1 of 3 parallel agents fails | Retry only failed agent, preserve successful results | Unit | tests/commands/test_error_handling.py::test_parallel_failure_recovery |
| TS-6 | File conflict detection | 2 SCs modifying same file | Sequential execution enforced | Unit | tests/commands/test_dependency_analysis.py::test_file_conflict_detection |

### Test Environment (Detected)

**Auto-Detected Configuration**:
- **Project Type**: Markdown-based (claude-pilot uses markdown for commands/guides)
- **Test Framework**: Integration verification via command execution
- **Test Command**: Manual verification (grep pattern matching in command files)
- **Test Directory**: `.claude/commands/` (verify command file updates)
- **Coverage Target**: N/A (documentation updates, not code coverage)

> **Note**: Since this plan updates markdown command files (not Python code), "tests" are actually:
> 1. **File verification**: `grep -A 10 "Parallel.*Coder" .claude/commands/02_execute.md`
> 2. **Structure verification**: Check dependency analysis sections exist
> 3. **Integration verification**: Manual testing with actual plans
>
> **Test Scenarios table below documents verification approach**, but actual "tests" are:
> - Grep commands to verify pattern presence in updated files
> - Manual execution of commands with test plans
> - Visual inspection of parallel invocation patterns

> **Test File Paths**: Refer to `.claude/commands/` for verification, not `tests/` directory

---

## Execution Plan

### Phase 1: Discovery & Analysis

**Objective**: Understand current implementation and design dependency analysis

**Tasks**:
1. Analyze current 02_execute.md implementation
2. Design SC dependency algorithm:
   - File conflict detection (same file modified by multiple SCs)
   - Order dependency detection (SC-2 requires SC-1 output)
   - Integration point identification
3. Define parallel grouping strategy:
   - Group 1: Fully independent SCs (different files, no dependencies)
   - Group 2: SCs dependent on Group 1
   - Group N: SCs dependent on previous groups

**Expected Output**: Dependency analysis algorithm specification

---

### Phase 2: Implementation (TDD Cycle)

#### SC-1: Dependency Analysis Algorithm

**Red Phase**: Write failing test
```python
# tests/commands/test_dependency_analysis.py
def test_sc_grouping():
    plan = parse_plan("plan_with_3_scs.md")
    groups = analyze_dependencies(plan)
    assert groups[0].sc_ids == ["SC-1", "SC-2"]  # Independent
    assert groups[1].sc_ids == ["SC-3"]  # Depends on SC-1
```

**Green Phase**: Implement minimal algorithm

> **Implementation Approach**: Inline logic within commands (NOT separate script)
>
> **Decision**: Dependency analysis will be implemented as **inline markdown documentation** within each command file, NOT as a separate shell script or Python utility.
>
> **Rationale**:
> - Commands are markdown files that guide Claude agents
> - Dependency analysis is a conceptual framework, not executable code
> - Each command performs analysis during execution by reading the plan
> - No external scripts needed - the "algorithm" is guidance for agents

```markdown
## Step 2.1: SC Dependency Analysis (INLINE)
> **MANDATORY**: Before invoking Coder agents, analyze SC dependencies
>
> This analysis is performed by the main orchestrator reading the plan file:
> 1. Extract all Success Criteria from plan
> 2. Parse file paths mentioned in each SC
> 3. Check for file overlaps (conflicts)
> 4. Check for dependency keywords ("requires", "depends on", "after")
> 5. Group SCs: Independent (Group 1), Dependent (Group 2+)

### Dependency Analysis Table
| SC | Files | Dependencies | Parallel Group |
|----|-------|--------------|----------------|
| SC-1 | src/auth/login.ts | None | Group 1 |
| SC-2 | src/auth/logout.ts | None | Group 1 |
| SC-3 | tests/auth.test.ts | None | Group 1 |
| SC-4 | src/auth/middleware.ts | SC-1 | Group 2 |
```

**Refactor Phase**: Optimize for clarity and performance

#### SC-2: Update 02_execute.md for Parallel Coder Invocation

**Red Phase**: Write test
```python
# tests/commands/test_02_execute.py
def test_parallel_coder_invocation():
    execute_cmd = parse_command("02_execute.md")
    assert "Parallel.*Coder" in execute_cmd.content
```

**Green Phase**: Update 02_execute.md
```markdown
## Step 2.1: SC Dependency Analysis (NEW)
> **MANDATORY**: Before invoking Coder agents, analyze SC dependencies

### Dependency Analysis
| SC | Files | Dependencies | Parallel Group |
|----|-------|--------------|----------------|
| SC-1 | src/auth/login.ts | None | Group 1 |
| SC-2 | src/auth/logout.ts | None | Group 1 |
| SC-3 | tests/auth.test.ts | None | Group 1 |
| SC-4 | src/auth/middleware.ts | SC-1 | Group 2 |

## Step 2.2: Parallel Coder Invocation (UPDATED)
> **For independent SCs (Group 1)**: Invoke multiple Coder agents concurrently

```markdown
[Parallel Group 1]
Task:
  subagent_type: coder
  prompt: |
    Execute SC-1: {DESCRIPTION}
    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

Task:
  subagent_type: coder
  prompt: |
    Execute SC-2: {DESCRIPTION}
    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}

Task:
  subagent_type: coder
  prompt: |
    Execute SC-3: {DESCRIPTION}
    Plan Path: {PLAN_PATH}
    Test Scenarios: {TS_LIST}
```

### 2.2.1 Process Parallel Results
- Wait for ALL parallel agents to complete
- Mark all parallel todos as `completed` together
- Integrate results (no conflicts expected)
- Proceed to Group 2 (if any)

> **For dependent SCs (Group 2)**: Sequential execution after Group 1 completes
```

#### SC-3: Update 90_review.md for Optional Parallel Review

**Red Phase**: Write test
```python
# tests/commands/test_90_review.py
def test_parallel_review_optional():
    review_cmd = parse_command("90_review.md")
    assert "Parallel.*Review" in review_cmd.content
    assert "optional" in review_cmd.content.lower()
```

**Green Phase**: Update 90_review.md
```markdown
## Step 0.6: Optional Parallel Multi-Angle Review (NEW)
> **For complex plans (5+ SCs)**: Leverage multiple plan-reviewer agents concurrently

### When to Use Parallel Review
- Plan has 5+ success criteria
- High-stakes features (security, payments, auth)
- System-wide architectural changes

### When NOT to Use Parallel Review
- Simple plans (< 5 SCs)
- Resource constraints (cost concerns)
- Time-sensitive reviews (sequential faster for simple plans)

### Parallel Review Implementation
```markdown
[Optional Parallel Review - Triggered by plan complexity]
Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from SECURITY angle:
    - External API security
    - Input validation
    - Authentication/authorization

Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from QUALITY angle:
    - Vibe Coding compliance
    - Code quality standards
    - Testing coverage

Task:
  subagent_type: plan-reviewer
  prompt: |
    Review plan from ARCHITECTURE angle:
    - System design
    - Component relationships
    - Scalability considerations
```
```

#### SC-4: Result Integration Pattern

**Red Phase**: Write test
```python
# tests/commands/test_result_integration.py
def test_parallel_result_merge():
    results = execute_parallel_agents(["coder1", "coder2", "coder3"])
    merged = merge_results(results)
    assert merged.files_modified == 6  # 2 files per agent
    assert merged.no_conflicts == True
```

**Green Phase**: Document integration pattern
```markdown
### Result Integration Pattern

#### Parallel Agent Completion
1. **Wait for all agents**: Task tool blocks until all complete
2. **Process inline results**: Each agent returns summary with `<CODER_COMPLETE>` or `<CODER_BLOCKED>`
3. **Update todos**: Mark all parallel todos as `completed` together
4. **Verify no conflicts**: Check file overlap (should be none if dependency analysis correct)
5. **Merge results**: Combine file lists, test results, coverage data
6. **Proceed to next phase**: Integration testing or next parallel group

#### Partial Failure Handling
If 1 of 3 parallel agents fails:
1. Note the failure with agent ID
2. Continue waiting for other agents
3. Present all results together
4. Re-invoke only failed agent (with error context)
5. Merge successful results once retry succeeds
```

#### SC-5: Update Todo Management for Parallel Groups

**Red Phase**: Write test
```python
# tests/commands/test_todo_management.py
def test_parallel_todo_marking():
    todos = create_todos(["SC-1", "SC-2", "SC-3"])
    mark_parallel_in_progress(todos, group=1)
    assert all(t.status == "in_progress" for t in todos)

    complete_parallel(todos, group=1)
    assert all(t.status == "completed" for t in todos)
```

**Green Phase**: Update todo examples in commands
```markdown
### Todo Management Pattern

**Sequential Execution** (default):
```markdown
[Sequential]
- ✅ SC-1: Read plan
- 🔄 SC-2: Implement feature X ← Single in_progress
- ⏳ SC-3: Implement feature Y
```

**Parallel Execution** (for independent SCs):
```markdown
[Parallel Group 1]
- 🔄 SC-1: Implement feature X (Coder Agent 1)
- 🔄 SC-2: Implement feature Y (Coder Agent 2)
- 🔄 SC-3: Implement feature Z (Coder Agent 3)

[After all return]
- ✅ SC-1: Implement feature X ← Completed together
- ✅ SC-2: Implement feature Y
- ✅ SC-3: Implement feature Z

[Parallel Group 2 - Verification]
- 🔄 Run tests (Tester Agent)
- 🔄 Run type check + lint (Validator Agent)
- 🔄 Code review (Code-Reviewer Agent)
```
```

#### SC-6: Verify Already-Optimal Commands

**Red Phase**: Write test
```python
# tests/commands/test_no_regressions.py
def test_00_plan_unchanged():
    original = read_file("00_plan.md.backup")
    current = read_file("00_plan.md")
    assert parallel_section_unchanged(original, current)
```

**Green Phase**: Verify minimal changes
- 00_plan: Already parallel (Explorer + Researcher) → No change
- 01_confirm: Single plan-reviewer optimal → No change
- 03_close: Single documenter optimal → No change
- 91_document: Single documenter optimal → No change

#### SC-7: Update Documentation

**Red Phase**: Write test
```python
# tests/documentation/test_alignment.py
def test_parallel_docs_aligned():
    doc = read_file("parallel-execution-REFERENCE.md")
    execute_cmd = read_file("02_execute.md")
    assert doc_patterns_match_implementation(doc, execute_cmd)
```

**Green Phase**: Update examples in parallel-execution-REFERENCE.md
- Ensure all documented patterns are reflected in actual commands
- Add real examples from updated commands
- Update anti-patterns section with actual pitfalls

---

### Phase 3: Ralph Loop (Autonomous Completion)

**Entry**: After first code change

**Loop until**:
- [ ] All tests pass
- [ ] Coverage ≥80% (core ≥90%)
- [ ] Type check clean
- [ ] Lint clean
- [ ] All todos completed

**Max iterations**: 7

---

### Phase 4: Verification

**Parallel verification** (3 agents):
- [ ] Tester: Run tests, verify coverage
- [ ] Validator: Type check, lint
- [ ] Code-Reviewer: Review code quality

---

## Constraints

### Technical Constraints
- Task tool parallel invocation must be supported (already available)
- Agent configuration files must remain unchanged
- No changes to MCP server configuration

### Business Constraints
- Must maintain backward compatibility with existing workflows
- Token cost increase must be justified by performance gain
- Optional parallel execution for cost-sensitive users

### Quality Constraints
- **Coverage**: ≥80% overall, ≥90% core modules
- **Type Safety**: Type check must pass
- **Code Quality**: Lint must pass
- **Standards**: Vibe Coding (functions ≤50 lines, files ≤200 lines, nesting ≤3 levels)

---

## Review History

| Date | Reviewer | Findings | Status |
|------|----------|----------|--------|
| 2026-01-17 22:26 | Claude (Main Orchestrator) | Initial plan created | Pending Review |
| 2026-01-17 22:30 | Plan-Reviewer Agent (Claude Sonnet) | 0 BLOCKING, 0 Critical, 2 Warnings | APPROVED |
| 2026-01-17 22:35 | Warning Resolution | Warning #1: Dependency analysis approach clarified (inline logic, not separate script) | Resolved |
| 2026-01-17 22:35 | Warning Resolution | Warning #2: Test framework clarified (markdown-based, grep verification) | Resolved |

---

**Template Version**: claude-pilot 4.0.5
**Last Updated**: 2026-01-17
