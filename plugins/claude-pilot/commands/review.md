---
description: Review plans with multi-angle analysis (mandatory + extended + autonomous)
argument-hint: "[security] [plan_path] - security-focused review or path to plan file"
allowed-tools: Read, Glob, Grep, Bash(*), Bash(git:*)
disable-model-invocation: true
---

# /review

Invoke the review skill and follow it exactly as presented to you.

## Arguments
- `security` - Security-focused review using security-analyst agent

## Security Review
`/review security` invokes security-analyst agent for OWASP Top 10 review with high-risk findings marked as blockers.

Pass arguments: $ARGUMENTS
