# Git Master Reference Guide

> **Purpose**: Detailed reference for Git workflow mastery and conventions
> **Complements**: @./SKILL.md (core methodology)

---

## Conventional Commits Deep Dive

### Commit Message Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Type Definitions

| Type | Purpose | Example |
|------|---------|---------|
| **feat** | New feature | `feat(auth): add OAuth2 login support` |
| **fix** | Bug fix | `fix(api): resolve race condition in user creation` |
| **refactor** | Code change without functional change | `refactor(user): simplify validation logic` |
| **perf** | Performance improvement | `perf(query): add database indexing` |
| **test** | Adding or updating tests | `test(auth): add login validation tests` |
| **docs** | Documentation only | `docs(readme): update installation instructions` |
| **style** | Code style (formatting, semicolons) | `style: format code with prettier` |
| **chore** | Build process, dependencies, tooling | `chore: upgrade to Node.js 20` |
| **revert** | Revert previous commit | `revert: feat(auth): remove OAuth2` |
| **ci** | CI/CD configuration | `ci: add GitHub Actions workflow` |
| **build** | Build system or dependencies | `build: update webpack configuration` |

### Scope Guidelines

**Purpose**: Group commits by module/component

```bash
# Good scopes (project-specific)
feat(auth): add password reset
feat(database): add user migrations
feat(api): add rate limiting
fix(ui): resolve button alignment issue
refactor(payments): simplify checkout flow

# Common scopes by layer
feat(backend): ...
feat(frontend): ...
feat(shared): ...
fix(types): ...
test(unit): ...
test(integration): ...
```

### Body and Footers

**Body**: Explain WHAT and WHY, not HOW

```bash
feat(api): add user pagination

Implement cursor-based pagination for user list endpoint
to improve performance with large datasets.

- Added `cursor` and `limit` query parameters
- Returns `next_cursor` for pagination continuation
- Implemented efficient database queries with indexed cursors

Closes #123
```

**Footers**: Reference issues, breaking changes

```bash
feat(api): remove deprecated endpoints

BREAKING CHANGE: The `/api/v1/users` endpoint has been removed.
Migrate to `/api/v2/users` before upgrading.

Deprecates #45
Refs #46
```

---

## Advanced Git Patterns

### Interactive Rebase

**When**: Clean up commit history before pushing

```bash
# Interactive rebase last 5 commits
git rebase -i HEAD~5

# Commands in rebase:
# p, pick = keep commit as is
# r, reword = edit commit message
# e, edit = pause rebase to modify commit
# s, squash = merge with previous commit
# d, drop = remove commit

# Example: Clean up WIP commits
pick 1a2b3c feat: add user model
pick 4d5e6f fix: validation error
pick 7g8h9i style: format code
pick 0j1k2l test: add user tests
pick 3m4n5o docs: update readme

# After squashing test/style into feat:
pick 1a2b3c feat: add user model
s 7g8h9i test: add user tests
s 0j1k2l docs: update readme
pick 4d5e6f fix: validation error
d 3m4n5o docs: update readme  # duplicate, drop
```

### Fixup Commits

**When**: Make small fixes to previous commits

```bash
# Original commit
git commit -m "feat: add user authentication"

# Later:发现 small issue
# Make fixup commit (don't squash manually)
git commit -m "fixup: add missing import"

# Interactive rebase to auto-squash
git rebase -i --autosquash HEAD~2

# Git automatically marks:
# pick abc123 feat: add user authentication
# fixup def456 fixup: add missing import
```

### Bisect for Bug Hunting

**When**: Find which commit introduced a bug

```bash
# Start bisect
git bisect start

# Mark known bad commit (current)
git bisect bad

# Mark known good commit (past)
git bisect good v1.0.0

# Git will checkout middle commit
# Test the code
# If bad: git bisect bad
# If good: git bisect good

# Continue until bug found
# Git outputs: abc123 is the first bad commit

# Reset to original state
git bisect reset
```

---

## Branch Strategies

### Feature Branch Workflow

```
main (protected)
  ↑
  ├── feature/user-authentication
  ├── feature/payments-integration
  └── feature/refactor-database

# Process
1. Create feature branch from main
git checkout -b feature/user-authentication

2. Work on feature (commits to feature branch)
git commit -m "feat(auth): add login"

3. Push feature branch
git push -u origin feature/user-authentication

4. Create PR/MR
gh pr create --base main --head feature/user-authentication

5. After review and merge, delete branch
git checkout main
git pull
git branch -d feature/user-authentication
```

### Release Branch Workflow

```
main (dev)          release/v2.1        v2.1.0 (production)
    ↑                    ↑                   ↑
    ├── develop          ├── final prep     ├── tagged
    └── features         └── testing        └── deployed

# Process
1. Create release branch from develop
git checkout -b release/v2.1 develop

2. Finalize release (only bug fixes, no features)
git commit -m "fix: resolve critical bug"

3. Tag release
git tag -a v2.1.0 -m "Release v2.1.0"

4. Merge to main and develop
git checkout main
git merge release/v2.1
git checkout develop
git merge release/v2.1

5. Delete release branch
git branch -d release/v2.1
```

### Git Flow

```
main (production releases)
  ↑
  ├── develop (integration branch)
  │     ↑
  │     ├── feature/* (short-lived)
  │     ├── hotfix/* (production fixes)
  │     └── release/* (release prep)
  │
  └── tags (v1.0.0, v2.0.0, ...)

# Initialize git flow
git flow init

# Start feature
git flow feature start user-auth

# Finish feature (merge to develop)
git flow feature finish user-auth

# Start release
git flow release start v2.1

# Finish release (merge to main + tag)
git flow release finish v2.1
```

---

## Collaboration Patterns

### Pull Request Etiquette

**Good PR Checklist**:
- [ ] Descriptive title following conventional commits
- [ ] Clear description of WHAT and WHY
- [ ] Linked issues (Fixes #123)
- [ ] Screenshots for UI changes
- [ ] Tests included
- [ ] Documentation updated
- [ ] No merge conflicts

**PR Description Template**:
```markdown
## Summary
• Adds OAuth2 authentication with Google provider
• Implements secure token storage
• Updates user profile with OAuth data

## Changes
- `POST /api/auth/google` - Google OAuth callback
- `User` model - Add `oauth_provider` and `oauth_id` fields
- Migration `002_add_oauth_fields.sql`

## Testing
- Added unit tests for OAuth flow
- Manually tested with Google sandbox
- All existing tests pass

## Checklist
- [x] Tests pass
- [x] Documentation updated
- [x] No breaking changes

Fixes #45
```

### Code Review Guidelines

**For Reviewers**:
- Focus on logic, not style (use linting/formatting)
- Ask questions, don't just dictate
- Explain why something is wrong
- Approve with minor suggestions if blockers are fixed

**For Authors**:
- Keep PRs small (≤400 lines changed)
- One PR per feature/concern
- Address review comments promptly
- Use "Request changes" sparingly

### Merge Conflict Resolution

```bash
# Scenario: Both main and feature changed same file

# 1. Update feature branch with latest main
git checkout feature/awesome-feature
git fetch origin
git rebase origin/main

# 2. Conflicts marked in files
<<<<<<< HEAD
const version = "2.0.0";  // Your change
=======
const version = "1.0.0";  // Main's change
>>>>>>> origin/main

# 3. Resolve conflicts (edit files)
const version = "2.0.0";  // Resolved: keep your version

# 4. Mark conflicts resolved
git add <resolved-files>
git rebase --continue

# 5. Push (may need force)
git push --force-with-lease origin feature/awesome-feature
```

---

## Git Hooks Automation

### Pre-commit Hook

**Purpose**: Check code before commit

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Run tests
pytest || exit 1

# Run type check
mypy . || exit 1

# Run lint
ruff check . || exit 1

# Check file sizes
MAX_SIZE=$((1024 * 1024))  # 1MB
large_files=$(find . -type f -size +${MAX_SIZE}c | grep -v ".git")
if [ -n "$large_files" ]; then
    echo "Error: Large files detected:"
    echo "$large_files"
    exit 1
fi

echo "✅ Pre-commit checks passed"
```

### Commit Message Hook

**Purpose**: Enforce conventional commits

```bash
# .git/hooks/commit-msg
#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Conventional commit pattern
PATTERN="^(feat|fix|refactor|perf|test|docs|style|chore|revert|ci|build)(\(.+\))?: .{1,72}"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo "❌ Invalid commit message format"
    echo "Expected: <type>[optional scope]: <description>"
    echo "Example: feat(auth): add OAuth login"
    exit 1
fi

# Check line length (max 72 for first line, 80 for body)
FIRST_LINE=$(echo "$COMMIT_MSG" | head -1)
if [ ${#FIRST_LINE} -gt 72 ]; then
    echo "❌ First line too long (max 72 chars)"
    exit 1
fi

echo "✅ Commit message format valid"
```

### Pre-push Hook

**Purpose**: Check before pushing

```bash
# .git/hooks/pre-push
#!/bin/bash

# Check if sensitive data is committed
if git diff --cached --name-only | xargs grep -l "password\|secret\|api_key"; then
    echo "❌ Possible sensitive data detected"
    exit 1
fi

# Check if branch is up to date
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "⚠️  Local branch is behind remote"
    echo "Run: git pull --rebase"
    exit 1
fi

echo "✅ Pre-push checks passed"
```

---

## Git Maintenance

### Repository Cleanup

```bash
# Remove merged branches
git branch --merged | grep -v "\*" | xargs git branch -d

# Remove stale remote branches
git remote prune origin

# Clean up untracked files
git clean -fd  # Dry run first
git clean -fdX  # Remove ignored files too

# Garbage collection
git gc --aggressive --prune=now

# Verify repository integrity
git fsck --full
```

### Large File Storage

**Problem**: Large files bloat repository

**Solution**: Git LFS or Git Annex

```bash
# Git LFS setup
git lfs install

# Track large files
git lfs track "*.psd"
git lfs track "*.mov"
git lfs track "data/*.csv"

# Commit .gitattributes
git add .gitattributes
git commit -m "chore: configure git lfs"

# Migrate existing large files
git lfs migrate import --include="*.psd,*.mov"

# Push LFS files
git push origin --all
git push origin --refs/heads/git-lfs
```

---

## Troubleshooting

### Undo Common Mistakes

| Mistake | Command | Explanation |
|---------|---------|-------------|
| Committed to wrong branch | `git reset HEAD~1` | Undo last commit, keep changes |
| Pushed to wrong branch | `git reset --hard HEAD~1` + force push | Remove commit (be careful!) |
| Wrong commit message | `git commit --amend` | Edit last commit message |
| Forgot to add file | `git add forgotten.txt` + `git commit --amend` | Add to last commit |
| Committed secrets | `git reset HEAD~1` + rotate secrets | Undo and change credentials |

### Recover Lost Commits

```bash
# Find lost commit
git reflog

# Output shows:
# abc123 HEAD@{0}: commit: feat: add authentication
# def456 HEAD@{1}: commit: fix: validation error

# Recover lost commit
git checkout abc123

# Or create new branch from it
git branch recovered-features abc123
```

### Resolve Merge Hell

```bash
# Scenario: Complex merge with many conflicts

# Strategy 1: Abort and try again
git merge --abort
git pull --rebase  # Use rebase instead

# Strategy 2: Use merge tool
git mergetool  # Opens configured merge tool

# Strategy 3: Resolve manually with markers
# Edit files, remove <<<<<<< >>>>>>> markers
git add <resolved-files>
git commit

# Strategy 4: Use theirs (accept their version)
git checkout --theirs <file>
git add <file>

# Strategy 5: Use ours (accept your version)
git checkout --ours <file>
git add <file>
```

---

## Co-Authored-By Pattern

**When**: Multiple authors contribute to a commit

```bash
# Add co-authors to commit body
git commit -m "feat(auth): add OAuth2 support

Co-Authored-By: Alice <alice@example.com>
Co-Authored-By: Bob <bob@example.com>"

# GitHub/GitLab recognizes this and credits all authors
```

**Format**:
```
Co-Authored-By: Name <email>
Co-Authored-By: username <email@example.com>
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│                       GIT MASTER QUICK REFERENCE                  │
├─────────────────────────────────────────────────────────────────┤
│  COMMIT TYPES: feat, fix, refactor, test, docs, chore          │
│  FORMAT: <type>[scope]: <description>                           │
│  EXAMPLE: feat(auth): add OAuth2 login                          │
├─────────────────────────────────────────────────────────────────┤
│  BRANCHES: feature/* (short-lived) → main (protected)           │
│  WORKFLOW: feature → PR → review → merge → delete               │
├─────────────────────────────────────────────────────────────────┤
│  ATTRIBUTION: Co-Authored-By: Name <email>                     │
│  AMEND: git commit --amend (last commit only)                  │
├─────────────────────────────────────────────────────────────────┤
│  REBASE: git rebase -i HEAD~5 (clean history)                  │
│  BISECT: git bisect start (find bugs)                          │
│  CHERRY-PICK: git cherry-pick <hash> (apply specific commit)    │
├─────────────────────────────────────────────────────────────────┤
│  NEVER: git push --force (use --force-with-lease)               │
│  NEVER: git commit --amend after push (creates diverged hist)  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Further Reading

### Internal Resources
- @.claude/skills/tdd/SKILL.md - Test-Driven Development
- @.claude/skills/ralph-loop/SKILL.md - Quality verification loop

### External Resources
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)

---

**Last Updated**: 2026-01-15
