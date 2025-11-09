<script lang="ts">
  import api from '../api/index';

  // Import the new form components
  import Name from '../components/forms_commons/Name.svelte';
  import LastName from '../components/forms_commons/LastName.svelte';
  import Cpf from '../components/forms_commons/Cpf.svelte';
  import Rg from '../components/forms_commons/Rg.svelte';
  import Gender from '../components/forms_commons/Gender.svelte';
  import Nationality from '../components/forms_commons/Nationality.svelte';
  import CivilStatus from '../components/forms_commons/CivilStatus.svelte';
  import Birth from '../components/forms_commons/Birth.svelte';
  import Phone from '../components/forms_commons/Phone.svelte';
  import Address from '../components/forms_commons/Address.svelte';
  import OabId from '../components/forms_commons/OabId.svelte';

  import { BRAZILIAN_STATES } from '../constants/brazilian-states';

  export let isOpen = false;
  export let userData: any = {};
  export let missingFields: string[] = [];
  export let onComplete: (result: any) => void = () => {};
  export let onClose: () => void = () => {};

  // Check if critical fields are missing (indicating API failure or incomplete data)
  const hasCriticalMissingFields =
    missingFields.includes('name') ||
    missingFields.includes('last_name') ||
    missingFields.includes('role') ||
    missingFields.includes('address');

  const formData = {
    // Basic fields
    name: userData.name || '',
    last_name: userData.last_name || '',
    role: userData.role || '',
    oab: userData.oab || '',
    cpf: '',
    rg: '',
    gender: userData.gender || '',
    civil_status: '',
    nationality: 'brazilian',
    birth: '',
    phone: '',
    // Address object for the Address component
    address: {
      street: userData.address?.street || '',
      number: userData.address?.number || '',
      complement: '',
      neighborhood: userData.address?.neighborhood || '',
      city: userData.address?.city || '',
      state: userData.address?.state || '',
      zip_code: userData.address?.zip_code || '',
      address_type: 'main' // Used internally by Address component
    }
  };

  // Pre-populate phone if available
  if (userData.phone) {
    formData.phone = userData.phone;
  }

  let loading = false;
  let message = '';
  let isSuccess = false;

  // Track errors for each field
  let errors: Record<string, string | null> = {};
  let touched: Record<string, boolean> = {};

  const roleOptions = [
    { value: 'lawyer', label: 'Advogado(a)' },
    { value: 'secretary', label: 'Secretário(a)' },
    { value: 'intern', label: 'Estagiário(a)' },
    { value: 'paralegal', label: 'Paralegal' },
    { value: 'accountant', label: 'Contador(a)' }
  ];

  function isFieldRequired(fieldName: string): boolean {
    return missingFields.includes(fieldName);
  }

  function closeModal() {
    if (!loading) {
      onClose();
    }
  }

  function handleBackdropClick(event: MouseEvent) {
    if (event.target === event.currentTarget) {
      closeModal();
    }
  }

  async function handleSubmit() {
    // Validate required fields
    const requiredFieldErrors: string[] = [];

    missingFields.forEach((field) => {
      if (field === 'address') {
        if (
          !formData.address.street ||
          !formData.address.number ||
          !formData.address.city ||
          !formData.address.state ||
          !formData.address.zip_code
        ) {
          requiredFieldErrors.push('endereço');
        }
      } else if (
        !formData[field as keyof typeof formData] ||
        (typeof formData[field as keyof typeof formData] === 'string' &&
          formData[field as keyof typeof formData].trim() === '')
      ) {
        requiredFieldErrors.push(field);
      }
    });

    if (requiredFieldErrors.length > 0) {
      message = `Campos obrigatórios não preenchidos: ${requiredFieldErrors.join(', ')}`;
      isSuccess = false;
      return;
    }

    loading = true;
    message = '';

    try {
      // Prepare data with nested attributes for address
      const dataToSend: any = {};

      // Add basic fields including OAB
      Object.keys(formData).forEach((key) => {
        if (key !== 'address') {
          const value = formData[key as keyof typeof formData];
          if (value && typeof value === 'string' && value.trim() !== '') {
            dataToSend[key] = value.trim();
          }
        }
      });

      // Add address as nested attributes if needed
      if (isFieldRequired('address') && formData.address.street) {
        dataToSend.addresses_attributes = [
          {
            street: formData.address.street,
            number: formData.address.number,
            complement: formData.address.complement || '',
            neighborhood: formData.address.neighborhood || '',
            city: formData.address.city,
            state: formData.address.state,
            zip_code: formData.address.zip_code
            // Removed description field - backend might not have it
          }
        ];
      }

      // Add phone as nested attribute
      if (formData.phone) {
        dataToSend.phones_attributes = [
          {
            phone_number: formData.phone
          }
        ];
      }

      const result = await api.auth.completeProfile(dataToSend);
      message = 'Perfil completado com sucesso!';
      isSuccess = true;

      // Wait a bit to show success message
      setTimeout(() => {
        onComplete(result);
      }, 1500);
    } catch (error: any) {
      message = error.message || 'Erro ao completar perfil';
      isSuccess = false;
    } finally {
      loading = false;
    }
  }
</script>

<!-- Modal Backdrop -->
{#if isOpen}
  <div
    class="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 modal modal-open"
    onclick={handleBackdropClick}
    role="button"
    tabindex="0"
    onkeydown={(e) => e.key === 'Escape' && closeModal()}
  >
    <div class="modal-box max-w-5xl max-h-[90vh] overflow-y-auto" role="dialog" aria-modal="true">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-base-content">
          {hasCriticalMissingFields ? 'Complete seu Cadastro' : 'Complete seu Perfil'}
        </h2>
        <button
          type="button"
          class="btn btn-circle btn-ghost"
          onclick={closeModal}
          disabled={loading}
        >
          ✕
        </button>
      </div>

      <div>
        {#if userData.oab || userData.name}
          <div class="alert alert-info mb-6">
            <div>
              <div class="font-semibold">Informações do Usuário</div>
              <p class="text-sm mt-2">
                {#if userData.name}
                  <strong>Nome:</strong> {userData.name} {userData.last_name || ''}
                {/if}
              </p>
              {#if userData.oab}
                <p class="text-sm"><strong>OAB:</strong> {userData.oab}</p>
              {/if}
              {#if userData.role}
                <p class="text-sm"><strong>Função:</strong> {userData.role}</p>
              {/if}
            </div>
          </div>
        {/if}

        {#if hasCriticalMissingFields}
          <div class="alert alert-warning mb-6">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              class="stroke-current shrink-0 h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
            <span
              >Alguns dados não foram preenchidos automaticamente. Por favor, complete as
              informações manualmente.</span
            >
          </div>
        {/if}

        <form onsubmit={(e) => { e.preventDefault(); handleSubmit(); }}>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Name field (shown if missing) -->
            {#if isFieldRequired('name')}
              <Name
                bind:value={formData.name}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- Last name field (shown if missing) -->
            {#if isFieldRequired('last_name')}
              <LastName
                bind:value={formData.last_name}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- Role field (shown if missing) -->
            {#if isFieldRequired('role')}
              <div class="form-control">
                <label class="label" for="role">
                  <span class="label-text font-semibold">Função *</span>
                </label>
                <select
                  id="role"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.role}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each roleOptions as option}
                    <option value={option.value}>{option.label}</option>
                  {/each}
                </select>
              </div>
            {/if}

            <!-- OAB field (shown for lawyers or when missing) -->
            {#if (formData.role === 'lawyer' || userData.role === 'lawyer') && (isFieldRequired('oab') || !userData.oab)}
              <OabId
                bind:value={formData.oab}
                type="lawyer"
                required={formData.role === 'lawyer'}
                disabled={loading}
              />
            {/if}

            <!-- CPF field -->
            {#if isFieldRequired('cpf')}
              <Cpf
                bind:value={formData.cpf}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- RG field -->
            {#if isFieldRequired('rg')}
              <Rg
                bind:value={formData.rg}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- Gender field -->
            {#if isFieldRequired('gender')}
              <Gender
                bind:value={formData.gender}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- Civil Status field -->
            {#if isFieldRequired('civil_status')}
              <CivilStatus
                bind:value={formData.civil_status}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- Nationality field -->
            {#if isFieldRequired('nationality')}
              <Nationality
                bind:value={formData.nationality}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- Birth field -->
            {#if isFieldRequired('birth')}
              <Birth
                bind:value={formData.birth}
                required={true}
                disabled={loading}
              />
            {/if}

            <!-- Phone field -->
            {#if isFieldRequired('phone') || !userData.phone}
              <div class="md:col-span-2">
                <Phone
                  bind:value={formData.phone}
                  required={isFieldRequired('phone')}
                  disabled={loading}
                />
              </div>
            {/if}

            <!-- Address fields -->
            {#if isFieldRequired('address')}
              <div class="md:col-span-2">
                <h3 class="text-lg font-semibold mb-3">Endereço *</h3>
                <Address
                  bind:address={formData.address}
                  required={true}
                  disabled={loading}
                  bind:errors={errors}
                  bind:touched={touched}
                />
              </div>
            {/if}
          </div>

          <!-- Action buttons -->
          <div class="modal-action">
            {#if message}
              <div class="flex-1">
                <div class="alert {isSuccess ? 'alert-success' : 'alert-error'}">
                  <span>{message}</span>
                </div>
              </div>
            {/if}

            {#if !isSuccess}
              <button
                type="button"
                class="btn btn-ghost"
                onclick={closeModal}
                disabled={loading}
              >
                Cancelar
              </button>
              <button
                type="submit"
                class="btn btn-primary"
                disabled={loading}
              >
                {#if loading}
                  <span class="loading loading-spinner"></span>
                  Salvando...
                {:else}
                  Completar Cadastro
                {/if}
              </button>
            {/if}
          </div>
        </form>
      </div>
    </div>
  </div>
{/if}