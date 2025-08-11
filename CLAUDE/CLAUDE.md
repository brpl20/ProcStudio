# Repos
Backend: /Users/brpl/code/prc_api
Frontend: /Users/brpl/code/prc_admin-fe
Testing: /Users/brpl/code/prc_api/test

## Description
Backend: Ruby on Rails API
Frontend: React with TypeScript
State Management: Redux Toolkit
API Communication: REST API with JSON serialization
Authentication: JWT token-based auth
Database: PostgreSQL
Background Jobs: Sidekiq with Redis
Testing: RSpec (backend) and Jest/React Testing Library (frontend)
Static Code Analysis: RuboCop, ESLint, TypeScript

## System Requirements
  System Requirements:
  - Ruby 3.1.0 ✓
  - Rails 7.0.4+ ✓
  - PostgreSQL 14+ ✓
  - Bundler 2.5+ ✓

  Key Dependencies:
  - Database: PostgreSQL
  - Authentication: Devise + JWT
  - Authorization: Pundit
  - API Serialization: jsonapi-serializer
  - File Storage: AWS S3
  - Email: Mailjet
  - Document Processing: Prawn (PDF), Docx, Libreconv

  Development Tools:
  - Testing: RSpec 6.0
  - Code Quality: Rubocop
  - Debugging: Pry-byebug
  - Environment: dotenv-rails

### Key Architectural Principles
Service-Oriented Design: Backend organized around domain services
Clean Architecture: Separation of concerns with presenters, services, and repositories
API Versioning: All endpoints versioned for future compatibility
Feature-Based Organization: Frontend code organized by features rather than technology types

# API Endpoints
- Backend: Rails API
- Check at /Users/brpl/code/prc_api/API_ENDPOINTS_2025-08-10.yaml

## Connections Between Front And Back:
It's always important to establish clear communication channels between the frontend and backend teams to ensure smooth collaboration and efficient development. Regular meetings, code reviews, and documentation are essential for maintaining a healthy workflow:

- src/services/api.ts: Axios client with `baseURL` from `NEXT_PUBLIC_SERVER_URL`
- src/services/powers.ts: `/powers`, `/powers/:id`
- src/services/tasks.ts: `/jobs`, `/jobs/:id`, restore/delete variants
- src/services/works.ts: `/works`, `/draft/works`, document upload/convert
- src/services/teams.ts: `/teams`, members, switch, subscriptions, usage
- src/services/offices.ts: `/offices`, `/office_types`
- src/services/admins.ts: `/profile_admins`, `/admins`
- src/services/customers.ts: `/profile_customers`, `/customers`
- src/services/wiki.ts: `/teams/:teamId/wiki_pages*`, `/wiki_categories*`
- src/pages/api/auth/[...nextauth].tsx: direct `fetch` to `${NEXT_PUBLIC_SERVER_URL}/login`
- src/pages/register/index.tsx: `serverApi.post('/profile_admins', ...)`
- src/pages/team-check/index.tsx: `api.get('/profile_admins/me')`
- src/components/ProfileSetupModal/index.tsx: `api.post('/profile_admins')`, `api.post('/offices')`
- src/components/Modals/WorkStatusModal/index.tsx: `api.put('/works/:id')`, `api.post('/work_events')`
- src/components/Details/works/index.tsx: uses `api` for work updates/events

### External APIs
- src/services/zapsign.ts: `/zapsign`
- src/services/brasilAPI.ts: `https://brasilapi.com.br/api/*`
- src/components/ProfileSetupModal/index.tsx: `https://viacep.com.br/ws/*` (CEPlookup)
- src/components/LandingPageSections/PlansSection/index.tsx: `https://api.whatsapp.com/send?...`
- src/components/LandingPageSections/SeventhSection/index.tsx: `https://api.whatsapp.com/send?...`

# Environments
Staging: env.STAGING
Production: env.PRODUCTION

# Architecture
- Backend: Rails API
- Frontend: React App
- Testing: Playwright and Backend Checker

# Coding Best Practices
- Use descriptive variable and function names
- Follow the DRY (Don't Repeat Yourself) principle
- Use comments to explain complex logic
- Use version control (Git) to manage changes

# Testing
- The testing is end-2-end
- Using Playwright and Backend Checker

# Frontend Libraries


## Landing Page
The landing page is a simple page that welcomes the user to the platform and provides a brief overview of the features and benefits of the platform.

# Rails Configs
- Follow general Rails conventions except for seeding

# Seeding and Cleaning
- For seeding use: /Users/brpl/code/prc_api/lib/tasks/
- `rake staging:setup` # this will drop db and create basic seeds
- For other seeds check:
- admin.rake
- customer.rake
- jobs.rake
- office_with_admin.rake
- powers.rake
- seed_works.rake
- office_type.rake
- office.rake
- seed_customers.rake
- staging.rake
- delete_works.rake

# Automations
- auto_annotate_models.rake

# Models
Admins => Basic users of the system, mostly for login;
ProfileAdmin => Where we going to store the user's profile information;
Teams => Where we going to store the user's teams information;
Office => Where we going to store the user's office information;
Customer => Basic users of the system, mostly for login;
ProfileCustomer => Where we going to store the user's profile information;

# Mailer
MailJet: Not used in Dev mode, we will be implemented in Production mode.

### Todays ToDos
- We have a problematic /register method that we must address:
- Right now, the register method is problematic because we are asking for personal information and Team settings;
- But in this moment is not the best moment to ask so many questions, we will ask them later.
- In this moment we will only get his e-mail and password
- The problem is, the Team is always required, so when proceeding to the registration process, we will need to handle this requirement.
- We will need to implement a way to create a team for the user during registration.
- We can set up the user as team leader (think how this is done in the backend)
- And create a mock team for the user during registration, that will be updated when he login in the first time.
- You can check register images here:
  - /Users/brpl/code/prc_admin-fe/images/first.png  # first screen => email, name, last name
  - /Users/brpl/code/prc_admin-fe/images/second.png # second screeen => Team creation with team name and subdomain
- So the output should be an straight and clean register processes
- Use end2end testing to ensure the registration process is working as expected.
- Let me know when you finish the task, tested the output and know that everything is working.
- Dont advance further on the task, keep working only on the first registration process and we will handle the team creation and the user details later.
