<!-- components/ui/StatusBadge.svelte -->
<script lang="ts">
  let {
    status = '',
    customClasses = ''
  }: {
    status?: string;
    customClasses?: string;
  } = $props();

  const statusClassMap: Record<string, string> = {
    active: 'badge-success',
    inactive: 'badge-warning',
    deceased: 'badge-neutral',
    confirmed: 'badge-success',
    unconfirmed: 'badge-warning'
  };

  const statusTextMap: Record<string, string> = {
    active: 'Ativo',
    inactive: 'Inativo',
    deceased: 'Falecido',
    confirmed: 'Sim',
    unconfirmed: 'Não'
  };

  let badgeClass = $derived(statusClassMap[status] || 'badge-ghost');
  let displayText = $derived(statusTextMap[status] || status);
</script>

<span class="badge {badgeClass} {customClasses}">
  {displayText}
</span>
