# Icons System

This document describes how to use the centralized SVG icons system in our Svelte application.

## Overview

Instead of having inline SVG code scattered throughout components, we've centralized all icons in `frontend/src/lib/icons.svelte`. This provides:

- **Cleaner code**: No more huge SVG blocks cluttering your components
- **Consistency**: All icons use the same styling approach
- **Reusability**: Use the same icon across multiple components
- **Maintainability**: Update an icon in one place, it updates everywhere
- **Customization**: Easy to override size, stroke width, and CSS classes

## Usage

### Basic Usage

```svelte
<script>
  import Icon from '../icons.svelte';
</script>

<Icon name="dashboard" />
<Icon name="settings" />
<Icon name="logout" />
```

### With Custom Properties

```svelte
<!-- Custom size -->
<Icon name="dashboard" className="h-8 w-8" />

<!-- Custom stroke width -->
<Icon name="settings" strokeWidth="1" />

<!-- Both custom size and stroke -->
<Icon name="admin" className="h-6 w-6 text-blue-500" strokeWidth="3" />
```

## Available Icons

| Icon Name      | Usage                          | Description                 |
| -------------- | ------------------------------ | --------------------------- |
| `dashboard`    | `<Icon name="dashboard" />`    | Home/dashboard icon         |
| `admin`        | `<Icon name="admin" />`        | Admin/users management icon |
| `settings`     | `<Icon name="settings" />`     | Settings/configuration icon |
| `reports`      | `<Icon name="reports" />`      | Reports/charts icon         |
| `tasks`        | `<Icon name="tasks" />`        | Tasks/checklist icon        |
| `teams`        | `<Icon name="teams" />`        | Teams/groups icon           |
| `logout`       | `<Icon name="logout" />`       | Logout/exit icon            |
| `hamburger`    | `<Icon name="hamburger" />`    | Mobile menu hamburger       |
| `search`       | `<Icon name="search" />`       | Search/magnifying glass     |
| `notification` | `<Icon name="notification" />` | Bell/notification icon      |
| `heart`        | `<Icon name="heart" />`        | Heart/favorite icon         |
| `lightning`    | `<Icon name="lightning" />`    | Lightning/fast icon         |
| `briefcase`    | `<Icon name="briefcase" />`    | Briefcase/work icon         |
| `adjustments`  | `<Icon name="adjustments" />`  | Adjustments/sliders icon    |

## Properties

| Property      | Type     | Default      | Description                      |
| ------------- | -------- | ------------ | -------------------------------- |
| `name`        | `string` | **required** | The name of the icon to display  |
| `className`   | `string` | `'h-5 w-5'`  | CSS classes for styling the icon |
| `strokeWidth` | `string` | `'2'`        | SVG stroke width                 |

## Adding New Icons

To add a new icon:

1. Open `frontend/src/lib/icons.svelte`
2. Add a new `{:else if name === 'your-icon-name'}` block
3. Paste your SVG content, making sure to:
   - Use `class={className}` for the main SVG element
   - Use `stroke-width={strokeWidth}` for stroke-based icons
   - Use `stroke="currentColor"` to inherit text color
4. Add the new icon to the table above

### Example

```svelte
{:else if name === 'new-icon'}
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
  import Icon from '../icons.svelte';
</script>

<Icon name="dashboard" />
```

## Best Practices

1. **Always import the Icon component** at the top of your script block
2. **Use descriptive icon names** that clearly indicate their purpose
3. **Keep default sizing consistent** across similar UI elements
4. **Use Tailwind classes** for custom styling via `className` prop
5. **Test new icons** in both light and dark themes if applicable

## Files Using Icons

The Icon component is currently used in:

- `frontend/src/lib/components/AuthSidebar.svelte`
- `frontend/src/lib/components/AuthenticatedNavbar.svelte`

You can extend this to other components that currently have inline SVGs for better consistency.
