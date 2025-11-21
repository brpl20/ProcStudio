<script lang="ts">
  import { buildLogoUrl, getPlaceholderEmoji } from '$lib/utils/logo.utils';

  interface Office {
    id: number;
    name: string;
    logo_url?: string;
    deleted: boolean;
    cnpj?: string;
    site?: string;
    street?: string;
    number?: string;
    complement?: string;
    neighborhood?: string;
    city?: string;
    state?: string;
    cep?: string;
    email?: string;
    phone?: string;
    quote_value?: number;
    number_of_quotes?: number;
    [key: string]: any;
  }

  let {
    office,
    onClose = () => {}
  }: {
    office: Office;
    onClose?: () => void;
  } = $props();

  function formatCurrency(value: number): string {
    if (value == null) return '-';
    return value.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
  }

  function stopPropagation(event: MouseEvent) {
    event.stopPropagation();
  }
  
</script>

<div
  class="fixed inset-0 bg-[#01013D]/70 backdrop-blur-sm flex items-center justify-center z-50 p-4"
  onclick={onClose}
  role="presentation"
>
  <div
    class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl mx-4 animate-in fade-in slide-in-from-bottom-4 duration-300 max-h-[90vh] overflow-y-auto"
    onclick={stopPropagation}
    role="dialog"
    aria-modal="true"
    aria-labelledby="office-details-title"
  >
    <div class="border-b border-[#eef0ef] px-8 py-6 sticky top-0 bg-white z-10">
      <div class="flex justify-between items-start">
        <div class="flex items-center gap-4">
          <div
            class="w-16 h-16 rounded-xl flex-shrink-0 overflow-hidden bg-gradient-to-br from-[#eef0ef] to-[#0277EE]/10 flex items-center justify-center"
          >
            {#if buildLogoUrl(office.logo_url)}
              <img
                src={buildLogoUrl(office.logo_url)}
                alt="Logo do {office.name}"
                class="w-full h-full object-cover"
              />
            {:else}
              <div class="text-3xl">{getPlaceholderEmoji('office')}</div>
            {/if}
          </div>
          <div>
            <h2
              id="office-details-title"
              class="text-2xl font-bold bg-gradient-to-r from-[#01013D] to-[#0277EE] bg-clip-text text-transparent"
            >
              {office.name}
            </h2>
            {#if office.deleted}
              <span
                class="mt-1 inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-red-100 text-red-900 text-xs font-semibold"
              >
                <div class="w-2 h-2 rounded-full bg-red-600" />
                Arquivado
              </span>
            {:else}
              <span
                class="mt-1 inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-green-100 text-green-900 text-xs font-semibold"
              >
                <div class="w-2 h-2 rounded-full bg-green-600" />
                Ativo
              </span>
            {/if}
          </div>
        </div>
        <button
          class="p-2 rounded-lg text-gray-400 hover:text-[#01013D] hover:bg-[#eef0ef] transition-all duration-200"
          onclick={onClose}
          aria-label="Fechar modal"
        >
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
        </button>
      </div>
    </div>

    <div class="p-8 space-y-6">
      <section>
        <h3 class="font-bold text-lg text-[#01013D] mb-3 border-b border-[#eef0ef] pb-2">
          Informações Gerais
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4">
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">CNPJ</p>
            <p class="text-sm font-mono font-semibold text-[#01013D] mt-1">{office.cnpj || '-'}</p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Site</p>
            {#if office.site}
              <a
                href={office.site}
                
                rel="noopener noreferrer"
                class="text-sm text-[#0277EE] hover:underline truncate block mt-1"
              >
                {office.site}
              </a>
            {:else}
              <p class="text-sm text-gray-600 mt-1">-</p>
            {/if}
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Email</p>
            <p class="text-sm text-gray-600 mt-1">{office.email || '-'}</p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Telefone</p>
            <p class="text-sm text-gray-600 mt-1">{office.phone || '-'}</p>
          </div>
        </div>
      </section>

      <section>
        <h3 class="font-bold text-lg text-[#01013D] mb-3 border-b border-[#eef0ef] pb-2">
          Endereço
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4">
          <div class="md:col-span-2">
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">
              Rua / Logradouro
            </p>
            <p class="text-sm text-gray-600 mt-1">
              {office.street || '-'}, {office.number || 'S/N'}
            </p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Complemento</p>
            <p class="text-sm text-gray-600 mt-1">{office.complement || '-'}</p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Bairro</p>
            <p class="text-sm text-gray-600 mt-1">{office.neighborhood || '-'}</p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Cidade</p>
            <p class="text-sm text-gray-600 mt-1">{office.city || '-'}</p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Estado</p>
            <p class="text-sm text-gray-600 mt-1">{office.state || '-'}</p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">CEP</p>
            <p class="text-sm font-mono text-gray-600 mt-1">{office.cep || '-'}</p>
          </div>
        </div>
      </section>

      <section>
        <h3 class="font-bold text-lg text-[#01013D] mb-3 border-b border-[#eef0ef] pb-2">
          Informações de Cotas
        </h3>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-4">
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Valor da Cota</p>
            <p class="text-sm font-semibold text-[#0277EE] mt-1">
              {formatCurrency(office.quote_value)}
            </p>
          </div>
          <div>
            <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide">Total de Cotas</p>
            <p class="text-sm font-semibold text-[#01013D] mt-1">{office.number_of_quotes || 0}</p>
          </div>
        </div>
      </section>
    </div>
  </div>
</div>