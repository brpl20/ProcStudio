
<script lang="ts">
  import api from '../api/index';
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
    // Address fields
    address: {
      street: '',
      number: '',
      neighborhood: '',
      city: '',
      state: '',
      zip_code: '',
      description: 'Principal'
    }
  };

  // Pre-populate with OAB data if available
  if (userData.address) {
    formData.address.street = userData.address.street || '';
    formData.address.city = userData.address.city || '';
    formData.address.state = userData.address.state || '';
    formData.address.zip_code = userData.address.zip_code || '';
  }
  if (userData.phone) {
    formData.phone = userData.phone;
  }

  let loading = false;
  let message = '';
  let isSuccess = false;

  // Opções para os selects
  const genderOptions = [
    { value: 'male', label: 'Masculino' },
    { value: 'female', label: 'Feminino' }
  ];

  const civilStatusOptions = [
    { value: 'single', labelMale: 'Solteiro', labelFemale: 'Solteira' },
    { value: 'married', labelMale: 'Casado', labelFemale: 'Casada' },
    { value: 'divorced', labelMale: 'Divorciado', labelFemale: 'Divorciada' },
    { value: 'widower', labelMale: 'Viúvo', labelFemale: 'Viúva' },
    { value: 'union', labelMale: 'União Estável', labelFemale: 'União Estável' }
  ];

  const nationalityOptions = [
    { value: 'brazilian', label: 'Brasileira' },
    { value: 'foreigner', label: 'Estrangeira' }
  ];

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

  function formatPhoneInput(event: Event) {
    const input = event.target as HTMLInputElement;
    let value = input.value.replace(/\D/g, '');

    if (value.length <= 11) {
      if (value.length >= 11) {
        value = value.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
      } else if (value.length >= 10) {
        value = value.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
      } else if (value.length >= 6) {
        value = value.replace(/(\d{2})(\d{4})(\d*)/, '($1) $2-$3');
      } else if (value.length >= 2) {
        value = value.replace(/(\d{2})(\d*)/, '($1) $2');
      }
    }

    formData.phone = value;
  }

  function formatZipCode(event: Event) {
    const input = event.target as HTMLInputElement;
    let value = input.value.replace(/\D/g, '');

    if (value.length <= 8) {
      if (value.length >= 5) {
        value = value.replace(/(\d{5})(\d*)/, '$1-$2');
      }
    }

    formData.address.zip_code = value;
  }

  function validateBrazilianPhone(phone: string): boolean {
    const phonePattern = /^\(\d{2}\)\s\d{4,5}-\d{4}$/;
    return phonePattern.test(phone);
  }

  function getCivilStatusLabel(option: any): string {
    const currentGender = userData?.gender || formData.gender;
    if (currentGender === 'female') {
      return option.labelFemale;
    }
    return option.labelMale;
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
        if (!formData.address.street || !formData.address.number ||
            !formData.address.city || !formData.address.state ||
            !formData.address.zip_code) {
          requiredFieldErrors.push('endereço');
        }
      } else if (!formData[field as keyof typeof formData] ||
                 (typeof formData[field as keyof typeof formData] === 'string' &&
                  formData[field as keyof typeof formData].trim() === '')) {
        requiredFieldErrors.push(field);
      }
    });

    if (requiredFieldErrors.length > 0) {
      message = `Campos obrigatórios não preenchidos: ${requiredFieldErrors.join(', ')}`;
      isSuccess = false;
      return;
    }

    // CPF validation
    if (isFieldRequired('cpf') && formData.cpf) {
      const cpfPattern = /^\d{3}\.\d{3}\.\d{3}-\d{2}$|^\d{11}$/;
      if (!cpfPattern.test(formData.cpf)) {
        message = 'CPF deve estar no formato: 000.000.000-00 ou 00000000000';
        isSuccess = false;
        return;
      }
    }

    // Birth date validation
    if (isFieldRequired('birth') && formData.birth) {
      const birthDate = new Date(formData.birth);
      const today = new Date();
      if (birthDate >= today) {
        message = 'Data de nascimento deve ser anterior à data atual';
        isSuccess = false;
        return;
      }
    }

    // Phone validation
    if (isFieldRequired('phone') && formData.phone) {
      if (!validateBrazilianPhone(formData.phone)) {
        message = 'Telefone deve estar no formato: (XX) XXXXX-XXXX ou (XX) XXXX-XXXX';
        isSuccess = false;
        return;
      }
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
        dataToSend.addresses_attributes = [{
          street: formData.address.street,
          number: formData.address.number,
          neighborhood: formData.address.neighborhood || '',
          city: formData.address.city,
          state: formData.address.state,
          zip_code: formData.address.zip_code,
          description: formData.address.description
        }];
      }

      // Add phone as nested attribute
      if (formData.phone) {
        dataToSend.phones_attributes = [{
          phone_number: formData.phone
        }];
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
    class="modal modal-open"
    on:click={handleBackdropClick}
    role="button"
    tabindex="0"
    on:keydown={(e) => e.key === 'Escape' && closeModal()}
  >
    <div class="modal-box max-w-5xl max-h-[90vh] overflow-y-auto" role="dialog" aria-modal="true">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-base-content">
          {hasCriticalMissingFields ? 'Complete seu Cadastro' : 'Complete seu Perfil'}
        </h2>
        <button
          type="button"
          class="btn btn-circle btn-ghost"
          on:click={closeModal}
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
            <svg xmlns="http://www.w3.org/2000/svg" class="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
            </svg>
            <span>Alguns dados não foram preenchidos automaticamente. Por favor, complete as informações manualmente.</span>
          </div>
        {/if}

        <form on:submit|preventDefault={handleSubmit}>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <!-- Name field (shown if missing) -->
            {#if isFieldRequired('name')}
              <div class="form-control">
                <label class="label" for="name">
                  <span class="label-text font-semibold">Nome *</span>
                </label>
                <input
                  type="text"
                  id="name"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.name}
                  placeholder="João"
                  required
                  disabled={loading}
                />
              </div>
            {/if}

            <!-- Last name field (shown if missing) -->
            {#if isFieldRequired('last_name')}
              <div class="form-control">
                <label class="label" for="last_name">
                  <span class="label-text font-semibold">Sobrenome *</span>
                </label>
                <input
                  type="text"
                  id="last_name"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.last_name}
                  placeholder="Silva"
                  required
                  disabled={loading}
                />
              </div>
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
              <div class="form-control">
                <label class="label" for="oab">
                  <span class="label-text font-semibold">OAB *</span>
                </label>
                <input
                  type="text"
                  id="oab"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.oab}
                  placeholder="PR123456 ou 123456"
                  required={formData.role === 'lawyer'}
                  disabled={loading}
                />
                <label class="label">
                  <span class="label-text-alt">Digite apenas os números ou o formato completo (ex: PR123456)</span>
                </label>
              </div>
            {/if}

            <!-- CPF field -->
            {#if isFieldRequired('cpf')}
              <div class="form-control">
                <label class="label" for="cpf">
                  <span class="label-text font-semibold">CPF *</span>
                </label>
                <input
                  type="text"
                  id="cpf"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.cpf}
                  placeholder="000.000.000-00"
                  required
                  disabled={loading}
                />
              </div>
            {/if}

            <!-- RG field -->
            {#if isFieldRequired('rg')}
              <div class="form-control">
                <label class="label" for="rg">
                  <span class="label-text font-semibold">RG *</span>
                </label>
                <input
                  type="text"
                  id="rg"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.rg}
                  placeholder="00.000.000-0"
                  required
                  disabled={loading}
                />
              </div>
            {/if}

            <!-- Gender field -->
            {#if isFieldRequired('gender')}
              <div class="form-control">
                <label class="label" for="gender">
                  <span class="label-text font-semibold">Gênero *</span>
                </label>
                <select
                  id="gender"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.gender}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each genderOptions as option}
                    <option value={option.value}>{option.label}</option>
                  {/each}
                </select>
              </div>
            {/if}

            <!-- Civil Status field -->
            {#if isFieldRequired('civil_status')}
              <div class="form-control">
                <label class="label" for="civil_status">
                  <span class="label-text font-semibold">Estado Civil *</span>
                </label>
                <select
                  id="civil_status"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.civil_status}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each civilStatusOptions as option}
                    <option value={option.value}>{getCivilStatusLabel(option)}</option>
                  {/each}
                </select>
              </div>
            {/if}

            <!-- Nationality field -->
            {#if isFieldRequired('nationality')}
              <div class="form-control">
                <label class="label" for="nationality">
                  <span class="label-text font-semibold">Nacionalidade *</span>
                </label>
                <select
                  id="nationality"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.nationality}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each nationalityOptions as option}
                    <option value={option.value}>{option.label}</option>
                  {/each}
                </select>
              </div>
            {/if}

            <!-- Birth date field -->
            {#if isFieldRequired('birth')}
              <div class="form-control">
                <label class="label" for="birth">
                  <span class="label-text font-semibold">Data de Nascimento *</span>
                </label>
                <input
                  type="date"
                  id="birth"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.birth}
                  required
                  disabled={loading}
                />
              </div>
            {/if}

            <!-- Phone field -->
            {#if isFieldRequired('phone')}
              <div class="form-control">
                <label class="label" for="phone">
                  <span class="label-text font-semibold">Telefone *</span>
                </label>
                <input
                  type="tel"
                  id="phone"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.phone}
                  placeholder="(45) 98405-5504"
                  required
                  disabled={loading}
                  on:input={formatPhoneInput}
                  maxlength="15"
                />
              </div>
            {/if}
          </div>

          <!-- Address Section (shown if address is missing) -->
          {#if isFieldRequired('address')}
            <div class="divider mt-6">Endereço</div>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div class="form-control">
                <label class="label" for="zip_code">
                  <span class="label-text font-semibold">CEP *</span>
                </label>
                <input
                  type="text"
                  id="zip_code"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.address.zip_code}
                  placeholder="00000-000"
                  required
                  disabled={loading}
                  on:input={formatZipCode}
                  maxlength="9"
                />
              </div>

              <div class="form-control">
                <label class="label" for="street">
                  <span class="label-text font-semibold">Rua/Avenida *</span>
                </label>
                <input
                  type="text"
                  id="street"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.address.street}
                  placeholder="Rua das Flores"
                  required
                  disabled={loading}
                />
              </div>

              <div class="form-control">
                <label class="label" for="number">
                  <span class="label-text font-semibold">Número *</span>
                </label>
                <input
                  type="text"
                  id="number"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.address.number}
                  placeholder="123"
                  required
                  disabled={loading}
                />
              </div>

              <div class="form-control">
                <label class="label" for="neighborhood">
                  <span class="label-text font-semibold">Bairro</span>
                </label>
                <input
                  type="text"
                  id="neighborhood"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.address.neighborhood}
                  placeholder="Centro"
                  disabled={loading}
                />
              </div>

              <div class="form-control">
                <label class="label" for="city">
                  <span class="label-text font-semibold">Cidade *</span>
                </label>
                <input
                  type="text"
                  id="city"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.address.city}
                  placeholder="São Paulo"
                  required
                  disabled={loading}
                />
              </div>

              <div class="form-control">
                <label class="label" for="state">
                  <span class="label-text font-semibold">Estado *</span>
                </label>
                <select
                  id="state"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.address.state}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each BRAZILIAN_STATES as state}
                    <option value={state.value}>{state.label}</option>
                  {/each}
                </select>
              </div>
            </div>
          {/if}

          {#if message}
            <div class="alert mt-6" class:alert-success={isSuccess} class:alert-error={!isSuccess}>
              <span>{message}</span>
            </div>
          {/if}

          <div class="modal-action">
            <button type="button" class="btn btn-outline" on:click={closeModal} disabled={loading}>
              Cancelar
            </button>
            <button type="submit" class="btn btn-primary" class:loading disabled={loading}>
              {loading ? 'Salvando...' : 'Completar Cadastro'}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
{/if}