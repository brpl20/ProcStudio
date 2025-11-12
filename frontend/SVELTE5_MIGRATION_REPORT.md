# Svelte 5 Migration Report
**Generated**: 2025-11-12
**Status**: In Progress

## Executive Summary
This report identifies all old Svelte syntax patterns across the codebase that need migration to Svelte 5 runes mode. Customer-related files are excluded as they will be refactored separately.

## Migration Statistics

| Pattern | Occurrences | Files | Priority |
|---------|-------------|-------|----------|
| Event Handlers (`on:`) | 69 | 14 | HIGH |
| Reactive Statements (`$:`) | 0 | 0 | N/A (customer files excluded) |
| Console Logs | 32 | 7 | MEDIUM |
| `createEventDispatcher` | 3 | 3 | HIGH |
| `export let` (props) | ~30 | ~30 | MEDIUM |
| `$$restProps`/`$$slots` | 1 | 1 | LOW |

## Detailed Findings

### 1. Event Handlers (`on:`) - 69 occurrences across 14 files

**Old Syntax**: `on:click={handler}`
**New Syntax**: `onclick={handler}`

#### Files to Update:

**High Priority (Auth & Core):**
- `src/lib/components/MainLayout.svelte` - 15 occurrences
- `src/lib/components/AuthSidebar.svelte` - 8 occurrences
- `src/lib/pages/LoginPage.svelte` - 4 occurrences
- `src/lib/pages/RegisterPage.svelte` - 5 occurrences
- `src/lib/pages/LandingPage.svelte` - 11 occurrences

**Medium Priority (Feature Pages):**
- `src/lib/pages/UserConfigPage.svelte` - 4 occurrences
- `src/lib/pages/CustomersPage.svelte` - 2 occurrences

**Teams Components (Partially Done):**
- `src/lib/components/teams/OfficeManagement.svelte` - 5 occurrences
- `src/lib/components/teams/AdvogadosManagement.svelte` - 5 occurrences
- `src/lib/components/teams/TeamManagement.svelte` - 3 occurrences
- `src/lib/components/teams/OfficeList.svelte` - 4 occurrences
- `src/lib/components/teams/TeamMembers.svelte` - 1 occurrence
- `src/lib/components/teams/Teams.svelte` - 1 occurrence

**Other:**
- `src/lib/components/jobs/JobList.svelte` - 1 occurrence

#### Common Patterns Found:
```svelte
<!-- OLD -->
on:click={handler}
on:submit|preventDefault={handler}
on:change={handler}
on:blur={handler}
on:focus={handler}
on:click|preventDefault={handler}

<!-- NEW -->
onclick={handler}
onsubmit={(e) => { e.preventDefault(); handler(e); }}
onchange={handler}
onblur={handler}
onfocus={handler}
onclick={(e) => { e.preventDefault(); handler(e); }}
```

### 2. Console Logs - 32 occurrences across 7 files

**Files with Console Logs:**
- `src/lib/pages/LawyersTestDebugPage.svelte` - 10 occurrences (debug page - keep)
- `src/lib/pages/CustomersNewPage.svelte` - 8 occurrences
- `src/lib/components/teams/OfficeManagement.svelte` - 6 occurrences
- `src/lib/components/forms_offices/PartnerLawyerSelect.svelte` - 5 occurrences
- `src/lib/pages/Office/OfficeCreationPage.svelte` - 1 occurrence
- `src/lib/pages/AdminPage.svelte` - 1 occurrence
- `src/App.svelte` - 1 occurrence

**Action**: Remove debug console logs from production components. Keep only in debug/test pages or convert to proper logging service.

### 3. `createEventDispatcher` - 3 files

**Old Pattern**: Component events using `createEventDispatcher`
**New Pattern**: Callback props using `$props()`

**Files to Update:**
- `src/lib/components/teams/UserDetailView.svelte`
- `src/lib/components/customers/CustomerForm.svelte` (excluded - customer refactor)
- `src/lib/components/customers/CustomerFormStep1.svelte` (excluded - customer refactor)
- `src/lib/components/customers/CustomerProfileView.svelte` (excluded - customer refactor)

#### Migration Pattern:
```svelte
<!-- OLD -->
<script>
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();

  function handleClick() {
    dispatch('confirm', { data: value });
  }
</script>

<!-- NEW -->
<script>
  let { onconfirm = () => {} } = $props();

  function handleClick() {
    onconfirm({ data: value });
  }
</script>
```

### 4. `export let` (Props) - ~30 files

**Old Pattern**: `export let propName`
**New Pattern**: `let { propName } = $props()`

**Files to Update (excluding icons and customer files):**
- `src/lib/pages/User/ProfileCompletion.svelte`
- `src/lib/pages/CustomerProfilePage.svelte`
- `src/lib/pages/CustomersEditPage.svelte`
- `src/lib/Register.svelte`
- `src/lib/HomePage.svelte`
- `src/lib/router/Link.svelte`
- All icon components (34 files) - LOW PRIORITY

**Note**: Icon components can be migrated last as they're simple and isolated.

### 5. `$$restProps` / `$$slots` - 1 file

**File**: `src/lib/router/Link.svelte`

**Old Pattern**: `$$restProps`, `$$slots`
**New Pattern**: `$props()` with rest syntax

```svelte
<!-- OLD -->
<a {...$$restProps}>
  {#if $$slots.default}
    <slot />
  {/if}
</a>

<!-- NEW -->
<script>
  let { children, ...restProps } = $props();
</script>

<a {...restProps}>
  {@render children?.()}
</a>
```

## Migration Priority

### Phase 1: Critical Components ✅ **COMPLETED**
1. ✅ Teams components state management
2. ✅ MainLayout.svelte (15 handlers)
3. ✅ AuthSidebar.svelte (8 handlers)
4. ✅ LoginPage.svelte (4 handlers)
5. ✅ RegisterPage.svelte (5 handlers)
6. ✅ LandingPage.svelte (11 handlers)

**Total: 43 event handlers migrated**
**Commits:**
- `302760a4` - MainLayout & AuthSidebar
- `020203a5` - MainLayout & AuthSidebar
- `32b24aa5` - Login, Register, Landing pages

### Phase 2: Feature Pages (Week 2)
1. UserConfigPage
2. CustomersPage (list only, not forms)
3. JobList component

### Phase 3: Supporting Components (Week 3)
1. UserDetailView (event dispatcher)
2. Link component ($$restProps)
3. Office-related pages

### Phase 4: Low Priority (Week 4)
1. Icon components (bulk update)
2. Debug pages cleanup
3. Console log cleanup

## Risks & Considerations

1. **Event Modifiers**: `on:click|preventDefault` needs careful conversion to explicit `e.preventDefault()`
2. **Event Bubbling**: Ensure event propagation behavior remains consistent
3. **Bind Directives**: Some `bind:` directives may need review
4. **Testing**: Each migrated component should be tested in browser
5. **Store Integration**: Ensure stores work correctly with new reactive system

## Recommended Approach

1. **Migrate by file, not by pattern** - Complete one file at a time to avoid partial states
2. **Test after each file** - Run the app and test the migrated component
3. **Use Playwright** - Automated testing for critical paths
4. **Commit frequently** - Small, atomic commits following Conventional Commits
5. **Update this document** - Check off completed files as we go

## Next Steps

1. Start with MainLayout.svelte (15 event handlers)
2. Then AuthSidebar.svelte (8 event handlers + complex state)
3. Continue with Login/Register pages
4. Update this report after each phase

## Notes

- Customer-related components excluded from this migration
- Icon components can use bulk find/replace safely
- Console logs should be removed or replaced with proper logging
- Each file should be validated with svelte-autofixer after migration
