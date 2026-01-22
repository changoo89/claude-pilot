# Git Master Reference Guide

> **Purpose**: Advanced Git patterns, branch strategies, and collaboration workflows
> **Complements**: @./SKILL.md (core methodology)

---

## Conventional Commits Extended

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
| **test** | Adding/updating tests | `test(auth): add login validation tests` |
| **docs** | Documentation only | `docs(readme): update installation instructions` |
| **style** | Code style (formatting) | `style: format code with prettier` |
| **chore** | Build, dependencies, tooling | `chore: upgrade to Node.js 20` |
| **revert** | Revert previous commit | `revert: feat(auth): remove OAuth2` |
| **ci** | CI/CD configuration | `ci: add GitHub Actions workflow` |
| **build** | Build system or dependencies | `build: update webpack configuration` |

### Body and Footers

**Body**: Explain WHAT and WHY, not HOW
```bash
feat(api): add user pagination

Implement cursor-based pagination for performance.
Closes #123
```

**Footers**: Reference issues, breaking changes
```bash
BREAKING CHANGE: /api/v1/users endpoint removed.
Refs #46
```

---

## Advanced Git Patterns

### Interactive Rebase

Clean up commit history before pushing:
```bash
git rebase -i HEAD~5
# p=pick, r=reword, s=squash, d=drop
```

### Fixup Commits

Small fixes to previous commits:
```bash
git commit -m "fixup: add missing import"
git rebase -i --autosquash HEAD~2
```

### Bisect for Bug Hunting

Find which commit introduced a bug:
```bash
git bisect start
git bisect bad        # Current is bad
git bisect good v1.0.0
# Test at each checkout, mark good/bad
git bisect reset
```

---

## Branch Strategies

### Feature Branch Workflow

```
main (protected)
  ├── feature/user-authentication
  ├── feature/payments-integration
  └── feature/refactor-database

# Process:
1. git checkout -b feature/user-authentication
2. git commit -m "feat(auth): add login"
3. git push -u origin feature/user-authentication
4. gh pr create --base main --head feature/user-authentication
5. After merge: git branch -d feature/user-authentication
```

### Release Branch Workflow

```
main (dev)          release/v2.1        v2.1.0 (production)
    ↑                    ↑                   ↑
    ├── develop          ├── testing        ├── tagged
    └── features         └── fixes          └── deployed

# Process:
1. git checkout -b release/v2.1 develop
2. git commit -m "fix: resolve critical bug"  # Only fixes
3. git tag -a v2.1.0 -m "Release v2.1.0"
4. Merge to main and develop
5. git branch -d release/v2.1
```

### Git Flow

```
main (production)
  ├── develop (integration)
  │     ├── feature/* (short-lived)
  │     ├── hotfix/* (production fixes)
  │     └── release/* (release prep)
  └── tags (v1.0.0, v2.0.0)

# Commands:
git flow init
git flow feature start user-auth
git flow feature finish user-auth
git flow release start v2.1
git flow release finish v2.1
```

---

## Collaboration Patterns

### Pull Request Best Practices

**Checklist**:
- [ ] Descriptive title (conventional commits)
- [ ] Clear WHAT and WHY description
- [ ] Linked issues (Fixes #123)
- [ ] Tests + documentation updated

**Review Guidelines**:
- Reviewers: Focus on logic, ask questions
- Authors: Keep PRs small (≤400 lines), one feature per PR

### Merge Conflict Resolution

```bash
git checkout feature/awesome-feature
git fetch origin && git rebase origin/main
# Resolve conflicts, remove <<<<<<< >>>>>>> markers
git add <resolved-files> && git rebase --continue
git push --force-with-lease origin feature/awesome-feature
```

---

## Repository Maintenance

### Cleanup Commands

```bash
git branch --merged | grep -v "\*" | xargs git branch -d  # Remove merged
git remote prune origin  # Remove stale remote branches
git clean -fd  # Clean untracked files
git gc --aggressive --prune=now  # Garbage collection
```

### Large File Storage

```bash
git lfs install
git lfs track "*.psd" "*.mov"
git add .gitattributes && git commit -m "chore: configure git lfs"
git lfs migrate import --include="*.psd,*.mov"  # Migrate existing
```

---

## Troubleshooting

### Undo Common Mistakes

| Mistake | Command | Explanation |
|---------|---------|-------------|
| Committed to wrong branch | `git reset HEAD~1` | Undo last commit, keep changes |
| Wrong commit message | `git commit --amend` | Edit last commit message |
| Forgot to add file | `git add file.txt && git commit --amend` | Add to last commit |
| Committed secrets | `git reset HEAD~1` + rotate secrets | Undo and change credentials |

### Recover Lost Commits

```bash
git reflog  # Find lost commits
git checkout abc123  # Recover
git branch recovered-features abc123  # Or create branch
```

### Resolve Merge Conflicts

```bash
git merge --abort && git pull --rebase  # Abort and retry
git mergetool  # Use merge tool
git checkout --theirs <file>  # Accept their version
git checkout --ours <file>  # Accept your version
```

---

## Co-Authored-By Pattern

Multiple authors contribute to a commit:
```bash
git commit -m "feat(auth): add OAuth2

Co-Authored-By: Alice <alice@example.com>"
```

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│                   GIT MASTER QUICK REFERENCE                    │
├─────────────────────────────────────────────────────────────────┤
│  COMMIT: <type>[scope]: <description>                           │
│  TYPES: feat, fix, refactor, test, docs, chore                  │
│  EXAMPLE: feat(auth): add OAuth2 login                          │
├─────────────────────────────────────────────────────────────────┤
│  BRANCHES: feature/* → main (protected)                         │
│  WORKFLOW: feature → PR → review → merge → delete               │
├─────────────────────────────────────────────────────────────────┤
│  ATTRIBUTION: Co-Authored-By: Name <email>                      │
│  AMEND: git commit --amend (last commit only)                   │
├─────────────────────────────────────────────────────────────────┤
│  REBASE: git rebase -i HEAD~5 (clean history)                   │
│  BISECT: git bisect start (find bugs)                           │
├─────────────────────────────────────────────────────────────────┤
│  NEVER: git push --force (use --force-with-lease)               │
│  NEVER: git commit --amend after push                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## Further Reading

### Internal Resources
- @.claude/skills/git-operations/SKILL.md - Safe push/pull/merge operations
- @.claude/skills/using-git-worktrees/SKILL.md - Parallel development
- @.claude/skills/tdd/SKILL.md - Test-Driven Development
- @.claude/skills/ralph-loop/SKILL.md - Quality verification loop

### External Resources
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Flow](https://docs.github.com/en/get-started/quickstart/github-flow)
- [Git LFS Documentation](https://git-lfs.github.com/)

---

**Last Updated**: 2026-01-22
