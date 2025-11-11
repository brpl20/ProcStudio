<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { buildLogoUrl, getLogoThumbnailStyle, getPlaceholderEmoji } from '$lib/utils/logo.utils';

  interface Office {
    id: number;
    name: string;
    logo_url?: string;
    deleted: boolean;
    [key: string]: any;
  }

  export let offices: Office[] = [];
  export let showDeleted = false;

  const dispatch = createEventDispatcher();

  function handleEdit(office: Office): void {
    dispatch('edit', office);
  }

  function handleDelete(office: Office): void {
    dispatch('delete', office);
  }

  function handleRestore(office: Office): void {
    dispatch('restore', office);
  }

  function formatCurrency(value: number): string {
    return value.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
  }
</script>

<div class="space-y-4">
  {#if offices.length === 0}
    <div class="text-center py-12">
      <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 mb-4">
        <svg class="w-8 h-8 text-[#0277EE]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
        </svg>
      </div>
      <p class="text-[#01013D] font-bold text-lg">
        {showDeleted ? 'Nenhum escritório arquivado' : 'Nenhum escritório cadastrado'}
      </p>
      <p class="text-gray-500 text-sm mt-1">
        {showDeleted
          ? 'Não há escritórios arquivados no momento.'
          : 'Comece criando seu primeiro escritório.'}
      </p>
    </div>
  {:else}
    <div class="overflow-x-auto">
      <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-1">
        {#each offices as office (office.id)}
          <div class="bg-white rounded-2xl border border-[#eef0ef] hover:border-[#0277EE] hover:shadow-lg hover:shadow-[#0277EE]/10 transition-all duration-300 overflow-hidden group {office.deleted ? 'opacity-60' : ''}">
            <div class="p-6">
              <div class="flex items-start justify-between mb-4">
                <div class="flex items-start gap-4 flex-1">
                  <!-- Logo -->
                  <div class="w-16 h-16 rounded-xl flex-shrink-0 overflow-hidden bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 flex items-center justify-center">
                    {#if buildLogoUrl(office.logo_url)}
                      <img
                        src={buildLogoUrl(office.logo_url)}
                        alt="Logo do {office.name}"
                        class="w-full h-full object-cover"
                      />
                    {:else}
                      <div class="text-3xl">
                        {getPlaceholderEmoji('office')}
                      </div>
                    {/if}
                  </div>

                  <!-- Office Info -->
                  <div class="flex-1 min-w-0">
                    <h3 class="font-bold text-lg text-[#01013D] {office.deleted ? 'line-through' : ''} truncate">
                      {office.name}
                    </h3>
                    {#if office.site}
                      <a 
                        href={office.site} 
                        target="_blank" 
                        class="text-sm text-[#0277EE] hover:text-[#01013D] transition-colors duration-200 truncate block"
                      >
                        {office.site}
                      </a>
                    {/if}
                    <div class="flex items-center gap-2 mt-2">
                      {#if office.deleted}
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-red-100 text-red-900 text-xs font-semibold">
                          <div class="w-2 h-2 rounded-full bg-red-600"></div>
                          Arquivado
                        </span>
                      {:else}
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-green-100 text-green-900 text-xs font-semibold">
                          <div class="w-2 h-2 rounded-full bg-green-600"></div>
                          Ativo
                        </span>
                      {/if}
                    </div>
                  </div>
                </div>

                <!-- Actions Menu -->
                <div class="relative group/menu ml-4">
                  <button 
                    class="p-2 rounded-lg text-gray-400 hover:text-[#0277EE] hover:bg-[#eef0ef] transition-all duration-200"
                    aria-label="Opções do escritório"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                      <path d="M12 8c1.1 0 2-0.9 2-2s-0.9-2-2-2-2 0.9-2 2 0.9 2 2 2zm0 2c-1.1 0-2 0.9-2 2s0.9 2 2 2 2-0.9 2-2-0.9-2-2-2zm0 6c-1.1 0-2 0.9-2 2s0.9 2 2 2 2-0.9 2-2-0.9-2-2-2z"/>
                    </svg>
                  </button>
                  <div class="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-lg border border-[#eef0ef] opacity-0 invisible group-hover/menu:opacity-100 group-hover/menu:visible transition-all duration-200 z-50">
                    {#if !office.deleted}
                      <button 
                        on:click={() => handleEdit(office)}
                        class="w-full text-left px-4 py-3 text-sm text-[#0277EE] hover:bg-[#eef0ef] transition-colors duration-200 flex items-center gap-2 border-b border-[#eef0ef]"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                        </svg>
                        Editar
                      </button>
                      <button 
                        on:click={() => handleDelete(office)}
                        class="w-full text-left px-4 py-3 text-sm text-orange-600 hover:bg-[#eef0ef] transition-colors duration-200 flex items-center gap-2"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"/>
                        </svg>
                        Arquivar
                      </button>
                    {:else}
                      <button 
                        on:click={() => handleRestore(office)}
                        class="w-full text-left px-4 py-3 text-sm text-green-600 hover:bg-[#eef0ef] transition-colors duration-200 flex items-center gap-2 border-b border-[#eef0ef]"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                        </svg>
                        Restaurar
                      </button>
                      <button 
                        on:click={() => handleDelete(office)}
                        class="w-full text-left px-4 py-3 text-sm text-red-600 hover:bg-[#eef0ef] transition-colors duration-200 flex items-center gap-2"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
                        </svg>
                        Excluir permanentemente
                      </button>
                    {/if}
                  </div>
                </div>
              </div>

              <!-- Details Grid -->
              <div class="grid grid-cols-2 md:grid-cols-3 gap-4 pt-4 border-t border-[#eef0ef]">
                <div>
                  <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">CNPJ</p>
                  <p class="text-sm font-mono font-semibold text-[#01013D]">{office.cnpj || '-'}</p>
                </div>
                <div>
                  <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Cidade</p>
                  <p class="text-sm font-semibold text-[#01013D]">{office.city || '-'}</p>
                </div>
                <div>
                  <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Estado</p>
                  <p class="text-sm font-semibold text-[#01013D]">{office.state || '-'}</p>
                </div>
                <div>
                  <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Valor da Cota</p>
                  <p class="text-sm font-semibold text-[#0277EE]">
                    {office.quote_value ? formatCurrency(office.quote_value) : '-'}
                  </p>
                </div>
                <div>
                  <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1">Total de Cotas</p>
                  <p class="text-sm font-semibold text-[#01013D]">{office.number_of_quotes || 0}</p>
                </div>
              </div>
            </div>
          </div>
        {/each}
      </div>
    </div>

    <div class="mt-6 p-4 bg-gradient-to-r from-[#eef0ef] to-[#0277EE]/5 rounded-xl border border-[#eef0ef]">
      <p class="text-sm font-semibold text-[#01013D]">
        Total: {offices.length} escritório{offices.length !== 1 ? 's' : ''}
      </p>
    </div>
  {/if}
</div>
