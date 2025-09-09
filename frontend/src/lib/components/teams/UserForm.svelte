<script>
  import { createEventDispatcher } from 'svelte';
  import api from '../../api';

  export let isOpen = false;
  export let user = null;
  export let mode = 'create'; // 'create' or 'edit'

  const dispatch = createEventDispatcher();

  let loading = false;
  let error = null;

  // Form data
  let formData = {
    // User fields
    email: '',
    password: '',
    password_confirmation: '',

    // User Profile fields
    name: '',
    last_name: '',
    role: 'lawyer',
    status: 'active',
    gender: '',
    oab: '',
    rg: '',
    cpf: '',
    nationality: 'brazilian',
    civil_status: 'single',
    birth: '',
    mother_name: '',

    // Contact info
    phone_number: '',

    // Address
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    zip_code: ''
  };

  // Role options
  const roleOptions = [
    { value: 'lawyer', label: 'Advogado' },
    { value: 'paralegal', label: 'Paralegal' },
    { value: 'trainee', label: 'Estagiário' },
    { value: 'secretary', label: 'Secretário' },
    { value: 'counter', label: 'Contador' },
    { value: 'excounter', label: 'Ex-Contador' },
    { value: 'representant', label: 'Representante' }
  ];

  const statusOptions = [
    { value: 'active', label: 'Ativo' },
    { value: 'inactive', label: 'Inativo' },
    { value: 'pending', label: 'Pendente' }
  ];

  const genderOptions = [
    { value: 'male', label: 'Masculino' },
    { value: 'female', label: 'Feminino' },
    { value: 'other', label: 'Outro' }
  ];

  const nationalityOptions = [
    { value: 'brazilian', label: 'Brasileiro' },
    { value: 'foreigner', label: 'Estrangeiro' }
  ];

  const civilStatusOptions = [
    { value: 'single', label: 'Solteiro' },
    { value: 'married', label: 'Casado' },
    { value: 'divorced', label: 'Divorciado' },
    { value: 'widower', label: 'Viúvo' },
    { value: 'union', label: 'União Estável' }
  ];

  // Initialize form data when user changes
  $: if (user && mode === 'edit') {
    formData = {
      email: user.attributes?.access_email || '',
      password: '',
      password_confirmation: '',
      name: user.attributes?.name || '',
      last_name: user.attributes?.last_name || '',
      role: user.attributes?.role || 'lawyer',
      status: user.attributes?.status || 'active',
      gender: user.attributes?.gender || '',
      oab: user.attributes?.oab || '',
      rg: user.attributes?.rg || '',
      cpf: user.attributes?.cpf || '',
      nationality: user.attributes?.nationality || 'brazilian',
      civil_status: user.attributes?.civil_status || 'single',
      birth: user.attributes?.birth || '',
      mother_name: user.attributes?.mother_name || '',
      phone_number: user.attributes?.phones?.[0]?.phone_number || '',
      street: user.attributes?.addresses?.[0]?.street || '',
      number: user.attributes?.addresses?.[0]?.number || '',
      complement: user.attributes?.addresses?.[0]?.complement || '',
      neighborhood: user.attributes?.addresses?.[0]?.neighborhood || '',
      city: user.attributes?.addresses?.[0]?.city || '',
      state: user.attributes?.addresses?.[0]?.state || '',
      zip_code: user.attributes?.addresses?.[0]?.zip_code || ''
    };
  }

  async function handleSubmit() {
    try {
      loading = true;
      error = null;

      if (mode === 'create') {
        // Create new user with profile
        const createData = {
          user_profile: {
            name: formData.name,
            last_name: formData.last_name,
            role: formData.role,
            status: formData.status,
            gender: formData.gender,
            oab: formData.oab,
            rg: formData.rg,
            cpf: formData.cpf,
            nationality: formData.nationality,
            civil_status: formData.civil_status,
            birth: formData.birth,
            mother_name: formData.mother_name,
            user_attributes: {
              email: formData.email,
              password: formData.password,
              password_confirmation: formData.password_confirmation
            },
            phones_attributes: formData.phone_number
              ? [{ phone_number: formData.phone_number }]
              : [],
            addresses_attributes:
              formData.street && formData.city
                ? [
                  {
                    street: formData.street,
                    number: formData.number,
                    complement: formData.complement,
                    neighborhood: formData.neighborhood,
                    city: formData.city,
                    state: formData.state,
                    zip_code: formData.zip_code
                  }
                ]
                : []
          }
        };

        const response = await api.users.createUserProfile(createData);

        if (response.success !== false) {
          dispatch('saved', {
            success: true,
            message: 'Usuário criado com sucesso!'
          });
        } else {
          error = response.message || 'Erro ao criar usuário';
        }
      } else {
        // Update existing user profile
        const updateData = {
          user_profile: {
            name: formData.name,
            last_name: formData.last_name,
            role: formData.role,
            status: formData.status,
            gender: formData.gender,
            oab: formData.oab,
            rg: formData.rg,
            cpf: formData.cpf,
            nationality: formData.nationality,
            civil_status: formData.civil_status,
            birth: formData.birth,
            mother_name: formData.mother_name
          }
        };

        await api.users.updateUserProfile(user.id, updateData);

        dispatch('saved', {
          success: true,
          message: 'Usuário atualizado com sucesso!'
        });
      }
    } catch (err) {
      error = err.message || 'Erro ao salvar usuário';
      // console.error('Error saving user:', err);
    } finally {
      loading = false;
    }
  }

  function handleClose() {
    dispatch('close');
  }

  function resetForm() {
    formData = {
      email: '',
      password: '',
      password_confirmation: '',
      name: '',
      last_name: '',
      role: 'lawyer',
      status: 'active',
      gender: '',
      oab: '',
      rg: '',
      cpf: '',
      nationality: 'brazilian',
      civil_status: 'single',
      birth: '',
      mother_name: '',
      phone_number: '',
      street: '',
      number: '',
      complement: '',
      neighborhood: '',
      city: '',
      state: '',
      zip_code: ''
    };
    error = null;
  }

  // Reset form when modal opens for create mode
  $: if (isOpen && mode === 'create') {
    resetForm();
  }
</script>

<!-- Modal -->
{#if isOpen}
  <div class="modal modal-open">
    <div class="modal-box w-11/12 max-w-4xl max-h-[90vh] overflow-y-auto">
      <div class="flex justify-between items-center mb-6">
        <h3 class="font-bold text-lg">
          {mode === 'create' ? 'Criar Novo Usuário' : 'Editar Usuário'}
        </h3>
        <button class="btn btn-sm btn-circle btn-ghost" on:click={handleClose} disabled={loading}>
          ✕
        </button>
      </div>

      <!-- Error Alert -->
      {#if error}
        <div class="alert alert-error mb-4">
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
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>{error}</span>
        </div>
      {/if}

      <form on:submit|preventDefault={handleSubmit}>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Basic Information -->
          <div class="col-span-full">
            <h4 class="text-lg font-semibold mb-4 border-b pb-2">Informações Básicas</h4>
          </div>

          {#if mode === 'create'}
            <div class="form-control">
              <label class="label" for="email-input">
                <span class="label-text font-medium">Email *</span>
              </label>
              <input
                id="email-input"
                type="email"
                bind:value={formData.email}
                class="input input-bordered w-full"
                required
                disabled={loading}
              />
            </div>

            <div class="form-control">
              <label class="label" for="password-input">
                <span class="label-text font-medium">Senha *</span>
              </label>
              <input
                id="password-input"
                type="password"
                bind:value={formData.password}
                class="input input-bordered w-full"
                required
                disabled={loading}
                minlength="6"
              />
            </div>

            <div class="form-control">
              <label class="label" for="password-confirmation-input">
                <span class="label-text font-medium">Confirmar Senha *</span>
              </label>
              <input
                id="password-confirmation-input"
                type="password"
                bind:value={formData.password_confirmation}
                class="input input-bordered w-full"
                required
                disabled={loading}
                minlength="6"
              />
            </div>
          {/if}

          <div class="form-control">
            <label class="label" for="name-input">
              <span class="label-text font-medium">Nome *</span>
            </label>
            <input
              id="name-input"
              type="text"
              bind:value={formData.name}
              class="input input-bordered w-full"
              required
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="last-name-input">
              <span class="label-text font-medium">Sobrenome</span>
            </label>
            <input
              id="last-name-input"
              type="text"
              bind:value={formData.last_name}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="role-select">
              <span class="label-text font-medium">Função *</span>
            </label>
            <select
              id="role-select"
              bind:value={formData.role}
              class="select select-bordered w-full"
              required
              disabled={loading}
            >
              {#each roleOptions as option}
                <option value={option.value}>{option.label}</option>
              {/each}
            </select>
          </div>

          <div class="form-control">
            <label class="label" for="status-select">
              <span class="label-text font-medium">Status</span>
            </label>
            <select
              id="status-select"
              bind:value={formData.status}
              class="select select-bordered w-full"
              disabled={loading}
            >
              {#each statusOptions as option}
                <option value={option.value}>{option.label}</option>
              {/each}
            </select>
          </div>

          <!-- Personal Information -->
          <div class="col-span-full mt-4">
            <h4 class="text-lg font-semibold mb-4 border-b pb-2">Informações Pessoais</h4>
          </div>

          <div class="form-control">
            <label class="label" for="gender-select">
              <span class="label-text font-medium">Gênero</span>
            </label>
            <select
              id="gender-select"
              bind:value={formData.gender}
              class="select select-bordered w-full"
              disabled={loading}
            >
              <option value="">Selecionar</option>
              {#each genderOptions as option}
                <option value={option.value}>{option.label}</option>
              {/each}
            </select>
          </div>

          <div class="form-control">
            <label class="label" for="oab-input">
              <span class="label-text font-medium">OAB</span>
            </label>
            <input
              id="oab-input"
              type="text"
              bind:value={formData.oab}
              class="input input-bordered w-full"
              disabled={loading}
              placeholder="Ex: 123456 OAB/SP"
            />
          </div>

          <div class="form-control">
            <label class="label" for="rg-input">
              <span class="label-text font-medium">RG</span>
            </label>
            <input
              id="rg-input"
              type="text"
              bind:value={formData.rg}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="cpf-input">
              <span class="label-text font-medium">CPF</span>
            </label>
            <input
              id="cpf-input"
              type="text"
              bind:value={formData.cpf}
              class="input input-bordered w-full"
              disabled={loading}
              placeholder="000.000.000-00"
            />
          </div>

          <div class="form-control">
            <label class="label" for="nationality-select">
              <span class="label-text font-medium">Nacionalidade</span>
            </label>
            <select
              id="nationality-select"
              bind:value={formData.nationality}
              class="select select-bordered w-full"
              disabled={loading}
            >
              {#each nationalityOptions as option}
                <option value={option.value}>{option.label}</option>
              {/each}
            </select>
          </div>

          <div class="form-control">
            <label class="label" for="civil-status-select">
              <span class="label-text font-medium">Estado Civil</span>
            </label>
            <select
              id="civil-status-select"
              bind:value={formData.civil_status}
              class="select select-bordered w-full"
              disabled={loading}
            >
              {#each civilStatusOptions as option}
                <option value={option.value}>{option.label}</option>
              {/each}
            </select>
          </div>

          <div class="form-control">
            <label class="label" for="birth-input">
              <span class="label-text font-medium">Data de Nascimento</span>
            </label>
            <input
              id="birth-input"
              type="date"
              bind:value={formData.birth}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="mother-name-input">
              <span class="label-text font-medium">Nome da Mãe</span>
            </label>
            <input
              id="mother-name-input"
              type="text"
              bind:value={formData.mother_name}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <!-- Contact Information -->
          <div class="col-span-full mt-4">
            <h4 class="text-lg font-semibold mb-4 border-b pb-2">Informações de Contato</h4>
          </div>

          <div class="form-control col-span-full">
            <label class="label" for="phone-input">
              <span class="label-text font-medium">Telefone</span>
            </label>
            <input
              id="phone-input"
              type="tel"
              bind:value={formData.phone_number}
              class="input input-bordered w-full"
              disabled={loading}
              placeholder="(11) 99999-9999"
            />
          </div>

          <!-- Address Information -->
          <div class="col-span-full mt-4">
            <h4 class="text-lg font-semibold mb-4 border-b pb-2">Endereço</h4>
          </div>

          <div class="form-control">
            <label class="label" for="zip-code-input">
              <span class="label-text font-medium">CEP</span>
            </label>
            <input
              id="zip-code-input"
              type="text"
              bind:value={formData.zip_code}
              class="input input-bordered w-full"
              disabled={loading}
              placeholder="00000-000"
            />
          </div>

          <div class="form-control">
            <label class="label" for="street-input">
              <span class="label-text font-medium">Logradouro</span>
            </label>
            <input
              id="street-input"
              type="text"
              bind:value={formData.street}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="number-input">
              <span class="label-text font-medium">Número</span>
            </label>
            <input
              id="number-input"
              type="text"
              bind:value={formData.number}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="complement-input">
              <span class="label-text font-medium">Complemento</span>
            </label>
            <input
              id="complement-input"
              type="text"
              bind:value={formData.complement}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="neighborhood-input">
              <span class="label-text font-medium">Bairro</span>
            </label>
            <input
              id="neighborhood-input"
              type="text"
              bind:value={formData.neighborhood}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="city-input">
              <span class="label-text font-medium">Cidade</span>
            </label>
            <input
              id="city-input"
              type="text"
              bind:value={formData.city}
              class="input input-bordered w-full"
              disabled={loading}
            />
          </div>

          <div class="form-control">
            <label class="label" for="state-input">
              <span class="label-text font-medium">Estado</span>
            </label>
            <input
              id="state-input"
              type="text"
              bind:value={formData.state}
              class="input input-bordered w-full"
              disabled={loading}
              maxlength="2"
              placeholder="SP"
            />
          </div>
        </div>

        <!-- Actions -->
        <div class="modal-action">
          <button type="button" class="btn btn-ghost" on:click={handleClose} disabled={loading}>
            Cancelar
          </button>
          <button type="submit" class="btn btn-primary" disabled={loading}>
            {#if loading}
              <span class="loading loading-spinner loading-sm"></span>
            {/if}
            {mode === 'create' ? 'Criar Usuário' : 'Salvar Alterações'}
          </button>
        </div>
      </form>
    </div>
    <div
      class="modal-backdrop"
      on:click={handleClose}
      role="button"
      tabindex="-1"
      on:keydown={(e) => e.key === 'Escape' && handleClose()}
    ></div>
  </div>
{/if}
