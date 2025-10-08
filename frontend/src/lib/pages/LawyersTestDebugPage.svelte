<script lang="ts">
  import { onMount } from 'svelte';
  import { RenderScan } from 'svelte-render-scan';
  import BasicInformation from '../components/forms_commons_wrappers/BasicInformation.svelte';
  import { newOfficeStore } from '../stores/newOfficeStore.svelte';
  import type { NewOfficeFormData } from '../schemas/new-office-form';
  import { validateNewOfficeForm, isNewOfficeFormValid } from '../schemas/new-office-form';

  // Create two separate instances for comparison
  let formData1: NewOfficeFormData = $state({
    name: '',
    cnpj: '',
    society: '',
    accounting_type: '',
    foundation: '',
    site: ''
  });

  let formData2: NewOfficeFormData = $state({
    name: 'Test Office',
    cnpj: '12.345.678/0001-90',
    society: 'ltda',
    accounting_type: 'simple',
    foundation: '2024-01-01',
    site: 'https://test.com'
  });

  // Debug tracking with derived state (no effects to avoid loops)
  let renderCount = $state(0);
  let lastUpdate = $state('');

  // Use derived for validation to avoid infinite loops
  const validationErrors1 = $derived(validateNewOfficeForm(formData1));
  const isValid1 = $derived(isNewOfficeFormValid(formData1));
  const isDirty1 = $derived(!!(
    formData1.name?.trim() ||
    formData1.cnpj?.trim() ||
    formData1.society ||
    formData1.accounting_type ||
    formData1.foundation?.trim() ||
    formData1.site?.trim()
  ));

  const validationErrors2 = $derived(validateNewOfficeForm(formData2));
  const isValid2 = $derived(isNewOfficeFormValid(formData2));
  const isDirty2 = $derived(!!(
    formData2.name?.trim() ||
    formData2.cnpj?.trim() ||
    formData2.society ||
    formData2.accounting_type ||
    formData2.foundation?.trim() ||
    formData2.site?.trim()
  ));

  // Simple render tracking without effects
  function updateRenderInfo() {
    renderCount++;
    lastUpdate = new Date().toISOString();
  }

  // Handle form submission for testing
  async function handleSubmitForm1() {
    console.log('Form 1 submitted:', formData1);
    try {
      newOfficeStore.updateFormData(formData1);
      const result = await newOfficeStore.saveNewOffice();
      console.log('Form 1 result:', result);
    } catch (error) {
      console.error('Form 1 error:', error);
    }
  }

  async function handleSubmitForm2() {
    console.log('Form 2 submitted:', formData2);
    try {
      // Create a temporary store instance for testing
      const tempData = { ...formData2 };
      console.log('Form 2 would submit:', tempData);
    } catch (error) {
      console.error('Form 2 error:', error);
    }
  }

  // Reset functions
  function resetForm1() {
    formData1 = {
      name: '',
      cnpj: '',
      society: '',
      accounting_type: '',
      foundation: '',
      site: ''
    };
    updateRenderInfo();
  }

  function resetForm2() {
    formData2 = {
      name: 'Test Office',
      cnpj: '12.345.678/0001-90',
      society: 'ltda',
      accounting_type: 'simple',
      foundation: '2024-01-01',
      site: 'https://test.com'
    };
    updateRenderInfo();
  }

  // Copy form data between forms
  function copyForm1ToForm2() {
    formData2 = { ...formData1 };
    updateRenderInfo();
  }

  function copyForm2ToForm1() {
    formData1 = { ...formData2 };
    updateRenderInfo();
  }

  onMount(() => {
    console.log('Debug page mounted');
  });
</script>

<RenderScan />

<div class="container mx-auto p-6 max-w-7xl">
  <h1 class="text-3xl font-bold mb-8 text-center">🐛 Office Creation Debug Page</h1>

  <!-- Debug Info Panel -->
  <div class="bg-gray-100 p-4 rounded-lg mb-8">
    <h2 class="text-xl font-semibold mb-4">Debug Information</h2>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
      <div class="bg-white p-3 rounded">
        <strong>Render Count:</strong> {renderCount}
      </div>
      <div class="bg-white p-3 rounded">
        <strong>Last Update:</strong> {lastUpdate}
      </div>
      <div class="bg-white p-3 rounded">
        <strong>Store State:</strong>
        <div>Saving: {newOfficeStore.formState.saving}</div>
        <div>Loading: {newOfficeStore.formState.loading}</div>
        <div>Can Submit: {newOfficeStore.canSubmit}</div>
      </div>
    </div>
  </div>

  <!-- Side by Side Forms -->
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

    <!-- Form 1 - Empty Form -->
    <div class="border-2 border-blue-300 rounded-lg p-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-semibold text-blue-600">Form 1 - Empty State</h2>
        <div class="flex gap-2">
          <button class="btn btn-sm btn-outline" onclick={resetForm1}>Reset</button>
          <button class="btn btn-sm btn-primary" onclick={copyForm1ToForm2}>Copy to Form 2</button>
        </div>
      </div>

      <!-- Form 1 Debug Info -->
      <div class="bg-blue-50 p-3 rounded mb-4 text-sm">
        <div class="grid grid-cols-2 gap-2">
          <div><strong>Valid:</strong> {isValid1 ? '✅' : '❌'}</div>
          <div><strong>Dirty:</strong> {isDirty1 ? '✅' : '❌'}</div>
          <div class="col-span-2">
            <strong>Errors:</strong>
            {#if validationErrors1.length > 0}
              <ul class="list-disc list-inside text-red-600">
                {#each validationErrors1 as error}
                  <li>{error}</li>
                {/each}
              </ul>
            {:else}
              <span class="text-green-600">None</span>
            {/if}
          </div>
        </div>
      </div>

      <BasicInformation bind:formData={formData1} title="Empty Form Test" />

      <div class="mt-4">
        <button
          class="btn btn-primary w-full"
          onclick={handleSubmitForm1}
          disabled={!isValid1}
        >
          Submit Form 1 {isValid1 ? '' : '(Invalid)'}
        </button>
      </div>

      <!-- Form 1 Data Display -->
      <div class="mt-4 bg-gray-50 p-3 rounded">
        <h4 class="font-semibold mb-2">Form 1 Data:</h4>
        <pre class="text-xs overflow-auto">{JSON.stringify(formData1, null, 2)}</pre>
      </div>
    </div>

    <!-- Form 2 - Pre-filled Form -->
    <div class="border-2 border-green-300 rounded-lg p-6">
      <div class="flex justify-between items-center mb-4">
        <h2 class="text-xl font-semibold text-green-600">Form 2 - Pre-filled State</h2>
        <div class="flex gap-2">
          <button class="btn btn-sm btn-outline" onclick={resetForm2}>Reset</button>
          <button class="btn btn-sm btn-success" onclick={copyForm2ToForm1}>Copy to Form 1</button>
        </div>
      </div>

      <!-- Form 2 Debug Info -->
      <div class="bg-green-50 p-3 rounded mb-4 text-sm">
        <div class="grid grid-cols-2 gap-2">
          <div><strong>Valid:</strong> {isValid2 ? '✅' : '❌'}</div>
          <div><strong>Dirty:</strong> {isDirty2 ? '✅' : '❌'}</div>
          <div class="col-span-2">
            <strong>Errors:</strong>
            {#if validationErrors2.length > 0}
              <ul class="list-disc list-inside text-red-600">
                {#each validationErrors2 as error}
                  <li>{error}</li>
                {/each}
              </ul>
            {:else}
              <span class="text-green-600">None</span>
            {/if}
          </div>
        </div>
      </div>

      <BasicInformation bind:formData={formData2} title="Pre-filled Form Test" />

      <div class="mt-4">
        <button
          class="btn btn-success w-full"
          onclick={handleSubmitForm2}
          disabled={!isValid2}
        >
          Submit Form 2 {isValid2 ? '' : '(Invalid)'}
        </button>
      </div>

      <!-- Form 2 Data Display -->
      <div class="mt-4 bg-gray-50 p-3 rounded">
        <h4 class="font-semibold mb-2">Form 2 Data:</h4>
        <pre class="text-xs overflow-auto">{JSON.stringify(formData2, null, 2)}</pre>
      </div>
    </div>
  </div>

  <!-- Store Debug Section -->
  <div class="mt-8 bg-yellow-50 border-2 border-yellow-300 rounded-lg p-6">
    <h2 class="text-xl font-semibold text-yellow-700 mb-4">Store Debug Information</h2>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <h3 class="font-semibold mb-2">Store Form Data:</h3>
        <pre class="text-xs bg-white p-3 rounded overflow-auto">{JSON.stringify(newOfficeStore.formData, null, 2)}</pre>
      </div>

      <div>
        <h3 class="font-semibold mb-2">Store State:</h3>
        <pre class="text-xs bg-white p-3 rounded overflow-auto">{JSON.stringify(newOfficeStore.formState, null, 2)}</pre>
      </div>
    </div>

    <div class="mt-4 flex gap-4">
      <button class="btn btn-warning" onclick={() => newOfficeStore.resetForm()}>
        Reset Store
      </button>
      <button class="btn btn-info" onclick={() => newOfficeStore.updateFormData(formData1)}>
        Load Form 1 to Store
      </button>
      <button class="btn btn-info" onclick={() => newOfficeStore.updateFormData(formData2)}>
        Load Form 2 to Store
      </button>
    </div>
  </div>

  <!-- Test Actions -->
  <div class="mt-8 bg-purple-50 border-2 border-purple-300 rounded-lg p-6">
    <h2 class="text-xl font-semibold text-purple-700 mb-4">Test Actions</h2>

    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <button class="btn btn-outline" onclick={() => console.log('Current Debug State:', { renderCount, lastUpdate, isValid1, isValid2, isDirty1, isDirty2, validationErrors1, validationErrors2 })}>
        Log Debug State
      </button>
      <button class="btn btn-outline" onclick={() => console.log('Form Data Comparison:', { form1: formData1, form2: formData2 })}>
        Compare Forms
      </button>
      <button class="btn btn-outline" onclick={() => console.log('Store State:', newOfficeStore)}>
        Log Store State
      </button>
    </div>
  </div>

  <!-- Navigation -->
  <div class="mt-8 text-center">
    <a href="/lawyers-test" class="btn btn-primary">
      Go to Production Office Creation Page
    </a>
  </div>
</div>