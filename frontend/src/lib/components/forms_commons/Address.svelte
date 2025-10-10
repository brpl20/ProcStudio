<script lang="ts">
  import { BRAZILIAN_STATES } from '../../constants/brazilian-states';
  import type { BrazilianState } from '../../constants/brazilian-states';

  const states: BrazilianState[] = BRAZILIAN_STATES;

  interface AddressData {
    street: string;
    number: string;
    complement: string;
    neighborhood: string;
    city: string;
    state: string;
    zip_code: string;
    address_type: string;
  }

  type Props = {
    address?: AddressData;
    index?: number;
    showRemoveButton?: boolean;
    disabled?: boolean;
    id?: string;
    wrapperClass?: string;
    required?: boolean;
    errors?: Record<string, string>;
    touched?: Record<string, boolean>;
    oninput?: (event: CustomEvent) => void;
    onblur?: (event: CustomEvent) => void;
    onremove?: (event: CustomEvent) => void;
  };

  let {
    address = $bindable({
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
      zip_code: '',
      address_type: 'main'
    }),
    errors = $bindable({}),
    touched = $bindable({}),
    index = 0,
    showRemoveButton = false,
    disabled = false,
    id = `address-0`,
    wrapperClass = '',
    required = false,
    oninput,
    onblur,
    onremove
  }: Props = $props();

  function handleInput(field: string, event: Event) {
    const target = event.target as HTMLInputElement;
    address[field as keyof AddressData] = target.value;
    oninput?.(new CustomEvent('input', { detail: { field, value: address[field as keyof AddressData], index } }));
  }

  function handleBlur(field: string) {
    touched[field] = true;
    onblur?.(new CustomEvent('blur', { detail: { field, value: address[field as keyof AddressData], index } }));
  }

  function handleRemove() {
    onremove?.(new CustomEvent('remove', { detail: { index } }));
  }
</script>

<div class="border rounded p-4 mb-4 {wrapperClass}">
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    <!-- Street Field -->
    <div class="form-control flex flex-col lg:col-span-2">
      <label class="label pb-1" for="{id}-street">
        <span class="label-text">Rua {required ? '*' : ''}</span>
      </label>
      <input
        id="{id}-street"
        type="text"
        class="input input-bordered input-sm w-full {errors.street && touched.street
          ? 'input-error'
          : ''}"
        bind:value={address.street}
        oninput={(e) => handleInput('street', e)}
        onblur={() => handleBlur('street')}
        placeholder="Nome da rua"
        {disabled}
        aria-required={required ? 'true' : 'false'}
      />
      {#if errors.street && touched.street}
        <div class="text-error text-xs mt-1">{errors.street}</div>
      {/if}
    </div>

    <!-- Number Field -->
    <div class="form-control flex flex-col">
      <label class="label pb-1" for="{id}-number">
        <span class="label-text">Número {required ? '*' : ''}</span>
      </label>
      <input
        id="{id}-number"
        type="text"
        class="input input-bordered input-sm w-full {errors.number && touched.number
          ? 'input-error'
          : ''}"
        bind:value={address.number}
        oninput={(e) => handleInput('number', e)}
        onblur={() => handleBlur('number')}
        placeholder="123"
        {disabled}
        aria-required={required ? 'true' : 'false'}
      />
      {#if errors.number && touched.number}
        <div class="text-error text-xs mt-1">{errors.number}</div>
      {/if}
    </div>

    <!-- Neighborhood Field -->
    <div class="form-control flex flex-col">
      <label class="label pb-1" for="{id}-neighborhood">
        <span class="label-text">Bairro {required ? '*' : ''}</span>
      </label>
      <input
        id="{id}-neighborhood"
        type="text"
        class="input input-bordered input-sm w-full {errors.neighborhood && touched.neighborhood
          ? 'input-error'
          : ''}"
        bind:value={address.neighborhood}
        oninput={(e) => handleInput('neighborhood', e)}
        onblur={() => handleBlur('neighborhood')}
        placeholder="Nome do bairro"
        {disabled}
        aria-required={required ? 'true' : 'false'}
      />
      {#if errors.neighborhood && touched.neighborhood}
        <div class="text-error text-xs mt-1">{errors.neighborhood}</div>
      {/if}
    </div>

    <!-- City Field -->
    <div class="form-control flex flex-col">
      <label class="label pb-1" for="{id}-city">
        <span class="label-text">Cidade {required ? '*' : ''}</span>
      </label>
      <input
        id="{id}-city"
        type="text"
        class="input input-bordered input-sm w-full {errors.city && touched.city
          ? 'input-error'
          : ''}"
        bind:value={address.city}
        oninput={(e) => handleInput('city', e)}
        onblur={() => handleBlur('city')}
        placeholder="Nome da cidade"
        {disabled}
        aria-required={required ? 'true' : 'false'}
      />
      {#if errors.city && touched.city}
        <div class="text-error text-xs mt-1">{errors.city}</div>
      {/if}
    </div>

    <!-- State Field -->
    <div class="form-control flex flex-col">
      <label class="label pb-1" for="{id}-state">
        <span class="label-text">Estado {required ? '*' : ''}</span>
      </label>
      <select
        id="{id}-state"
        class="select select-bordered select-sm w-full {errors.state && touched.state
          ? 'select-error'
          : ''}"
        bind:value={address.state}
        onblur={() => handleBlur('state')}
        {disabled}
        aria-required={required ? 'true' : 'false'}
      >
        <option value="" disabled selected>Selecione o estado</option>
        {#each states as state}
          <option value={state.value}>{state.label}</option>
        {/each}
      </select>
      {#if errors.state && touched.state}
        <div class="text-error text-xs mt-1">{errors.state}</div>
      {/if}
    </div>

    <!-- Complement Field -->
    <div class="form-control flex flex-col lg:col-span-2">
      <label class="label pb-1" for="{id}-complement">
        <span class="label-text">Complemento</span>
      </label>
      <input
        id="{id}-complement"
        type="text"
        class="input input-bordered input-sm w-full"
        bind:value={address.complement}
        oninput={(e) => handleInput('complement', e)}
        onblur={() => handleBlur('complement')}
        placeholder="Apartamento, sala, etc."
        {disabled}
      />
    </div>
  </div>

  {#if showRemoveButton}
    <div class="flex justify-end mt-2">
      <button class="btn btn-error btn-sm" onclick={handleRemove} type="button" {disabled}>
        🗑️ Remover
      </button>
    </div>
  {/if}
</div>
