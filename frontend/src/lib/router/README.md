# Improved Router System for Vite + Svelte + Rails

This is an improved routing system specifically designed for your Vite + Svelte frontend with Rails API backend architecture.

## Features

- ✅ **Svelte 5 Runes** - Uses `$state` and `$derived` for reactive routing
- ✅ **Type-Safe Routes** - Full TypeScript support with route typing
- ✅ **Route Guards** - Multiple guard types with backend validation
- ✅ **Lazy Loading** - Support for code-splitting and lazy-loaded components
- ✅ **SPA Navigation** - Automatic link interception for smooth navigation
- ✅ **Security-First** - Backend validation for protected routes

## Usage

### Basic Navigation

```svelte
<script>
  import { router } from '$lib/router/router.svelte';
  import Link from '$lib/router/Link.svelte';
</script>

<!-- Using the Link component -->
<Link href="/dashboard">Dashboard</Link>
<Link href="/customers" activeClass="text-primary">Customers</Link>

<!-- Programmatic navigation -->
<button onclick={() => router.navigate('/settings')}>
  Go to Settings
</button>
```

### Protected Routes

Routes are protected using guards that validate with your Rails backend:

```typescript
// In routes.ts
{
  path: '/admin',
  component: AdminPage,
  guards: [
    guards.auth(),  // Validates token with backend
    guards.roles('admin')  // Checks user roles
  ],
  meta: {
    title: 'Admin Panel',
    requiresAuth: true,
    roles: ['admin']
  }
}
```

### Route Parameters

```svelte
<script>
  import { router } from '$lib/router/router.svelte';
  
  // Access route params
  let params = $derived(router.params);
  let customerId = $derived(params.customerId);
</script>

<!-- Navigate with params -->
<Link href="/customers/profile/123">View Customer</Link>
```

### Guards

Available guards:

1. **AuthGuard** - Validates authentication with backend
2. **GuestGuard** - Ensures user is NOT authenticated
3. **RoleGuard** - Checks user roles
4. **ProfileCompleteGuard** - Ensures profile is complete
5. **ResourceOwnerGuard** - Validates resource ownership
6. **FeatureFlagGuard** - Controls feature access

### Security Features

1. **Backend Validation** - Auth guard validates tokens with Rails API
2. **Session Management** - Automatic logout on invalid tokens
3. **Redirect Protection** - Stores intended destination for post-login
4. **Role-Based Access** - Fine-grained access control

## Migration from Current System

To migrate from your current routing:

1. **Keep your existing App.svelte** as backup
2. **Test the new router** with App-improved.svelte
3. **Update components** to use Link component instead of router.navigate
4. **Add backend validation** endpoints for auth checks

### Example Backend Endpoint (Rails)

```ruby
# app/controllers/api/v1/auth_controller.rb
def validate_session
  if current_user
    render json: { 
      valid: true, 
      user: UserSerializer.new(current_user) 
    }
  else
    render json: { valid: false }, status: :unauthorized
  end
end
```

## Advantages Over Current System

1. **Type Safety** - Full TypeScript support
2. **Better Performance** - Lazy loading and efficient re-renders
3. **Security** - Backend validation for all protected routes
4. **Developer Experience** - Centralized route configuration
5. **Svelte 5 Patterns** - Uses modern runes instead of stores
6. **Maintainability** - Clear separation of concerns

## Testing

```typescript
// Check if user can access route
const canAccess = await canAccessRoute('/admin');

// Check if route is active
const isActive = router.isActive('/dashboard');

// Build URLs with params
const url = router.buildPath('/customers/:id', { id: '123' });
```

## Important Notes

- This router is designed specifically for SPA with Rails API
- Does NOT include SSR (not needed with Rails backend)
- Guards validate with your Rails API for security
- Compatible with your existing authentication flow