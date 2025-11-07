<script lang="ts">
  import type { Lawyer } from '../../api/types/user.lawyer';

  type Props = {
    totalLawyers?: number;
    activeLawyers?: Lawyer[];
    selectedLawyers?: Lawyer[];
  };

  const {
    totalLawyers = 0,
    activeLawyers = [],
    selectedLawyers = []
  }: Props = $props();

  const selectedLawyersCount = $derived(selectedLawyers.length);
  const remainingLawyersCount = $derived(activeLawyers.length - selectedLawyers.length);
</script>

<div>
  <p>Total lawyers: {totalLawyers}</p>
</div>
<div>
  <p>Active lawyers: {activeLawyers.length}</p>
</div>
<div>
  <p>Selected Lawyers: {selectedLawyersCount}</p>
</div>
<div>
  <p>Remaining Lawyers: {remainingLawyersCount}</p>
</div>