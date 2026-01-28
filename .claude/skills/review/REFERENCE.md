# /review - Detailed Reference

> **Companion**: `90_review.md` | **Purpose**: Detailed implementation reference for plan review workflow

---

## GPT Delegation Triggers

| Condition | Threshold | Action |
|-----------|-----------|--------|
| Success criteria count | 5+ SCs | Delegate to GPT Plan Reviewer |
| Architecture decisions | Keywords: architecture, tradeoffs, design | Delegate to GPT Architect |
| Security-sensitive changes | Keywords: auth, credential, security, API | Delegate to GPT Security Analyst |
| Simple plan | < 5 SCs | Use Claude plan-reviewer agent |

**Graceful Fallback**: If Codex CLI not installed → Use Claude plan-reviewer agent

**Implementation**: See @.claude/skills/gpt-delegation/SKILL.md for direct codex CLI format

---

## Investigation Targets

> **Purpose**: Investigate all "needs investigation/confirmation/review" items upfront

| Target | Investigation Method | Tools |
|--------|---------------------|-------|
| **Existing code/patterns** | Search similar implementations | Glob, Grep, Read |
| **API documentation** | Check official docs | WebSearch, WebFetch |
| **Dependencies** | Check package registries | Bash(npm info, pip show) |

**Keywords**: "need to investigate", "confirm", "TODO", "check", "verify", "unclear", "TBD"

---

## Type Detection Matrix

| Type | Keywords (Trigger) | Test File Requirement | Extended Reviews |
|------|-------------------|----------------------|------------------|
| **Code** | function, component, API, bug fix, src/, lib/ | **Required** | A (API compat), B (Types), D (Tests) |
| **Config** | .claude/, settings, rules, template, workflow | **Optional** (N/A allowed) | None |
| **Documentation** | CLAUDE.md, README, guide, docs/, CONTEXT.md | **Optional** (N/A allowed) | C (Consistency) |
| **Scenario** | test, validation, edge cases | **Required** | H (Coverage) |
| **Infra** | Vercel, env, deploy, CI/CD | **Required** | F (Deployment) |
| **DB** | migration, table, schema | **Required** | E (Migration) |
| **AI** | LLM, prompts, AI | **Required** | G (Prompts) |

---

## Mandatory Reviews (8 Items)

> **Purpose**: Execute 8 mandatory reviews for every plan

1. **Development Principles**: SOLID, DRY, KISS, YAGNI compliance
2. **Project Structure**: File locations, naming, module boundaries
3. **Requirement Completeness**: Explicit + implicit requirements coverage
4. **Logic Errors**: Order of operations, dependencies, edge cases
5. **Existing Code Reuse**: Search existing utilities, hooks, common patterns
6. **Better Alternatives**: Simpler/scalable/testable approaches
7. **Project Alignment**: Type-check compliance, API docs consistency
8. **Long-term Impact**: Future consequences, technical debt, scalability

**Assessment Levels**: ✅ Pass / ⚠️ Warning / ❌ Fail

---

## Extended Reviews

> **Purpose**: Type-specific reviews beyond mandatory 8 items

| Review | Type | Checks |
|--------|------|--------|
| **A: API Compatibility** | Code | Breaking changes, version compatibility, deprecation warnings |
| **B: Type Safety** | Code | TypeScript types, interface contracts, type coverage |
| **C: Documentation Consistency** | Documentation | Terminology, formatting, cross-references |
| **D: Test Coverage** | Code, Scenario | Unit tests, integration tests, edge cases |
| **E: Migration Strategy** | DB Schema | Migration path, data preservation, rollback plan |
| **F: Deployment** | Infrastructure | Deployment steps, env vars, rollback plan |
| **G: Prompt Engineering** | AI/Prompts | Prompt clarity, context boundaries, output format |
| **H: Coverage Scenarios** | Scenario | Happy path, error paths, edge cases |

---

## Autonomous Review Perspectives

> **Purpose**: Self-judged review beyond mandatory/extended items

**Checklist**:
- [ ] **Security**: Input validation, auth/authz, secret management, OWASP Top 10
- [ ] **Performance**: Expectations defined, bottlenecks identified, optimization strategy
- [ ] **UX**: User experience, error messages, edge case handling
- [ ] **Maintainability**: Code organization, documentation, future maintenance
- [ ] **Concurrency**: Race conditions, parallel operations, locking strategy
- [ ] **Error Recovery**: Error handling, recovery strategies, graceful degradation

**Assessment**: ✅ Pass / ⚠️ Improvements / ❌ Risks

---

## Gap Detection

> **Purpose**: Identify gaps in external service integration

### Severity Levels

| Level | Symbol | Description | Action |
|-------|--------|-------------|--------|
| **BLOCKING** | 🛑 | Cannot proceed without addressing | Interactive Recovery |
| **Critical** | 🚨 | Must fix before execution | Fix required |
| **Warning** | ⚠️ | Should fix before execution | Recommend fix |
| **Suggestion** | 💡 | Nice to have | Optional improvement |

### Gap Categories

- **9.1 External API**: SDK vs HTTP, endpoint verification, error handling, rate limiting
- **9.2 Database Operations**: Migration files, rollback strategy, connection management
- **9.3 Async Operations**: Timeout config, concurrent limits, race conditions
- **9.4 File Operations**: Path resolution, existence checks, cleanup strategy
- **9.5 Environment Variables**: Documentation, existence verification, no secrets in plan
- **9.6 Error Handling**: No silent catches, user notification, graceful degradation
- **9.7 Test Plan Verification** (BLOCKING): Scenarios defined, test files specified (or N/A), test commands, coverage command, test environment

---

## Parallel Review Task Patterns

> **Purpose**: Explicit Task tool patterns for Step 2 parallel review

**Step 2 (Parallel Review)**:
```bash
# Invoke all 3 review agents in parallel (single response with multiple Task calls)
Task: subagent_type: tester, prompt: "Run test coverage analysis for current changes"
Task: subagent_type: validator, prompt: "Run type-check and lint verification"
Task: subagent_type: code-reviewer, prompt: "Perform deep code quality review"
```

**Reference**: @.claude/skills/parallel-subagents/SKILL.md - Parallel execution patterns

---

## Apply Findings to Plan

> **Purpose**: Apply review findings to improve plan

**Step 4 (Plan Updates)**:
```bash
# Delegate plan section updates to documenter
Task: subagent_type: documenter, prompt: "Update plan sections based on review findings"
```

### Issue Type Mapping

| Issue Type | Target Section | Method | Example |
|------------|----------------|--------|---------|
| Missing step | Execution Plan | Add checkbox | "- [ ] Add input validation" |
| Unclear requirement | User Requirements | Clarify wording | "Fix" → "Fix null pointer in auth.ts:45" |
| Test gap | Test Plan | Add scenario | "+ TS-4: Handle edge case where user is null" |
| Risk identified | Risks | Add item | "- API rate limits may affect performance" |
| Missing dependency | Scope | Add requirement | "- [ ] Install lodash for utility functions" |

**Process**:
1. Read plan file
2. Apply modifications to appropriate sections
3. Write updated plan
4. Append findings to Review History

---

## Parallel Multi-Angle Review

> **Purpose**: Leverage multiple Claude plan-reviewer agents concurrently

**Use When**:
- Plan has 5+ success criteria
- High-stakes features (security, payments, auth)
- System-wide architectural changes

**Do NOT Use When**:
- Simple plans (< 5 SCs)
- Cost constraints (3x token cost)
- Time-sensitive review (sequential faster)

**Approach**: Invoke 3 plan-reviewer agents concurrently with different angles:
- Security angle: External API security, input validation, auth/authz, secret management
- Quality angle: Vibe Coding, code quality, testing coverage, documentation
- Architecture angle: System design, component relationships, scalability, integration points

**Merge Strategy**: Collect all findings, deduplicate, prioritize by severity, apply to plan

---

## GPT Expert Review

> **Purpose**: Leverage GPT experts for high-difficulty analysis

### GPT Expert Selection

| Scenario | GPT Expert | Trigger | Expert Prompt File |
|----------|------------|---------|-------------------|
| **Architecture review** | Architect | System design, tradeoffs, scalability | `prompts/architect.md` |
| **Security review** | Security Analyst | Auth, sensitive data, external APIs | `prompts/security-analyst.md` |
| **Large plan validation** | Plan Reviewer | 5+ success criteria, complex dependencies | `prompts/plan-reviewer.md` |
| **Scope ambiguity** | Scope Analyst | Unclear requirements, multiple interpretations | `prompts/scope-analyst.md` |

**Implementation**: See @.claude/skills/gpt-delegation/SKILL.md for direct codex CLI format

**Cost Awareness**: GPT calls cost money (~$0.10-$0.50 per call), use for high-value analysis only

---

## Testing

### Manual Testing

**Test Standard Review**:
```bash
/review .pilot/plan/pending/test_plan.md
```
Expected: Comprehensive review with findings applied to plan

**Test Complex Plan (Parallel Review)**:
```bash
/review .pilot/plan/pending/complex_plan.md
```
Expected: Triggers parallel multi-angle review (3 agents)

### Verification Checklist

After running `/review`:
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
**Last Updated**: 2026-01-22
