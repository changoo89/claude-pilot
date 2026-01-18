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
