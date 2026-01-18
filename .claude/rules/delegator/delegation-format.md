# Delegation Prompt Templates

When delegating to GPT experts, use these structured templates.

## The 7-Section Format (MANDATORY)

Every delegation prompt MUST include these sections:

```
1. TASK: [One sentence—atomic, specific goal]

2. EXPECTED OUTCOME: [What success looks like]

3. CONTEXT:
   - Current state: [what exists now]
   - Relevant code: [paths or snippets]
   - Background: [why this is needed]

4. CONSTRAINTS:
   - Technical: [versions, dependencies]
   - Patterns: [existing conventions to follow]
   - Limitations: [what cannot change]

5. MUST DO:
   - [Requirement 1]
   - [Requirement 2]

6. MUST NOT DO:
   - [Forbidden action 1]
   - [Forbidden action 2]

7. OUTPUT FORMAT:
   - [How to structure response]
```

---

## Expert-Specific Templates

### Architect

```markdown
TASK: [Analyze/Design/Implement] [specific system/component] for [goal].

EXPECTED OUTCOME: [Clear recommendation OR working implementation]

MODE: [Advisory / Implementation]

CONTEXT:
- Current architecture: [description]
- Relevant code:
  [file paths or snippets]
- Problem/Goal: [what needs to be solved]

CONSTRAINTS:
- Must work with [existing systems]
- Cannot change [protected components]
- Performance requirements: [if applicable]

MUST DO:
- [Specific requirement]
- Provide effort estimate (Quick/Short/Medium/Large)
- [For implementation: Report all modified files]

MUST NOT DO:
- Over-engineer for hypothetical future needs
- Introduce new dependencies without justification
- [For implementation: Modify files outside scope]

OUTPUT FORMAT:
[Advisory: Bottom line → Action plan → Effort estimate]
[Implementation: Summary → Files modified → Verification]
```

### Plan Reviewer

```markdown
TASK: Review [plan name/description] for completeness and clarity.

EXPECTED OUTCOME: APPROVE/REJECT verdict with specific feedback.

CONTEXT:
- Plan to review:
  [plan content]
- Goals: [what the plan is trying to achieve]
- Constraints: [timeline, resources, technical limits]

MUST DO:
- Evaluate all 4 criteria (Clarity, Verifiability, Completeness, Big Picture)
- Simulate actually doing the work to find gaps
- Provide specific improvements if rejecting

MUST NOT DO:
- Rubber-stamp without real analysis
- Provide vague feedback
- Approve plans with critical gaps

OUTPUT FORMAT:
[APPROVE / REJECT]
Justification: [explanation]
Summary: [4-criteria assessment]
[If REJECT: Top 3-5 improvements needed]
```

### Plan Reviewer (Planning Phase)

> Use when reviewing plan documents BEFORE implementation starts

PHASE CONTEXT: Planning Phase
- Files don't exist yet (this is a design document)
- Focus: Plan clarity, completeness, verifiability
- DO NOT check file system

```markdown
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
```

### Plan Reviewer (Implementation Phase)

> Use when reviewing AFTER implementation is complete

PHASE CONTEXT: Implementation Phase
- Code should exist now
- Focus: Verify implementation matches plan
- DO check file system

```markdown
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

### Scope Analyst

```markdown
TASK: Analyze [request/feature] before planning begins.

EXPECTED OUTCOME: Clear understanding of scope, risks, and questions to resolve.

CONTEXT:
- Request: [what was asked for]
- Current state: [what exists now]
- Known constraints: [technical, business, timeline]

MUST DO:
- Classify intent (Refactoring/Build/Mid-sized/Architecture/Bug Fix/Research)
- Identify hidden requirements and ambiguities
- Surface questions that need answers before proceeding
- Assess risks and blast radius

MUST NOT DO:
- Start planning (that comes after analysis)
- Make assumptions about unclear requirements
- Skip intent classification

OUTPUT FORMAT:
Intent: [classification]
Findings: [key discoveries]
Questions: [what needs clarification]
Risks: [with mitigations]
Recommendation: [Proceed / Clarify First / Reconsider]
```

### Code Reviewer

```markdown
TASK: [Review / Review and fix] [code/PR/file] for [focus areas].

EXPECTED OUTCOME: [Issue list with verdict OR fixed code]

MODE: [Advisory / Implementation]

CONTEXT:
- Code to review:
  [file paths or snippets]
- Purpose: [what this code does]
- Recent changes: [what changed, if PR review]

MUST DO:
- Prioritize: Correctness → Security → Performance → Maintainability
- Focus on issues that matter, not style nitpicks
- [For implementation: Fix issues and verify]

MUST NOT DO:
- Nitpick style (let formatters handle this)
- Flag theoretical concerns unlikely to matter
- [For implementation: Change unrelated code]

OUTPUT FORMAT:
[Advisory: Summary → Critical issues → Recommendations → Verdict]
[Implementation: Summary → Issues fixed → Files modified → Verification]
```

### Security Analyst

```markdown
TASK: [Analyze / Harden] [system/code/endpoint] for security vulnerabilities.

EXPECTED OUTCOME: [Vulnerability report OR hardened code]

MODE: [Advisory / Implementation]

CONTEXT:
- Code/system to analyze:
  [file paths, architecture description]
- Assets at risk: [what's valuable]
- Threat model: [who might attack, if known]

MUST DO:
- Check OWASP Top 10 categories
- Consider authentication, authorization, input validation
- Provide practical remediation, not theoretical concerns
- [For implementation: Fix vulnerabilities and verify]

MUST NOT DO:
- Flag low-risk theoretical issues
- Provide vague "be more secure" advice
- [For implementation: Break functionality while hardening]

OUTPUT FORMAT:
[Advisory: Threat summary → Vulnerabilities → Recommendations → Risk rating]
[Implementation: Summary → Vulnerabilities fixed → Files modified → Verification]
```

---

## Quick Reference

| Expert | Advisory Output | Implementation Output |
|--------|-----------------|----------------------|
| Architect | Recommendation + plan + effort | Changes + files + verification |
| Plan Reviewer | APPROVE/REJECT + justification | Revised plan |
| Scope Analyst | Analysis + questions + risks | Refined requirements |
| Code Reviewer | Issues + verdict | Fixes + verification |
| Security Analyst | Vulnerabilities + risk rating | Hardening + verification |
