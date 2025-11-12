<script lang="ts">
  import SearchInput from '../../ui/SearchInput.svelte';
  import FilterButton, { type FilterOption } from '../../ui/FilterButton.svelte';
  import { JOBPRIORITY } from '../../../constants/formOptions';

interface Props {
    searchTerm: string;
    priorityFilter: string;
  }

  let { 
    searchTerm = $bindable(),
    priorityFilter = $bindable()
  }: Props = $props();

  const priorityOptions: FilterOption<string>[] = JOBPRIORITY.map((item) => ({
    value: item.value,
    label: item.label,
    badgeClass: item.badgeClass
  }));

  // Handler para receber mudanças do SearchInput
  function handleSearchChange(value: string) {
    searchTerm = value;
  }
</script>

<div class="mb-4 flex gap-2">
  <SearchInput 
    value={searchTerm}
    onSearchChange={handleSearchChange}
    placeholder="Insira palavras chaves..." 
  />
  
  <FilterButton
    bind:value={priorityFilter}
    options={priorityOptions}
    placeholder="Filtros"
    allOptionLabel="Todas"
    onFilterChange={(value) => priorityFilter = value}
  />
</div>