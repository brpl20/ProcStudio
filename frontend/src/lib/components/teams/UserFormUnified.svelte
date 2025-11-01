<script lang="ts">
  import { userFormStore } from '$lib/stores/userFormStore.svelte.ts';
  import UserBasicInfo from '$lib/components/forms_users_wrappers/UserBasicInfo.svelte';
  import UserPersonalInfo from '$lib/components/forms_users_wrappers/UserPersonalInfo.svelte';
  import UserContactInfo from '$lib/components/forms_users_wrappers/UserContactInfo.svelte';
  import UserCredentials from '$lib/components/forms_users_wrappers/UserCredentials.svelte';

  const state = userFormStore;

  function handleSubmit() {
    userFormStore.submit();
  }
</script>

<div class="space-y-6">
  <h3 class="font-bold text-lg">
    {$state.mode === 'create' ? 'Criar Novo Usuário' : 'Editar Usuário'}
  </h3>

  <UserCredentials bind:credentials={$state.formData.credentials} isEditMode={$state.mode === 'edit'}/>
  <UserBasicInfo bind:basicInfo={$state.formData.basicInfo} />
  <UserPersonalInfo bind:personalInfo={$state.formData.personalInfo} />
  <UserContactInfo bind:contactInfo={$state.formData.contactInfo} />

  <div class="modal-action mt-8">
    <button type="button" class="btn btn-ghost" on:click={() => userFormStore.reset()} disabled={$state.loading}>Cancelar</button>
    <button type="submit" class="btn btn-primary" on:click={handleSubmit} disabled={$state.loading}>
      {#if $state.loading}
        <span class="loading loading-spinner"></span>
      {/if}
      {$state.mode === 'create' ? 'Criar Usuário' : 'Salvar Alterações'}
    </button>
  </div>

  {#if $state.error}
    <div class="alert alert-error mt-4">
      <span>Erro: {$state.error}</span>
    </div>
  {/if}
</div>