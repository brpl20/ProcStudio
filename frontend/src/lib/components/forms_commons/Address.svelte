<!-- Address.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { BRAZILIAN_STATES } from '../../constants/brazilian-states';
  import type { BrazilianState } from '../../constants/brazilian-states';

  // Brazilian states
  const states: BrazilianState[] = BRAZILIAN_STATES;

  // Props with defaults
  export let address = {
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    zip_code: '',
    address_type: 'main'
  };
  export let index = 0;
  export let showRemoveButton = false;
  export let disabled = false;
  export let id = `address-${index}`; // Unique ID for form fields
  export let wrapperClass = ''; // Additional classes for the wrapper
  export let required = false; // Whether the address fields are required
  export let errors = {}; // Object with field-specific errors
  export let touched = {}; // Object tracking which fields have been touched

  // Set up event dispatcher
  const dispatch = createEventDispatcher();

  // Handle generic input for other fields
  function handleInput(field, event) {
    address[field] = event.target.value;
    dispatch('input', { field, value: address[field], index });
  }

  // Handle generic blur for validation
  function handleBlur(field) {
    touched[field] = true;
    dispatch('blur', { field, value: address[field], index });
  }

  // Handle remove address
  function handleRemove() {
    dispatch('remove', { index });
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
        on:input={(e) => handleInput('street', e)}
        on:blur={() => handleBlur('street')}
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
        on:input={(e) => handleInput('number', e)}
        on:blur={() => handleBlur('number')}
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
        on:input={(e) => handleInput('neighborhood', e)}
        on:blur={() => handleBlur('neighborhood')}
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
        on:input={(e) => handleInput('city', e)}
        on:blur={() => handleBlur('city')}
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
        on:blur={() => handleBlur('state')}
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
        on:input={(e) => handleInput('complement', e)}
        on:blur={() => handleBlur('complement')}
        placeholder="Apartamento, sala, etc."
        {disabled}
      />
    </div>
  </div>

  {#if showRemoveButton}
    <div class="flex justify-end mt-2">
      <button class="btn btn-error btn-sm" on:click={handleRemove} type="button" {disabled}>
        🗑️ Remover
      </button>
    </div>
  {/if}
</div>
