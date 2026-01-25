# Issue Categories and Severity

## Severity Levels

### Critical (Must Fix Immediately)
Issues that pose immediate security or data integrity risks.

**Examples:**
- SQL injection vulnerabilities
- Missing authentication on sensitive endpoints
- Exposed secrets/credentials
- RLS bypass vulnerabilities
- Unencrypted sensitive data
- Remote code execution risks

**Action:** Stop development, fix immediately.

### High (Should Fix Soon)
Issues that significantly impact functionality, security, or user experience.

**Examples:**
- Missing RLS policies on data tables
- Unprotected API endpoints
- Authentication token mishandling
- Accessibility violations (WCAG A)
- Critical dependency vulnerabilities
- Data validation bypass
- Missing error handling in critical flows

**Action:** Fix within current sprint.

### Medium (Plan to Fix)
Issues that affect code quality, performance, or maintainability.

**Examples:**
- Outdated dependencies (non-security)
- Missing loading/error states
- Performance bottlenecks
- Code duplication
- Missing TypeScript types
- Incomplete documentation
- Analytics event gaps

**Action:** Add to backlog, fix within 2-4 weeks.

### Low (Nice to Have)
Minor improvements that enhance consistency or follow best practices.

**Examples:**
- Naming convention inconsistencies
- Missing JSDoc comments
- Minor accessibility improvements
- Unused imports
- Suboptimal code patterns
- Missing tests for edge cases

**Action:** Fix opportunistically.

## Category-Specific Issues

### Database Issues
| Severity | Issue Type |
|----------|------------|
| Critical | RLS bypass, SQL injection |
| High | Missing RLS, no auth checks |
| Medium | Missing indexes, unused tables |
| Low | Naming inconsistencies |

### API Issues
| Severity | Issue Type |
|----------|------------|
| Critical | Auth bypass, data exposure |
| High | Missing auth, no error handling |
| Medium | Missing documentation, N+1 queries |
| Low | Inconsistent response formats |

### Frontend Issues
| Severity | Issue Type |
|----------|------------|
| Critical | XSS vulnerabilities |
| High | Missing accessibility, no error states |
| Medium | Performance issues, missing loading states |
| Low | UI inconsistencies, missing memoization |

### Dependencies Issues
| Severity | Issue Type |
|----------|------------|
| Critical | Known exploited CVEs |
| High | High-severity CVEs, deprecated with security issues |
| Medium | Outdated packages, deprecated packages |
| Low | Unused dependencies, suboptimal alternatives |

### Analytics Issues
| Severity | Issue Type |
|----------|------------|
| Critical | PII in events |
| High | Missing critical event tracking |
| Medium | Inconsistent naming, stale flags |
| Low | Missing optional properties |

### Documentation Issues
| Severity | Issue Type |
|----------|------------|
| Critical | Documented security misconfigurations |
| High | Missing setup/deployment docs |
| Medium | Stale documentation, missing features |
| Low | Formatting inconsistencies |

### Security Issues
| Severity | Issue Type |
|----------|------------|
| Critical | Auth bypass, injection vulnerabilities, exposed secrets |
| High | Weak auth patterns, missing validation, CORS misconfiguration |
| Medium | Missing rate limiting, insufficient logging |
| Low | Minor security headers missing |

### Performance Issues
| Severity | Issue Type |
|----------|------------|
| Critical | Memory leaks, blocking operations |
| High | N+1 queries, large bundle sizes |
| Medium | Missing caching, unoptimized images |
| Low | Minor render optimizations |

## Issue Template

```markdown
### [SEVERITY] Issue Title

**Category**: Database | API | Frontend | Dependencies | Analytics | Docs | Security | Performance
**Confidence**: XX%
**File**: path/to/file.ts:line

**Problem**:
Clear description of what's wrong.

**Evidence**:
Why we know this is an issue.

**Risk**:
What could happen if not fixed.

**Fix**:
```typescript
// Code example of the fix
```

**Effort**: Low | Medium | High
**Impact**: Low | Medium | High
```

## Prioritization Matrix

| | High Impact | Medium Impact | Low Impact |
|---|-------------|---------------|------------|
| **Low Effort** | Do First | Do Second | Quick Wins |
| **Medium Effort** | Do Second | Backlog | Defer |
| **High Effort** | Plan Carefully | Defer | Skip |

## Reporting Guidelines

1. **Be specific** - Include file paths and line numbers
2. **Provide evidence** - Show why it's an issue
3. **Suggest fixes** - Include code examples when possible
4. **Estimate effort** - Help with prioritization
5. **Consider context** - Not all issues apply equally
