# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# ProcStudio Frontend

A Svelte-based frontend for the ProcStudio API, built with modern development tools and integrated with a Rails backend.

## Architecture Overview

### Frontend Stack
- **Framework**: Svelte 5 with TypeScript
- **Styling**: Tailwind CSS 4 with DaisyUI components
- **Build Tool**: Vite with custom proxy configuration for API requests
- **State Management**: Svelte stores for auth, customer data, board management, and routing

### Project Structure
```
src/
├── lib/
│   ├── api/                 # API client and services layer
│   │   ├── config.ts       # API configuration and endpoints
│   │   ├── services/       # Typed service classes for each domain
│   │   ├── types/          # TypeScript interfaces for API responses
│   │   └── utils/          # HTTP client and logging utilities
│   ├── components/         # Reusable UI components
│   │   ├── board/          # Kanban board components with drag/drop
│   │   ├── customers/      # Customer management forms and lists
│   │   └── ui/            # Generic UI components (dialogs, badges)
│   ├── pages/             # Route-level page components
│   ├── stores/            # Svelte stores for state management
│   ├── utils/             # Helper functions and utilities
│   └── validation/        # Form validation logic (CPF, CNPJ, email)
```

### Key Features
- **Authentication**: JWT-based auth with automatic token refresh
- **Customer Management**: CRUD operations with profile completion workflow
- **Kanban Board**: Drag-and-drop task management system
- **API Integration**: Comprehensive service layer with error handling and logging

## Development Commands

### Core Development
```bash
npm run dev          # Start development server with hot reload
npm run build        # Build for production
npm run preview      # Preview production build locally
```

### Code Quality
```bash
npm run lint         # Run ESLint on all files
npm run lint:fix     # Fix auto-fixable ESLint issues
npm run format       # Format code with Prettier
npm run format:check # Check code formatting
npm run check        # Run both lint and format check
```

### Git Hooks
- **Pre-commit**: Automatically runs `npm test` via Husky
- **Lint-staged**: Formats and lints staged files before commit

## API Integration

### Development Proxy
Vite proxy configuration routes `/api/*` requests to `http://localhost:3000` with comprehensive request/response logging for debugging.

### Service Architecture
Each domain has a dedicated service class in `src/lib/api/services/`:
- `AuthService` - Authentication and user management
- `CustomerService` - Customer CRUD operations
- `TeamService` - Team management
- `UserService` - User profile operations

### Test Credentials
```json
{
  "auth": {
    "email": "u2@gmail.com",
    "password": "123456"
  }
}
```

## Code Conventions

### Styling
- **Only use Tailwind CSS with DaisyUI** - no styled-components or other CSS frameworks
- Follow DaisyUI component patterns for consistent UI
- Prefer utility classes over custom CSS

### TypeScript
- All new code must use TypeScript
- Define interfaces for all API responses in `src/lib/api/types/`
- Use strict type checking

### Git Workflow
- Create feature branches for all new work
- Never switch branches without explicit authorization
- Follow conventional commit message format

### Code Quality
- **Always run linting after code changes** - don't bypass ESLint rules without express authorization
- Use Prettier for consistent formatting
- Write self-documenting code with clear variable names

## Testing and Validation

### Customer/ProfileCustomer Integration
After frontend updates affecting customer functionality, verify backend integration:
```bash
npx mocha ./tests/Customers/customers_test.js --reporter spec
npx mocha ./tests/ProfileCustomers/profile_customers_test.js --reporter spec
```

## Documentation Resources

### Local Documentation
Reference files in `/frontend/ai-docs/`:
- `daisy.txt` - DaisyUI component reference
- `svelte-*.txt` - Svelte framework documentation at different detail levels
- `tailwind.txt` - Tailwind CSS utilities reference

### Reference Projects
- Insights available at: `/Users/brpl/code/SoftOwn_procstudio_admin-fe`

## Important Constraints

- **Never create files** unless absolutely necessary for the requested feature
- **Always prefer editing existing files** over creating new ones
- **No documentation files** should be created proactively (*.md, README)
- **Maintain consistency** with existing code patterns and architecture
