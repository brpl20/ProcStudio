# Linting Rules - ProcStudio Frontend

This document outlines the linting and code formatting rules for the ProcStudio frontend project.

## Overview

The project uses ESLint for code quality and Prettier for code formatting. These tools work together to maintain consistent code style across the entire codebase.

## Tools Used

- **ESLint**: JavaScript/TypeScript linting and code quality
- **Prettier**: Code formatting and style consistency
- **Husky**: Git hooks for automated checks
- **lint-staged**: Run linters on staged files only

## Commands

### Core Commands

```bash
# Run linting checks
npm run lint

# Auto-fix linting issues
npm run lint:fix

# Format code with Prettier
npm run format

# Check code formatting
npm run format:check

# Run both lint and format checks
npm run check
```

### Git Hooks

Pre-commit hooks automatically run via Husky:
- ESLint fix on staged `.js`, `.ts`, `.svelte` files
- Prettier formatting on staged files
- Tests must pass before commit

## ESLint Configuration

### General Rules

- **Indentation**: Handled by Prettier (ESLint indent rule disabled to prevent conflicts)
- **Quotes**: Single quotes preferred
- **Semicolons**: Required
- **Trailing commas**: Not allowed
- **Arrow functions**: Always use parentheses around parameters
- **Object spacing**: Always use spaces inside braces

### TypeScript Rules

- Unused variables starting with `_` are ignored
- Explicit return types not required
- `any` type usage generates warnings
- Non-null assertions generate warnings

### Svelte Rules

- No `@html` tags (warning)
- Unused svelte-ignore comments are errors
- Inner declarations not allowed
- Compilation errors are caught

## Prettier Configuration

```json
{
  "singleQuote": true,
  "trailingComma": "none",
  "printWidth": 100,
  "tabWidth": 2,
  "semi": true,
  "bracketSpacing": true,
  "arrowParens": "always",
  "endOfLine": "lf"
}
```

## Ignored Files

The following files/directories are ignored by ESLint:

- `node_modules/`
- `dist/`
- `.svelte-kit/`
- `build/`
- `*.min.js`
- `vite.config.js`
- Specific problematic files (listed in `eslint.config.js`)

## Troubleshooting

### Common Issues

1. **Indentation errors after commit**: 
   - Run `npm run lint:fix` to auto-fix
   - ESLint indent rule is disabled to prevent conflicts with Prettier

2. **Pre-commit hook failures**:
   - Check that all tests pass: `npm test`
   - Fix linting issues: `npm run lint:fix`
   - Format code: `npm run format`

3. **Conflicting rules between ESLint and Prettier**:
   - ESLint indent rule is disabled
   - Prettier handles all formatting
   - ESLint focuses on code quality, not formatting

### Best Practices

1. **Before committing**:
   ```bash
   npm run check
   ```

2. **If you encounter persistent linting issues**:
   ```bash
   npm run lint:fix
   npm run format
   ```

3. **IDE Integration**:
   - Install ESLint and Prettier extensions
   - Enable format on save
   - Configure auto-fix on save

## Configuration Files

- `eslint.config.js` - ESLint configuration
- `.prettierrc` - Prettier configuration
- `package.json` - lint-staged configuration
- `.husky/pre-commit` - Git hook configuration

## Maintenance

When adding new rules or changing configuration:

1. Test on a small file first
2. Run `npm run lint:fix` on the entire codebase
3. Verify no conflicts between ESLint and Prettier
4. Update this documentation if needed
5. Communicate changes to the team