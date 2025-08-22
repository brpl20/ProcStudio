# ProcStudio Frontend

## Svelte as Frontend

- Tailwind with DaisyUi only, no styled-components

## API Integration with Rails Backend

### Rails Parameter Wrappers

**IMPORTANT**: Rails expects parameters wrapped with the model name for POST/PUT requests.

**✅ Correct format:**

```javascript
// For Jobs/Tasks
await httpClient.post('/jobs', { job: { title: '...', description: '...' } });
await httpClient.put('/jobs/1', { job: { title: '...' } });

// For Users
await httpClient.post('/users', { user: { email: '...', password: '...' } });

// For Teams
await httpClient.post('/teams', { team: { name: '...', description: '...' } });
```

**❌ Incorrect format:**

```javascript
// This will cause "Unpermitted parameter" errors
await httpClient.post('/jobs', { title: '...', description: '...' });
```

**Exception**: Some endpoints like login don't use wrappers:

```javascript
// Login endpoint accepts direct parameters
await httpClient.post('/login', { email: '...', password: '...' });
```

### Field Mapping Between Frontend and Rails

**IMPORTANT**: Some Rails models use different field names than expected.

**Jobs/Tasks mapping:**

```javascript
// Frontend ➜ Rails
title        ➜ title        ✅
description  ➜ description  ✅
priority     ➜ priority     ✅
assigned_to  ➜ assigned_to  ✅
deadline     ➜ deadline     ✅ (NOT due_date!)
status       ➜ status       ✅ (Required field)
```

**Always include required fields:**

- `status` is required for Jobs (default: 'pending')
- Check Rails model validations for other required fields

### Debugging API Issues

1. Check browser console for `📤 POST Request:` logs (DEBUG_MODE is enabled)
2. Look for Rails logs showing `Unpermitted parameter: :model_name`
3. Check for `nil` values in Rails logs indicating field name mismatches
4. Verify the wrapper structure matches the Rails model name
5. Ensure all required fields are being sent

## Dev environment tips

- npx turbo run where <project_name>
- Check the name field inside each package's package.json to confirm the right name—skip the top-level one.

## Git

- Never switch branchs without user autorization

## Lint and Husky

- Check on the end of each interaction
- Don't bypass linting rules except for with express authorization
