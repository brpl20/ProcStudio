<script lang="ts">
  import { userFormStore } from '$lib/stores/userFormStore.svelte.ts';
  import UserBasicInfo from '$lib/components/forms_users_wrappers/UserBasicInfo.svelte';
  import UserPersonalInfo from '$lib/components/forms_users_wrappers/UserPersonalInfo.svelte';
  import UserContactInfo from '$lib/components/forms_users_wrappers/UserContactInfo.svelte';
  import UserCredentials from '$lib/components/forms_users_wrappers/UserCredentials.svelte';
  import Bank from '$lib/components/forms_commons/Bank.svelte';

  let currentEmail = '';

  function handleSubmit() {
    userFormStore.submit();
  }

  function handleAddEmail() {
    userFormStore.addEmail(currentEmail);
    if (!userFormStore.error) {
      currentEmail = ''; 
    }
  }

  function handleKeyPress(event: KeyboardEvent) {
    if (event.key === 'Enter') {
      event.preventDefault(); 
      handleAddEmail();
    }
  }
</script>

<div class="space-y-6 p-6">
  <div class="mb-8">
    <h2 class="text-3xl font-bold text-[#01013D]">
      {#if userFormStore.mode === 'create'}
        Criar Novo Usuário
      {:else if userFormStore.mode === 'invite'}
        Convidar Usuários por Email
      {:else}
        Editar Usuário
      {/if}
    </h2>
    <div class="h-1 w-20 bg-gradient-to-r from-[#0277EE] to-[#01013D] mt-3 rounded-full"></div>
  </div>

  {#if userFormStore.mode === 'invite'}
    <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] p-6">
      <div class="flex items-center gap-3 mb-6">
        <div class="w-10 h-10 bg-gradient-to-br from-[#0277EE] to-[#01013D] rounded-lg flex items-center justify-center">
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
          </svg>
        </div>
        <h3 class="text-lg font-semibold text-[#01013D]">Emails para Convite</h3>
      </div>
      
      <div class="space-y-4">
        <div>
            <label class="block text-sm font-medium text-[#01013D] mb-2" for="invite-email">
              Adicionar endereço de email
            </label>
            <div class="flex items-center gap-2">
              <input
                id="invite-email"
                type="email"
                placeholder="usuario@exemplo.com"
                class="flex-grow px-4 py-3 rounded-lg border border-gray-300 focus:border-[#0277EE] focus:ring-2 focus:ring-[#0277EE]/20 outline-none transition-all duration-200 text-[#01013D] placeholder-gray-400"
                bind:value={currentEmail}
                onkeydown={handleKeyPress}
                disabled={userFormStore.loading}
              />
              <button
                type="button"
                class="flex-shrink-0 w-12 h-12 rounded-lg bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-bold text-2xl flex items-center justify-center hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                onclick={handleAddEmail}
                disabled={userFormStore.loading}
                aria-label="Adicionar email"
              >
                +
              </button>
            </div>
        </div>

        {#if userFormStore.inviteEmails.length > 0}
          <div class="pt-4">
            <h4 class="text-sm font-medium text-[#01013D] mb-2">Lista de convites ({userFormStore.inviteEmails.length}):</h4>
            <div class="flex flex-wrap gap-2">
              {#each userFormStore.inviteEmails as email, index (email)}
                <div class="flex items-center gap-2 bg-blue-100 text-blue-800 text-sm font-medium px-3 py-1.5 rounded-full">
                  <span>{email}</span>
                  <button 
                    type="button"
                    class="w-5 h-5 flex items-center justify-center bg-blue-200 rounded-full hover:bg-blue-300 text-blue-900"
                    onclick={() => userFormStore.removeEmail(index)}
                    disabled={userFormStore.loading}
                    aria-label="Remover {email}"
                  >
                    <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
                  </button>
                </div>
              {/each}
            </div>
          </div>
        {/if}
      </div>
    </div>
  {:else}
    <!-- O restante do formulário para 'create' e 'edit' permanece o mesmo -->
    <div class="space-y-6">
      <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Credenciais de Acesso</h3>
          </div>
        </div>
        <div class="p-6">
          <UserCredentials bind:credentials={userFormStore.formData.credentials} isEditMode={userFormStore.mode === 'edit'}/>
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Dados Básicos</h3>
          </div>
        </div>
        <div class="p-6">
          <UserBasicInfo bind:basicInfo={userFormStore.formData.basicInfo} />
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 6H5a2 2 0 00-2 2v9a2 2 0 002 2h14a2 2 0 002-2V8a2 2 0 00-2-2h-5m-4 0V5a2 2 0 114 0v1m-4 0a2 2 0 104 0m-5 8a2 2 0 100-4 2 2 0 000 4zm0 0c1.306 0 2.417.835 2.83 2M9 14a3.001 3.001 0 00-2.83 2M15 11h3m-3 4h2"/>
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Informações Pessoais</h3>
          </div>
        </div>
        <div class="p-6">
          <UserPersonalInfo bind:personalInfo={userFormStore.formData.personalInfo} />
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"/>
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Informações de Contato</h3>
          </div>
        </div>
        <div class="p-6">
          <UserContactInfo bind:contactInfo={userFormStore.formData.contactInfo} />
        </div>
      </div>

      <div class="bg-white rounded-xl shadow-sm border border-[#eef0ef] overflow-hidden">
        <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
          <div class="flex items-center gap-3">
            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
              <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z"/>
              </svg>
            </div>
            <h3 class="text-lg font-semibold text-white">Dados Bancários</h3>
            <span class="ml-auto text-xs text-white/70 bg-white/20 px-3 py-1 rounded-full">Opcional</span>
          </div>
        </div>
        <div class="p-6">
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
        </div>
      </div>
    </div>
  {/if}

  <div class="flex justify-end gap-3 pt-6 border-t border-[#eef0ef]">
    <button 
      type="button" 
      class="px-6 py-3 rounded-lg border border-gray-300 text-[#01013D] font-medium hover:bg-gray-50 transition-colors duration-200 disabled:opacity-50 disabled:cursor-not-allowed" 
      onclick={() => userFormStore.reset()} 
      disabled={userFormStore.loading}
    >
      Cancelar
    </button>
    <button 
      type="submit" 
      class="px-6 py-3 rounded-lg bg-gradient-to-r from-[#0277EE] to-[#01013D] text-white font-medium hover:shadow-lg transform hover:-translate-y-0.5 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed flex items-center gap-2" 
      onclick={handleSubmit} 
      disabled={userFormStore.loading || (userFormStore.mode === 'invite' && userFormStore.inviteEmails.length === 0)}
    >
      {#if userFormStore.loading}
        <svg class="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
      {/if}
      {#if userFormStore.mode === 'create'}
        Criar Usuário
      {:else if userFormStore.mode === 'invite'}
        Enviar Convite{#if userFormStore.inviteEmails.length > 1}s{/if}
      {:else}
        Salvar Alterações
      {/if}
    </button>
  </div>

  {#if userFormStore.error}
    <div class="bg-red-50 border border-red-200 rounded-lg p-4 flex items-start gap-3">
      <svg class="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
      </svg>
      <div>
        <h4 class="font-semibold text-red-900">Ocorreu um Erro</h4>
        <p class="text-sm text-red-700">{userFormStore.error}</p>
      </div>
    </div>
  {/if}
</div>