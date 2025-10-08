<!-- components/ui/SearchInput.svelte -->
<script lang="ts">
  import Icon from '../../icons/icons.svelte';

  interface Props {
    value?: string;
    placeholder?: string;
    debounceMs?: number;
    width?: string;
    className?: string;
    onSearchChange?: (value: string) => void;
  }

  const {
    value = $bindable(''),
    placeholder = 'Pesquisar...',
    debounceMs = 200,
    width = 'w-64',
    className = '',
    onSearchChange = () => {}
  }: Props = $props();

  let timer: ReturnType<typeof setTimeout>;
  let localValue = $state(value);
  let isFocused = $state(false);

  function handleInput() {
    clearTimeout(timer);
    timer = setTimeout(() => {
      onSearchChange(localValue);
    }, debounceMs);
  }

  function clearSearch() {
    localValue = '';
    onSearchChange('');
  }

  function handleFocus() {
    isFocused = true;
  }

  function handleBlur() {
    isFocused = false;
  }

  $effect(() => {
    localValue = value;
  });
</script>

<div class="relative {width} {className}">

    <!-- Search Icon -->
    <div class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none z-10">
      <Icon
        name="search"
        className="h-4 w-4 transition-colors duration-200 {isFocused
          ? 'text-primary'
          : 'text-base-300'}"
      />
    </div>

    <!-- Input Field -->
    <input
      type="text"
      bind:value={localValue}
      oninput={handleInput}
      onfocus={handleFocus}
      onblur={handleBlur}
      {placeholder}
      class="input input-bordered input-sm w-full pl-9 {localValue.trim() ? 'pr-9' : 'pr-3'}
             {isFocused ? 'input-primary' : ''}"
    />

    <!-- Clear Button -->
    {#if localValue.trim()}
      <button
        onclick={clearSearch}
        class="absolute inset-y-0 right-0 flex items-center pr-3 hover:text-primary transition-colors duration-200 z-10"
        aria-label="Limpar pesquisa"
        tabindex="-1"
      >
        <Icon name="clear" className="h-4 w-4 text-base-300 hover:text-base-content" />
      </button>
    {/if}
</div>
