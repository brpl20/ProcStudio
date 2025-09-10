# Icons System

This document describes how to use the centralized SVG icons system in our Svelte application.

## Overview

We've implemented a modular icon system where each icon is a separate Svelte component in the `/src/lib/icons/` directory. This provides:

- **Modular structure**: Each icon is its own component for better organization
- **Cleaner code**: No more huge SVG blocks or conditional logic cluttering your components
- **Consistency**: All icons use the same prop interface and styling approach
- **Reusability**: Use the same icon across multiple components
- **Maintainability**: Update an icon in one place, it updates everywhere
- **Tree shaking**: Only used icons are bundled in your final build
- **Customization**: Easy to override size, stroke width, and CSS classes

## Usage

### Method 1: Using the Main Icon Component (Recommended)

```svelte
<script>
  import Icon from '$lib/icons.svelte';
</script>

<Icon name="dashboard" />
<Icon name="settings" />
<Icon name="logout" />
```

### Method 2: Direct Component Imports

For better tree shaking and when you know exactly which icons you need:

```svelte
<script>
  import { Dashboard, Settings, Logout } from '$lib/icons';
  // or import individual components:
  // import Dashboard from '$lib/icons/Dashboard.svelte';
</script>

<Dashboard />
<Settings />
<Logout />
```

### With Custom Properties

Both methods support the same properties:

```svelte
<!-- Using main Icon component -->
<Icon name="dashboard" className="h-8 w-8" />
<Icon name="settings" strokeWidth="1" />
<Icon name="admin" className="h-6 w-6 text-blue-500" strokeWidth="3" />

<!-- Using direct imports -->
<Dashboard className="h-8 w-8" />
<Settings strokeWidth="1" />
<Admin className="h-6 w-6 text-blue-500" strokeWidth="3" />
```

## Available Icons

| Icon Name      | Main Component Usage           | Direct Import Usage | Description                 |
| -------------- | ------------------------------ | ------------------- | --------------------------- |
| `dashboard`    | `<Icon name="dashboard" />`    | `<Dashboard />`     | Home/dashboard icon         |
| `admin`        | `<Icon name="admin" />`        | `<Admin />`         | Admin/users management icon |
| `settings`     | `<Icon name="settings" />`     | `<Settings />`      | Settings/configuration icon |
| `reports`      | `<Icon name="reports" />`      | `<Reports />`       | Reports/charts icon         |
| `tasks`        | `<Icon name="tasks" />`        | `<Tasks />`         | Tasks/checklist icon        |
| `teams`        | `<Icon name="teams" />`        | `<Teams />`         | Teams/groups icon           |
| `logout`       | `<Icon name="logout" />`       | `<Logout />`        | Logout/exit icon            |
| `hamburger`    | `<Icon name="hamburger" />`    | `<Hamburger />`     | Mobile menu hamburger       |
| `search`       | `<Icon name="search" />`       | `<Search />`        | Search/magnifying glass     |
| `notification` | `<Icon name="notification" />` | `<Notification />`  | Bell/notification icon      |
| `heart`        | `<Icon name="heart" />`        | `<Heart />`         | Heart/favorite icon         |
| `lightning`    | `<Icon name="lightning" />`    | `<Lightning />`     | Lightning/fast icon         |
| `briefcase`    | `<Icon name="briefcase" />`    | `<Briefcase />`     | Briefcase/work icon         |
| `adjustments`  | `<Icon name="adjustments" />`  | `<Adjustments />`   | Adjustments/sliders icon    |
| `work`         | `<Icon name="work" />`         | `<Work />`          | Document/work icon          |
| `customer`     | `<Icon name="customer" />`     | `<Customer />`      | User/customer icon          |
| `chevron-up`   | `<Icon name="chevron-up" />`   | `<ChevronUp />`     | Up arrow/chevron            |
| `help`         | `<Icon name="help" />`         | `<Help />`          | Question mark/help icon     |
| `support`      | `<Icon name="support" />`      | `<Support />`       | Chat/support icon           |
| `logout-alt`   | `<Icon name="logout-alt" />`   | `<LogoutAlt />`     | Alternative logout icon     |
| `arrow-left`   | `<Icon name="arrow-left" />`   | `<ArrowLeft />`     | Left arrow icon             |
| `error`        | `<Icon name="error" />`        | `<Error />`         | Error/cross icon            |
| `success`      | `<Icon name="success" />`      | `<Success />`       | Success/checkmark icon      |
| `warning`      | `<Icon name="warning" />`      | `<Warning />`       | Warning/alert icon          |
| `comment`      | `<Icon name="comment" />`      | `<Comment />`       | Comment/chat icon           |

## Properties

| Property      | Type     | Default      | Description                      |
| ------------- | -------- | ------------ | -------------------------------- |
| `name`        | `string` | **required** | The name of the icon to display  |
| `className`   | `string` | `'h-5 w-5'`  | CSS classes for styling the icon |
| `strokeWidth` | `string` | `'2'`        | SVG stroke width                 |

## Adding New Icons

To add a new icon:

1. Create a new Svelte component in `/src/lib/icons/` (e.g., `NewIcon.svelte`)
2. Use the standard icon component template:

   ```svelte
   <script>
     export let className = 'h-5 w-5';
     export let strokeWidth = '2';
   </script>

   <svg
     xmlns="http://www.w3.org/2000/svg"
     class={className}
     fill="none"
     viewBox="0 0 24 24"
     stroke="currentColor"
   >
     <path
       stroke-linecap="round"
       stroke-linejoin="round"
       stroke-width={strokeWidth}
       d="M... your path data here ..."
     />
   </svg>
   ```

3. Export the new icon in `/src/lib/icons/index.js`:
   ```javascript
   export { default as NewIcon } from './NewIcon.svelte';
   ```
4. Add to the iconMap in the same file:
   ```javascript
   export const iconMap = {
     // ... existing icons
     'new-icon': NewIcon
   };
   ```
5. Update the table in this README

### Component Naming Convention

- **File names**: PascalCase (e.g., `ChevronUp.svelte`, `ArrowLeft.svelte`)
- **Icon names**: kebab-case (e.g., `'chevron-up'`, `'arrow-left'`)
- **Export names**: PascalCase matching file names

## Migration from Inline SVGs

### Before (Inline SVG)

```svelte
<svg
  xmlns="http://www.w3.org/2000/svg"
  class="h-5 w-5"
  fill="none"
  viewBox="0 0 24 24"
  stroke="currentColor"
>
  <path
    stroke-linecap="round"
    stroke-linejoin="round"
    stroke-width="2"
    d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
  />
</svg>
```

### After (Icon Component)

```svelte
<script>
  import Icon from '$lib/icons.svelte';
  // or direct import:
  // import { Dashboard } from '$lib/icons';
</script>

<Icon name="dashboard" />
<!-- or direct usage: -->
<!-- <Dashboard /> -->
```

## Best Practices

1. **Choose the right import method**:
   - Use `Icon` component for dynamic icon selection
   - Use direct imports when you know exactly which icons you need (better for tree shaking)
2. **Use descriptive icon names** that clearly indicate their purpose
3. **Keep default sizing consistent** across similar UI elements
4. **Use Tailwind classes** for custom styling via `className` prop
5. **Test new icons** in both light and dark themes if applicable
6. **Follow naming conventions** when adding new icons

## Project Structure

```
src/lib/icons/
├── index.js              # Export barrel and icon mapping
├── Dashboard.svelte      # Individual icon components
├── Admin.svelte
├── Settings.svelte
├── Reports.svelte
├── Tasks.svelte
├── Teams.svelte
├── Logout.svelte
├── Hamburger.svelte
├── Search.svelte
├── Notification.svelte
├── Heart.svelte
├── Lightning.svelte
├── Briefcase.svelte
├── Adjustments.svelte
├── Work.svelte
├── Customer.svelte
├── ChevronUp.svelte
├── Help.svelte
├── Support.svelte
├── LogoutAlt.svelte
├── ArrowLeft.svelte
├── Error.svelte
├── Success.svelte
├── Warning.svelte
├── Comment.svelte
└── Default.svelte        # Fallback icon
```

## Files Using Icons

The Icon component is currently used in:

- `src/lib/components/AuthSidebar.svelte`
- `src/lib/components/AuthenticatedNavbar.svelte`

You can extend this to other components that currently have inline SVGs for better consistency.
