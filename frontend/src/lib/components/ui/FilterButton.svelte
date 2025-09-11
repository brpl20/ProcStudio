<!-- components/ui/FilterButton.svelte -->
<script lang="ts" generics="T extends string | number">
  import Filter from '../../icons/Filter.svelte';
  import Clear from '../../icons/Clear.svelte';
  import Check from '../../icons/Check.svelte';

  export interface FilterOption<T> {
    value: T;
    label: string;
    color?: string;
    icon?: string;
    badgeClass?: string;
  }

  interface Props<T> {
    value?: T;
    options: FilterOption<T>[];
    placeholder?: string;
    clearLabel?: string;
    showAllOption?: boolean;
    allOptionLabel?: string;
    onFilterChange?: (value: T) => void;
  }

  let {
    value = $bindable<T>('all' as T),
    options,
    placeholder = 'Filtrar',
    clearLabel = 'Limpar filtro',
    showAllOption = true,
    allOptionLabel = 'Todas',
    onFilterChange = () => {}
  }: Props<T> = $props();

  let isOpen = $state(false);
  let buttonRef = $state<HTMLButtonElement>();
  let dropdownRef = $state<HTMLDivElement>();

  const allOption: FilterOption<T> = {
    value: 'all' as T,
    label: allOptionLabel,
    color: 'text-base-content'
  };

  const filterOptions = $derived(
    showAllOption ? [allOption, ...options] : options
  );

  const selectedOption = $derived(
    filterOptions.find((opt) => opt.value === value) || filterOptions[0]
  );

  const hasActiveFilter = $derived(value !== ('all' as T));

  function toggleDropdown() {
    isOpen = !isOpen;
  }

  function selectOption(option: FilterOption<T>) {
    value = option.value;
    onFilterChange(option.value);
    isOpen = false;
  }

  function clearFilter() {
    value = 'all' as T;
    onFilterChange('all' as T);
  }

  function handleClickOutside(event: MouseEvent) {
    if (
      buttonRef &&
      dropdownRef &&
      !buttonRef.contains(event.target as Node) &&
      !dropdownRef.contains(event.target as Node)
    ) {
      isOpen = false;
    }
  }

  function handleKeyDown(event: KeyboardEvent) {
    if (event.key === 'Escape') {
      isOpen = false;
    }
  }

  $effect(() => {
    if (isOpen) {
      document.addEventListener('click', handleClickOutside);
      document.addEventListener('keydown', handleKeyDown);
      return () => {
        document.removeEventListener('click', handleClickOutside);
        document.removeEventListener('keydown', handleKeyDown);
      };
    }
  });
</script>

<div class="relative">
  <!-- Filter Button -->
  <button
    bind:this={buttonRef}
    onclick={toggleDropdown}
    class="btn btn-sm gap-2 
           {hasActiveFilter
             ? 'btn-primary btn-outline'
             : 'btn-outline'}
           {isOpen ? 'btn-active' : ''}"
    aria-expanded={isOpen}
    aria-haspopup="listbox"
  >
    <Filter
      className="h-4 w-4 {hasActiveFilter ? 'text-primary' : 'text-base-300'}"
    />
    <span class="font-medium">
      {hasActiveFilter ? selectedOption.label : placeholder}
    </span>
    {#if hasActiveFilter}
      <span
        onclick={(e) => {
          e.stopPropagation();
          clearFilter();
        }}
        class="ml-1 hover:text-primary-focus transition-colors duration-200 cursor-pointer"
        aria-label={clearLabel}
        role="button"
        tabindex="0"
        onkeydown={(e) => {
          if (e.key === 'Enter' || e.key === ' ') {
            e.stopPropagation();
            clearFilter();
          }
        }}
      >
        <Clear className="h-3 w-3" />
      </span>
    {/if}
  </button>

  <!-- Dropdown Menu -->
  {#if isOpen}
    <div
      bind:this={dropdownRef}
      class="absolute top-full left-0 mt-1 w-40 bg-base-100 border border-base-300
             rounded-lg shadow-lg z-50 overflow-hidden"
      role="listbox"
    >
      <div class="py-1">
        {#each filterOptions as option}
          <button
            onclick={() => selectOption(option)}
            class="w-full px-3 py-2 text-sm text-left hover:bg-base-200
                   transition-colors duration-150 flex items-center justify-between
                   {value === option.value ? 'bg-primary/5' : ''}"
            role="option"
            aria-selected={value === option.value}
          >
            <span class="flex items-center gap-2">
              {#if option.badgeClass}
                <span class="{option.badgeClass} badge-sm">
                  {option.label}
                </span>
              {:else}
                <span class="{option.color || 'text-base-content'}">
                  {option.label}
                </span>
              {/if}
            </span>
            {#if value === option.value}
              <Check className="h-4 w-4 text-primary" />
            {/if}
          </button>
        {/each}
      </div>
    </div>
  {/if}
</div>
