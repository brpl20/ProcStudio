<!-- components/ui/StatusBadge.svelte -->
<script lang="ts">
  export let status: string = '';
  export let customClasses: string = '';

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

  const badgeClass = statusClassMap[status] || 'badge-ghost';
  const displayText = statusTextMap[status] || status;
</script>

<span class="badge {badgeClass} {customClasses}">
  {displayText}
</span>