# Slash Command Enhancement - Examples

> **Purpose**: Demonstrate the difference between vague specifications and complete External Service Integration details
> **Context**: These examples show how the enhanced `/00_plan`, `/review`, and `/01_confirm` workflow prevents assumption-based implementation

---

## The Original Problem

### Case Study: Silent `crime_facts` Generation Failure

**Original Plan (Vague)**:
```markdown
## User Requirements
Generate crime_facts for legal complaints using GPT 5.1.

## Execution Plan
1. Call GPT 5.1 for crime_facts
2. Save result to database
```

**What Happened**:
- Implementer assumed `/hater/analyze` endpoint existed (it didn't)
- Error was caught with `console.error()` only - no user notification
- Feature appeared to work but produced no output
- **Responsibility Distribution**: 70% Planner (vague spec), 30% Executor (no verification)

**Review Findings with Enhanced System**:
```
### 🛑 BLOCKING (Must resolve before proceeding)
- **[External API]** API mechanism unspecified - missing SDK/HTTP, endpoint, error handling
  - Location: "Call GPT 5.1 for crime_facts" in Execution Plan
  - Required: Specify SDK package (e.g., `openai@4.x`) or HTTP endpoint (e.g., `POST /api/analyze`)
- **[Error Handling]** Silent error handling detected
  - Location: Plan describes `catch(e) { console.error(e) }` pattern
  - Required: Specify user notification method (toast, status, alert)
```

---

## Example 1: External API Integration

### Bad: Vague "Call API" Specification

```markdown
## Implementation
- Call OpenAI GPT-4 for text analysis
- Return result to frontend
```

**Gap Detection Review Result**:
```
🛑 BLOCKING: External API - API mechanism unspecified
🛑 BLOCKING: Error Handling - No strategy defined
⚠️ Warning: Existing endpoint not verified
```

**Interactive Recovery Questions**:
1. "Which SDK package should be used?" → `openai@4.x`
2. "What's the fallback on API error?" → `Retry 3x, then show error toast`

---

### Good: Complete External Service Integration

```markdown
## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| Text Analysis | Next.js API route | OpenAI | N/A (SDK) | openai@4.x | New | [ ] `npm list openai` |

### Environment Variables Required
| Variable | Service | Status | Verification |
|----------|---------|--------|--------------|
| OPENAI_API_KEY | Next.js | Existing | [ ] In .env.example |

### Error Handling Strategy
| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
| GPT call | Timeout (30s) | Toast + status update | Retry 3x then fail |
| GPT call | API error (401/429) | Toast with message | Fail immediately |

## Implementation Details Matrix

| Task | WHO (Service) | WHAT (Action) | HOW (Mechanism) | VERIFY (Check) |
|------|---------------|---------------|-----------------|----------------|
| Analyze text | Next.js API route | Call GPT-4 | `openai.chat.completions.create()` | SDK installed, API key set |
| Return result | Next.js API route | Serialize response | JSON stringify | Response schema matches |

## Gap Verification Checklist

### External API
- [x] All API calls specify SDK vs HTTP mechanism → SDK: openai@4.x
- [x] All "Existing" endpoints verified via codebase search → N/A (New)
- [x] All "New" endpoints have creation tasks → Task 2.1 in Execution Plan
- [x] Error handling strategy defined → Table above

### Error Handling
- [x] No silent catches → Toast notifications specified
- [x] User notification strategy → Toast for each failure mode
- [x] Graceful degradation paths → Retry logic then fail
```

**Gap Detection Review Result**:
```
✅ PASS - All external service details specified
```

---

## Example 2: Multi-Service Integration

### Bad: Cross-Service Call Without Details

```markdown
## Implementation
- Frontend calls helper-server for PDF generation
- helper-server calls /hater/complaints/pdf endpoint
```

**Gap Detection Review Result**:
```
🛑 BLOCKING: External API - Endpoint /hater/complaints/pdf not verified
🛑 BLOCKING: Database Operation - Save mechanism unspecified
⚠️ Warning: Async Operation - No timeout specified
```

**Interactive Recovery Questions**:
1. "Does /hater/complaints/pdf endpoint exist?" → Search codebase...
2. "How should frontend call helper-server?" → Need to specify
3. "What's the timeout for PDF generation?" → Specify value

---

### Good: Multi-Service Architecture

```markdown
## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| Generate PDF | Frontend | helper-server | POST /api/generate-pdf | HTTP fetch | Existing | [ ] Verified in codebase |
| Complaint data | helper-server | Next.js API | GET /api/complaints/:id | HTTP fetch | Existing | [ ] Verified |
| Save PDF URL | helper-server | Database | Prisma write | Prisma Client | Existing | [ ] Schema has field |

### New Endpoints to Create
| Endpoint | Service | Method | Handler | Request Schema | Response Schema |
|----------|---------|--------|---------|----------------|-----------------|
| /api/generate-pdf | helper-server | POST | generatePdf.ts | { complaintId: string } | { pdfUrl: string } |

### Environment Variables Required
| Variable | Service | Status | Verification |
|----------|---------|--------|--------------|
| PDF_SERVICE_URL | helper-server | Existing | [ ] In .env.example |
| DATABASE_URL | helper-server | Existing | [ ] In .env.example |

### Error Handling Strategy
| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
| PDF generation | Timeout (60s) | Status indicator + error toast | Show "Generation failed" message |
| Database save | Connection error | Error toast | Retry 3x |
| Endpoint call | 404 Not Found | Error toast + redirect | Redirect to complaints list |

## Gap Verification Checklist

### External API
- [x] All API calls specify SDK vs HTTP mechanism → HTTP fetch for all
- [x] All "Existing" endpoints verified → grep confirmed /api/complaints/:id exists
- [x] All "New" endpoints have creation tasks → Task 3.1: Create generatePdf.ts
- [x] Error handling strategy defined → Table above

### Async Operations
- [x] Timeout values specified → 60s for PDF generation
- [x] Concurrent operation limits defined → N/A (single operation)
- [x] Race condition scenarios addressed → N/A (read-only)

### File Operations
- [x] File paths are absolute → PDF_SERVICE_URL is absolute URL
- [x] Cleanup strategy → PDF service handles temp files
```

**Gap Detection Review Result**:
```
✅ PASS - All multi-service integration points specified
```

---

## Example 3: Database Migration

### Bad: Schema Change Without Details

```markdown
## Database Changes
- Add analysis_result column to complaints table
```

**Gap Detection Review Result**:
```
🛑 BLOCKING: Database Operation - Migration file not specified
🛑 BLOCKING: Database Operation - No rollback strategy
⚠️ Warning: Data integrity - No validation checks
```

---

### Good: Complete Migration Plan

```markdown
## External Service Integration

### Database Schema Changes
| Table | Change | Type | Migration File | Rollback |
|-------|--------|------|----------------|----------|
| complaints | Add analysis_result | TEXT | 20250114_add_analysis_result.sql | Drop column |

### Environment Variables Required
| Variable | Service | Status | Verification |
|----------|---------|--------|--------------|
| DATABASE_URL | Next.js | Existing | [ ] Verified |

### Error Handling Strategy
| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
| Migration | Schema conflict | Error log + alert | Manual review required |
| Query | Invalid column type | Error toast | Use null default |

## Gap Verification Checklist

### Database Operations
- [x] Schema changes have migration files specified → 20250114_add_analysis_result.sql
- [x] Rollback strategy documented → Drop column if migration fails
- [x] Data integrity checks included → Validate TEXT type, add null default

### Migration File Content
```sql
-- Migration: 20250114_add_analysis_result.sql
ALTER TABLE complaints ADD COLUMN analysis_result TEXT;

-- Rollback
-- ALTER TABLE complaints DROP COLUMN analysis_result;

-- Validation
-- SELECT COUNT(*) FROM complaints WHERE analysis_result IS NOT NULL;
```
```

**Gap Detection Review Result**:
```
✅ PASS - Database migration fully specified
```

---

## Example 4: Before/After Comparison

### Before: Vague Plan (Original Bug Scenario)

```markdown
# Crime Facts Generation

## User Requirements
Add crime_facts field to complaints using GPT analysis.

## Execution Plan
1. Call GPT 5.1 for crime_facts
2. Save result to complaints table

## Acceptance Criteria
- crime_facts populated after user clicks generate
```

**Review Results**:
```
🛑 BLOCKING: External API (3 issues)
- API mechanism unspecified
- Endpoint not verified
- Error handling missing

🛑 BLOCKING: Database Operation (2 issues)
- Migration file not specified
- Rollback strategy missing

⚠️ Warning: Error Handling
- Silent catch pattern detected
```

---

### After: Complete Plan (Enhanced Workflow)

```markdown
# Crime Facts Generation

## External Service Integration

### API Calls Required
| Call | From | To | Endpoint | SDK/HTTP | Status | Verification |
|------|------|----|----------|----------|--------|--------------|
| Generate crime facts | Next.js API | OpenAI | N/A | openai@4.x | New | [ ] SDK installed |

### Database Schema Changes
| Table | Change | Type | Migration File | Rollback |
|-------|--------|------|----------------|----------|
| complaints | Add crime_facts | TEXT | 20250114_add_crime_facts.sql | Drop column |

### Environment Variables Required
| Variable | Service | Status | Verification |
|----------|---------|--------|--------------|
| OPENAI_API_KEY | Next.js | New | [ ] Add to .env.example |

### Error Handling Strategy
| Operation | Failure Mode | User Notification | Fallback |
|-----------|--------------|-------------------|----------|
| GPT call | Timeout (30s) | Toast + status | Retry 3x |
| GPT call | API error | Toast with error | Show error message |
| DB save | Connection error | Error toast | Retry 3x |

## Gap Verification Checklist

### External API
- [x] SDK specified: openai@4.x
- [x] Error handling: Table above
- [x] Verification: npm list openai

### Database Operations
- [x] Migration file: 20250114_add_crime_facts.sql
- [x] Rollback: Drop column
- [x] Data integrity: TEXT type validated

### Error Handling
- [x] No silent catches: Toast notifications
- [x] User notification: All failure modes covered
- [x] Graceful degradation: Retry logic

## Execution Plan
1. Install openai@4.x SDK
2. Create migration file 20250114_add_crime_facts.sql
3. Add OPENAI_API_KEY to .env.example
4. Implement /api/generate-crime-facts endpoint
5. Add frontend "Generate" button with loading state
6. Test error scenarios (timeout, API error, DB error)
```

**Review Results**:
```
✅ PASS - All gaps resolved
```

---

## Validation Script Example

```bash
#!/bin/bash
# validate-gaps.sh - Automated gap detection verification

echo "=== Gap Detection Validation ==="

# Check external API specifications
echo "1. Checking API specifications..."
grep -q "openai@4.x" plan.md && echo "✅ SDK specified" || echo "🛑 BLOCKING: SDK not specified"

# Check endpoint existence
echo "2. Checking endpoint existence..."
grep -r "/api/generate-crime-facts" --include="*.ts" | grep -q "route" && echo "✅ Endpoint verified" || echo "⚠️ Warning: Endpoint not found"

# Check environment variables
echo "3. Checking environment variables..."
grep -q "OPENAI_API_KEY" .env.example && echo "✅ Env var documented" || echo "🛑 BLOCKING: Env var not in .env.example"

# Check migration files
echo "4. Checking migration files..."
ls migrations/*crime_facts.sql 2>/dev/null && echo "✅ Migration file exists" || echo "🛑 BLOCKING: Migration file missing"

# Check error handling strategy
echo "5. Checking error handling..."
grep -q "Error Handling Strategy" plan.md && echo "✅ Strategy defined" || echo "🛑 BLOCKING: Error handling not specified"

echo "=== Validation Complete ==="
```

---

## Summary

| Aspect | Bad (Vague) | Good (Complete) |
|--------|-------------|-----------------|
| **API Call** | "Call GPT 5.1" | "SDK: openai@4.x, Endpoint: N/A, Timeout: 30s" |
| **Endpoint** | "Call /api/analyze" | "HTTP: POST /api/analyze, Verified: ✅" |
| **Error Handling** | (not specified) | Table with Failure Mode, Notification, Fallback |
| **Database** | "Save to DB" | "Migration: file.sql, Rollback: DROP COLUMN" |
| **Environment** | (not specified) | "VAR_NAME: In .env.example, Status: Existing" |

**Key Takeaway**: The enhanced workflow prevents assumption-based implementation by requiring explicit details for all external service integrations.

---

**Examples Version**: 1.0.0
**Last Updated**: 2026-01-14
