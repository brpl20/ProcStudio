<script lang="ts">
  interface User {
    id: number;
    type: string;
    attributes: {
      name?: string;
      last_name?: string;
      email?: string;
      access_email?: string;
      role?: string;
      oab?: string;
      status?: string;
      profile?: {
        id?: number;
        full_name?: string;
        avatar_url?: string;
        cpf?: string;
        rg?: string;
        birth?: string;
        nationality?: string;
        civil_status?: string;
        gender?: 'male' | 'female';
        mother_name?: string;
      };
      phones?: { phone_number?: string; phone_type?: string }[];
      addresses?: {
        street?: string;
        number?: string;
        complement?: string;
        neighborhood?: string;
        city?: string;
        state?: string;
        zip_code?: string;
        address_type?: string;
      }[];
      bank_accounts?: { bank_name?: string; agency?: string; account_number?: string }[];
    };
  }

  let { user, onEdit } = $props<{
    user: User;
    onEdit: (user: User) => void;
  }>();

  function getRoleLabel(role: string | undefined): string {
    if (!role) {
      return 'Não informado';
    }
    const map: Record<string, string> = {
      lawyer: 'Advogado',
      paralegal: 'Paralegal',
      trainee: 'Estagiário',
      secretary: 'Secretário',
      counter: 'Contador'
    };
    return map[role] || role;
  }

  // Funções auxiliares para formatar dados
  function formatCPF(cpf: string | undefined): string {
    if (!cpf) return 'Não informado';
    // Remove tudo que não é dígito e aplica a máscara
    const cleaned = cpf.replace(/\D/g, '');
    return cleaned.replace(/(\d{3})(\d{3})(\d{3})(\d{2})/, '$1.$2.$3-$4');
  }

  function formatCEP(cep: string | undefined): string {
    if (!cep) return 'Não informado';
    // Remove tudo que não é dígito e aplica a máscara
    const cleaned = cep.replace(/\D/g, '');
    return cleaned.replace(/(\d{5})(\d{3})/, '$1-$2');
  }

  function formatPhoneNumber(phone: string | undefined): string {
    if (!phone) return 'Não informado';
    // Remove tudo que não é dígito
    const cleaned = phone.replace(/\D/g, '');
    if (cleaned.length === 11) { // (XX) XXXXX-XXXX
      return cleaned.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
    } else if (cleaned.length === 10) { // (XX) XXXX-XXXX
      return cleaned.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
    }
    return phone; // Retorna o original se não corresponder
  }

  let fullName = $derived(user.attributes.profile?.full_name || `${user.attributes.name || ''} ${user.attributes.last_name || ''}`.trim());
  let userProfile = $derived(user.attributes.profile);
  let userPhones = $derived(user.attributes.phones || []);
  let userAddresses = $derived(user.attributes.addresses || []);
  let userBankAccounts = $derived(user.attributes.bank_accounts || []);
</script>

<div class="min-h-screen bg-gradient-to-br from-[#eef0ef] to-white p-4 md:p-8">
  <div class="max-w-7xl mx-auto">
    {#if user}
      <div class="space-y-6">
        <!-- Cabeçalho do Perfil com Avatar -->
        <div class="bg-gradient-to-br from-[#01013D] to-[#0277EE] rounded-2xl shadow-2xl overflow-hidden">
          <div class="p-8 md:p-12">
            <div class="flex flex-col md:flex-row items-center gap-8">
              <div class="relative">
                <div class="w-32 h-32 rounded-full overflow-hidden ring-4 ring-white shadow-xl">
                  {#if userProfile?.avatar_url}
                    <img src={userProfile.avatar_url} alt={fullName} class="w-full h-full object-cover" />
                  {:else}
                    <div class="w-full h-full bg-[#0277EE] flex items-center justify-center">
                      <span class="text-6xl font-bold text-white">{fullName.charAt(0).toUpperCase() || '?'}</span>
                    </div>
                  {/if}
                </div>
              </div>

              <div class="flex-1 text-center md:text-left">
                <h1 class="text-4xl md:text-5xl font-bold text-white mb-2">{fullName}</h1>
                <p class="text-xl text-[#eef0ef] mb-4">
                  {getRoleLabel(user.attributes.role)}
                </p>
                <div class="flex flex-wrap gap-4 justify-center md:justify-start text-[#eef0ef]">
                  {#if user.attributes.access_email}
                    <div class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                      </svg>
                      <span>{user.attributes.access_email}</span>
                    </div>
                  {/if}
                  {#if user.attributes.role === 'lawyer' && user.attributes.oab}
                    <div class="flex items-center gap-2">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                      <span>OAB: {user.attributes.oab}</span>
                    </div>
                  {/if}
                </div>
              </div>

              <div class="grid grid-cols-2 gap-6">
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
          <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
            <h2 class="text-xl font-bold text-white flex items-center gap-2">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
              Informações da Conta e Pessoais
            </h2>
          </div>
          <div class="p-6 space-y-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="group">
                <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nome Completo</label>
                <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{fullName || 'Não informado'}</div>
              </div>
              <div class="group">
                <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Email de Acesso</label>
                <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{user.attributes.access_email || 'Não informado'}</div>
              </div>
              <div class="group">
                <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Cargo</label>
                <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{getRoleLabel(user.attributes.role)}</div>
              </div>
              {#if user.attributes.role === 'lawyer'}
                <div class="group">
                  <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">OAB</label>
                  <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{user.attributes.oab || 'Não informado'}</div>
                </div>
              {/if}
              <div class="group">
                <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Status</label>
                <div class="inline-flex items-center {user.attributes.status === 'active' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'} px-4 py-3 rounded-lg font-semibold">
                  <span class="w-2 h-2 {user.attributes.status === 'active' ? 'bg-green-500' : 'bg-yellow-500'} rounded-full mr-2"></span>
                  {user.attributes.status === 'active' ? 'Ativo' : 'Inativo'}
                </div>
              </div>
              {#if userProfile?.cpf}
                <div class="group">
                  <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">CPF</label>
                  <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{formatCPF(userProfile.cpf)}</div>
                </div>
              {/if}
              {#if userProfile?.rg}
                <div class="group">
                  <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">RG</label>
                  <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.rg}</div>
                </div>
              {/if}
              {#if userProfile?.birth}
                <div class="group">
                  <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nascimento</label>
                  <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.birth}</div>
                </div>
              {/if}
              {#if userProfile?.nationality}
                <div class="group">
                  <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nacionalidade</label>
                  <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.nationality}</div>
                </div>
              {/if}
              {#if userProfile?.civil_status}
                <div class="group">
                  <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Estado Civil</label>
                  <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.civil_status}</div>
                </div>
              {/if}
              {#if userProfile?.gender}
                <div class="group">
                  <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Gênero</label>
                  <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.gender === 'female' ? 'Feminino' : 'Masculino'}</div>
                </div>
              {/if}
            </div>
            {#if userProfile?.mother_name}
              <div class="pt-2">
                <label class="text-xs font-semibold text-[#01013D] uppercase tracking-wider mb-1 block">Nome da Mãe</label>
                <div class="text-gray-700 font-medium bg-[#eef0ef] px-4 py-3 rounded-lg">{userProfile.mother_name}</div>
              </div>
            {/if}
          </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {#if userPhones.length > 0}
            <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
              <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                <h2 class="text-xl font-bold text-white flex items-center gap-2">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  Telefones
                </h2>
              </div>
              <div class="p-6 space-y-3">
                {#each userPhones as phone}
                  <div class="flex items-center justify-between bg-[#eef0ef] px-4 py-3 rounded-lg hover:bg-gray-100 transition-colors duration-200">
                    <span class="font-medium text-[#01013D]">{formatPhoneNumber(phone.phone_number)}</span>
                    {#if phone.phone_type}
                      <span class="text-xs bg-[#0277EE] text-white px-3 py-1 rounded-full font-semibold capitalize">{phone.phone_type}</span>
                    {/if}
                  </div>
                {/each}
              </div>
            </div>
          {:else}
            <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100">
              <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                <h2 class="text-xl font-bold text-white flex items-center gap-2">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                  </svg>
                  Telefones
                </h2>
              </div>
              <div class="p-6">
                <p class="text-gray-600">Nenhum telefone cadastrado.</p>
              </div>
            </div>
          {/if}

          {#if userAddresses.length > 0}
            <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100 hover:shadow-xl transition-shadow duration-300">
              <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                <h2 class="text-xl font-bold text-white flex items-center gap-2">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  Endereços
                </h2>
              </div>
              <div class="p-6 space-y-4">
                {#each userAddresses as address}
                  <div class="bg-gradient-to-br from-[#eef0ef] to-white p-4 rounded-xl border border-gray-200 hover:border-[#0277EE] transition-all duration-300">
                    <div class="space-y-1 text-sm text-gray-700">
                      <p class="font-semibold text-[#01013D]">{address.street || 'Rua não informada'}, {address.number || 'S/N'}</p>
                      {#if address.complement}
                        <p class="text-gray-600">{address.complement}</p>
                      {/if}
                      <p>{address.neighborhood || 'Bairro não informado'}</p>
                      <p>{address.city || 'Cidade'} - {address.state || 'UF'}</p>
                      <p class="font-medium">CEP: {formatCEP(address.zip_code)}</p>
                      {#if address.address_type}
                        <div class="pt-2">
                          <span class="inline-block text-xs bg-[#0277EE] text-white px-3 py-1 rounded-full font-semibold capitalize">{address.address_type}</span>
                        </div>
                      {/if}
                    </div>
                  </div>
                {/each}
              </div>
            </div>
          {:else}
            <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100">
              <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
                <h2 class="text-xl font-bold text-white flex items-center gap-2">
                  <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                  </svg>
                  Endereços
                </h2>
              </div>
              <div class="p-6">
                <p class="text-gray-600">Nenhum endereço cadastrado.</p>
              </div>
            </div>
          {/if}
        </div>

        <div class="bg-white rounded-xl shadow-lg overflow-hidden border border-gray-100">
          <div class="bg-gradient-to-r from-[#0277EE] to-[#01013D] px-6 py-4">
            <h2 class="text-xl font-bold text-white flex items-center gap-2">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
              </svg>
              Dados Bancários
            </h2>
          </div>
          <div class="p-6">
            {#if userBankAccounts.length > 0}
              <div class="space-y-3">
                {#each userBankAccounts as account}
                  <div class="bg-gradient-to-br from-[#eef0ef] to-white p-4 rounded-xl border border-gray-200 hover:border-[#0277EE] transition-all duration-300">
                    <p class="text-sm">
                      <strong class="text-[#01013D]">Banco:</strong> {account.bank_name || 'Não informado'}
                    </p>
                    <p class="text-sm">
                      <strong class="text-[#01013D]">Agência:</strong> {account.agency || 'Não informada'}
                    </p>
                    <p class="text-sm">
                      <strong class="text-[#01013D]">Conta:</strong> {account.account_number || 'Não informada'}
                    </p>
                  </div>
                {/each}
              </div>
            {:else}
              <p class="text-gray-600">Nenhum dado bancário cadastrado.</p>
            {/if}
          </div>
        </div>

      </div>
    {:else}
      <div class="bg-yellow-50 border-l-4 border-yellow-500 p-6 rounded-lg shadow-sm">
        <div class="flex items-center gap-3">
          <svg class="w-6 h-6 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          <span class="text-yellow-800 font-medium">Nenhum dado de usuário encontrado para exibição.</span>
        </div>
      </div>
    {/if}
  </div>
</div>