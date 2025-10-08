<script lang="ts">
  import { RenderScan } from 'svelte-render-scan';
  import BasicInformation from '../../components/forms_commons_wrappers/BasicInformation.svelte';
  import { newOfficeStore } from '../../stores/newOfficeStore.svelte';

  // Handle form submission
  async function handleSubmit() {
    try {
      const result = await newOfficeStore.saveNewOffice();
      if (result) {
        console.log('Office created successfully:', result);
      }
    } catch (error) {
      console.error('Error creating office:', error);
    }
  }
</script>

<RenderScan />

<div class="container mx-auto p-6">
  <h1 class="text-2xl font-bold mb-6">Criar Escritório</h1>
  
  <form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
    <BasicInformation bind:formData={newOfficeStore.formData} />
    
    <!-- Form actions -->
    <div class="flex gap-4 mt-6">
      <button 
        type="submit" 
        class="btn btn-primary"
        disabled={!newOfficeStore.canSubmit}
        class:loading={newOfficeStore.formState.saving}
      >
        {newOfficeStore.formState.saving ? 'Salvando...' : 'Criar Escritório'}
      </button>
      
      <button 
        type="button" 
        class="btn btn-outline"
        onclick={(() => newOfficeStore.resetForm())}
      >
        Limpar
      </button>
    </div>

    <!-- Success/Error messages -->
    {#if newOfficeStore.formState.success}
      <div class="alert alert-success mt-4">
        {newOfficeStore.formState.success}
      </div>
    {/if}

    {#if newOfficeStore.formState.error}
      <div class="alert alert-error mt-4">
        {newOfficeStore.formState.error}
      </div>
    {/if}
  </form>

  <!-- Debug Section -->
  <div class="mt-8 bg-gray-50 border rounded-lg p-4">
    <h3 class="text-lg font-semibold mb-3">Debug Information</h3>
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
      <div class="bg-white p-3 rounded">
        <strong>Form Valid:</strong> {newOfficeStore.isValid ? '✅' : '❌'}
      </div>
      <div class="bg-white p-3 rounded">
        <strong>Form Dirty:</strong> {newOfficeStore.isDirty ? '✅' : '❌'}
      </div>
      <div class="bg-white p-3 rounded">
        <strong>Can Submit:</strong> {newOfficeStore.canSubmit ? '✅' : '❌'}
      </div>
    </div>
    
    {#if newOfficeStore.getValidationErrors().length > 0}
      <div class="mt-3 bg-red-50 border border-red-200 rounded p-3">
        <strong class="text-red-700">Validation Errors:</strong>
        <ul class="list-disc list-inside text-red-600 mt-1">
          {#each newOfficeStore.getValidationErrors() as error}
            <li>{error}</li>
          {/each}
        </ul>
      </div>
    {/if}

    <div class="mt-4">
      <a href="/lawyers-test-debug" class="btn btn-info btn-sm">
        🐛 Go to Debug Page
      </a>
    </div>
  </div>
</div>
