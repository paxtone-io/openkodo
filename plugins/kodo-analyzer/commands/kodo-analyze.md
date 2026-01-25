---
name: kodo-analyze
description: Analyze an existing codebase to infer features, identify gaps, and generate health reports
---

# /kodo analyze - Comprehensive Codebase Analysis

Analyze an existing codebase to infer features, identify gaps, and generate health reports.

## What You Do

When the user runs `/kodo analyze [scope] [flags]`:

1. **Parse Arguments**:
   - `scope` (optional): `full` | `quick` | `database` | `api` | `frontend` | `dependencies` | `analytics` | `docs` | `security` | `performance`
   - `--quick`: Run abbreviated analysis (skip deep scans)
   - `--force`: Re-analyze even if recent analysis exists
   - `--output <dir>`: Custom output directory (default: `./docs/analysis`)

2. **Check Prerequisites**:
   - Look for `.kodo/config.json` in project root
   - If missing, suggest running `kodo init` first or continue with defaults
   - Check if analysis already exists in `./docs/analysis/summary.md`
   - If recent (< 7 days) and no `--force`, ask if user wants to re-run

3. **Prepare Output Directory**:
   ```
   ./docs/analysis/
   ├── summary.md              # Executive summary with health scores
   ├── database/
   │   └── report.md
   ├── api/
   │   └── report.md
   ├── frontend/
   │   └── report.md
   ├── dependencies/
   │   └── report.md
   ├── analytics/
   │   └── report.md
   ├── documentation/
   │   └── report.md
   ├── security/
   │   └── report.md
   └── performance/
       └── report.md
   ```

4. **Run Analysis Based on Scope**:

   ### Full Analysis (default)
   Use the Task tool to spawn all 8 analyzers in parallel:

   **Group 1** (spawn simultaneously):
   ```
   Task (kodo-database-analyzer): Analyze database schema, RLS, indexes
   Task (kodo-api-analyzer): Analyze API endpoints, auth coverage
   Task (kodo-frontend-analyzer): Analyze components, accessibility
   ```

   **Group 2** (spawn simultaneously):
   ```
   Task (kodo-dependencies-analyzer): Check packages, vulnerabilities
   Task (kodo-posthog-analyzer): Analyze event coverage, flags
   Task (kodo-documentation-analyzer): Check docs coverage, accuracy
   ```

   **Group 3** (spawn simultaneously):
   ```
   Task (kodo-security-analyzer): Check security vulnerabilities
   Task (kodo-performance-analyzer): Analyze performance bottlenecks
   ```

   ### Quick Analysis (`--quick`)
   Run abbreviated checks:
   - Glob file counts
   - Surface-level pattern matching
   - Skip deep code tracing
   - Focus on critical issues only

   ### Single Scope (e.g., `database`)
   Only run the specified analyzer.

5. **Aggregate Results**:
   - Collect outputs from all sub-agents
   - Calculate health scores per category (0-100)
   - Calculate weighted overall score
   - Identify cross-cutting concerns
   - Prioritize issues by severity x impact

6. **Generate Reports**:
   - Write individual reports to `./docs/analysis/{category}/report.md`
   - Write executive summary to `./docs/analysis/summary.md`
   - Infer features and populate `./docs/features/` if empty

7. **Store in Kodo Context**:
   - Save analysis snapshot to `.kodo/context/analysis/`
   - Update health score history
   - Track trends over time

8. **Print Summary** to user:
   - Overall health score
   - Critical issues count
   - Top 3 recommendations
   - Links to detailed reports

## Health Score Calculation

| Category | Weight | Key Factors |
|----------|--------|-------------|
| Database | 15% | RLS coverage, index quality, no unused tables |
| API | 15% | Auth coverage, error handling, documentation |
| Frontend | 15% | Accessibility, state coverage, performance |
| Dependencies | 10% | Up-to-date, no vulnerabilities |
| Analytics | 10% | Event coverage, naming consistency |
| Documentation | 10% | Coverage, accuracy, freshness |
| Security | 15% | Auth, validation, secrets management |
| Performance | 10% | Query optimization, bundle size, caching |

Score Interpretation:
- 90-100: Excellent
- 70-89: Good
- 50-69: Fair
- Below 50: Needs Work

## Example Usage

```
User: /kodo analyze
Claude: [runs full analysis, displays summary]

User: /kodo analyze database
Claude: [runs only database analysis]

User: /kodo analyze security
Claude: [runs only security analysis]

User: /kodo analyze --quick
Claude: [runs abbreviated analysis]

User: /kodo analyze --force
Claude: [re-runs full analysis]
```

## Output Example

```markdown
# Codebase Analysis Complete

**Overall Health: 72/100** (Good)

## Health by Category
- Database: 85/100
- API: 78/100
- Frontend: 65/100
- Dependencies: 70/100
- Analytics: 60/100
- Documentation: 55/100
- Security: 80/100
- Performance: 72/100

## Critical Issues (3)
1. Missing RLS on `user_settings` table
2. 2 high-severity dependency vulnerabilities
3. No error handling in `checkout` flow

## Top Recommendations
1. Enable RLS on all tables (impact: high, effort: low)
2. Update axios and lodash for security (impact: high, effort: low)
3. Add error states to checkout components (impact: medium, effort: medium)

## Features Inferred
- User Authentication (docs/features/auth.md)
- Product Catalog (docs/features/products.md)
- Shopping Cart (docs/features/cart.md)
- Checkout Flow (docs/features/checkout.md)

Detailed reports: ./docs/analysis/
```

## Skills to Read

Before executing, read these skills for context:
- `${CLAUDE_PLUGIN_ROOT}/skills/analyzer/SKILL.md` - Analysis methodology
- `${CLAUDE_PLUGIN_ROOT}/skills/analyzer/references/health-scoring.md` - Score calculation
- `${CLAUDE_PLUGIN_ROOT}/skills/analyzer/references/issue-categories.md` - Issue classification

## Configuration

Read from `.kodo/config.json`:
```json
{
  "analyzer": {
    "analyzers": {
      "database": { "enabled": true },
      "api": { "enabled": true },
      "frontend": { "enabled": true },
      "dependencies": { "enabled": true },
      "analytics": { "enabled": true },
      "documentation": { "enabled": true },
      "security": { "enabled": true },
      "performance": { "enabled": true }
    },
    "output": {
      "directory": "./docs/analysis",
      "populateFeatureDocs": true
    },
    "thresholds": {
      "critical": 50,
      "warning": 70
    }
  }
}
```

## Error Handling

- If a sub-agent fails, continue with others
- Mark failed category as "Unable to analyze"
- Include error details in report
- Don't fail entire analysis for single category failure
