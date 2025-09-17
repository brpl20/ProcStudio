<script lang="ts">
  import { lawyerStore } from '../../stores/lawyerStore.svelte';
  import type { Lawyer } from '../../api/types/user.lawyer';
  import { onMount } from 'svelte';

  onMount(() => {
    lawyerStore.init();
  });
</script>

<div>
  <p>Total lawyers: {lawyerStore.lawyersCount}</p>
</div>
<div>
  <p>Active lawyers: {lawyerStore.activeLawyers.length}</p>
</div>
<div>
  <p>Selected Lawyers: {lawyerStore.selectedLawyersCount}</p>
</div>
<div>
  <p>Remaining Lawyers: {lawyerStore.remainingLawyersCount}</p>
</div>
