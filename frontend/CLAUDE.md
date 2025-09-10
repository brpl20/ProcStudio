# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# MCP Server Svelte Instructions

When connected to the svelte-llm MCP server, you have access to comprehensive Svelte 5 and SvelteKit documentation. Here's how to use the available tools effectively:

## Available MCP Tools:

### 1. list_sections

Use this FIRST to discover all available documentation sections. Returns a structured list with titles and paths.
When asked about Svelte or SvelteKit topics, ALWAYS use this tool at the start of the chat to find relevant sections.

### 2. get_documentation

Retrieves full documentation content for specific sections. Accepts single or multiple sections.
After calling the list_sections tool, you MUST analyze the returned documentation sections and then use the get_documentation tool to fetch ALL documentation sections that are relevant for the users task.

# ProcStudio Frontend

A Svelte-based frontend for the ProcStudio API, built with modern development tools and integrated with a Rails backend. This is a system for lawyer (our User) management their customers, jobs and workflows.

## Architecture Overview

### Frontend Stack

- **Framework**: Svelte 5 with TypeScript
- **Styling**: Tailwind CSS 4 with DaisyUI components
- **Build Tool**: Vite with custom proxy configuration for API requests
- **State Management**: Svelte stores for auth, customer data, board management, and routing

### Project Structure

Run Tool for Structure analyzer at ./ai-tools them read ./ai-tools/project-structure.yml

```
node ai-tools/structure-analyzer.js
```

## Development Commands

### Core Development

```bash
npm run dev          # Start development server with hot reload
npm run build        # Build for production
npm run preview      # Preview production build locally
```

### Code Quality

Follow DRY, SOLID, separation of concerns and minimum code possible to run the app.

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
- `CustomerService` - Customer and ProfileCustomer CRUD operations
- `TeamService` - Team management
- `UserService` - User profile operations
- `JobService` - Dedicated to Job CRUD operations
- `LawAreaService` - Dedicated for User experience and customization selecting the best area of scope
- `OfficeService` - To create users offices
- `PowerService` - To relate the powers that the lawyers have to act in behave of their customers
- `TeamService` - The isolation layer to each tenant work with his own structure of teams, members, works and jobs
- `UserService` - To deal with User and UserProfile CRUD
- `WorkService` - The creation of Works, legal process and other related topics

### Test Credentials

```json
{
  "auth": {
    "email": "u2@gmail.com", // you can switch from u2 to u1, to u3
    "password": "123456"
  }
}
```

## Code Conventions

### Styling

- Don't create components or styles without reading Tailwind or Daisy documentation properly
- **Only use Tailwind CSS with DaisyUI** - no styled-components or other CSS frameworks
- Follow DaisyUI component patterns for consistent UI
- Prefer utility classes over custom CSS

### TypeScript

- All new code must use TypeScript
- Define interfaces for all API responses in `src/lib/api/types/`
- Use strict type checking

### Git Workflow

- Never switch branches without explicit authorization
- Follow conventional commit message format

### Code Quality

- After creation: check lint for specific code change
- Before commit: check lint for the whole repository
- Use Prettier for consistent formatting
- Write self-documenting code with clear variable names

## Testing and Validation

### User/UserProfile Integration

After frontend updates affecting Users and UserProfile please run tests:

- /Users/brpl/code/prc_api/docs/tests/User-UserProfile.md

### Customer/ProfileCustomer Integration

After frontend updates affecting Customer and CustomerProfile functionality, please run tests:

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

## Important Constraints

- Follow Svelte 5 best practices and rules;
- Ask before file creation or decoupling files;
