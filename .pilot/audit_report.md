# Git Files Audit Report

> **Generated**: $(date +%Y-%m-%d\ %H:%M:%S)
> **Total Files**: 561
> **Purpose**: Categorize all git-tracked files for cleanup planning

---

## Executive Summary

| Category | File Count | Percentage | Action |
|----------|------------|------------|--------|
| Core Plugin | 396 | 70.6% | Keep |
| Runtime State (.pilot/) | 137 | 24.4% | Remove |
| Duplicate (.claude-pilot/) | 7 | 1.2% | Remove |
| Backup/Temp | 7 | 1.2% | Remove |
| Historical Plans | 0 | 0% | Included in Runtime State |
| External Skills | 14 | 2.5% | Review |

**Total**: 561 files
**Recommended for Removal**: 151 files (26.9%)

---

## File Categories

### 1. Core Plugin Files (396 files)

**Purpose**: Essential plugin functionality - must keep

**Subcategories**:

#### 1.1 Commands (11 files)
.claude/commands/*.md

#### 1.2 Guides (17 files)  
.claude/guides/*.md

#### 1.3 Skills (30 files)
.claude/skills/*/*.md, SKILL.md

#### 1.4 Agents (8 files)
.claude/agents/*.md

#### 1.5 Rules (18 files)
.claude/rules/**/*.md

#### 1.6 Scripts (15 files)
.claude/scripts/*.sh

#### 1.7 Hooks (4 files)
.claude/hooks/*.json

#### 1.8 Documentation (50+ files)
CLAUDE.md, README.md, docs/**/*.md

#### 1.9 Configuration (10+ files)
.gitignore, .serena/*.yml, .claude-plugin/*.json

#### 1.10 Tests (100+ files)
.pilot/tests/*.sh, .claude-pilot/.pilot/tests/*.sh

#### 1.11 Templates (40+ files)
.claude/templates/*, .github/*

#### 1.12 Other Core Files
.misc scripts, LICENSE, etc.

---

### 2. Runtime State - .pilot/ (137 files)

**Purpose**: Runtime planning state - should NOT be in git

**Justification**: 
- Contains work-in-progress plans
- Auto-generated continuation state
- Temporary planning artifacts
- Should be in .gitignore

**Files**:

```
.pilot/CONTEXT.md
.pilot/audit/documentation_audit_report.md
.pilot/audit/remaining_issues_report.md
.pilot/backup_files.txt
.pilot/docs/claude-md-redesign.md
.pilot/docs/inventory.md
.pilot/docs/progressive-disclosure-plan.md
.pilot/docs/standards-mapping.md
.pilot/plan/active/.gitkeep
.pilot/plan/active/integration-test.txt
.pilot/plan/done/.gitkeep
.pilot/plan/done/1768716134_fix-plugin-deployment-permissions.md
.pilot/plan/done/20250113_200145_claude_pilot_cli.md
.pilot/plan/done/20250113_install_sh_backup_cleanup.md
.pilot/plan/done/20250115_222942_enhance_plan_context_preservation.md
.pilot/plan/done/20250117_213045_gpt_delegation_expansion.md
.pilot/plan/done/20250117_213045_gpt_delegation_expansion/coverage-report.txt
.pilot/plan/done/20250117_213045_gpt_delegation_expansion/ralph-loop-log.md
.pilot/plan/done/20250117_213045_gpt_delegation_expansion/test-scenarios.md
.pilot/plan/done/20250118_090000_plugin_release_workflow.md
.pilot/plan/done/20250118_delegation_prompt_improvements.md
.pilot/plan/done/20250118_plugin_distribution_analysis.md
.pilot/plan/done/20250118_sisyphus_continuation_system.md
.pilot/plan/done/2026-01-18_frontend-design-skill.md
.pilot/plan/done/2026-01-19_command-file-structure-optimization.md
.pilot/plan/done/20260113_130619_worktree_wt_option_improvements.md
.pilot/plan/done/20260113_150947_review_apply_to_plan.md
.pilot/plan/done/20260113_160000_worktree_support.md
.pilot/plan/done/20260113_171250_00_plan_implementation_guard/plan.md
.pilot/plan/done/20260113_175845_glm_extended_thinking/plan.md
.pilot/plan/done/20260113_183913_command_refactoring_with_vibe_coding.md
.pilot/plan/done/20260113_190000_workflow_restructure.md
.pilot/plan/done/20260113_193928_structure_improvement_ralph_loop/plan.md
.pilot/plan/done/20260113_195858_enforce_english_plan_documents/plan.md
.pilot/plan/done/20260113_201623_fix_workflow_documentation.md
.pilot/plan/done/20260113_212228_moai_style_installation_flow.md
.pilot/plan/done/20260113_3tier_documentation_system.md
.pilot/plan/done/20260113_curl_install_update.md
.pilot/plan/done/20260113_plan_file_structure_and_git_check.md
.pilot/plan/done/20260114_115842_ensure_git_commit_cross_repo.md
.pilot/plan/done/20260114_131513_slash_command_enhancement.md
.pilot/plan/done/20260114_143110_prevent_implementation_rush.md
.pilot/plan/done/20260114_152941_update_ux_pypi_check.md
.pilot/plan/done/20260114_183640_command_structure_refactoring.md
.pilot/plan/done/20260114_191733_enhance_plan_execution_context.md
.pilot/plan/done/20260114_203151_skills_agents_3tier_refactor.md
.pilot/plan/done/20260114_215100_context_isolation_skills_agents.md
.pilot/plan/done/20260114_225647_01_confirm_highlights_extraction.md
.pilot/plan/done/20260114_ralph_loop_tdd_prompt_enhancement.md
.pilot/plan/done/20260115_060147_parallel_workflow_optimization.md
.pilot/plan/done/20260115_090250_agent_usage_optimization.md
.pilot/plan/done/20260115_094330_optimize_guide_skill_deduplication.md
.pilot/plan/done/20260115_102527_execute_plan_move_priority.md
.pilot/plan/done/20260115_112508_legacy_cleanup_and_template_sync.md
.pilot/plan/done/20260115_142530_claude_docs_review_and_optimization/.gitkeep
.pilot/plan/done/20260115_142530_claude_docs_review_and_optimization/20260115_142530_claude_docs_review_and_optimization.md
.pilot/plan/done/20260115_143000_fix_agent_yaml_format.md
.pilot/plan/done/20260115_175822_parallel_todo_consistency.md
.pilot/plan/done/20260115_194500_agent_error_handling.md
.pilot/plan/done/20260115_195021_documentation_enhancement_research.md
.pilot/plan/done/20260115_211212_documentation_phase2_refactoring.md
.pilot/plan/done/20260115_234419_statusline_pending_count.md
.pilot/plan/done/20260115_234419_statusline_pending_count/coverage-report.txt
.pilot/plan/done/20260115_234419_statusline_pending_count/ralph-loop-log.md
.pilot/plan/done/20260115_234419_statusline_pending_count/test-scenarios.md
.pilot/plan/done/20260115_docs_optimization_tdd_enforcement.md
.pilot/plan/done/20260115_plan_mode_ambiguous_confirmation_protection.md
.pilot/plan/done/20260115_worktree_architecture_fix.md
.pilot/plan/done/20260115_worktree_architecture_fix/coverage-report.txt
.pilot/plan/done/20260115_worktree_architecture_fix/ralph-loop-log.md
.pilot/plan/done/20260115_worktree_architecture_fix/test-scenarios.md
.pilot/plan/done/20260116_090342_03_close_git_push_enhancement.md
.pilot/plan/done/20260116_093511_user_requirements_tracking_verification.md
.pilot/plan/done/20260116_110000_external_skills_sync.md
.pilot/plan/done/20260116_213106_auto_apply_reviewer_suggestions.md
.pilot/plan/done/20260116_220906_fix_execute_plan_detection.md
.pilot/plan/done/20260116_221711_codex_delegator_integration.md
.pilot/plan/done/20260116_221711_codex_delegator_integration_artifacts/documentation-update-summary.md
.pilot/plan/done/20260116_222500_codex_delegator_integration.md
.pilot/plan/done/20260116_222500_codex_delegator_integration/artifacts/coverage-report.txt
.pilot/plan/done/20260116_222500_codex_delegator_integration/artifacts/ralph-loop-log.md
.pilot/plan/done/20260116_222500_codex_delegator_integration/artifacts/test-scenarios.md
.pilot/plan/done/20260116_231701_codex_delegator_source_fix.md
.pilot/plan/done/20260116_234359_remove_audit_report.md
.pilot/plan/done/20260116_instruction_clarity_improvement.md
.pilot/plan/done/20260117_000631_fix_git_push_visibility.md
.pilot/plan/done/20260117_004443_fix_hater_deployment_after_claude_pilot_update.md
.pilot/plan/done/20260117_013225_gpt_expert_integration_with_commands_and_agents.md
.pilot/plan/done/20260117_063116_worktree_close_flow_improvement.md
.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4.md
.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4/coverage-report.txt
.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4/ralph-loop-log.md
.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4/test-scenarios.md
.pilot/plan/done/20260117_100223_ssot_assets_buildhook_and_template_removal.md
.pilot/plan/done/20260117_102930_documentation_inconsistency_fixes.md
.pilot/plan/done/20260117_105133_deployment_process_audit.md
.pilot/plan/done/20260117_121642_gpt_delegation_git_push_enhancement.md
.pilot/plan/done/20260117_161348_claude_pilot_docs_concise_first.md
.pilot/plan/done/20260117_212451_gpt_delegation_improvements.md
.pilot/plan/done/20260117_222637_intelligent_codex_delegation.md
.pilot/plan/done/20260117_222637_parallel_execution_improvement.md
.pilot/plan/done/20260117_230259_improve_plugin_installation.md
.pilot/plan/done/20260117_230643_clone_sample_installation_structure.md
.pilot/plan/done/20260117_234749_verify_plugin_structure_and_cleanup.md
.pilot/plan/done/20260117_improve_plugin_installation.md
.pilot/plan/done/20260117_pure_plugin_migration.md
.pilot/plan/done/20260118_150431_sisyphus_continuation_system.md
.pilot/plan/done/20260118_150431_sisyphus_continuation_system/ralph-loop-log.md
.pilot/plan/done/20260118_150431_sisyphus_continuation_system/test-scenarios.md
.pilot/plan/done/20260118_150431_sisyphus_continuation_system_continuation_state.json
.pilot/plan/done/20260118_151255_fix_codex_intermittent_detection.md
.pilot/plan/done/20260118_223110_documentation_refactoring.md
.pilot/plan/done/20260118_235147_fix-cgcode-directory-path.md
.pilot/plan/done/20260118_235333_documentation_structure_refactoring.md
.pilot/plan/done/20260118_fix_codex_intermittent_detection.md
.pilot/plan/done/20260118_fix_worktree_mode.md
.pilot/plan/done/20260118_fix_worktree_mode_closed_20260118_173057.md
.pilot/plan/done/20260118_github_actions_cicd_integration.md
.pilot/plan/done/20260118_github_actions_cicd_integration_tests.md
.pilot/plan/done/20260119_165356_fix_path_duplication_and_04_fix_plan_creation.md
.pilot/plan/done/20260119_171404_separate_claude_md_from_local.md
.pilot/plan/done/20260119_182921_prevent_auto_plan_done.md
.pilot/plan/done/20260119_195749_hooks_performance_optimization.md
.pilot/plan/done/20260119_195749_hooks_performance_optimization/coverage-report.txt
.pilot/plan/done/20260119_195749_hooks_performance_optimization/ralph-loop-log.md
.pilot/plan/done/20260119_195749_hooks_performance_optimization/test-scenarios.md
.pilot/plan/done/20260119_214151_dead_code_cleanup_command.md
.pilot/plan/done/20260119_222853_update_documentation_remove_pypi_add_codex.md
.pilot/plan/done/20260119_232207_improve_05_cleanup_auto_apply.md
.pilot/plan/done/20260120_021451_command_reorganization.md
.pilot/plan/done/20260120_083000_fix_plan_detection_and_statusline.md
.pilot/plan/done/20260120_090542_github_seo_optimization.md
.pilot/plan/done/20260120_091719_claude_pilot_meta_skill.md
.pilot/plan/done/20260120_095501_fix_execute_plan_detection.md
.pilot/plan/done/codex-timeout-fix.md
.pilot/plan/done/docs-improvement-plan-4.0.3_20260117_055625.md
.pilot/plan/done/fix-version-sync-system.md
.pilot/plan/done/researcher-agent-case-sensitivity-fix.md
.pilot/plan/done/skill-docs-and-parallel-execution.md
.pilot/plan/done/skill-docs-and-parallel-execution/implementation-summary.md
.pilot/plan/done/skill-docs-and-parallel-execution/verification-log.txt
.pilot/plan/draft/20260120_095315_extend_cleanup_dead_documents.md
.pilot/plan/pending/.gitkeep
.pilot/plan/pending/20260120_095816_git_files_audit_cleanup.md
.pilot/scripts/CONTEXT.md
.pilot/scripts/state_backup.sh
.pilot/scripts/state_read.sh
.pilot/scripts/state_write.sh
.pilot/state/continuation.json.backup
.pilot/state/continuation.json.example
.pilot/state/continuation.json.final.backup
.pilot/state/continuation.json.lock
.pilot/test/continuation_state_test.sh
.pilot/test/continue_command_test.sh
.pilot/test/integration_test.sh
.pilot/tests/CLEANUP_TESTS_SUMMARY.md
.pilot/tests/SC1_SUMMARY.md
.pilot/tests/cleanup-apply.test.sh
.pilot/tests/cleanup-auto.test.sh
.pilot/tests/cleanup-ci-apply.test.sh
.pilot/tests/cleanup-ci.test.sh
.pilot/tests/cleanup-confirm.test.sh
.pilot/tests/cleanup-conflict.test.sh
.pilot/tests/cleanup-dryrun.test.sh
.pilot/tests/cleanup-preflight.test.sh
.pilot/tests/cleanup-rollback.test.sh
.pilot/tests/cleanup-verify.test.sh
.pilot/tests/execute/test_empty_pending.sh
.pilot/tests/execute/test_in_progress_selection.sh
.pilot/tests/execute/test_multiple_plans.sh
.pilot/tests/execute/test_plan_detection.sh
.pilot/tests/execute/test_sync_edge_case.sh
.pilot/tests/final_verification.sh
.pilot/tests/fixtures/test-plan-integration.md
.pilot/tests/integration/test-setup-permissions.sh
.pilot/tests/sc1_claude_code_standards_audit.md
.pilot/tests/test-cache-hit-rate.sh
.pilot/tests/test-check-todos-integration.sh
.pilot/tests/test-debounce-deterministic.sh
.pilot/tests/test-dispatcher-perf.sh
.pilot/tests/test-early-exit-process.sh
.pilot/tests/test-profile-mode-switch.sh
.pilot/tests/test-profiles.sh
.pilot/tests/test-stop-no-infinite-loop.sh
.pilot/tests/test_00_continue.test.sh
.pilot/tests/test_00_plan_delegation.test.sh
.pilot/tests/test_01_confirm_delegation.test.sh
.pilot/tests/test_91_document_delegation.test.sh
.pilot/tests/test_999_skip_gh.sh
.pilot/tests/test_all_sc.sh
.pilot/tests/test_claude_md_structure.test.sh
.pilot/tests/test_close_push_fail.sh
.pilot/tests/test_close_worktree_push.sh
.pilot/tests/test_close_worktree_push_fail.sh
.pilot/tests/test_codex_detection.test.sh
.pilot/tests/test_continuation_state.test.sh
.pilot/tests/test_debug_mode.test.sh
.pilot/tests/test_delegation.test.sh
.pilot/tests/test_execute_no_move.sh
.pilot/tests/test_execute_status.sh
.pilot/tests/test_github_workflow.sh
.pilot/tests/test_gitignore_behavior.test.sh
.pilot/tests/test_graceful_fallback.test.sh
.pilot/tests/test_helpers.sh
.pilot/tests/test_no_delegation.test.sh
.pilot/tests/test_path_init.test.sh
.pilot/tests/test_plan_detection.sh
.pilot/tests/test_prompt_warnings.sh
.pilot/tests/test_sc1_no_plan_creation.sh
.pilot/tests/test_sc1_simple_fix.sh
.pilot/tests/test_sc2_draft_save.sh
.pilot/tests/test_sc2_multistep_fix.sh
.pilot/tests/test_sc3_continuation_support.sh
.pilot/tests/test_sc4_scope_validation.sh
.pilot/tests/test_sc5_commit_confirmation.sh
.pilot/tests/test_sc5_error_messages.sh
.pilot/tests/test_sc5_gpt_prioritization.sh
.pilot/tests/test_sc5_integration.test.sh
.pilot/tests/test_sc6_explicit_close.sh
.pilot/tests/test_sc7_final_verification.test.sh
.pilot/tests/test_sc7_progressive_disclosure.test.sh
.pilot/tests/test_state_recovery.test.sh
.pilot/tests/test_statusline.sh
.pilot/tests/test_success_criteria.sh
.pilot/tests/test_template_creation.test.sh
.pilot/tests/test_verify_push.sh
.pilot/tests/test_worktree_absolute_paths.sh
.pilot/tests/test_worktree_continuation.sh
.pilot/tests/test_worktree_create.sh
.pilot/tests/test_worktree_cwd_reset.sh
.pilot/tests/test_worktree_integration.sh
.pilot/tests/test_worktree_persistence.sh
.pilot/tests/test_worktree_plan_state.sh
```

---

### 3. Duplicate Files - .claude-pilot/ (7 files)

**Purpose**: Historical duplicate prefix - should remove

**Justification**:
- Duplicates .pilot/ directory structure
- Legacy artifact from old naming
- No longer referenced

**Files**:

```
.claude-pilot/.pilot/plan/done/.gitkeep
.claude-pilot/.pilot/plan/done/20260119_160104_command_workflow_refactor.md
.claude-pilot/.pilot/plan/draft/.gitkeep
.claude-pilot/.pilot/plan/in_progress/.gitkeep
.claude-pilot/.pilot/plan/pending/.gitkeep
.claude-pilot/.pilot/tests/test_sc3_auto_apply_review.sh
.claude-pilot/.pilot/tests/test_sc4_oldest_plan_selection.sh
```

---

### 4. Backup and Temporary Files (7 files)

**Purpose**: Backup/temp files - should NEVER be in git

**Justification**:
- Backup files (.backup, .bak) belong in local storage
- Temporary files (.tmp) are transient
- Already covered by .gitignore patterns

**Files**:

```
.claude/commands/02_execute.md.bak
.claude/scripts/codex-sync.sh.backup
.pilot/state/continuation.json.backup
.pilot/state/continuation.json.final.backup
.tmp
CLAUDE.md.backup
```

---

### 5. External Skills (14 files)

**Purpose**: Third-party skills bundled with plugin

**Justification**: Review if necessary - consider removing if outdated

**Files**:

```
.claude/skills/external/vercel-agent-skills/claude.ai/vercel-deploy-claimable.zip
.claude/skills/external/vercel-agent-skills/claude.ai/vercel-deploy-claimable/SKILL.md
.claude/skills/external/vercel-agent-skills/claude.ai/vercel-deploy-claimable/scripts/deploy.sh
.claude/skills/external/vercel-agent-skills/react-best-practices/AGENTS.md
.claude/skills/external/vercel-agent-skills/react-best-practices/README.md
.claude/skills/external/vercel-agent-skills/react-best-practices/SKILL.md
.claude/skills/external/vercel-agent-skills/react-best-practices/metadata.json
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/_sections.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/_template.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/advanced-event-handler-refs.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/advanced-use-latest.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-api-routes.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-defer-await.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-dependencies.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-parallel.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-suspense-boundaries.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-barrel-imports.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-conditional.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-defer-third-party.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-dynamic-imports.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-preload.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-event-listeners.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-localstorage-schema.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-passive-event-listeners.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-swr-dedup.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-batch-dom-css.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-cache-function-results.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-cache-property-access.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-cache-storage.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-combine-iterations.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-early-exit.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-hoist-regexp.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-index-maps.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-length-check-first.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-min-max-loop.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-set-map-lookups.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-tosorted-immutable.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-activity.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-animate-svg-wrapper.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-conditional-render.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-content-visibility.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-hoist-jsx.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-hydration-no-flicker.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-svg-precision.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-defer-reads.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-dependencies.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-derived-state.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-functional-setstate.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-lazy-state-init.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-memo.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-transitions.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-after-nonblocking.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-cache-lru.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-cache-react.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-parallel-fetching.md
.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-serialization.md
.claude/skills/external/vercel-agent-skills/skills/claude.ai/vercel-deploy-claimable.zip
.claude/skills/external/vercel-agent-skills/skills/claude.ai/vercel-deploy-claimable/SKILL.md
.claude/skills/external/vercel-agent-skills/skills/claude.ai/vercel-deploy-claimable/scripts/deploy.sh
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/AGENTS.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/README.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/SKILL.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/metadata.json
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/_sections.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/_template.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/advanced-event-handler-refs.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/advanced-use-latest.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-api-routes.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-defer-await.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-dependencies.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-parallel.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-suspense-boundaries.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-barrel-imports.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-conditional.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-defer-third-party.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-dynamic-imports.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-preload.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/client-event-listeners.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/client-swr-dedup.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-batch-dom-css.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-cache-function-results.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-cache-property-access.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-cache-storage.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-combine-iterations.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-early-exit.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-hoist-regexp.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-index-maps.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-length-check-first.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-min-max-loop.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-set-map-lookups.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-tosorted-immutable.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-activity.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-animate-svg-wrapper.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-conditional-render.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-content-visibility.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-hoist-jsx.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-hydration-no-flicker.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-svg-precision.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-defer-reads.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-dependencies.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-derived-state.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-functional-setstate.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-lazy-state-init.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-memo.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-transitions.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-after-nonblocking.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-cache-lru.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-cache-react.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-parallel-fetching.md
.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-serialization.md
.claude/skills/external/vercel-agent-skills/skills/web-design-guidelines.zip
.claude/skills/external/vercel-agent-skills/skills/web-design-guidelines/SKILL.md
.claude/skills/external/vercel-agent-skills/web-design-guidelines.zip
.claude/skills/external/vercel-agent-skills/web-design-guidelines/SKILL.md
```

---

## Detailed File Listing

### All 561 Git-Tracked Files


| # | File Path | Category |
|---|-----------|----------|
| 1 | `.claude-pilot/.pilot/plan/done/.gitkeep` | Duplicate |
| 2 | `.claude-pilot/.pilot/plan/done/20260119_160104_command_workflow_refactor.md` | Duplicate |
| 3 | `.claude-pilot/.pilot/plan/draft/.gitkeep` | Duplicate |
| 4 | `.claude-pilot/.pilot/plan/in_progress/.gitkeep` | Duplicate |
| 5 | `.claude-pilot/.pilot/plan/pending/.gitkeep` | Duplicate |
| 6 | `.claude-pilot/.pilot/tests/test_sc3_auto_apply_review.sh` | Duplicate |
| 7 | `.claude-pilot/.pilot/tests/test_sc4_oldest_plan_selection.sh` | Duplicate |
| 8 | `.claude-plugin/marketplace.json` | Core |
| 9 | `.claude-plugin/plugin.json` | Core |
| 10 | `.claude/.external-skills-version` | Core |
| 11 | `.claude/agents/CONTEXT.md` | Core |
| 12 | `.claude/agents/code-reviewer.md` | Core |
| 13 | `.claude/agents/coder.md` | Core |
| 14 | `.claude/agents/documenter.md` | Core |
| 15 | `.claude/agents/explorer.md` | Core |
| 16 | `.claude/agents/plan-reviewer.md` | Core |
| 17 | `.claude/agents/researcher.md` | Core |
| 18 | `.claude/agents/tester.md` | Core |
| 19 | `.claude/agents/validator.md` | Core |
| 20 | `.claude/commands/00_plan.md` | Core |
| 21 | `.claude/commands/01_confirm.md` | Core |
| 22 | `.claude/commands/02_execute.md` | Core |
| 23 | `.claude/commands/02_execute.md.bak` | Backup/Temp |
| 24 | `.claude/commands/03_close.md` | Core |
| 25 | `.claude/commands/04_fix.md` | Core |
| 26 | `.claude/commands/05_cleanup.md` | Core |
| 27 | `.claude/commands/999_release.md` | Core |
| 28 | `.claude/commands/CONTEXT.md` | Core |
| 29 | `.claude/commands/continue.md` | Core |
| 30 | `.claude/commands/document.md` | Core |
| 31 | `.claude/commands/review.md` | Core |
| 32 | `.claude/commands/setup.md` | Core |
| 33 | `.claude/generated/import-analysis.json` | Core |
| 34 | `.claude/generated/import-analysis.md` | Core |
| 35 | `.claude/generated/import-fixes.json` | Core |
| 36 | `.claude/guides/.backup/claude-code-standards.md` | Core |
| 37 | `.claude/guides/.backup/parallel-execution-REFERENCE.md` | Core |
| 38 | `.claude/guides/.backup/todo-granularity.md` | Core |
| 39 | `.claude/guides/3tier-documentation-REFERENCE.md` | Core |
| 40 | `.claude/guides/3tier-documentation.md` | Core |
| 41 | `.claude/guides/CONTEXT.md` | Core |
| 42 | `.claude/guides/claude-code-standards-REFERENCE.md` | Core |
| 43 | `.claude/guides/claude-code-standards.md` | Core |
| 44 | `.claude/guides/continuation-system-REFERENCE.md` | Core |
| 45 | `.claude/guides/continuation-system.md` | Core |
| 46 | `.claude/guides/gap-detection-REFERENCE.md` | Core |
| 47 | `.claude/guides/gap-detection.md` | Core |
| 48 | `.claude/guides/instruction-clarity-REFERENCE.md` | Core |
| 49 | `.claude/guides/instruction-clarity.md` | Core |
| 50 | `.claude/guides/intelligent-delegation-REFERENCE.md` | Core |
| 51 | `.claude/guides/intelligent-delegation.md` | Core |
| 52 | `.claude/guides/parallel-execution-REFERENCE.md` | Core |
| 53 | `.claude/guides/parallel-execution.md` | Core |
| 54 | `.claude/guides/prp-framework.md` | Core |
| 55 | `.claude/guides/requirements-tracking.md` | Core |
| 56 | `.claude/guides/requirements-verification-REFERENCE.md` | Core |
| 57 | `.claude/guides/requirements-verification.md` | Core |
| 58 | `.claude/guides/review-checklist-REFERENCE.md` | Core |
| 59 | `.claude/guides/review-checklist.md` | Core |
| 60 | `.claude/guides/test-environment-REFERENCE.md` | Core |
| 61 | `.claude/guides/test-environment.md` | Core |
| 62 | `.claude/guides/test-plan-design.md` | Core |
| 63 | `.claude/guides/todo-granularity-REFERENCE.md` | Core |
| 64 | `.claude/guides/todo-granularity.md` | Core |
| 65 | `.claude/guides/worktree-setup-REFERENCE.md` | Core |
| 66 | `.claude/guides/worktree-setup.md` | Core |
| 67 | `.claude/hooks.json` | Core |
| 68 | `.claude/quality-profile.json.template` | Core |
| 69 | `.claude/rules/CONTEXT.md` | Core |
| 70 | `.claude/rules/core/workflow.md` | Core |
| 71 | `.claude/rules/delegator/delegation-checklist.md` | Core |
| 72 | `.claude/rules/delegator/delegation-format.md` | Core |
| 73 | `.claude/rules/delegator/examples/after-phase-detection.md` | Core |
| 74 | `.claude/rules/delegator/examples/after-stateless.md` | Core |
| 75 | `.claude/rules/delegator/examples/before-phase-detection.md` | Core |
| 76 | `.claude/rules/delegator/examples/before-stateless.md` | Core |
| 77 | `.claude/rules/delegator/intelligent-triggers.md` | Core |
| 78 | `.claude/rules/delegator/model-selection.md` | Core |
| 79 | `.claude/rules/delegator/orchestration.md` | Core |
| 80 | `.claude/rules/delegator/pattern-standard.md` | Core |
| 81 | `.claude/rules/delegator/prompts/architect.md` | Core |
| 82 | `.claude/rules/delegator/prompts/code-reviewer.md` | Core |
| 83 | `.claude/rules/delegator/prompts/plan-reviewer.md` | Core |
| 84 | `.claude/rules/delegator/prompts/scope-analyst.md` | Core |
| 85 | `.claude/rules/delegator/prompts/security-analyst.md` | Core |
| 86 | `.claude/rules/delegator/triggers.md` | Core |
| 87 | `.claude/rules/documentation/tier-rules.md` | Core |
| 88 | `.claude/scripts/CONTEXT.md` | Core |
| 89 | `.claude/scripts/analyze-typescript.mjs` | Core |
| 90 | `.claude/scripts/api-pattern-analyzer.mjs` | Core |
| 91 | `.claude/scripts/cleanup.sh` | Core |
| 92 | `.claude/scripts/codex-sync.sh` | Core |
| 93 | `.claude/scripts/codex-sync.sh.backup` | Backup/Temp |
| 94 | `.claude/scripts/component-analyzer.mjs` | Core |
| 95 | `.claude/scripts/context-package-generator.mjs` | Core |
| 96 | `.claude/scripts/data-flow-tracker.mjs` | Core |
| 97 | `.claude/scripts/hooks/CONTEXT.md` | Core |
| 98 | `.claude/scripts/hooks/branch-guard.sh` | Core |
| 99 | `.claude/scripts/hooks/cache.sh` | Core |
| 100 | `.claude/scripts/hooks/check-todos.sh` | Core |
| 101 | `.claude/scripts/hooks/lint.sh` | Core |
| 102 | `.claude/scripts/hooks/quality-dispatch.sh` | Core |
| 103 | `.claude/scripts/hooks/typecheck.sh` | Core |
| 104 | `.claude/scripts/run-analysis.mjs` | Core |
| 105 | `.claude/scripts/simple-analyzer.mjs` | Core |
| 106 | `.claude/scripts/simple_post_hook.sh` | Core |
| 107 | `.claude/scripts/simple_test.sh` | Core |
| 108 | `.claude/scripts/smart-import-generator.mjs` | Core |
| 109 | `.claude/scripts/statusline.sh` | Core |
| 110 | `.claude/scripts/test-agent-names.sh` | Core |
| 111 | `.claude/scripts/test-context.mjs` | Core |
| 112 | `.claude/scripts/worktree-create.sh` | Core |
| 113 | `.claude/scripts/worktree-utils.sh` | Core |
| 114 | `.claude/settings.default.json` | Core |
| 115 | `.claude/settings.json` | Core |
| 116 | `.claude/settings.json.example` | Core |
| 117 | `.claude/settings.json.package` | Core |
| 118 | `.claude/skills/CONTEXT.md` | Core |
| 119 | `.claude/skills/claude-pilot-standards/EXAMPLES.md` | Core |
| 120 | `.claude/skills/claude-pilot-standards/REFERENCE.md` | Core |
| 121 | `.claude/skills/claude-pilot-standards/SKILL.md` | Core |
| 122 | `.claude/skills/claude-pilot-standards/TEMPLATES.md` | Core |
| 123 | `.claude/skills/close-plan/REFERENCE.md` | Core |
| 124 | `.claude/skills/close-plan/SKILL.md` | Core |
| 125 | `.claude/skills/confirm-plan/REFERENCE.md` | Core |
| 126 | `.claude/skills/confirm-plan/SKILL.md` | Core |
| 127 | `.claude/skills/continue-work/REFERENCE.md` | Core |
| 128 | `.claude/skills/continue-work/SKILL.md` | Core |
| 129 | `.claude/skills/documentation-best-practices/REFERENCE.md` | Core |
| 130 | `.claude/skills/documentation-best-practices/SKILL.md` | Core |
| 131 | `.claude/skills/execute-plan/REFERENCE.md` | Core |
| 132 | `.claude/skills/execute-plan/SKILL.md` | Core |
| 133 | `.claude/skills/external/vercel-agent-skills/claude.ai/vercel-deploy-claimable.zip` | External Skill |
| 134 | `.claude/skills/external/vercel-agent-skills/claude.ai/vercel-deploy-claimable/SKILL.md` | External Skill |
| 135 | `.claude/skills/external/vercel-agent-skills/claude.ai/vercel-deploy-claimable/scripts/deploy.sh` | External Skill |
| 136 | `.claude/skills/external/vercel-agent-skills/react-best-practices/AGENTS.md` | External Skill |
| 137 | `.claude/skills/external/vercel-agent-skills/react-best-practices/README.md` | External Skill |
| 138 | `.claude/skills/external/vercel-agent-skills/react-best-practices/SKILL.md` | External Skill |
| 139 | `.claude/skills/external/vercel-agent-skills/react-best-practices/metadata.json` | External Skill |
| 140 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/_sections.md` | External Skill |
| 141 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/_template.md` | External Skill |
| 142 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/advanced-event-handler-refs.md` | External Skill |
| 143 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/advanced-use-latest.md` | External Skill |
| 144 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-api-routes.md` | External Skill |
| 145 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-defer-await.md` | External Skill |
| 146 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-dependencies.md` | External Skill |
| 147 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-parallel.md` | External Skill |
| 148 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/async-suspense-boundaries.md` | External Skill |
| 149 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-barrel-imports.md` | External Skill |
| 150 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-conditional.md` | External Skill |
| 151 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-defer-third-party.md` | External Skill |
| 152 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-dynamic-imports.md` | External Skill |
| 153 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/bundle-preload.md` | External Skill |
| 154 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-event-listeners.md` | External Skill |
| 155 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-localstorage-schema.md` | External Skill |
| 156 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-passive-event-listeners.md` | External Skill |
| 157 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/client-swr-dedup.md` | External Skill |
| 158 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-batch-dom-css.md` | External Skill |
| 159 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-cache-function-results.md` | External Skill |
| 160 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-cache-property-access.md` | External Skill |
| 161 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-cache-storage.md` | External Skill |
| 162 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-combine-iterations.md` | External Skill |
| 163 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-early-exit.md` | External Skill |
| 164 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-hoist-regexp.md` | External Skill |
| 165 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-index-maps.md` | External Skill |
| 166 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-length-check-first.md` | External Skill |
| 167 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-min-max-loop.md` | External Skill |
| 168 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-set-map-lookups.md` | External Skill |
| 169 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/js-tosorted-immutable.md` | External Skill |
| 170 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-activity.md` | External Skill |
| 171 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-animate-svg-wrapper.md` | External Skill |
| 172 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-conditional-render.md` | External Skill |
| 173 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-content-visibility.md` | External Skill |
| 174 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-hoist-jsx.md` | External Skill |
| 175 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-hydration-no-flicker.md` | External Skill |
| 176 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rendering-svg-precision.md` | External Skill |
| 177 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-defer-reads.md` | External Skill |
| 178 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-dependencies.md` | External Skill |
| 179 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-derived-state.md` | External Skill |
| 180 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-functional-setstate.md` | External Skill |
| 181 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-lazy-state-init.md` | External Skill |
| 182 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-memo.md` | External Skill |
| 183 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/rerender-transitions.md` | External Skill |
| 184 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-after-nonblocking.md` | External Skill |
| 185 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-cache-lru.md` | External Skill |
| 186 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-cache-react.md` | External Skill |
| 187 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-parallel-fetching.md` | External Skill |
| 188 | `.claude/skills/external/vercel-agent-skills/react-best-practices/rules/server-serialization.md` | External Skill |
| 189 | `.claude/skills/external/vercel-agent-skills/skills/claude.ai/vercel-deploy-claimable.zip` | External Skill |
| 190 | `.claude/skills/external/vercel-agent-skills/skills/claude.ai/vercel-deploy-claimable/SKILL.md` | External Skill |
| 191 | `.claude/skills/external/vercel-agent-skills/skills/claude.ai/vercel-deploy-claimable/scripts/deploy.sh` | External Skill |
| 192 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/AGENTS.md` | External Skill |
| 193 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/README.md` | External Skill |
| 194 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/SKILL.md` | External Skill |
| 195 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/metadata.json` | External Skill |
| 196 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/_sections.md` | External Skill |
| 197 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/_template.md` | External Skill |
| 198 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/advanced-event-handler-refs.md` | External Skill |
| 199 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/advanced-use-latest.md` | External Skill |
| 200 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-api-routes.md` | External Skill |
| 201 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-defer-await.md` | External Skill |
| 202 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-dependencies.md` | External Skill |
| 203 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-parallel.md` | External Skill |
| 204 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/async-suspense-boundaries.md` | External Skill |
| 205 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-barrel-imports.md` | External Skill |
| 206 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-conditional.md` | External Skill |
| 207 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-defer-third-party.md` | External Skill |
| 208 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-dynamic-imports.md` | External Skill |
| 209 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/bundle-preload.md` | External Skill |
| 210 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/client-event-listeners.md` | External Skill |
| 211 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/client-swr-dedup.md` | External Skill |
| 212 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-batch-dom-css.md` | External Skill |
| 213 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-cache-function-results.md` | External Skill |
| 214 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-cache-property-access.md` | External Skill |
| 215 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-cache-storage.md` | External Skill |
| 216 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-combine-iterations.md` | External Skill |
| 217 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-early-exit.md` | External Skill |
| 218 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-hoist-regexp.md` | External Skill |
| 219 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-index-maps.md` | External Skill |
| 220 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-length-check-first.md` | External Skill |
| 221 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-min-max-loop.md` | External Skill |
| 222 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-set-map-lookups.md` | External Skill |
| 223 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/js-tosorted-immutable.md` | External Skill |
| 224 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-activity.md` | External Skill |
| 225 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-animate-svg-wrapper.md` | External Skill |
| 226 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-conditional-render.md` | External Skill |
| 227 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-content-visibility.md` | External Skill |
| 228 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-hoist-jsx.md` | External Skill |
| 229 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-hydration-no-flicker.md` | External Skill |
| 230 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rendering-svg-precision.md` | External Skill |
| 231 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-defer-reads.md` | External Skill |
| 232 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-dependencies.md` | External Skill |
| 233 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-derived-state.md` | External Skill |
| 234 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-functional-setstate.md` | External Skill |
| 235 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-lazy-state-init.md` | External Skill |
| 236 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-memo.md` | External Skill |
| 237 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/rerender-transitions.md` | External Skill |
| 238 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-after-nonblocking.md` | External Skill |
| 239 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-cache-lru.md` | External Skill |
| 240 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-cache-react.md` | External Skill |
| 241 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-parallel-fetching.md` | External Skill |
| 242 | `.claude/skills/external/vercel-agent-skills/skills/react-best-practices/rules/server-serialization.md` | External Skill |
| 243 | `.claude/skills/external/vercel-agent-skills/skills/web-design-guidelines.zip` | External Skill |
| 244 | `.claude/skills/external/vercel-agent-skills/skills/web-design-guidelines/SKILL.md` | External Skill |
| 245 | `.claude/skills/external/vercel-agent-skills/web-design-guidelines.zip` | External Skill |
| 246 | `.claude/skills/external/vercel-agent-skills/web-design-guidelines/SKILL.md` | External Skill |
| 247 | `.claude/skills/frontend-design/REFERENCE.md` | Core |
| 248 | `.claude/skills/frontend-design/SKILL.md` | Core |
| 249 | `.claude/skills/frontend-design/examples/brutalist-portfolio.tsx` | Core |
| 250 | `.claude/skills/frontend-design/examples/minimalist-dashboard.tsx` | Core |
| 251 | `.claude/skills/frontend-design/examples/warm-landing.tsx` | Core |
| 252 | `.claude/skills/git-master/REFERENCE.md` | Core |
| 253 | `.claude/skills/git-master/SKILL.md` | Core |
| 254 | `.claude/skills/ralph-loop/REFERENCE.md` | Core |
| 255 | `.claude/skills/ralph-loop/SKILL.md` | Core |
| 256 | `.claude/skills/rapid-fix/REFERENCE.md` | Core |
| 257 | `.claude/skills/rapid-fix/SKILL.md` | Core |
| 258 | `.claude/skills/release/REFERENCE.md` | Core |
| 259 | `.claude/skills/release/SKILL.md` | Core |
| 260 | `.claude/skills/review/REFERENCE.md` | Core |
| 261 | `.claude/skills/review/SKILL.md` | Core |
| 262 | `.claude/skills/safe-file-ops/REFERENCE.md` | Core |
| 263 | `.claude/skills/safe-file-ops/SKILL.md` | Core |
| 264 | `.claude/skills/safe-file-ops/examples.md` | Core |
| 265 | `.claude/skills/tdd/REFERENCE.md` | Core |
| 266 | `.claude/skills/tdd/SKILL.md` | Core |
| 267 | `.claude/skills/vibe-coding/REFERENCE.md` | Core |
| 268 | `.claude/skills/vibe-coding/SKILL.md` | Core |
| 269 | `.claude/templates/AGENT.md.template` | Core |
| 270 | `.claude/templates/CLAUDE.local.template.md` | Core |
| 271 | `.claude/templates/CONTEXT-template.md` | Core |
| 272 | `.claude/templates/CONTEXT-tier2.md.template` | Core |
| 273 | `.claude/templates/CONTEXT-tier3.md.template` | Core |
| 274 | `.claude/templates/CONTEXT-usage-guide.md` | Core |
| 275 | `.claude/templates/CONTEXT.md.template` | Core |
| 276 | `.claude/templates/README.md` | Core |
| 277 | `.claude/templates/SKILL.md.template` | Core |
| 278 | `.claude/templates/feature-list.json` | Core |
| 279 | `.claude/templates/gap-checklist.md` | Core |
| 280 | `.claude/templates/init.sh` | Core |
| 281 | `.claude/templates/progress.md` | Core |
| 282 | `.claude/templates/prp-template.md` | Core |
| 283 | `.gitattributes` | Core |
| 284 | `.github/scripts/validate_versions.sh` | Core |
| 285 | `.github/workflows/release.yml` | Core |
| 286 | `.gitignore` | Core |
| 287 | `.pilot/CONTEXT.md` | Runtime State |
| 288 | `.pilot/audit/documentation_audit_report.md` | Runtime State |
| 289 | `.pilot/audit/remaining_issues_report.md` | Runtime State |
| 290 | `.pilot/backup_files.txt` | Runtime State |
| 291 | `.pilot/docs/claude-md-redesign.md` | Runtime State |
| 292 | `.pilot/docs/inventory.md` | Runtime State |
| 293 | `.pilot/docs/progressive-disclosure-plan.md` | Runtime State |
| 294 | `.pilot/docs/standards-mapping.md` | Runtime State |
| 295 | `.pilot/plan/active/.gitkeep` | Runtime State |
| 296 | `.pilot/plan/active/integration-test.txt` | Runtime State |
| 297 | `.pilot/plan/done/.gitkeep` | Runtime State |
| 298 | `.pilot/plan/done/1768716134_fix-plugin-deployment-permissions.md` | Runtime State |
| 299 | `.pilot/plan/done/20250113_200145_claude_pilot_cli.md` | Runtime State |
| 300 | `.pilot/plan/done/20250113_install_sh_backup_cleanup.md` | Runtime State |
| 301 | `.pilot/plan/done/20250115_222942_enhance_plan_context_preservation.md` | Runtime State |
| 302 | `.pilot/plan/done/20250117_213045_gpt_delegation_expansion.md` | Runtime State |
| 303 | `.pilot/plan/done/20250117_213045_gpt_delegation_expansion/coverage-report.txt` | Runtime State |
| 304 | `.pilot/plan/done/20250117_213045_gpt_delegation_expansion/ralph-loop-log.md` | Runtime State |
| 305 | `.pilot/plan/done/20250117_213045_gpt_delegation_expansion/test-scenarios.md` | Runtime State |
| 306 | `.pilot/plan/done/20250118_090000_plugin_release_workflow.md` | Runtime State |
| 307 | `.pilot/plan/done/20250118_delegation_prompt_improvements.md` | Runtime State |
| 308 | `.pilot/plan/done/20250118_plugin_distribution_analysis.md` | Runtime State |
| 309 | `.pilot/plan/done/20250118_sisyphus_continuation_system.md` | Runtime State |
| 310 | `.pilot/plan/done/2026-01-18_frontend-design-skill.md` | Runtime State |
| 311 | `.pilot/plan/done/2026-01-19_command-file-structure-optimization.md` | Runtime State |
| 312 | `.pilot/plan/done/20260113_130619_worktree_wt_option_improvements.md` | Runtime State |
| 313 | `.pilot/plan/done/20260113_150947_review_apply_to_plan.md` | Runtime State |
| 314 | `.pilot/plan/done/20260113_160000_worktree_support.md` | Runtime State |
| 315 | `.pilot/plan/done/20260113_171250_00_plan_implementation_guard/plan.md` | Runtime State |
| 316 | `.pilot/plan/done/20260113_175845_glm_extended_thinking/plan.md` | Runtime State |
| 317 | `.pilot/plan/done/20260113_183913_command_refactoring_with_vibe_coding.md` | Runtime State |
| 318 | `.pilot/plan/done/20260113_190000_workflow_restructure.md` | Runtime State |
| 319 | `.pilot/plan/done/20260113_193928_structure_improvement_ralph_loop/plan.md` | Runtime State |
| 320 | `.pilot/plan/done/20260113_195858_enforce_english_plan_documents/plan.md` | Runtime State |
| 321 | `.pilot/plan/done/20260113_201623_fix_workflow_documentation.md` | Runtime State |
| 322 | `.pilot/plan/done/20260113_212228_moai_style_installation_flow.md` | Runtime State |
| 323 | `.pilot/plan/done/20260113_3tier_documentation_system.md` | Runtime State |
| 324 | `.pilot/plan/done/20260113_curl_install_update.md` | Runtime State |
| 325 | `.pilot/plan/done/20260113_plan_file_structure_and_git_check.md` | Runtime State |
| 326 | `.pilot/plan/done/20260114_115842_ensure_git_commit_cross_repo.md` | Runtime State |
| 327 | `.pilot/plan/done/20260114_131513_slash_command_enhancement.md` | Runtime State |
| 328 | `.pilot/plan/done/20260114_143110_prevent_implementation_rush.md` | Runtime State |
| 329 | `.pilot/plan/done/20260114_152941_update_ux_pypi_check.md` | Runtime State |
| 330 | `.pilot/plan/done/20260114_183640_command_structure_refactoring.md` | Runtime State |
| 331 | `.pilot/plan/done/20260114_191733_enhance_plan_execution_context.md` | Runtime State |
| 332 | `.pilot/plan/done/20260114_203151_skills_agents_3tier_refactor.md` | Runtime State |
| 333 | `.pilot/plan/done/20260114_215100_context_isolation_skills_agents.md` | Runtime State |
| 334 | `.pilot/plan/done/20260114_225647_01_confirm_highlights_extraction.md` | Runtime State |
| 335 | `.pilot/plan/done/20260114_ralph_loop_tdd_prompt_enhancement.md` | Runtime State |
| 336 | `.pilot/plan/done/20260115_060147_parallel_workflow_optimization.md` | Runtime State |
| 337 | `.pilot/plan/done/20260115_090250_agent_usage_optimization.md` | Runtime State |
| 338 | `.pilot/plan/done/20260115_094330_optimize_guide_skill_deduplication.md` | Runtime State |
| 339 | `.pilot/plan/done/20260115_102527_execute_plan_move_priority.md` | Runtime State |
| 340 | `.pilot/plan/done/20260115_112508_legacy_cleanup_and_template_sync.md` | Runtime State |
| 341 | `.pilot/plan/done/20260115_142530_claude_docs_review_and_optimization/.gitkeep` | Runtime State |
| 342 | `.pilot/plan/done/20260115_142530_claude_docs_review_and_optimization/20260115_142530_claude_docs_review_and_optimization.md` | Runtime State |
| 343 | `.pilot/plan/done/20260115_143000_fix_agent_yaml_format.md` | Runtime State |
| 344 | `.pilot/plan/done/20260115_175822_parallel_todo_consistency.md` | Runtime State |
| 345 | `.pilot/plan/done/20260115_194500_agent_error_handling.md` | Runtime State |
| 346 | `.pilot/plan/done/20260115_195021_documentation_enhancement_research.md` | Runtime State |
| 347 | `.pilot/plan/done/20260115_211212_documentation_phase2_refactoring.md` | Runtime State |
| 348 | `.pilot/plan/done/20260115_234419_statusline_pending_count.md` | Runtime State |
| 349 | `.pilot/plan/done/20260115_234419_statusline_pending_count/coverage-report.txt` | Runtime State |
| 350 | `.pilot/plan/done/20260115_234419_statusline_pending_count/ralph-loop-log.md` | Runtime State |
| 351 | `.pilot/plan/done/20260115_234419_statusline_pending_count/test-scenarios.md` | Runtime State |
| 352 | `.pilot/plan/done/20260115_docs_optimization_tdd_enforcement.md` | Runtime State |
| 353 | `.pilot/plan/done/20260115_plan_mode_ambiguous_confirmation_protection.md` | Runtime State |
| 354 | `.pilot/plan/done/20260115_worktree_architecture_fix.md` | Runtime State |
| 355 | `.pilot/plan/done/20260115_worktree_architecture_fix/coverage-report.txt` | Runtime State |
| 356 | `.pilot/plan/done/20260115_worktree_architecture_fix/ralph-loop-log.md` | Runtime State |
| 357 | `.pilot/plan/done/20260115_worktree_architecture_fix/test-scenarios.md` | Runtime State |
| 358 | `.pilot/plan/done/20260116_090342_03_close_git_push_enhancement.md` | Runtime State |
| 359 | `.pilot/plan/done/20260116_093511_user_requirements_tracking_verification.md` | Runtime State |
| 360 | `.pilot/plan/done/20260116_110000_external_skills_sync.md` | Runtime State |
| 361 | `.pilot/plan/done/20260116_213106_auto_apply_reviewer_suggestions.md` | Runtime State |
| 362 | `.pilot/plan/done/20260116_220906_fix_execute_plan_detection.md` | Runtime State |
| 363 | `.pilot/plan/done/20260116_221711_codex_delegator_integration.md` | Runtime State |
| 364 | `.pilot/plan/done/20260116_221711_codex_delegator_integration_artifacts/documentation-update-summary.md` | Runtime State |
| 365 | `.pilot/plan/done/20260116_222500_codex_delegator_integration.md` | Runtime State |
| 366 | `.pilot/plan/done/20260116_222500_codex_delegator_integration/artifacts/coverage-report.txt` | Runtime State |
| 367 | `.pilot/plan/done/20260116_222500_codex_delegator_integration/artifacts/ralph-loop-log.md` | Runtime State |
| 368 | `.pilot/plan/done/20260116_222500_codex_delegator_integration/artifacts/test-scenarios.md` | Runtime State |
| 369 | `.pilot/plan/done/20260116_231701_codex_delegator_source_fix.md` | Runtime State |
| 370 | `.pilot/plan/done/20260116_234359_remove_audit_report.md` | Runtime State |
| 371 | `.pilot/plan/done/20260116_instruction_clarity_improvement.md` | Runtime State |
| 372 | `.pilot/plan/done/20260117_000631_fix_git_push_visibility.md` | Runtime State |
| 373 | `.pilot/plan/done/20260117_004443_fix_hater_deployment_after_claude_pilot_update.md` | Runtime State |
| 374 | `.pilot/plan/done/20260117_013225_gpt_expert_integration_with_commands_and_agents.md` | Runtime State |
| 375 | `.pilot/plan/done/20260117_063116_worktree_close_flow_improvement.md` | Runtime State |
| 376 | `.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4.md` | Runtime State |
| 377 | `.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4/coverage-report.txt` | Runtime State |
| 378 | `.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4/ralph-loop-log.md` | Runtime State |
| 379 | `.pilot/plan/done/20260117_092028_repo_structure_improvement_4_0_4/test-scenarios.md` | Runtime State |
| 380 | `.pilot/plan/done/20260117_100223_ssot_assets_buildhook_and_template_removal.md` | Runtime State |
| 381 | `.pilot/plan/done/20260117_102930_documentation_inconsistency_fixes.md` | Runtime State |
| 382 | `.pilot/plan/done/20260117_105133_deployment_process_audit.md` | Runtime State |
| 383 | `.pilot/plan/done/20260117_121642_gpt_delegation_git_push_enhancement.md` | Runtime State |
| 384 | `.pilot/plan/done/20260117_161348_claude_pilot_docs_concise_first.md` | Runtime State |
| 385 | `.pilot/plan/done/20260117_212451_gpt_delegation_improvements.md` | Runtime State |
| 386 | `.pilot/plan/done/20260117_222637_intelligent_codex_delegation.md` | Runtime State |
| 387 | `.pilot/plan/done/20260117_222637_parallel_execution_improvement.md` | Runtime State |
| 388 | `.pilot/plan/done/20260117_230259_improve_plugin_installation.md` | Runtime State |
| 389 | `.pilot/plan/done/20260117_230643_clone_sample_installation_structure.md` | Runtime State |
| 390 | `.pilot/plan/done/20260117_234749_verify_plugin_structure_and_cleanup.md` | Runtime State |
| 391 | `.pilot/plan/done/20260117_improve_plugin_installation.md` | Runtime State |
| 392 | `.pilot/plan/done/20260117_pure_plugin_migration.md` | Runtime State |
| 393 | `.pilot/plan/done/20260118_150431_sisyphus_continuation_system.md` | Runtime State |
| 394 | `.pilot/plan/done/20260118_150431_sisyphus_continuation_system/ralph-loop-log.md` | Runtime State |
| 395 | `.pilot/plan/done/20260118_150431_sisyphus_continuation_system/test-scenarios.md` | Runtime State |
| 396 | `.pilot/plan/done/20260118_150431_sisyphus_continuation_system_continuation_state.json` | Runtime State |
| 397 | `.pilot/plan/done/20260118_151255_fix_codex_intermittent_detection.md` | Runtime State |
| 398 | `.pilot/plan/done/20260118_223110_documentation_refactoring.md` | Runtime State |
| 399 | `.pilot/plan/done/20260118_235147_fix-cgcode-directory-path.md` | Runtime State |
| 400 | `.pilot/plan/done/20260118_235333_documentation_structure_refactoring.md` | Runtime State |
| 401 | `.pilot/plan/done/20260118_fix_codex_intermittent_detection.md` | Runtime State |
| 402 | `.pilot/plan/done/20260118_fix_worktree_mode.md` | Runtime State |
| 403 | `.pilot/plan/done/20260118_fix_worktree_mode_closed_20260118_173057.md` | Runtime State |
| 404 | `.pilot/plan/done/20260118_github_actions_cicd_integration.md` | Runtime State |
| 405 | `.pilot/plan/done/20260118_github_actions_cicd_integration_tests.md` | Runtime State |
| 406 | `.pilot/plan/done/20260119_165356_fix_path_duplication_and_04_fix_plan_creation.md` | Runtime State |
| 407 | `.pilot/plan/done/20260119_171404_separate_claude_md_from_local.md` | Runtime State |
| 408 | `.pilot/plan/done/20260119_182921_prevent_auto_plan_done.md` | Runtime State |
| 409 | `.pilot/plan/done/20260119_195749_hooks_performance_optimization.md` | Runtime State |
| 410 | `.pilot/plan/done/20260119_195749_hooks_performance_optimization/coverage-report.txt` | Runtime State |
| 411 | `.pilot/plan/done/20260119_195749_hooks_performance_optimization/ralph-loop-log.md` | Runtime State |
| 412 | `.pilot/plan/done/20260119_195749_hooks_performance_optimization/test-scenarios.md` | Runtime State |
| 413 | `.pilot/plan/done/20260119_214151_dead_code_cleanup_command.md` | Runtime State |
| 414 | `.pilot/plan/done/20260119_222853_update_documentation_remove_pypi_add_codex.md` | Runtime State |
| 415 | `.pilot/plan/done/20260119_232207_improve_05_cleanup_auto_apply.md` | Runtime State |
| 416 | `.pilot/plan/done/20260120_021451_command_reorganization.md` | Runtime State |
| 417 | `.pilot/plan/done/20260120_083000_fix_plan_detection_and_statusline.md` | Runtime State |
| 418 | `.pilot/plan/done/20260120_090542_github_seo_optimization.md` | Runtime State |
| 419 | `.pilot/plan/done/20260120_091719_claude_pilot_meta_skill.md` | Runtime State |
| 420 | `.pilot/plan/done/20260120_095501_fix_execute_plan_detection.md` | Runtime State |
| 421 | `.pilot/plan/done/codex-timeout-fix.md` | Runtime State |
| 422 | `.pilot/plan/done/docs-improvement-plan-4.0.3_20260117_055625.md` | Runtime State |
| 423 | `.pilot/plan/done/fix-version-sync-system.md` | Runtime State |
| 424 | `.pilot/plan/done/researcher-agent-case-sensitivity-fix.md` | Runtime State |
| 425 | `.pilot/plan/done/skill-docs-and-parallel-execution.md` | Runtime State |
| 426 | `.pilot/plan/done/skill-docs-and-parallel-execution/implementation-summary.md` | Runtime State |
| 427 | `.pilot/plan/done/skill-docs-and-parallel-execution/verification-log.txt` | Runtime State |
| 428 | `.pilot/plan/draft/20260120_095315_extend_cleanup_dead_documents.md` | Runtime State |
| 429 | `.pilot/plan/pending/.gitkeep` | Runtime State |
| 430 | `.pilot/plan/pending/20260120_095816_git_files_audit_cleanup.md` | Runtime State |
| 431 | `.pilot/scripts/CONTEXT.md` | Runtime State |
| 432 | `.pilot/scripts/state_backup.sh` | Runtime State |
| 433 | `.pilot/scripts/state_read.sh` | Runtime State |
| 434 | `.pilot/scripts/state_write.sh` | Runtime State |
| 435 | `.pilot/state/continuation.json.backup` | Runtime State |
| 436 | `.pilot/state/continuation.json.example` | Runtime State |
| 437 | `.pilot/state/continuation.json.final.backup` | Runtime State |
| 438 | `.pilot/state/continuation.json.lock` | Runtime State |
| 439 | `.pilot/test/continuation_state_test.sh` | Runtime State |
| 440 | `.pilot/test/continue_command_test.sh` | Runtime State |
| 441 | `.pilot/test/integration_test.sh` | Runtime State |
| 442 | `.pilot/tests/CLEANUP_TESTS_SUMMARY.md` | Runtime State |
| 443 | `.pilot/tests/SC1_SUMMARY.md` | Runtime State |
| 444 | `.pilot/tests/cleanup-apply.test.sh` | Runtime State |
| 445 | `.pilot/tests/cleanup-auto.test.sh` | Runtime State |
| 446 | `.pilot/tests/cleanup-ci-apply.test.sh` | Runtime State |
| 447 | `.pilot/tests/cleanup-ci.test.sh` | Runtime State |
| 448 | `.pilot/tests/cleanup-confirm.test.sh` | Runtime State |
| 449 | `.pilot/tests/cleanup-conflict.test.sh` | Runtime State |
| 450 | `.pilot/tests/cleanup-dryrun.test.sh` | Runtime State |
| 451 | `.pilot/tests/cleanup-preflight.test.sh` | Runtime State |
| 452 | `.pilot/tests/cleanup-rollback.test.sh` | Runtime State |
| 453 | `.pilot/tests/cleanup-verify.test.sh` | Runtime State |
| 454 | `.pilot/tests/execute/test_empty_pending.sh` | Runtime State |
| 455 | `.pilot/tests/execute/test_in_progress_selection.sh` | Runtime State |
| 456 | `.pilot/tests/execute/test_multiple_plans.sh` | Runtime State |
| 457 | `.pilot/tests/execute/test_plan_detection.sh` | Runtime State |
| 458 | `.pilot/tests/execute/test_sync_edge_case.sh` | Runtime State |
| 459 | `.pilot/tests/final_verification.sh` | Runtime State |
| 460 | `.pilot/tests/fixtures/test-plan-integration.md` | Runtime State |
| 461 | `.pilot/tests/integration/test-setup-permissions.sh` | Runtime State |
| 462 | `.pilot/tests/sc1_claude_code_standards_audit.md` | Runtime State |
| 463 | `.pilot/tests/test-cache-hit-rate.sh` | Runtime State |
| 464 | `.pilot/tests/test-check-todos-integration.sh` | Runtime State |
| 465 | `.pilot/tests/test-debounce-deterministic.sh` | Runtime State |
| 466 | `.pilot/tests/test-dispatcher-perf.sh` | Runtime State |
| 467 | `.pilot/tests/test-early-exit-process.sh` | Runtime State |
| 468 | `.pilot/tests/test-profile-mode-switch.sh` | Runtime State |
| 469 | `.pilot/tests/test-profiles.sh` | Runtime State |
| 470 | `.pilot/tests/test-stop-no-infinite-loop.sh` | Runtime State |
| 471 | `.pilot/tests/test_00_continue.test.sh` | Runtime State |
| 472 | `.pilot/tests/test_00_plan_delegation.test.sh` | Runtime State |
| 473 | `.pilot/tests/test_01_confirm_delegation.test.sh` | Runtime State |
| 474 | `.pilot/tests/test_91_document_delegation.test.sh` | Runtime State |
| 475 | `.pilot/tests/test_999_skip_gh.sh` | Runtime State |
| 476 | `.pilot/tests/test_all_sc.sh` | Runtime State |
| 477 | `.pilot/tests/test_claude_md_structure.test.sh` | Runtime State |
| 478 | `.pilot/tests/test_close_push_fail.sh` | Runtime State |
| 479 | `.pilot/tests/test_close_worktree_push.sh` | Runtime State |
| 480 | `.pilot/tests/test_close_worktree_push_fail.sh` | Runtime State |
| 481 | `.pilot/tests/test_codex_detection.test.sh` | Runtime State |
| 482 | `.pilot/tests/test_continuation_state.test.sh` | Runtime State |
| 483 | `.pilot/tests/test_debug_mode.test.sh` | Runtime State |
| 484 | `.pilot/tests/test_delegation.test.sh` | Runtime State |
| 485 | `.pilot/tests/test_execute_no_move.sh` | Runtime State |
| 486 | `.pilot/tests/test_execute_status.sh` | Runtime State |
| 487 | `.pilot/tests/test_github_workflow.sh` | Runtime State |
| 488 | `.pilot/tests/test_gitignore_behavior.test.sh` | Runtime State |
| 489 | `.pilot/tests/test_graceful_fallback.test.sh` | Runtime State |
| 490 | `.pilot/tests/test_helpers.sh` | Runtime State |
| 491 | `.pilot/tests/test_no_delegation.test.sh` | Runtime State |
| 492 | `.pilot/tests/test_path_init.test.sh` | Runtime State |
| 493 | `.pilot/tests/test_plan_detection.sh` | Runtime State |
| 494 | `.pilot/tests/test_prompt_warnings.sh` | Runtime State |
| 495 | `.pilot/tests/test_sc1_no_plan_creation.sh` | Runtime State |
| 496 | `.pilot/tests/test_sc1_simple_fix.sh` | Runtime State |
| 497 | `.pilot/tests/test_sc2_draft_save.sh` | Runtime State |
| 498 | `.pilot/tests/test_sc2_multistep_fix.sh` | Runtime State |
| 499 | `.pilot/tests/test_sc3_continuation_support.sh` | Runtime State |
| 500 | `.pilot/tests/test_sc4_scope_validation.sh` | Runtime State |
| 501 | `.pilot/tests/test_sc5_commit_confirmation.sh` | Runtime State |
| 502 | `.pilot/tests/test_sc5_error_messages.sh` | Runtime State |
| 503 | `.pilot/tests/test_sc5_gpt_prioritization.sh` | Runtime State |
| 504 | `.pilot/tests/test_sc5_integration.test.sh` | Runtime State |
| 505 | `.pilot/tests/test_sc6_explicit_close.sh` | Runtime State |
| 506 | `.pilot/tests/test_sc7_final_verification.test.sh` | Runtime State |
| 507 | `.pilot/tests/test_sc7_progressive_disclosure.test.sh` | Runtime State |
| 508 | `.pilot/tests/test_state_recovery.test.sh` | Runtime State |
| 509 | `.pilot/tests/test_statusline.sh` | Runtime State |
| 510 | `.pilot/tests/test_success_criteria.sh` | Runtime State |
| 511 | `.pilot/tests/test_template_creation.test.sh` | Runtime State |
| 512 | `.pilot/tests/test_verify_push.sh` | Runtime State |
| 513 | `.pilot/tests/test_worktree_absolute_paths.sh` | Runtime State |
| 514 | `.pilot/tests/test_worktree_continuation.sh` | Runtime State |
| 515 | `.pilot/tests/test_worktree_create.sh` | Runtime State |
| 516 | `.pilot/tests/test_worktree_cwd_reset.sh` | Runtime State |
| 517 | `.pilot/tests/test_worktree_integration.sh` | Runtime State |
| 518 | `.pilot/tests/test_worktree_persistence.sh` | Runtime State |
| 519 | `.pilot/tests/test_worktree_plan_state.sh` | Runtime State |
| 520 | `.serena/.gitignore` | Core |
| 521 | `.serena/project.yml` | Core |
| 522 | `.tmp` | Backup/Temp |
| 523 | `CHANGELOG.md` | Core |
| 524 | `CLAUDE.md` | Core |
| 525 | `CLAUDE.md.backup` | Backup/Temp |
| 526 | `DOCUMENTATION_IMPROVEMENT_PENDING_ITEMS.md` | Core |
| 527 | `GETTING_STARTED.md` | Core |
| 528 | `LICENSE` | Core |
| 529 | `README.md` | Core |
| 530 | `docs/ai-context/agent-ecosystem.md` | Core |
| 531 | `docs/ai-context/cicd-integration.md` | Core |
| 532 | `docs/ai-context/codex-integration.md` | Core |
| 533 | `docs/ai-context/continuation-system.md` | Core |
| 534 | `docs/ai-context/docs-overview.md` | Core |
| 535 | `docs/ai-context/mcp-servers.md` | Core |
| 536 | `docs/ai-context/plugin-architecture.md` | Core |
| 537 | `docs/ai-context/project-structure.md` | Core |
| 538 | `docs/ai-context/system-integration.md` | Core |
| 539 | `docs/ai-context/testing-quality.md` | Core |
| 540 | `docs/ai-context/worktree-mode-fix-summary.md` | Core |
| 541 | `docs/ai-context/worktree-mode-limitations.md` | Core |
| 542 | `docs/archive/MIGRATION.md` | Core |
| 543 | `docs/migration-guide.md` | Core |
| 544 | `docs/plan-gap-analysis-external-api-calls.md` | Core |
| 545 | `docs/slash-command-enhancement-examples.md` | Core |
| 546 | `examples/README.md` | Core |
| 547 | `examples/minimal-typescript/.claude/scripts/hooks/branch-guard.sh` | Core |
| 548 | `examples/minimal-typescript/.claude/scripts/hooks/check-todos.sh` | Core |
| 549 | `examples/minimal-typescript/.claude/scripts/hooks/lint.sh` | Core |
| 550 | `examples/minimal-typescript/.claude/scripts/hooks/typecheck.sh` | Core |
| 551 | `examples/minimal-typescript/.claude/settings.json` | Core |
| 552 | `examples/minimal-typescript/CLAUDE.md` | Core |
| 553 | `examples/minimal-typescript/README.md` | Core |
| 554 | `mcp.json` | Core |
| 555 | `test-scripts/test-stateless-context.sh` | Core |
| 556 | `test-scripts/test-validation-checklist.sh` | Core |
| 557 | `tests/documentation/claude-md-length.test.sh` | Core |
| 558 | `tests/documentation/code-style-removal.test.sh` | Core |
| 559 | `tests/documentation/content-preservation.test.sh` | Core |
| 560 | `tests/documentation/context-existence.test.sh` | Core |
| 561 | `tests/documentation/cross-refs.test.sh` | Core |

---

## Cleanup Recommendations

### Priority 1: Safe to Remove (151 files)

#### Runtime State (.pilot/) - 137 files
```bash
git rm -r .pilot/
```

#### Duplicate Prefix (.claude-pilot/) - 7 files
```bash
git rm -r .claude-pilot/
```

#### Backup/Temp Files - 7 files
```bash
# Remove backup files
git ls-files | grep -E "(\.backup|\.bak|\.tmp|\.old|\.orig|~)$" | xargs git rm
```

### Priority 2: Review Before Removing

#### External Skills (.claude/skills/external/) - 14 files
- Review each skill for necessity
- Consider updating or removing outdated bundles
- Test plugin functionality after removal

### Priority 3: Update .gitignore

Add these patterns to prevent future tracking:
```gitignore
# Runtime state and plans
.pilot/

# Duplicate prefix
.claude-pilot/

# Backup and temporary files
*.backup
*.bak
*.tmp
*.old
*.orig
*~
```

---

## Verification Steps

1. **Before cleanup**:
   ```bash
   # Create backup branch
   git checkout -b backup-before-cleanup
   
   # Verify file counts
   git ls-files | wc -l  # Should be 561
   ```

2. **After cleanup**:
   ```bash
   # Verify file count reduced
   git ls-files | wc -l  # Should be ~410
   
   # Verify plugin functionality
   ls -la .claude/commands/
   ls -la .claude/agents/
   ```

3. **Test plugin**:
   - Test core commands (/00_plan, /02_execute)
   - Verify all agents load correctly
   - Check skills are accessible

---

## Risk Assessment

| Risk | Level | Mitigation |
|------|-------|------------|
| Breaking plugin functionality | Low | Core .claude/ files unchanged |
| Losing historical plans | Low | Plans are in .pilot/plan/done/, user can archive first |
| Accidental deletion | Low | Review staged changes before commit |
| Re-adding files later | Low | All changes reversible with git |

---

## Next Steps

1. Review this audit report
2. Archive historical plans if needed (copy to docs/archive/plans/)
3. Execute cleanup commands in Priority 1
4. Update .gitignore
5. Test plugin functionality
6. Commit changes with descriptive message

---

**Report End**
