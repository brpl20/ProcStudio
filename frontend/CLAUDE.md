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

```
node ai-tools/structure-analyzer.js
```

frontend: #
ai-docs: #
prompts.md: #
ai-tools: #
structure-analyzer.js: #
public: #
on-boarding.md: #
src: #
assets: #
lib: #
api: #
services: #
auth.service.ts: #
customer.service.ts: #
index.ts: #
job.service.ts: #
law-area.service.ts: #
office.service.ts: #
power.service.ts: #
team.service.ts: #
test.service.ts: #
user.service.ts: #
work.service.ts: #
types: #
auth.types.ts: #
customer.types.ts: #
index.ts: #
job.types.ts: #
law-area.types.ts: #
office.types.ts: #
power.types.ts: #
team.types.ts: #
test.types.ts: #
user.types.ts: #
work.types.ts: #
utils: #
http-client.ts: #
logger.ts: #
config.ts: #
index.ts: #
api-external: #
services: #
cep-service.ts: #
types: #
cep.types.ts: #
api-external-config.ts: #
api-external-index.ts: #
components: #
customers: #
CustomerFilters.svelte: #
CustomerForm.svelte: #
CustomerFormStep1.svelte: #
CustomerFormStep2.svelte: #
CustomerList.svelte: #
CustomerProfileView.svelte: #
forms_commons: #
Address.svelte: #
Bank.svelte: #
Cep.svelte: #
Cnpj.svelte: #
Cpf.svelte: #
Email.svelte: #
Phone.svelte: #
jobs: #
JobList.svelte: #
teams: #
AdvogadosManagement.svelte: #
OfficeForm.svelte: #
OfficeList.svelte: #
OfficeManagement.svelte: #
TeamManagement.svelte: #
TeamMembers.svelte: #
Teams.svelte: #
UserForm.svelte: #
test: #
<!--CepTestForm.svelte: #-->
ui: #
AvatarGroup.svelte: #
ConfirmDialog.svelte: #
FilterButton.svelte: #
FormSection.svelte: #
Pagination.svelte: #
SearchInput.svelte: #
StatusBadge.svelte: #
users: #
UserForm.svelte: #
AuthGuard.svelte: #
AuthLayout.svelte: #
AuthSidebar.svelte: #
Breadcrumbs.svelte: #
ErrorBoundary.svelte: #
Footer.svelte: #
MainLayout.svelte: #
SessionTimeout.svelte: #
TopBar.svelte: #
constants: #
bancos.json: #
bank-account-types.ts: #
brazilian-banks.ts: #
brazilian-states.ts: #
formOptions.ts: #
icons: #
Adjustments.svelte: #
Admin.svelte: #
ArrowLeft.svelte: #
Briefcase.svelte: #
Check.svelte: #
ChevronUp.svelte: #
Clear.svelte: #
Comment.svelte: #
Customer.svelte: #
Dashboard.svelte: #
Default.svelte: #
Error.svelte: #
Filter.svelte: #
Hamburger.svelte: #
Heart.svelte: #
Help.svelte: #
icons-README.md: #
icons.svelte: #
index.js: #
Info.svelte: #
Lightning.svelte: #
Logout.svelte: #
LogoutAlt.svelte: #
Notification.svelte: #
Reports.svelte: #
Search.svelte: #
Settings.svelte: #
Success.svelte: #
Support.svelte: #
Tasks.svelte: #
Teams.svelte: #
Warning.svelte: #
Work.svelte: #
pages: #
AdminPage.svelte: #
CustomerProfilePage.svelte: #
CustomersEditPage.svelte: #
CustomersNewPage.svelte: #
CustomersPage.svelte: #
DashboardPage.svelte: #
JobsPage.svelte: #
LandingPage.svelte: #
LoginPage.svelte: #
ProfileCompletion.svelte: #
ProfileCompletionEnhanced.svelte: #
RegisterPage.svelte: #
ReportsPage.svelte: #
SettingsPage.svelte: #
TeamsPage.svelte: #
UserConfigPage.svelte: #
UserCreatePage.svelte: #
WorksPage.svelte: #
schemas: #
customer-form.ts: #
office-form.ts: #
stores: #
authStore.ts: #
customerStore.ts: #
officeFormStore.ts: #
routerStore.js: #
userProfileStore.ts: #
usersCacheStore.ts: #
userStore.ts: #
validationStore.ts: #
utils: #
cep-address-mapper.ts: #
date.ts: #
form-helpers.ts: #
logo.utils.ts: #
office-form-processor.ts: #
profileCustomerUtils.ts: #
text.ts: #
validation: #
birthDate.ts: #
cep-formatter.ts: #
cep-validator.ts: #
cnpj.ts: #
cpf.ts: #
email.ts: #
index.ts: #
oabValidator.ts: #
password.ts: #
proLabore.ts: #
types.ts: #
ApiTester.svelte: #
AuthLayout.svelte: #
config.js: #
Counter.svelte: #
HomePage.svelte: #
Login.svelte: #
Navigation.svelte: #
Register.svelte: #
UserProfile.svelte: #
App.svelte: #
main.js: #
vite-env.d.ts: #
CLAUDE.md: # AI development instructions
eslint.config.js: #
frontend-libs.md: #
jsconfig.json: #
linter.md: #
package.json: # Project dependencies and scripts
README.md: #
svelte.config.js: #
tailwind.config.js: # Tailwind CSS configuration
tsconfig.json: # TypeScript configuration
tsconfig.node.json: #
vite.config.js: # %

## Development Commands

- When user is using Claude it will always have a server running, if not, ask him to run it the same goes for building, don't run those commands;

## Code Quality

- DRY
- SOLID
- Separation of Concerns
- Minimum code possible to run the app

```bash
npm run lint         # Run ESLint on all files
npm run lint:fix     # Fix auto-fixable ESLint issues
npm run format       # Format code with Prettier
npm run format:check # Check code formatting
npm run check        # Run both lint and format check
```

### Styling

- Don't create components or styles without reading Tailwind or Daisy documentation properly
- **Only use Tailwind CSS with DaisyUI** - no styled-components or other CSS frameworks
- Follow DaisyUI component patterns for consistent UI
- Prefer utility classes over custom CSS

### TypeScript

- All new code must use TypeScript
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

API services are organized by domain in `src/lib/api/services/` with TypeScript interfaces in `src/lib/api/types/`:

#### Core Services

- **`auth.service.ts`** - Authentication, login/logout, session management
- **`user.service.ts`** - User and UserProfile CRUD operations, profile management
- **`customer.service.ts`** - Customer and ProfileCustomer CRUD operations

TODO: FIX THIS!!

<!--### User/UserProfile Integration

After frontend updates affecting Users and UserProfile please run tests:

- /Users/brpl/code/prc_api/docs/tests/User-UserProfile.md

### Customer/ProfileCustomer Integration

After frontend updates affecting Customer and CustomerProfile functionality, please run tests:

```bash
npx mocha ./tests/Customers/customers_test.js --reporter spec
npx mocha ./tests/ProfileCustomers/profile_customers_test.js --reporter spec
```-->

#### Business Domain Services

- **`job.service.ts`** - Job management and workflow operations
- **`work.service.ts`** - Legal work creation and process management
- **`law-area.service.ts`** - Legal area categorization and user customization
- **`power.service.ts`** - Legal powers and authority management for customer representation

#### Organization Services

- **`office.service.ts`** - Law office creation and management
- **`team.service.ts`** - Team structure, member management, and tenant isolation

#### External API Services

- **`cep-service.ts`** - Brazilian postal code (CEP) validation and address lookup

#### Testing & Development

- **`test.service.ts`** - Development and testing utilities

#### Architecture Features

- Centralized HTTP client with request/response logging
- Consistent error handling and response formatting
- TypeScript interfaces for all service contracts
- Environment-based configuration management

## Testing and Validation

- Do not run browser testing, always ask user to verify:
  - Example: Verify if the avatar functionality is now working
- API Tests:
  - Use tool authenticator

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
