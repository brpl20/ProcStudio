<!-- ExampleComponent.svelte -->
<script>
  import { onMount } from 'svelte';
  import {
    lawyersStore,
    selectedLawyersStore,
    availableLawyersStore,
    getAvailableLawyersForIndex,
    lawyersUtils
  } from './stores/lawyersStore';

  // Partners array (reactive binding to selected lawyers)
  let partners = [];

  // Subscribe to stores
  $: lawyersState = $lawyersStore;
  $: availableLawyers = $availableLawyersStore;
  $: selectedLawyers = $selectedLawyersStore;

  // Load lawyers when component mounts
  onMount(async () => {
    // Only load if not already initialized
    if (!lawyersState.initialized) {
      await lawyersStore.loadLawyers();
    }

    // Initialize partners array with existing selections if any
    if (partners.length > 0) {
      const lawyerIds = partners.map((p) => p.lawyer_id).filter((id) => id);
      selectedLawyersStore.setAll(lawyerIds);
    }
  });

  // Handle adding a new partner
  function addPartner() {
    partners = [...partners, { lawyer_id: '', other_fields: {} }];
    selectedLawyersStore.add(null, partners.length - 1);
  }

  // Handle removing a partner
  function removePartner(index) {
    const lawyerId = partners[index]?.lawyer_id;
    partners = partners.filter((_, i) => i !== index);

    // Update selected lawyers store
    const newSelections = partners.map((p) => p.lawyer_id || null);
    selectedLawyersStore.setAll(newSelections);
  }

  // Handle lawyer selection change
  function handleLawyerChange(index, lawyerId) {
    partners[index].lawyer_id = lawyerId;
    selectedLawyersStore.updateAt(index, lawyerId);
  }

  // Get available lawyers for a specific partner index
  function getAvailableForPartner(index) {
    return getAvailableLawyersForIndex(index);
  }
</script>

{#if lawyersState.loading}
  <div class="loading">Loading lawyers...</div>
{:else if lawyersState.error}
  <div class="error">Error: {lawyersState.error}</div>
  <button on:click={() => lawyersStore.loadLawyers()}>Retry</button>
{:else}
  <div class="partners-form">
    <h3>Partners ({partners.length})</h3>

    <!-- Display total and available lawyers count -->
    <div class="stats">
      <span>Total Lawyers: {lawyersState.lawyers.length}</span>
      <span>Available: {lawyersUtils.getAvailableCount()}</span>
    </div>

    {#each partners as partner, index}
      <div class="partner-row">
        <label>
          Partner {index + 1}:
          <select
            bind:value={partner.lawyer_id}
            on:change={(e) => handleLawyerChange(index, e.target.value)}
          >
            <option value="">Select a lawyer</option>
            {#each getAvailableForPartner(index) as lawyer}
              <option value={lawyer.id}>
                {lawyersUtils.getFullName(lawyer)}
              </option>
            {/each}
          </select>
        </label>

        <button on:click={() => removePartner(index)}>Remove</button>
      </div>
    {/each}

    <button on:click={addPartner}>Add Partner</button>
  </div>

  <!-- Debug section (remove in production) -->
  <details>
    <summary>Debug Info</summary>
    <pre>{JSON.stringify(
        {
          totalLawyers: lawyersState.lawyers.length,
          selectedCount: selectedLawyers.length,
          availableCount: availableLawyers.length,
          partners: partners.map((p) => p.lawyer_id)
        },
        null,
        2
      )}</pre>
  </details>
{/if}
