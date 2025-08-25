# RuboCop Complex Metrics Violations Report

Generated: 2025-08-25

## Summary

This report details the complex metric violations in the codebase that require manual refactoring. These violations have been temporarily excluded in `.rubocop_todo.yml` to allow the codebase to pass RuboCop checks.

## Metrics Overview

- **Total Files with Violations**: 32 files
- **Total Violations**: 74 offenses
- **Categories**:
  - ABC Size: 32 violations
  - Method Length: 21 violations  
  - Cyclomatic Complexity: 8 violations
  - Perceived Complexity: 9 violations
  - Parameter Lists: 2 violations

## Critical Files (Multiple Violations)

### 1. `app/controllers/api/v1/auth_controller.rb`
- **Methods with issues**: 3
- **Violations**:
  - `destroy`: ABC Size 21.95/20
  - `build_auth_response`: ABC Size 43/20, Method Length 25/20
  - `check_profile_completeness`: ABC Size 39.23/20, Cyclomatic Complexity 14/10, Perceived Complexity 14/10

### 2. `app/controllers/api/v1/jobs_controller.rb`
- **Methods with issues**: 4
- **Violations**:
  - `create`: ABC Size 22.91/20, Method Length 29/20
  - `destroy`: Method Length 28/20
  - `restore`: Method Length 24/20
  - `assign_users_to_job`: ABC Size 53.09/20, Method Length 44/20, Cyclomatic Complexity 14/10, Perceived Complexity 14/10

### 3. `app/services/profile_customers/simple_procuration_service.rb`
- **Methods with issues**: 4
- **Violations**:
  - `substitute_word`: ABC Size 25.98/20
  - `substitute_client_info`: ABC Size 46.88/20
  - `substitute_justice_agents`: ABC Size 29.17/20, Cyclomatic Complexity 11/10, Perceived Complexity 12/10
  - `responsable`: ABC Size 49.34/20, Method Length 22/20, Cyclomatic Complexity 11/10, Perceived Complexity 12/10

### 4. `app/services/works/base.rb`
- **Methods with issues**: 2
- **Violations**:
  - `responsable_company`: ABC Size 38.17/20
  - `substitute_client_info`: ABC Size 99.34/20 (highest in codebase!), Method Length 30/20, Cyclomatic Complexity 15/10

## Violations by Metric Type

### ABC Size Violations (Assignment, Branch, Condition)
**Limit: 20 | Files: 16**

| File | Method | Score | Severity |
|------|--------|-------|----------|
| `app/services/works/base.rb` | `substitute_client_info` | 99.34 | Critical |
| `app/controllers/api/v1/jobs_controller.rb` | `assign_users_to_job` | 53.09 | High |
| `app/services/profile_customers/simple_procuration_service.rb` | `responsable` | 49.34 | High |
| `app/services/profile_customers/simple_procuration_service.rb` | `substitute_client_info` | 46.88 | High |
| `app/controllers/api/v1/auth_controller.rb` | `build_auth_response` | 43.00 | High |
| `app/controllers/api/v1/auth_controller.rb` | `check_profile_completeness` | 39.23 | High |
| `app/services/works/base.rb` | `responsable_company` | 38.17 | High |
| `app/controllers/api/v1/profile_customers_controller.rb` | `create` | 37.99 | High |
| Others | Various | 20-31 | Medium |

### Method Length Violations
**Limit: 20 lines | Files: 15**

| File | Method | Lines | Priority |
|------|--------|-------|----------|
| `app/controllers/api/v1/jobs_controller.rb` | `assign_users_to_job` | 44 | High |
| `app/controllers/api/v1/profile_customers_controller.rb` | `create` | 39 | High |
| `app/controllers/api/v1/customers_controller.rb` | `create` | 30 | Medium |
| `app/services/works/base.rb` | `substitute_client_info` | 30 | Medium |
| `app/controllers/api/v1/jobs_controller.rb` | `create` | 29 | Medium |
| Others | Various | 21-28 | Low |

### Cyclomatic Complexity Violations
**Limit: 10 | Files: 5**

| File | Method | Score |
|------|--------|-------|
| `app/services/works/base.rb` | `substitute_client_info` | 15 |
| `app/controllers/api/v1/auth_controller.rb` | `check_profile_completeness` | 14 |
| `app/controllers/api/v1/jobs_controller.rb` | `assign_users_to_job` | 14 |
| `app/services/profile_customers/simple_procuration_service.rb` | `substitute_justice_agents` | 11 |
| `app/services/profile_customers/simple_procuration_service.rb` | `responsable` | 11 |

### Parameter Lists Violations
**Limit: 5 parameters | Files: 2**

| File | Method | Parameters |
|------|--------|------------|
| `app/models/draft.rb` | `save_draft` | 6 |
| `app/services/draft_service.rb` | `auto_save` | 6 |

## Refactoring Recommendations

### Priority 1: Critical Complexity (Immediate Action)
1. **`app/services/works/base.rb#substitute_client_info`**
   - ABC Size: 99.34 (5x over limit!)
   - Extract conditional logic into separate methods
   - Consider using a strategy pattern for different client types

2. **`app/controllers/api/v1/jobs_controller.rb#assign_users_to_job`**
   - Multiple violations across all metrics
   - Break down into smaller methods for user assignment logic
   - Extract validation logic

### Priority 2: High Complexity (Next Sprint)
1. **Authentication Controllers**
   - Refactor response building into service objects
   - Extract profile completeness checks into validators

2. **Profile Customer Services**
   - Break down text substitution methods
   - Use template pattern for document generation

### Priority 3: Method Length Issues
- Extract complex conditionals into well-named methods
- Use early returns to reduce nesting
- Consider extracting business logic into service objects

## Recommended Actions

1. **Immediate**: Address critical ABC Size violations over 40
2. **Short-term**: Refactor methods with multiple metric violations
3. **Long-term**: Establish coding standards to prevent future violations
4. **Consider**: Adjusting limits in `.rubocop.yml` if business logic genuinely requires complexity

## Technical Debt Score

Based on the violations:
- **High Priority Debt**: 8 methods (multiple violations)
- **Medium Priority Debt**: 24 methods (single violation over 30% limit)
- **Low Priority Debt**: 42 methods (single violation under 30% limit)

## Notes

- Line length violations (45 occurrences) are excluded from this report as they're formatting issues
- Rails-specific cops and style violations are tracked separately
- Consider using code climate or similar tools for continuous monitoring