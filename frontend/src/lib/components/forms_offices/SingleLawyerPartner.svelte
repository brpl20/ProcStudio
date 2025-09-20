<script lang="ts">
  import type { Lawyer } from '../../api/types/user.lawyer';

  type Props = {
    lawyer: Lawyer | null;
  };

  let {
    lawyer = null
  }: Props = $props();

  function getFullName(lawyer: Lawyer) {
    return `${lawyer.attributes.name} ${lawyer.attributes.last_name || ''}`.trim();
  }
</script>

{#if lawyer}
  <div class="bg-base-200 rounded-lg p-4 mb-4">
    <div class="flex justify-between items-center">
      <div>
        <h4 class="font-semibold">Sócio Único</h4>
        <p class="text-base mt-1">{getFullName(lawyer)}</p>
      </div>
      <div class="flex flex-col items-end gap-1">
        <span class="badge badge-primary">Sócio Administrador</span>
        <span class="badge badge-secondary">100% de Participação</span>
      </div>
    </div>
  </div>
{/if}