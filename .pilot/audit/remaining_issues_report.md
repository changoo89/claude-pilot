# Remaining Issues Report (Autonomous Discovery)

> **Generated**: 2026-01-19  
> **Purpose**: Document all remaining files that exceed size targets

## Summary

While significant progress was made in SC-5, SC-6, and SC-7, several files still exceed size targets.

## Commands Exceeding 300 Lines (Target: ≤300)

| File | Current Lines | Target | Status |
|------|---------------|--------|--------|
| `04_fix.md` | 468 | ≤300 | ⚠️ Needs refactoring |
| `99_continue.md` | 402 | ≤300 | ⚠️ Needs refactoring |
| `90_review.md` | 375 | ≤300 | ⚠️ Needs refactoring |
| `01_confirm.md` | 349 | ≤300 | ⚠️ Needs refactoring |
| `91_document.md` | 319 | ≤300 | ⚠️ Needs refactoring |

## Guides Exceeding 200 Lines (Target: ≤200)

| File | Current Lines | Target | Status |
|------|---------------|--------|--------|
| `intelligent-delegation.md` | 409 | ≤200 | ⚠️ Needs refactoring |
| `continuation-system.md` | 354 | ≤200 | ⚠️ Needs refactoring |
| `3tier-documentation.md` | 297 | ≤200 | ⚠️ Needs refactoring |
| `instruction-clarity.md` | 271 | ≤200 | ⚠️ Needs refactoring |
| `parallel-execution.md` | 265 | ≤200 | ⚠️ Needs refactoring |
| `review-checklist.md` | 258 | ≤200 | ⚠️ Needs refactoring |
| `gap-detection.md` | 255 | ≤200 | ⚠️ Needs refactoring |
| `requirements-verification.md` | 254 | ≤200 | ⚠️ Needs refactoring |
| `prp-framework.md` | 245 | ≤200 | ⚠️ Needs refactoring |

## Docs Exceeding 40KB (Target: ≤40KB)

| File | Current Size | Target | Status |
|------|--------------|--------|--------|
| `system-integration.md` | 65KB | ≤40KB | ⚠️ Needs splitting |

## Priority Ranking

### High Priority (Commands - 300 lines is hard limit)
1. `04_fix.md` (468 lines) - 168 lines over
2. `99_continue.md` (402 lines) - 102 lines over
3. `90_review.md` (375 lines) - 75 lines over
4. `01_confirm.md` (349 lines) - 49 lines over
5. `91_document.md` (319 lines) - 19 lines over

### Medium Priority (Guides - 200 lines is target)
1. `intelligent-delegation.md` (409 lines) - 104% over target
2. `continuation-system.md` (354 lines) - 77% over target
3. `3tier-documentation.md` (297 lines) - 49% over target
4. `instruction-clarity.md` (271 lines) - 36% over target
5. `parallel-execution.md` (265 lines) - 33% over target
6. `review-checklist.md` (258 lines) - 29% over target
7. `gap-detection.md` (255 lines) - 28% over target
8. `requirements-verification.md` (254 lines) - 27% over target
9. `prp-framework.md` (245 lines) - 23% over target

### Low Priority (Docs - Already split, just needs completion)
1. `system-integration.md` (65KB) - Needs final splitting

## Next Steps

1. Refactor all commands exceeding 300 lines
2. Apply progressive disclosure to large guides (SKILL.md ≤75 + REFERENCE.md)
3. Complete system-integration.md splitting
4. Final verification of all files

## Success Criteria

- [ ] All commands ≤300 lines
- [ ] All guides ≤200 lines OR have progressive disclosure (SKILL.md ≤75 + REFERENCE.md)
- [ ] All docs ≤40KB
- [ ] All cross-references working
- [ ] No broken links
