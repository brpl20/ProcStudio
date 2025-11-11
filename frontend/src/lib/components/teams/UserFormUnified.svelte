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

  // Função para adicionar e-mail com a tecla "Enter"
  function handleEmailInputKeydown(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      event.preventDefault(); // Impede o submit do formulário ao pressionar Enter no input
      userFormStore.addCurrentEmail();
    }
  }
</script>

<div class="space-y-6">
  <h3 
    class="font-bold text-lg"
    class:text-center={userFormStore.mode === 'invite'}
  >
    {#if userFormStore.mode === 'create'}
      Criar Novo Usuário
    {:else if userFormStore.mode === 'invite'}
      Convidar Usuários por Email
    {:else}
      Editar Usuário
    {/if}
  </h3>

  {#if userFormStore.mode === 'invite'}
    <!-- ===================== LAYOUT OTIMIZADO PARA MÚLTIPLOS CONVITES ====================== -->
    <div class="w-full max-w-md mx-auto space-y-4">
      <div class="form-control w-full">
        <label class="label" for="invite-email">
          <span class="label-text">Email do Usuário</span>
        </label>
        <div class="join w-full">
          <input
            id="invite-email"
            type="email"
            placeholder="Digite um e-mail e clique em adicionar"
            class="input input-bordered join-item w-full"
            bind:value={userFormStore.currentInviteEmail}
            disabled={userFormStore.loading}
            onkeydown={handleEmailInputKeydown}
          />
          <button 
            class="btn join-item btn-neutral" 
            onclick={() => userFormStore.addCurrentEmail()}
            disabled={userFormStore.loading}
          >
            Adicionar
          </button>
        </div>
      </div>
      
      <!-- LISTA DE E-MAILS ADICIONADOS -->
      {#if userFormStore.inviteEmails.length > 0}
        <div class="space-y-2 pt-2">
          <p class="text-sm font-semibold text-left">E-mails para convidar:</p>
          <div class="flex flex-wrap gap-2 justify-center sm:justify-start">
            {#each userFormStore.inviteEmails as email, index (email)}
              <div class="badge badge-lg badge-outline gap-2">
                {email}
                <button 
                  class="btn btn-xs btn-circle btn-ghost"
                  onclick={() => userFormStore.removeEmail(index)}
                  aria-label="Remover {email}"
                >
                  ✕
                </button>
              </div>
            {/each}
          </div>
        </div>
      {/if}
    </div>
    <!-- ======================================================================================= -->
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
      showPixHelpers={true}
      pixHelperData={{
        email: userFormStore.formData.credentials.email,
        cpf: userFormStore.formData.personalInfo.cpf,
        cnpj: '',
        phone: userFormStore.formData.contactInfo.phone
      }}
      pixDocumentType="cpf"
    />
    <!-- ===================================================================================== -->
  {/if}

  <div class="modal-action mt-8">
    <button type="button" class="btn btn-ghost" onclick={() => userFormStore.reset()} disabled={userFormStore.loading}>Cancelar</button>
    <button 
      type="submit" 
      class="btn btn-primary" 
      onclick={handleSubmit} 
      disabled={userFormStore.loading || (userFormStore.mode === 'invite' && userFormStore.inviteEmails.length === 0)}
    >
      {#if userFormStore.loading}
        <span class="loading loading-spinner"></span>
      {/if}
      {#if userFormStore.mode === 'create'}
        Criar Usuário
      {:else if userFormStore.mode === 'invite'}
        Enviar Convite{#if userFormStore.inviteEmails.length !== 1}s{/if}
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