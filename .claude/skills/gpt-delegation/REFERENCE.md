# REFERENCE: GPT Delegation

> **Detailed patterns, examples, and troubleshooting for Codex/GPT delegation**

## Complete Prompt Templates

### Architect Prompt (workspace-write)

```
You are a senior software architect specializing in solving complex implementation problems.

TASK: [One sentence atomic goal]

EXPECTED OUTCOME: [What success looks like]

CONTEXT:
- Previous attempts: [what was tried, with code snippets]
- Errors: [exact error messages, with stack traces]
- Current iteration: [N/7]
- Codebase structure: [relevant files and their purposes]

CONSTRAINTS:
- Must work with existing codebase
- Cannot break existing functionality
- Must follow project coding standards
- Must maintain test coverage

MUST DO:
- Analyze why previous attempts failed (root cause analysis)
- Provide fresh approach different from failed attempts
- Report all files modified with summaries
- Suggest verification steps

MUST NOT DO:
- Repeat same approaches that already failed
- Break existing tests or functionality
- Introduce dependencies not in project

OUTPUT FORMAT:
## Summary
[Brief overview of approach]

## Issues Identified
[Root cause of previous failures]

## Fresh Approach
[Detailed implementation plan]

## Files Modified
- `path/to/file`: [change summary]

## Verification
[How to verify the fix works]
```

### Security Analyst Prompt (read-only)

```
You are a security analyst specializing in application vulnerabilities.

CONTEXT:
- Codebase: [description]
- Concerns: [specific security concerns]
- Files: [relevant file paths]

ANALYSIS REQUIRED:
1. Identify potential vulnerabilities (OWASP Top 10)
2. Check for common security issues:
   - SQL injection
   - XSS vulnerabilities
   - Authentication flaws
   - Authorization issues
   - Sensitive data exposure
3. Review authentication/authorization implementation
4. Check for hardcoded secrets or credentials

OUTPUT FORMAT:
## Security Findings
- [Severity] [Issue]: [Description]

## Recommendations
- [Priority] [Fix]: [Action required]

## Code Examples
[Show vulnerable code and fixed version]
```

### Plan Reviewer Prompt (read-only)

```
You are a technical lead reviewing implementation plans.

PLAN TO REVIEW:
[Full plan content]

REVIEW CRITERIA:
1. Clarity: Are SCs specific and verifiable?
2. Completeness: Are all requirements covered?
3. Feasibility: Can this be implemented within constraints?
4. Dependencies: Are dependencies correctly identified?
5. Risks: What could go wrong?

OUTPUT FORMAT:
## Plan Assessment
- Overall quality: [1-10]
- Clarity: [PASS/FAIL]
- Completeness: [PASS/FAIL]
- Feasibility: [PASS/FAIL]

## Issues Found
- [Severity] [Issue]: [Description]

## Recommendations
[Specific improvements needed]

## Risk Assessment
[High/medium/low risk items]
```

### Scope Analyst Prompt (read-only)

```
You are a business analyst clarifying requirements.

CURRENT REQUIREMENTS:
[User input or plan]

ANALYSIS REQUIRED:
1. Identify ambiguities
2. Clarify assumptions
3. Suggest edge cases
4. Propose acceptance criteria

OUTPUT FORMAT:
## Ambiguities Found
- [Issue]: [Clarification needed]

## Assumptions
- [What we're assuming]

## Edge Cases
- [Case]: [How to handle]

## Suggested Acceptance Criteria
[Specific, measurable criteria]
```

## Troubleshooting

### Issue: Codex CLI Not Installed

**Symptom**: Warning message about Codex CLI not installed

**Solution**: This is expected behavior. The skill gracefully falls back to Claude-only analysis.

**Code**:
```bash
if ! command -v codex &> /dev/null; then
  echo "Warning: Codex CLI not installed - falling back to Claude-only analysis"
  return 0  # NOT an error, continue with Claude
fi
```

### Issue: Delegation Not Triggering

**Symptom**: GPT Architect not called after 2 failures

**Possible Causes**:
1. Trigger condition not met (fewer than 2 failures)
2. Delegation skill not loaded
3. Codex CLI check failing

**Debug Steps**:
1. Check iteration count: `echo $iteration`
2. Verify skill loaded: `grep -r "gpt-delegation" .claude/skills/`
3. Test Codex CLI: `command -v codex`

### Issue: GPT Returns Same Approach

**Symptom**: GPT suggests same solution that already failed

**Solution**: Ensure previous attempts are clearly documented in the prompt:

```bash
PREVIOUS_ATTEMPTS="
Attempt 1: Used Promise.all() - Result: Race condition
Attempt 2: Added async/await - Result: Still hanging
"

# Include in prompt
echo "CONTEXT:
- Previous attempts: $PREVIOUS_ATTEMPTS
"
```

## Integration Examples

### Coder Agent Integration

```bash
# In Ralph Loop, after 2nd failure
if [ $iteration -ge 2 ] && [ $TEST_RESULT -ne 0 ]; then
  echo "Progressive escalation: Delegating to GPT Architect"

  # Build prompt
  PROMPT="
  TASK: Fix failing test ${TEST_NAME}

  EXPECTED OUTCOME: All tests pass

  CONTEXT:
  - Previous attempts: ${ATTEMPT_SUMMARY}
  - Errors: $(cat /tmp/test.log | tail -20)
  - Current iteration: ${iteration}

  MUST DO:
  - Analyze why previous attempts failed
  - Provide fresh approach
  - Report all files modified
  "

  # Delegate
  .claude/scripts/codex-sync.sh "workspace-write" "$PROMPT"

  # Apply suggestions
  # [Parse output and apply fixes]

  # Re-run tests
  npm test
fi
```

### Plan Review Integration

```bash
# In /00_plan, after generating plan
if [ $(echo "$PLAN" | grep -c "SC-") -ge 5 ]; then
  echo "Large plan detected: Delegating to GPT Plan Reviewer"

  PROMPT="
  You are a technical lead reviewing implementation plans.

  PLAN TO REVIEW:
  $PLAN

  REVIEW CRITERIA:
  1. Clarity: Are SCs specific and verifiable?
  2. Completeness: Are all requirements covered?
  3. Feasibility: Can this be implemented within constraints?
  4. Dependencies: Are dependencies correctly identified?
  5. Risks: What could go wrong?

  OUTPUT FORMAT:
  ## Plan Assessment
  ## Issues Found
  ## Recommendations
  ## Risk Assessment
  "

  .claude/scripts/codex-sync.sh "read-only" "$PROMPT"
fi
```

## Best Practices

1. **Always include graceful fallback**: Codex CLI may not be installed
2. **Document previous attempts clearly**: Include errors, stack traces, code snippets
3. **Specify expected outcome**: What does success look like?
4. **Use appropriate mode**: workspace-write for code changes, read-only for analysis
5. **Parse output carefully**: GPT output format may vary
6. **Verify suggestions**: Don't blindly apply GPT recommendations

## Further Reading

**Internal**: @.claude/skills/ralph-loop/SKILL.md - Ralph Loop integration with GPT delegation

**External**: [Codex Documentation](https://github.com/example/codex)
