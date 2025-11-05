<script lang="ts">
  import { userFormStore } from '$lib/stores/userFormStore.svelte.ts';
  import UserBasicInfo from '$lib/components/forms_users_wrappers/UserBasicInfo.svelte';
  import UserPersonalInfo from '$lib/components/forms_users_wrappers/UserPersonalInfo.svelte';
  import UserContactInfo from '$lib/components/forms_users_wrappers/UserContactInfo.svelte';
  import UserCredentials from '$lib/components/forms_users_wrappers/UserCredentials.svelte';
  import Bank from '$lib/components/forms_commons/Bank.svelte'; 


  const state = userFormStore;
  const formData = $state.formData

  function handleSubmit() {
    userFormStore.submit();
  }
</script>

<div class="space-y-6">
  <h3 class="font-bold text-lg">
    {#if $state.mode === 'create'}
      Criar Novo Usuário
    {:else if $state.mode === 'invite'}
      Convidar Usuário por Email
    {:else}
      Editar Usuário
    {/if}
  </h3>

  {#if $state.mode === 'invite'}
    <!-- ===================== FORMULÁRIO SIMPLIFICADO PARA CONVITE ====================== -->
    <div class="form-control w-full max-w-xs">
      <label class="label" for="invite-email">
        <span class="label-text">Email do Usuário</span>
      </label>
      <input
        id="invite-email"
        type="email"
        placeholder="Digite o e-mail para convidar"
        class="input input-bordered w-full max-w-xs"
        bind:value={formData.credentials.email}
        disabled={$state.loading}
        required
      />
      <!-- Se tivesse um componente EmailInput, usaria assim:
      <EmailInput bind:value={formData.credentials.email} disabled={$state.loading} />
      -->
    </div>
    <!-- ================================================================================== -->
  {:else}
    <!-- ====================== FORMULÁRIO COMPLETO PARA CRIAÇÃO/EDIÇÃO ====================== -->
    <UserCredentials bind:credentials={formData.credentials} isEditMode={$state.mode === 'edit'}/>
    <UserBasicInfo bind:basicInfo={formData.basicInfo} />
    <UserPersonalInfo bind:personalInfo={formData.personalInfo} />
    <UserContactInfo bind:contactInfo={formData.contactInfo} />

    <div class="divider pt-2">Dados Bancários (Opcional)</div>
    
    <Bank
      bind:bankAccount={formData.bankAccount}
      labelPrefix="user-bank"
      disabled={$state.loading}
    />
    <!-- ===================================================================================== -->
  {/if}

  <div class="modal-action mt-8">
    <button type="button" class="btn btn-ghost" on:click={() => userFormStore.reset()} disabled={$state.loading}>Cancelar</button>
    <button type="submit" class="btn btn-primary" on:click={handleSubmit} disabled={$state.loading}>
      {#if $state.loading}
        <span class="loading loading-spinner"></span>
      {/if}
      {#if $state.mode === 'create'}
        Criar Usuário
      {:else if $state.mode === 'invite'}
        Enviar Convite
      {:else}
        Salvar Alterações
      {/if}
    </button>
  </div>

  {#if $state.error}
    <div class="alert alert-error mt-4">
      <span>Erro: {$state.error}</span>
    </div>
  {/if}
</div>