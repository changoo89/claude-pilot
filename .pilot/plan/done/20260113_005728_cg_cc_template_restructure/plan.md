# cg-cc Template Restructure for Open Source Release

- Generated at: 2026-01-13 00:54:09
- Work name: cg_cc_template_restructure
- Location: .cgcode/plan/pending/20260113_005409_cg_cc_template_restructure.md

## User Requirements

1. **Core Workflow Preservation**: Maintain 00_make_plan → 04 workflow as the core system
2. **Reference Projects Integration**:
   - context-engineering-intro: Hierarchical CONTEXT.md management (not PRP focus)
   - moai-adk: SPEC-First TDD, multilingual support, curl+sh installation
   - oh-my-opencode: Ralph Loop pattern for autonomous iteration
   - Ralph Wiggum Technique: TDD-based backpressure until tests pass
   - claude-code-showcase: Hooks, TypeScript type-check, lint automation
3. **Project-Specific Content Removal**: Remove all PICK/Hater project dependencies completely
4. **English-Only Documentation**: Convert all docs to English (multilingual via runtime settings)
5. **Semantic Command Naming**: Keep numbers (00-03, 90-91) with meaningful names
6. **Target Audience**: Claude Code intermediate users
7. **GitHub Project Name**: cg-cc (Context-Guided Claude Code)
8. **Default MCPs**: context7, serena, grep-app, sequential-thinking
9. **Hooks Integration**: TypeScript type-check, ESLint, Ralph continuation
10. **Installation**: curl + sh one-line installation script

## Scope

### In scope

- Restructure command files (00-03 user-invoked, 90-91 auto-invoked)
- Create install.sh with language selection
- Create mcp.json with recommended MCPs
- Create settings.json with hooks configuration
- Enhance 02_execute with Ralph Loop + TDD integration
- Enhance 91_document with hierarchical CONTEXT.md management
- Create README.md with inspiration credits
- Remove Korean-only command files
- Remove PICK/Hater specific content (skills, quick-start, prp-templates)
- Create generic templates (CONTEXT.md, SKILL.md, PRP.md)

### Out of scope

- Actual MCP server implementation
- CI/CD pipeline setup (future work)
- Comprehensive test suite
- Multiple language translations (runtime only)

## Context Summary

Current template (claude-template) contains 73+ files (~798KB) with:
- 10 command files (duplicates in Korean/English)
- 9 project-specific skill folders
- 27 automation scripts (some project-specific)
- Project-specific quick-start and PRP templates

Target structure (cg-cc) will have:
- 6 command files (00-03 + 90-91)
- Generic templates only
- Essential hooks scripts
- Clean, reusable structure

## Assumptions

1. Users have Claude Code CLI installed
2. Users understand basic Claude Code concepts (CLAUDE.md, slash commands)
3. Node.js/npm available for MCP installation
4. Git available for version control hooks

## Inherited Items (if any)

- Source: None (first plan in this project)

## Execution Plan

### Phase 1: Discovery & Alignment

- [x] Analyze current folder structure (73+ files identified)
- [x] Research reference projects (context-engineering, moai-adk, oh-my-opencode)
- [x] Identify files to keep, modify, remove
- [x] Define target structure
- [ ] Verify no breaking dependencies in core workflow

### Phase 2: Design

- [x] Design command numbering system (00-03, 90-91)
- [x] Design MCP configuration (context7, serena, grep-app, sequential-thinking)
- [x] Design hooks structure (PreToolUse, PostToolUse, Stop)
- [x] Design install.sh flow with language selection
- [ ] Finalize CONTEXT.md template structure
- [ ] Finalize settings.json schema

### Phase 3: Implementation

#### 3.1 Core Files
- [ ] Create README.md with inspiration credits
- [ ] Create install.sh (curl + sh, language selection)
- [ ] Create mcp.json (4 recommended MCPs)
- [ ] Create .claude/settings.json (hooks, LSP, language)

#### 3.2 Command Restructure
- [ ] Rename 00_make_plan.md → 00_plan.md (update content)
- [ ] Rename 01_confirm_plan.md → 01_confirm.md (update content)
- [ ] Rename 02_action_plan.md → 02_execute.md (enhance with Ralph Loop + TDD)
- [ ] Rename 03_close_plan.md → 03_close.md (update content)
- [ ] Rename 04_documentation.md → 91_document.md (enhance with CONTEXT.md hierarchy)
- [ ] Rename 10_review-plan.md → 90_review.md (update content)

#### 3.3 Templates
- [ ] Create .claude/templates/CONTEXT.md.template
- [ ] Create .claude/templates/SKILL.md.template
- [ ] Create .claude/templates/PRP.md.template

#### 3.4 Hooks Scripts
- [ ] Create .claude/scripts/hooks/typecheck.sh
- [ ] Create .claude/scripts/hooks/lint.sh
- [ ] Create .claude/scripts/hooks/check-todos.sh (Ralph continuation)
- [ ] Create .claude/scripts/hooks/branch-guard.sh

#### 3.5 Cleanup
- [ ] Remove Korean command files (문서화.md, 리뷰플랜.md, 테스트(가상).md)
- [ ] Remove duplicate documentation.md
- [ ] Remove .claude/skills/* (project-specific)
- [ ] Remove .claude/quick-start/* (project-specific)
- [ ] Remove .claude/prp-templates/* (project-specific, except README)
- [ ] Remove CLAUDE-hater-example.md
- [ ] Clean CLAUDE.md (make generic)
- [ ] Update AGENTS.md (make generic)

### Phase 4: Verification

- [ ] Run: `grep -r "PICK\|Hater\|베트맨" .` → expect 0 results
- [ ] Run: `grep -r "[가-힣]" .claude/` → expect 0 results (except comments)
- [ ] Verify install.sh syntax: `bash -n install.sh`
- [ ] Verify JSON files: `cat mcp.json | jq .`
- [ ] Test command invocation: `/00_plan "test feature"` works
- [ ] Verify hooks execute without error

### Phase 5: Handoff

- [ ] Update CLAUDE.md with new structure documentation
- [ ] Create examples/ folder with sample configurations
- [ ] Git init and first commit
- [ ] Document next steps for users

## Acceptance Criteria

### Functional

- [ ] `/00_plan`, `/01_confirm`, `/02_execute`, `/03_close` commands work
- [ ] `/90_review`, `/91_document` auto-invoke correctly
- [ ] install.sh downloads and configures correctly
- [ ] mcp.json installs 4 MCPs without error
- [ ] Hooks trigger on file edit (typecheck, lint)

### Observable

- [ ] README.md lists all 6 inspiration sources
- [ ] No Korean text in any .claude/ files
- [ ] No PICK/Hater references in any files
- [ ] settings.json contains language, hooks, lsp sections

### Pass/Fail

| Check | Command | Expected |
|-------|---------|----------|
| No Korean content | `grep -r "[가-힣]" .claude/` | 0 matches |
| No project refs | `grep -ri "pick\|hater" .` | 0 matches |
| Valid JSON | `jq . mcp.json settings.json` | Exit 0 |
| Valid shell | `bash -n install.sh` | Exit 0 |
| Commands exist | `ls .claude/commands/*.md` | 6 files |

## Test Plan

### Objective

Verify the restructured template is:
1. Free of project-specific content
2. Functional with core workflow
3. Installable via curl + sh

### Prerequisites

- macOS/Linux environment
- Claude Code CLI installed
- Node.js 18+ available

### Test Cases

1. **Clean Install**: `curl | sh` in empty directory → .claude/ created with correct structure
2. **Language Selection**: Select Korean during install → settings.json has `"language": "ko"`
3. **MCP Installation**: Run `claude mcp add` from mcp.json → All 4 MCPs added
4. **Plan Workflow**: Run `/00_plan "test"` → Creates plan in .cgcode/plan/pending/
5. **Hook Execution**: Edit .ts file → TypeScript check runs automatically
6. **Korean Content Check**: `grep -r "[가-힣]" .` → No matches
7. **Project Reference Check**: `grep -ri "pick\|hater"` → No matches

### How to Execute

#### Commands:
```bash
# Test 1: Verify structure
ls -la .claude/commands/
# Expected: 00_plan.md, 01_confirm.md, 02_execute.md, 03_close.md, 90_review.md, 91_document.md

# Test 2: Verify no Korean
grep -r "[가-힣]" .claude/
# Expected: no output

# Test 3: Verify no project refs
grep -ri "pick\|hater\|베트맨" .
# Expected: no output

# Test 4: Validate JSON
jq . mcp.json .claude/settings.json
# Expected: valid JSON output

# Test 5: Validate shell script
bash -n install.sh
# Expected: exit 0
```

#### Manual steps:
1. Copy template to new project
2. Run install.sh
3. Open Claude Code
4. Execute `/00_plan "test feature"`
5. Verify plan file created

## Risks & Rollback

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing workflows | Low | High | Keep core command structure |
| Missing essential content | Medium | Medium | Review before deletion |
| Hook compatibility issues | Medium | Low | Provide fallback/disable option |
| MCP version conflicts | Low | Medium | Pin versions in mcp.json |

### Rollback Plan

1. Template is new project - no production rollback needed
2. Git history preserves all changes
3. Original claude-template remains unchanged as reference

## Open Questions

1. ~~Should review/document be skills or commands?~~ → **Resolved: Commands with 90-91 prefix**
2. ~~Which MCPs to include?~~ → **Resolved: context7, serena, grep-app, sequential-thinking**
3. Should examples/ folder include full sample projects or just configs?
4. Should we include GitHub Actions workflows from claude-code-showcase?

## Notes

### Inspiration Sources (for README.md)

**Core Methodology:**
- [context-engineering-intro](https://github.com/coleam00/context-engineering-intro) - Hierarchical CONTEXT.md, PRP pattern
- [moai-adk](https://github.com/modu-ai/moai-adk) - SPEC-First TDD, multilingual, curl install
- [oh-my-opencode](https://github.com/code-yeongyu/oh-my-opencode) - Ralph Loop, Claude Code compatibility

**Techniques:**
- [Ralph Wiggum Technique](https://github.com/ghuntley/how-to-ralph-wiggum) - Autonomous TDD iteration

**Implementation Reference:**
- [claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) - Hooks, skills, GitHub Actions
- [claude-hooks](https://github.com/johnlindquist/claude-hooks) - TypeScript hook implementation

**Official Resources:**
- [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) - Official MCP servers
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) - Anthropic guide

### File Structure Target

```
cg-cc/
├── README.md
├── install.sh
├── mcp.json
├── CLAUDE.md
├── AGENTS.md
├── .claude/
│   ├── settings.json
│   ├── commands/
│   │   ├── 00_plan.md
│   │   ├── 01_confirm.md
│   │   ├── 02_execute.md
│   │   ├── 03_close.md
│   │   ├── 90_review.md
│   │   └── 91_document.md
│   ├── guides/
│   │   ├── context-engineering.md
│   │   └── ralph-loop-tdd.md
│   ├── templates/
│   │   ├── CONTEXT.md.template
│   │   ├── SKILL.md.template
│   │   └── PRP.md.template
│   └── scripts/
│       └── hooks/
│           ├── typecheck.sh
│           ├── lint.sh
│           ├── check-todos.sh
│           └── branch-guard.sh
└── examples/
    └── settings-full.json
```
