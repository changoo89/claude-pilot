# Plan Gap Analysis: External API Calls

> **Case Study**: Complaint Crime Facts GPT Generation Bug (2026-01-14)
> **Project**: Hater Admin

---

## Incident Summary

A critical bug was discovered where the complaint generation feature failed silently. The `crime_facts` section was never populated because the code called a non-existent endpoint (`/hater/analyze`).

### Root Cause

The plan document specified "Call GPT 5.1 for crime_facts" without defining **HOW** the call should be made.

---

## Analysis

### What the Plan Said

**API Flow (Line 325)**:
```
├──▶ Call GPT 5.1 for crime_facts
```

**Execution Plan (Line 380)**:
```
- [ ] Call GPT 5.1 for crime_facts
```

### What Was Missing

| Missing Element | Impact |
|-----------------|--------|
| Endpoint specification | Implementer assumed `/hater/analyze` existed |
| SDK vs HTTP decision | No guidance on OpenAI SDK vs fetch |
| Service boundary | Unclear if Next.js or helper-server should make the call |
| Verification step | No "verify endpoint exists" checkpoint |

### What the Implementer Did

```typescript
// Assumed /hater/analyze existed (it didn't)
const response = await fetch(
  `${process.env.HELPER_SERVER_URL}/hater/analyze`,
  { ... }
);
```

The error was silently caught with `console.error()`, leaving the feature broken without user notification.

---

## Responsibility Distribution

| Party | Responsibility | Reasoning |
|-------|---------------|-----------|
| **Plan Author** | 70% | Vague specification "Call GPT 5.1" without implementation details |
| **Implementer** | 30% | Called non-existent endpoint without verification |

---

## Lessons Learned

### For Plan Authors

1. **Specify the mechanism** for external API calls:
   - Which service makes the call (Next.js API route vs helper-server)
   - SDK usage vs direct HTTP fetch
   - Endpoint path if calling another service

2. **Include verification checkpoints**:
   - "Verify endpoint exists before integration"
   - "Test API call in isolation"

3. **Document dependencies clearly**:
   - New endpoints that need to be created
   - Existing endpoints that will be reused

### For Implementers

1. **Verify external endpoints exist** before writing integration code
2. **Fail loudly** - don't silently catch errors in critical paths
3. **Ask for clarification** when plan is ambiguous about implementation details

---

## Recommended Plan Template Addition

### New Section: External Service Integration

Add this section to plan templates when external APIs are involved:

```markdown
## External Service Integration

### API Calls Required

| Call | From | To | Endpoint | Status |
|------|------|-----|----------|--------|
| GPT Generation | Next.js API | OpenAI | Direct SDK | New |
| PDF Generation | Next.js API | helper-server | /hater/complaints/pdf | Existing |

### New Endpoints to Create

| Endpoint | Service | Purpose | Handler |
|----------|---------|---------|---------|
| (none) | - | - | - |

### Verification Checklist

- [ ] All "Existing" endpoints verified to exist
- [ ] All "New" endpoints have implementation tasks in Execution Plan
- [ ] SDK dependencies added to package.json
- [ ] Environment variables documented
```

---

## Example: Corrected Plan Snippet

### Before (Vague)
```markdown
### Phase 2: GPT Prompt & Backend API
- [ ] Call GPT 5.1 for crime_facts
```

### After (Specific)
```markdown
### Phase 2: GPT Prompt & Backend API
- [ ] Install OpenAI SDK: `npm install openai`
- [ ] Create GPT client utility in `lib/openai.ts`
- [ ] Implement `generateCrimeFacts()` using direct OpenAI API call
  - Model: gpt-5.1 (consistent with helper-server)
  - Timeout: 60s
  - Error handling: Log + update complaint status
- [ ] Verify OPENAI_API_KEY env var exists in .env.local
```

---

## Action Items

1. **Update plan templates** to include "External Service Integration" section
2. **Add verification step** in `/01_confirm` to check for vague external API references
3. **Update `/90_review`** to flag plans with unspecified API call mechanisms

---

## References

- Original Plan: `.pilot/plan/done/20260114_092652_complaint_auto_generation.md`
- Fix Plan: `.pilot/plan/pending/20260114_125058_complaint_crime_facts_gpt_fix.md`
- Bug Location: `lib/api/complaints.ts:generateCrimeFacts()`
