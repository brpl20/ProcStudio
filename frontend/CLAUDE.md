# CLAUDE.md
- TailwindCSS (v4.1.12) - Utility-first CSS framework
- DaisyUI (v5.0.50) - TailwindCSS component library
- @tailwindcss/vite (v4.1.12) - Vite plugin for TailwindCSS
- Svelte (v5.38.1) - Frontend framework
- Vite (v7.1.2) - Build tool and dev server
- @sveltejs/vite-plugin-svelte (v6.1.1) - Svelte plugin for Vite

# ProcStudio Frontend
A Svelte-based frontend for the ProcStudio API, built with modern development tools and integrated with a Rails backend. This is a system for lawyer (our User) management their customers, jobs and workflows.

## Architecture Overview

### Frontend Stack

- **Framework**: Svelte 5 with TypeScript
- **Styling**: Tailwind CSS 4 with DaisyUI components
- **Build Tool**: Vite with custom proxy configuration for API requests
- **State Management**: Svelte stores for:
  - **Authentication**: `authStore` - handles user authentication, login/logout, profile completion
  - **User Management**:
    - `userStore` - user creation and management functionality
    - `userProfileStore` - current user profile with cache integration
    - `usersCacheStore` - centralized cache for user profiles with localStorage persistence
  - **Customer Management**: `customerStore` - comprehensive customer CRUD with filtering and pagination
  - **Form Management**:
    - `validationStore` - reusable form validation system with configurable rules
    - `officeFormStore` - specialized store for office/lawyer form management
  - **Data Architecture**: Stores follow a consistent pattern with loading states, error handling, and derived stores for computed values

### Project Structure
Use ./ai-tools/structure-analyzer.js if you need to check the full project structure.

## Development Commands
- When user is using Claude it will always have a server running, if not, ask him to run it the same goes for building, don't run those commands;

```bash
npm run lint         # Run ESLint on all files
npm run lint:fix     # Fix auto-fixable ESLint issues
npm run format       # Format code with Prettier
npm run format:check # Check code formatting
npm run check        # Run both lint and format check
```

## Code Quality
- DRY
- SOLID
- Separation of Concerns
- Minimum code possible to run the app

### Styling
- Don't create components or styles without reading Tailwind or Daisy documentation properly
- **Only use Tailwind CSS with DaisyUI** - no styled-components or other CSS frameworks
- Follow DaisyUI component patterns for consistent UI
- Prefer utility classes over custom CSS

### TypeScript
- All new and updated code must use TypeScript
- Define interfaces for all API responses in `src/lib/api/types/`
- Use strict type checking
- After creation: check lint for specific code change
- Before commit: check lint for the whole repository
- Use Prettier for consistent formatting
- Write self-documenting code with clear variable names

### Git Workflow
- Never switch branches without explicit authorization
- Follow conventional commit message format
- **Pre-commit**: Automatically runs `npm test` via Husky
- **Lint-staged**: Formats and lints staged files before commit

## API Integration

### Development Proxy
Vite proxy configuration routes `/api/*` requests to `http://localhost:3000` with comprehensive request/response logging for debugging.

### Service Architecture
- API services are organized by domain in `src/lib/api/services/` with TypeScript interfaces in `src/lib/api/types/`:
- Backend is organized like this:
  - controllers: /ProcStudio/api/app/controllers/api/v1/
  - models: /ProcStudio/api/app/models/api/v1/
  - serializers: /ProcStudio/api/app/serializers/api/v1/

#### Core Services
- `index.ts` - centralizer of all services:
- `auth.service.ts` - Authentication, login/logout, session management
  - backend controller: auth_controller.rb
  - backend controller: ../api/app/controllers/api/v1/public/user_registration_controller.rb
  - backend model: user.rb
  - backend serializer: user_serializer.rb, full_user_serializer.rb
- `user.service.ts` - User and UserProfile CRUD operations, profile management
  - backend controller: users_controller.rb
  - backend controller: user_profiles_controller.rb
  - backend controller: current_user_controller.rb
  - backend model: user.rb, user_profile.rb, user_office.rb, user_bank_account.rb, user_email.rb, user_society_compensation.rb
  - backend serializer: user_serializer.rb, user_profile_serializer.rb, full_user_serializer.rb
- `test.service.ts` - test-related operations
  - backend controller: test_controller.rb
- `customer.service.ts` - Customer and ProfileCustomer CRUD operations
  - backend controller: customers_controller.rb
  - backend controller: profile_customers_controller.rb
  - backend controller: represents_controller.rb
  - backend model: customer.rb, profile_customer.rb, represent.rb, team_customer.rb, customer_work.rb, customer_bank_account.rb, customer_email.rb, customer_file.rb
  - backend serializer: customer_serializer.rb, profile_customer_serializer.rb, represent_serializer.rb, customer_work_serializer.rb
- `job.service.ts` - job-related operations
  - backend controller: jobs_controller.rb
  - backend controller: job_comments_controller.rb
  - backend model: job.rb, job_comment.rb, job_work.rb, job_user_profile.rb
  - backend serializer: job_serializer.rb, job_comment_serializer.rb
- `office.service.ts` - office-related operations
  - backend controller: office_types_controller.rb
  - backend controller: offices_controller.rb
  - backend model: office_type.rb, office.rb, user_office.rb, office_work.rb, office_attachment_metadata.rb
  - backend serializer: office_type_serializer.rb, office_serializer.rb, office_with_lawyers_serializer.rb
- `team.service.ts` - team-related operations
  - backend controller: teams_controller.rb
  - backend controller: my_team_controller.rb
  - backend model: team.rb, team_customer.rb
  - backend serializer: team_serializer.rb
  -  Work Related Services:
  - `power.service.ts` - power-related operations
      - backend controller: powers_controller.rb
      - backend model: power.rb, power_work.rb
      - backend serializer: power_serializer.rb
  - `work.service.ts` - work-related operations
    - backend controller: works_controller.rb
    - backend model: work.rb, work_event.rb, work_update.rb, job_work.rb, customer_work.rb, user_profile_work.rb, power_work.rb, office_work.rb
    - backend serializer: work_serializer.rb, work_event_serializer.rb
  - `law-area.service.ts` - law area-related operations
    - backend controller: law_areas_controller.rb
    - backend controller: work_events_controller.rb
    - backend model: law_area.rb, work_event.rb
    - backend serializer: law_area_serializer.rb, work_event_serializer.rb

##### Pending Services Integration
- `draft.service.ts` - draft-related operations
  - backend controller: drafts_controller.rb
  - backend model: draft.rb
- `honorary.service.ts` - honorary-related operations
  - backend controller: honoraries_controller.rb
  - backend controller: honorary_components_controller.rb
  - backend model: honorary.rb, honorary_component.rb
- `legal-cost.service.ts` - legal cost-related operations
  - backend controller: legal_cost_entries_controller.rb
  - backend model: legal_cost_entry.rb, legal_cost.rb
- `notification.service.ts` - notification-related operations
  - backend controller: notifications_controller.rb
  - backend model: notification.rb
  - backend serializer: notification_serializer.rb
- `procedure.service.ts` - procedure-related operations
  - backend controller: procedural_parties_controller.rb
  - backend controller: procedures_controller.rb
  - backend model: procedural_party.rb, procedure.rb
- `zapsign.service.ts` - zapsign integration operations
  - backend controller: zapsign_controller.rb

#### External API Services
- **`cep-service.ts`** - Brazilian postal code (CEP) validation and address lookup

## Documentation and MCP Server Svelte Instructions
When connected to the svelte-llm MCP server, you have access to comprehensive Svelte 5 and SvelteKit documentation. Here's how to use the available tools effectively:

### Available MCP Tools:

#### 1. list_sections
Use this FIRST to discover all available documentation sections. Returns a structured list with titles and paths.
When asked about Svelte or SvelteKit topics, ALWAYS use this tool at the start of the chat to find relevant sections.

#### 2. get_documentation
Retrieves full documentation content for specific sections. Accepts single or multiple sections.
After calling the list_sections tool, you MUST analyze the returned documentation sections and then use the get_documentation tool to fetch ALL documentation sections that are relevant for the users task.

### Documentation Resources

#### Local Documentation
In case you don't find you documentation into MCP server for Svelte, please refer to local documentation:
Reference files in `/frontend/ai-docs/`:
- `svelte-*.txt` - Svelte framework documentation at different detail levels

#### Local Documentationfor CSS and Style (Daisy and Tailwind)
- `daisy.txt` - DaisyUI component reference
- `tailwind.txt` - Tailwind CSS utilities reference

## Testing and Validation
- Do not run browser testing unless you are connected to MCP Playwright;
- Otherwise always ask user to verify changes
  - Example: Verify if the avatar functionality is now working
- API Tests:
  - Use tool authenticator

## Important Constraints
- Follow Svelte 5 best practices and rules;
- Build small and reusable components (atomic components)
- Ask before file creation or decoupling files;
