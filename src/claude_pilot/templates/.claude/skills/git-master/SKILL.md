---
name: git-master
description: Git workflow mastery - staging, committing, branching, PR creation. Apply conventional commits, Co-Authored-By attribution. Only create commits when user explicitly requests.
---

# SKILL: Git Master (Version Control Workflow)

> **Purpose**: Execute Git operations with best practices - commits, branches, PRs
> **Target**: Coder Agent after completing implementation
> **Last Updated**: 2026-01-14

---

## Quick Start (30 seconds)

### When to Use This Skill
Use this skill when you need to:
- Stage and commit changes
- Create feature branches
- Create pull requests
- Review git history

### Quick Reference
```bash
# Stage and commit (ONLY when user requests)
git status
git diff
git add <files>
git commit -m "feat(scope): description

Co-Authored-By: Claude <noreply@anthropic.com>"

# Create PR
gh pr create --title "Title" --body "Description"
```

---

## What This Skill Covers

### In Scope
- Git staging and committing (on user request)
- Conventional commit messages
- Co-Authored-By attribution
- Branch creation
- Pull request creation
- Git history review

### Out of Scope
- Force pushes to main/master
- Git configuration changes
- Repository initialization
- .gitignore management

---

## Core Principles

### Commit ONLY When Requested

**CRITICAL**: Never create commits unless user explicitly asks.

**User requests commit**:
- `/commit` (slash command)
- "Create a commit"
- "Commit these changes"
- "Make a commit for this work"

**NOT requests**:
- "Fix this bug" → Implement only, don't commit
- "Add feature X" → Implement only, don't commit
- `/03_close` → Update plan, don't commit

### Conventional Commits

Format: `type(scope): description`

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code change that neither fixes bug nor adds feature
- `chore`: Maintenance task
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `test`: Adding or updating tests

### Co-Authored-By Attribution

Always include:
```
Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Typical Workflows

### Workflow 1: Create Commit After Implementation

**Prerequisites**:
- User explicitly requested commit
- All tests pass
- Changes staged

**Steps**:
1. **Check git status**
   ```bash
   git status
   ```

2. **Review changes**
   ```bash
   git diff
   ```

3. **Stage relevant files**
   ```bash
   # Stage specific files
   git add src/feature.ts tests/feature.test.ts

   # Or stage all changed files
   git add .
   ```

4. **Create commit with conventional message**
   ```bash
   git commit -m "feat(auth): add JWT token refresh mechanism

   Implement automatic token refresh 5 minutes before expiration.
   Add refresh endpoint and update auth middleware.

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

**Verification**:
```bash
# Commit created
git log -1 --format='%H %s'

# Correct format
git log -1 --format='%b' | grep 'Co-Authored-By'
```

### Workflow 2: Create Pull Request

**Prerequisites**:
- Feature branch created
- Changes committed
- Branch pushed to remote

**Steps**:
1. **Ensure branch is up to date**
   ```bash
   git fetch origin main
   git rebase origin/main
   ```

2. **Push branch to remote**
   ```bash
   git push -u origin feature/branch-name
   ```

3. **Create PR with gh CLI**
   ```bash
   gh pr create \
     --title "feat(auth): add JWT token refresh" \
     --body "## Summary
- Implement automatic token refresh 5 minutes before expiration
- Add refresh endpoint and update auth middleware

## Test plan
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Manual testing completed

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
   ```

**Verification**:
```bash
# PR created
gh pr view --web
```

### Workflow 3: Review Git History

**Prerequisites**:
- Need to understand recent changes

**Steps**:
1. **View recent commits**
   ```bash
   git log --oneline -10
   ```

2. **View commit details**
   ```bash
   git show <commit-hash>
   ```

3. **View changes in commit**
   ```bash
   git diff <commit-hash>^..<commit-hash>
   ```

**Verification**:
```bash
# History is clean
git log --oneline
```

---

## Common Patterns

### Pattern 1: Conventional Commit Message
**Use case**: Creating properly formatted commit

**Implementation**:
```bash
# Format: type(scope): description

git commit -m "feat(auth): add OAuth2 login

Implement Google and GitHub OAuth2 authentication.
Add user profile sync and session management.

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**Caveats**:
- Use lowercase for type and scope
- Keep description under 72 characters
- Include detailed body for complex changes
- Always include Co-Authored-By

### Pattern 2: Atomic Commits
**Use case**: Commit related changes together

**Implementation**:
```bash
# Good: One logical change per commit
git add auth/login.py tests/test_login.py
git commit -m "feat(auth): add login endpoint

Co-Authored-By: Claude <noreply@anthropic.com>"

git add auth/logout.py tests/test_logout.py
git commit -m "feat(auth): add logout endpoint

Co-Authored-By: Claude <noreply@anthropic.com>"

# Bad: Unrelated changes in one commit
git add auth/login.py docs/readme.md .gitignore
git commit -m "various changes"  # DON'T DO THIS
```

**Caveats**:
- Group related files
- Separate concerns into different commits
- Make each commit independently understandable

### Pattern 3: Branch Naming
**Use case**: Creating feature branches

**Implementation**:
```bash
# Format: type/description

git checkout -b feature/user-authentication
git checkout -b fix/payment-processing-bug
git checkout -b refactor/database-connection
git checkout -b docs/api-documentation
```

**Caveats**:
- Use lowercase with hyphens
- Include type prefix
- Be descriptive but concise

---

## Commit Safety Protocol

### NEVER (Forbidden Operations)

**NEVER update the git config**:
```bash
# ❌ FORBIDDEN
git config --global user.name "Some Name"
git config --global user.email "some@email.com"
```

**NEVER force push to main/master**:
```bash
# ❌ FORBIDDEN
git push --force origin main
```

**NEVER skip hooks**:
```bash
# ❌ FORBIDDEN
git commit --no-verify
```

**NEVER amend pushed commits**:
```bash
# ❌ FORBIDDEN (if already pushed)
git commit --amend
git push
```

### Commit Amendments (Conditional)

**ONLY use --amend when ALL conditions met**:
1. User explicitly requested amend
2. HEAD commit was created by YOU this session
3. Commit has NOT been pushed to remote

```bash
# ✅ ALLOWED (all conditions met)
git log -1 --format='%an %ae'  # Verify you created it
git status  # Verify not pushed
git commit --amend  # Now amend is OK
```

**If commit FAILED or REJECTED by hook**:
- NEVER amend
- Fix the issue
- Create NEW commit

---

## Troubleshooting

### Issue: Commit rejected by pre-commit hook
**Symptoms**: Hook fails, commit not created

**Diagnosis**:
```bash
# Check hook output
git commit -m "message"
# Hook shows: "Linting failed"
```

**Solution**:
```bash
# Fix lint issues
npm run lint

# Try commit again (NOT amend)
git add .
git commit -m "fix(lint): resolve linting issues"
```

### Issue: Committed wrong files
**Symptoms**: Commit includes files that shouldn't be there

**Diagnosis**:
```bash
# Check commit
git show --stat
```

**Solution**:
```bash
# If not pushed yet
git reset --soft HEAD~  # Undo commit, keep changes
git restore --staged <unwanted-files>  # Unstage unwanted
git commit -m "correct message"
```

### Issue: Need to change commit message
**Symptoms**: Typo or unclear message

**Diagnosis**:
```bash
# Check if pushed
git log --branches --not --remotes
```

**Solution**:
```bash
# If not pushed
git commit --amend -m "correct message"

# If pushed - create new commit
git commit -m "chore: update previous commit message"
```

---

## Best Practices

### Do's ✅
- Commit ONLY when user explicitly requests
- Use conventional commit format
- Include Co-Authored-By attribution
- Group related changes
- Write clear commit messages
- Review changes before committing

### Don'ts ❌
- Don't commit without user request
- Don't use force push to main/master
- Don't skip hooks (--no-verify)
- Don't amend pushed commits
- Don't commit unrelated changes together
- Don't use vague commit messages ("update", "fix")

---

## Integration with Other Skills

### Related Skills
- **tdd**: Commit after all tests pass
- **ralph-loop**: Commit after <RALPH_COMPLETE>
- **vibe-coding**: Commit clean, refactored code

### Call Patterns
```
tdd (Red-Green-Refactor)
     ↓
ralph-loop (Iterate until all pass)
     ↓
vibe-coding (Refactor with standards)
     ↓
[User requests commit]
     ↓
git-master (Create commit with attribution)
```

---

## Commit Message Reference

### Commit Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add OAuth2 login` |
| `fix` | Bug fix | `fix(api): resolve race condition in request handler` |
| `refactor` | Code change | `refactor(db): extract connection pool to separate class` |
| `chore` | Maintenance | `chore(deps): update lodash to 4.17.21` |
| `docs` | Documentation | `docs(readme): add installation instructions` |
| `style` | Code style | `style(lint): fix indentation errors` |
| `test` | Tests | `test(auth): add login validation tests` |

### Commit Message Template

```
type(scope): subject

body

footer

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Example**:
```
feat(payment): add Stripe checkout integration

Implement Stripe checkout session creation and webhook handling.
Add payment intent management and failure recovery.

Closes #123

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Further Reading

### Internal Documentation
- @.claude/guides/tdd-methodology.md - Red-Green-Refactor cycle
- @.claude/guides/ralph-loop.md - Autonomous completion loop
- @.claude/guides/vibe-coding.md - Code quality standards

### External Resources
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub CLI](https://cli.github.com/manual/gh_pr_create)

---

## FAQ

### Q: When should I create a commit?
**A**: ONLY when user explicitly requests:
- `/commit` slash command
- "Create a commit"
- "Commit these changes"

NOT after:
- "Fix this bug"
- "Add feature X"
- Completing implementation

### Q: Should I amend or create new commit?
**A**:
- **Amend**: Only if commit not pushed AND you created it AND user asks
- **New commit**: All other cases

### Q: What if pre-commit hook fails?
**A**: NEVER amend. Fix the issue and create new commit.

### Q: Can I force push to main?
**A**: NO. Never force push to main/master.

### Q: Do I always need Co-Authored-By?
**A**: Yes. Every commit should include:
```
Co-Authored-By: Claude <noreply@anthropic.com>
```
