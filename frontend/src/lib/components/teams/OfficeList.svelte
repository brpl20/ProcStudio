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
</script>

{#if offices.length === 0}
  <div class="text-center py-12">
    <div class="text-6xl mb-4">🏢</div>
    <h3 class="text-xl font-semibold text-gray-900 mb-2">
      {showDeleted ? 'Nenhum escritório arquivado' : 'Nenhum escritório cadastrado'}
    </h3>
    <p class="text-gray-500 mb-4">
      {showDeleted
        ? 'Não há escritórios arquivados no momento.'
        : 'Comece criando seu primeiro escritório.'}
    </p>
  </div>
{:else}
  <div class="overflow-x-auto">
    <table class="table table-zebra w-full">
      <thead>
        <tr>
          <th>Logo</th>
          <th>Nome</th>
          <th>CNPJ</th>
          <th>Cidade</th>
          <th>Estado</th>
          <th>Valor da Cota</th>
          <th>Total de Cotas</th>
          <th>Status</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>
        {#each offices as office (office.id)}
          <tr class:opacity-60={office.deleted}>
            <td>
              <div class="avatar">
                <div class="w-12 h-12 rounded">
                  {#if buildLogoUrl(office.logo_url)}
                    <img
                      src={buildLogoUrl(office.logo_url)}
                      alt="Logo do {office.name}"
                      class={getLogoThumbnailStyle()}
                    />
                  {:else}
                    <div
                      class="bg-gray-200 flex items-center justify-center w-full h-full text-gray-500"
                    >
                      {getPlaceholderEmoji('office')}
                    </div>
                  {/if}
                </div>
              </div>
            </td>
            <td>
              <div class="font-bold {office.deleted ? 'line-through' : ''}">{office.name}</div>
              {#if office.site}
                <div class="text-sm opacity-50">
                  <a href={office.site} target="_blank" class="link">{office.site}</a>
                </div>
              {/if}
            </td>
            <td class="font-mono">{office.cnpj}</td>
            <td>{office.city || '-'}</td>
            <td>{office.state || '-'}</td>
            <td>
              {#if office.quote_value}
                R$ {office.quote_value.toLocaleString('pt-BR', { minimumFractionDigits: 2 })}
              {:else}
                -
              {/if}
            </td>
            <td>{office.number_of_quotes || 0}</td>
            <td>
              {#if office.deleted}
                <div class="badge badge-error">Arquivado</div>
              {:else}
                <div class="badge badge-success">Ativo</div>
              {/if}
            </td>
            <td>
              <div class="dropdown dropdown-end">
                <button class="btn btn-ghost btn-xs" aria-label="Opções do escritório">⋮</button>
                <ul class="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52">
                  {#if !office.deleted}
                    <li>
                      <button onclick={() => handleEdit(office)} class="text-blue-600">
                        ✏️ Editar
                      </button>
                    </li>
                    <li>
                      <button onclick={() => handleDelete(office)} class="text-orange-600">
                        📦 Arquivar
                      </button>
                    </li>
                  {:else}
                    <li>
                      <button onclick={() => handleRestore(office)} class="text-green-600">
                        🔄 Restaurar
                      </button>
                    </li>
                    <li>
                      <button onclick={() => handleDelete(office)} class="text-red-600">
                        🗑️ Excluir permanentemente
                      </button>
                    </li>
                  {/if}
                </ul>
              </div>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

  <div class="mt-4 text-sm text-gray-500">
    Total: {offices.length} escritório{offices.length !== 1 ? 's' : ''}
  </div>
{/if}
