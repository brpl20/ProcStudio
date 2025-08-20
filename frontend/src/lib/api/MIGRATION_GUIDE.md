# API Migration Guide

## Overview
The API module has been refactored from a monolithic `api.ts` file to a modular structure following SOLID principles and DRY practices.

## Key Changes

### 1. Admin → User Migration
All references to `Admin` and `ProfileAdmin` have been updated to `User` and `UserProfile`:

**Old:**
```typescript
api.getAdmins()
// Returns AdminsListResponse with AdminData and ProfileAdminData
```

**New:**
```typescript
api.users.getUsers()
// Returns UsersListResponse with UserData and UserProfileData
```

### 2. New Modular Structure

**Old (Single file):**
```typescript
import { api } from './lib/api';

await api.login(email, password);
await api.getAdmins();
await api.getMyTeam();
```

**New (Modular services):**
```typescript
import api from './lib/api';
// or
import { api } from './lib/api';

await api.auth.login(email, password);
await api.users.getUsers();
await api.teams.getMyTeam();
```

### 3. New Services Added

#### Law Areas Service
```typescript
// Get all law areas
await api.lawAreas.getLawAreas();

// Get specific law area
await api.lawAreas.getLawArea(1);

// Create law area
await api.lawAreas.createLawArea({
  law_area: {
    name: 'Civil',
    code: 'civil',
    description: 'Civil Law'
  }
});

// Get main areas only
await api.lawAreas.getMainAreas();

// Get sub areas
await api.lawAreas.getSubAreas(parentId);
```

#### Powers Service
```typescript
// Get all powers
await api.powers.getPowers();

// Get specific power
await api.powers.getPower(1);

// Create power
await api.powers.createPower({
  power: {
    description: 'Represent in court',
    category: 'judicial',
    law_area_id: 1,
    is_base: false
  }
});

// Get base powers
await api.powers.getBasePowers();

// Get powers by category
await api.powers.getPowersByCategory('administrative');

// Get powers by law area
await api.powers.getPowersByLawArea(lawAreaId);
```

## Migration Steps

### Step 1: Update Imports
```typescript
// Old
import { api } from '$lib/api';

// New
import api from '$lib/api';
// Types are now imported separately if needed
import type { UserData, TeamData, LawAreaData, PowerData } from '$lib/api';
```

### Step 2: Update API Calls

| Old Method | New Method |
|------------|------------|
| `api.register()` | `api.auth.register()` |
| `api.login()` | `api.auth.login()` |
| `api.completeProfile()` | `api.auth.completeProfile()` |
| `api.getAdmins()` | `api.users.getUsers()` |
| `api.getMyTeam()` | `api.teams.getMyTeam()` |
| `api.updateTeam()` | `api.teams.updateMyTeam()` |
| `api.getMyTeamMembers()` | `api.teams.getMyTeamMembers()` |

### Step 3: Update Type References

| Old Type | New Type |
|----------|----------|
| `AdminData` | `UserData` |
| `ProfileAdminData` | `UserProfileData` |
| `AdminsListResponse` | `UsersListResponse` |
| `ProfileCompletionData` | `ProfileCompletionData` (unchanged) |

### Step 4: Update Component Props
If your components receive admin/profile data as props:

```typescript
// Old
interface Props {
  admin: AdminData;
  profile: ProfileAdminData;
}

// New
interface Props {
  user: UserData;
  profile: UserProfileData;
}
```

## Benefits of New Structure

1. **Better Organization**: Each service handles its own domain
2. **Type Safety**: Proper TypeScript types for all entities
3. **Maintainability**: Easy to add new endpoints without touching other services
4. **Testability**: Each service can be tested independently
5. **Reusability**: Services can be imported individually where needed
6. **Consistency**: All services follow the same pattern

## Backward Compatibility

The main API object still works with the same import:
```typescript
import { api } from '$lib/api';
```

However, method calls need to be updated to use the service structure:
- `api.auth.xxx()` for authentication
- `api.users.xxx()` for user management
- `api.teams.xxx()` for team management
- `api.lawAreas.xxx()` for law areas
- `api.powers.xxx()` for powers

## Need Help?

If you encounter any issues during migration:
1. Check TypeScript errors - they will guide you to the correct types
2. Refer to the service files in `/src/lib/api/services/`
3. Check the type definitions in `/src/lib/api/types/`