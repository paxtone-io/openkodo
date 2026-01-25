# Health Scoring Methodology

## Overview

Health scores quantify codebase quality across categories. Scores range from 0-100 and use weighted averages for the overall score.

## Category Weights

| Category | Weight | Rationale |
|----------|--------|-----------|
| Database | 15% | Core data integrity and security |
| API | 15% | Backend reliability and security |
| Frontend | 15% | User experience and accessibility |
| Dependencies | 10% | Supply chain security |
| Analytics | 10% | Tracking completeness |
| Documentation | 10% | Maintainability |
| Security | 15% | Application security posture |
| Performance | 10% | Speed and efficiency |

## Score Calculation

### Overall Score
```
overall = Sum(category_score x category_weight)
```

### Category Scores

Each category uses specific metrics:

#### Database Score (0-100)
```
database_score = (
  rls_coverage x 0.35 +
  index_quality x 0.20 +
  no_unused x 0.15 +
  relationships x 0.15 +
  migration_health x 0.15
)
```

| Metric | How Measured |
|--------|--------------|
| rls_coverage | % tables with RLS enabled |
| index_quality | Foreign keys indexed, query patterns covered |
| no_unused | 100 - (unused_tables + unused_columns) / total |
| relationships | Foreign keys defined, no orphans |
| migration_health | Sequential, reversible, documented |

#### API Score (0-100)
```
api_score = (
  auth_coverage x 0.30 +
  error_handling x 0.25 +
  documentation x 0.20 +
  consistency x 0.15 +
  performance x 0.10
)
```

| Metric | How Measured |
|--------|--------------|
| auth_coverage | % endpoints with auth protection |
| error_handling | try/catch, error responses |
| documentation | JSDoc, OpenAPI, README |
| consistency | Naming, response formats |
| performance | N+1 queries, caching |

#### Frontend Score (0-100)
```
frontend_score = (
  accessibility x 0.30 +
  state_coverage x 0.25 +
  component_quality x 0.20 +
  performance x 0.15 +
  consistency x 0.10
)
```

| Metric | How Measured |
|--------|--------------|
| accessibility | ARIA, keyboard nav, contrast |
| state_coverage | Loading, error, empty states |
| component_quality | Props typed, documented |
| performance | Memoization, lazy loading |
| consistency | Design token usage |

#### Dependencies Score (0-100)
```
dependencies_score = (
  no_vulnerabilities x 0.40 +
  freshness x 0.30 +
  no_deprecated x 0.15 +
  no_unused x 0.15
)
```

| Metric | How Measured |
|--------|--------------|
| no_vulnerabilities | 100 - (critical x 20 + high x 10 + medium x 5) |
| freshness | % packages up to date |
| no_deprecated | % packages not deprecated |
| no_unused | % packages actually imported |

#### Analytics Score (0-100)
```
analytics_score = (
  event_coverage x 0.35 +
  naming_consistency x 0.25 +
  property_completeness x 0.20 +
  flag_hygiene x 0.20
)
```

| Metric | How Measured |
|--------|--------------|
| event_coverage | Key actions tracked |
| naming_consistency | Follows convention |
| property_completeness | Required props included |
| flag_hygiene | No stale flags |

#### Documentation Score (0-100)
```
docs_score = (
  coverage x 0.35 +
  accuracy x 0.30 +
  freshness x 0.20 +
  quality x 0.15
)
```

| Metric | How Measured |
|--------|--------------|
| coverage | Features documented |
| accuracy | Matches current code |
| freshness | Updated within 90 days |
| quality | Structure, examples |

#### Security Score (0-100)
```
security_score = (
  auth_patterns x 0.30 +
  input_validation x 0.25 +
  secrets_management x 0.20 +
  dependency_security x 0.15 +
  config_security x 0.10
)
```

| Metric | How Measured |
|--------|--------------|
| auth_patterns | JWT validation, session handling |
| input_validation | SQL injection, XSS prevention |
| secrets_management | No hardcoded secrets, env vars |
| dependency_security | No known CVEs |
| config_security | CORS, rate limiting |

#### Performance Score (0-100)
```
performance_score = (
  query_efficiency x 0.30 +
  bundle_optimization x 0.25 +
  caching_strategy x 0.20 +
  render_performance x 0.15 +
  asset_optimization x 0.10
)
```

| Metric | How Measured |
|--------|--------------|
| query_efficiency | No N+1, proper indexes |
| bundle_optimization | Code splitting, tree shaking |
| caching_strategy | API caching, static assets |
| render_performance | Memoization, virtualization |
| asset_optimization | Image compression, lazy loading |

## Score Interpretation

| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Excellent | Minor improvements only |
| 80-89 | Very Good | Well-maintained, few issues |
| 70-79 | Good | Some areas need attention |
| 60-69 | Fair | Multiple issues to address |
| 50-59 | Needs Work | Significant improvements needed |
| Below 50 | Poor | Critical issues, prioritize fixes |

## Trend Tracking

Track scores over time:
- Weekly quick analysis
- Monthly full analysis
- Pre/post refactoring
- Before major releases

Store trends in `.kodo/context/analysis/`:
```json
{
  "history": [
    { "date": "2024-01-15", "overall": 72, "security": 80, "database": 75 },
    { "date": "2024-01-22", "overall": 75, "security": 82, "database": 78 }
  ]
}
```

## Caveats

1. **Scores are relative** - 100 doesn't mean perfect
2. **Context matters** - Early projects score lower
3. **Some issues matter more** - Critical > many minor
4. **Not all apply** - Skip irrelevant categories
