<script lang="ts">
  import { userFormStore } from '$lib/stores/userFormStore.svelte.ts';
  import UserBasicInfo from '$lib/components/forms_users_wrappers/UserBasicInfo.svelte';
  import UserPersonalInfo from '$lib/components/forms_users_wrappers/UserPersonalInfo.svelte';
  import UserContactInfo from '$lib/components/forms_users_wrappers/UserContactInfo.svelte';
  import UserCredentials from '$lib/components/forms_users_wrappers/UserCredentials.svelte';
  import Bank from '$lib/components/forms_commons/Bank.svelte';

  function handleSubmit() {
    userFormStore.submit();
  }
</script>

<div class="space-y-6">
  <h3 class="font-bold text-lg">
    {#if userFormStore.mode === 'create'}
      Criar Novo Usuário
    {:else if userFormStore.mode === 'invite'}
      Convidar Usuário por Email
    {:else}
      Editar Usuário
    {/if}
  </h3>

  {#if userFormStore.mode === 'invite'}
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
        bind:value={userFormStore.formData.credentials.email}
        disabled={userFormStore.loading}
        required
      />
      <!-- Se tivesse um componente EmailInput, usaria assim:
      <EmailInput bind:value={userFormStore.formData.credentials.email} disabled={userFormStore.loading} />
      -->
    </div>
    <!-- ================================================================================== -->
  {:else}
    <!-- ====================== FORMULÁRIO COMPLETO PARA CRIAÇÃO/EDIÇÃO ====================== -->
    <UserCredentials bind:credentials={userFormStore.formData.credentials} isEditMode={userFormStore.mode === 'edit'}/>
    <UserBasicInfo bind:basicInfo={userFormStore.formData.basicInfo} />
    <UserPersonalInfo bind:personalInfo={userFormStore.formData.personalInfo} />
    <UserContactInfo bind:contactInfo={userFormStore.formData.contactInfo} />

    <div class="divider pt-2">Dados Bancários (Opcional)</div>

    <Bank
      bind:bankAccount={userFormStore.formData.bankAccount}
      labelPrefix="user-bank"
      disabled={userFormStore.loading}
    />
    <!-- ===================================================================================== -->
  {/if}

  <div class="modal-action mt-8">
    <button type="button" class="btn btn-ghost" onclick={() => userFormStore.reset()} disabled={userFormStore.loading}>Cancelar</button>
    <button type="submit" class="btn btn-primary" onclick={handleSubmit} disabled={userFormStore.loading}>
      {#if userFormStore.loading}
        <span class="loading loading-spinner"></span>
      {/if}
      {#if userFormStore.mode === 'create'}
        Criar Usuário
      {:else if userFormStore.mode === 'invite'}
        Enviar Convite
      {:else}
        Salvar Alterações
      {/if}
    </button>
  </div>

  {#if userFormStore.error}
    <div class="alert alert-error mt-4">
      <span>Erro: {userFormStore.error}</span>
    </div>
  {/if}
</div>