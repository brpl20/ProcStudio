<!-- components/customers/CustomerForm.svelte -->
<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import {
    validateCPFRequired,
    formatCPF,
    validateEmailRequired,
    validatePasswordRequired,
    createPasswordConfirmationValidator,
    validateBirthDateRequired,
    getCapacityFromBirthDate,
    formatBirthDate,
    parseBrazilianDate,
    validationRules
  } from '../../validation';
  // Import API for state data
  import api from '../../api/index';

  export let customer: any = null;
  // TODO: Add Customer type
  // export let customer: Customer | null = null;

  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    submit: any;
    cancel: void;
  }>();

  // Form data key for localStorage
  const FORM_STORAGE_KEY = 'customer_form_draft';

  // Track initial form data for dirty state
  let initialFormData: any;
  let formIsDirty = false;

  // Form data with nested structure for API
  let formData = {
    customer_type: 'physical_person',
    name: '',
    last_name: '',
    status: 'active',
    cpf: '',
    rg: '',
    birth: '',
    gender: 'male',
    civil_status: 'single',
    nationality: 'brazilian',
    capacity: 'able',
    profession: '',
    mother_name: '',
    customer_attributes: {
      email: '',
      password: '',
      password_confirmation: ''
    },
    addresses_attributes: [
      {
        description: 'Home Address',
        zip_code: '',
        street: '',
        city: '',
        number: '',
        neighborhood: '',
        state: ''
      }
    ],
    phones_attributes: [
      {
        phone_number: ''
      }
    ],
    emails_attributes: [
      {
        email: ''
      }
    ],
    bank_accounts_attributes: [
      {
        bank_name: '',
        type_account: 'Corrente',
        agency: '',
        account: '',
        operation: '',
        pix: ''
      }
    ]
  };

  // Brazilian states - will be fetched from API if possible
  let states = [];
  const DEFAULT_STATES = [
    { value: 'AC', label: 'Acre' },
    { value: 'AL', label: 'Alagoas' },
    { value: 'AP', label: 'Amapá' },
    { value: 'AM', label: 'Amazonas' },
    { value: 'BA', label: 'Bahia' },
    { value: 'CE', label: 'Ceará' },
    { value: 'DF', label: 'Distrito Federal' },
    { value: 'ES', label: 'Espírito Santo' },
    { value: 'GO', label: 'Goiás' },
    { value: 'MA', label: 'Maranhão' },
    { value: 'MT', label: 'Mato Grosso' },
    { value: 'MS', label: 'Mato Grosso do Sul' },
    { value: 'MG', label: 'Minas Gerais' },
    { value: 'PA', label: 'Pará' },
    { value: 'PB', label: 'Paraíba' },
    { value: 'PR', label: 'Paraná' },
    { value: 'PE', label: 'Pernambuco' },
    { value: 'PI', label: 'Piauí' },
    { value: 'RJ', label: 'Rio de Janeiro' },
    { value: 'RN', label: 'Rio Grande do Norte' },
    { value: 'RS', label: 'Rio Grande do Sul' },
    { value: 'RO', label: 'Rondônia' },
    { value: 'RR', label: 'Roraima' },
    { value: 'SC', label: 'Santa Catarina' },
    { value: 'SP', label: 'São Paulo' },
    { value: 'SE', label: 'Sergipe' },
    { value: 'TO', label: 'Tocantins' }
  ];

  // Validation errors
  let errors: Record<string, string> = {};
  let touched: Record<string, boolean> = {};
  let capacityMessage = '';

  onMount(async () => {
    // Try to load states from API
    try {
      // Uncomment when API endpoint is available
      // const response = await api.locations.getStates();
      // states = response.data;

      // For now, use default states
      states = DEFAULT_STATES;
    } catch (error) {
      // Failed to load states
      states = DEFAULT_STATES;
    }

    // Try to restore form data from localStorage
    try {
      const savedData = localStorage.getItem(FORM_STORAGE_KEY);
      if (savedData) {
        const parsedData = JSON.parse(savedData);
        formData = { ...formData, ...parsedData };
        // Show notification that data was restored
        // Show notification that data was restored
        // TODO: Replace with proper notification system
      }
    } catch (error) {
      // Failed to restore form data
    }

    // Set initial form state for dirty checking
    initialFormData = JSON.parse(JSON.stringify(formData));
  });

  // Save form data to localStorage when it changes
  function saveFormDraft() {
    if (typeof localStorage !== 'undefined' && formIsDirty) {
      try {
        // Don't save passwords in the draft for security
        const draftData = { ...formData };
        draftData.customer_attributes = {
          ...draftData.customer_attributes,
          password: '',
          password_confirmation: ''
        };

        localStorage.setItem(FORM_STORAGE_KEY, JSON.stringify(draftData));
      } catch (error) {
        // Failed to save form draft
      }
    }
  }

  // Clear saved form data on successful submission
  function clearFormDraft() {
    if (typeof localStorage !== 'undefined') {
      try {
        localStorage.removeItem(FORM_STORAGE_KEY);
      } catch (error) {
        // Failed to clear form draft
      }
    }
  }

  // Reactive declarations for performance optimization
  $: fullName = `${formData.name} ${formData.last_name}`.trim();
  $: capacityInfo = getCapacityFromBirthDate(formData.birth);
  $: if (capacityInfo) {
    formData.capacity = capacityInfo.capacity;
    capacityMessage = capacityInfo.message || '';
  }
  $: formIsDirty = JSON.stringify(formData) !== JSON.stringify(initialFormData);
  $: if (formIsDirty) {
    saveFormDraft();
  }

  // Get gender-based civil status label
  function getCivilStatusLabel(status: string, gender: string): string {
    const labels: Record<string, Record<string, string>> = {
      single: { male: 'Solteiro', female: 'Solteira' },
      married: { male: 'Casado', female: 'Casada' },
      divorced: { male: 'Divorciado', female: 'Divorciada' },
      widower: { male: 'Viúvo', female: 'Viúva' },
      union: { male: 'Em união estável', female: 'Em união estável' }
    };

    return labels[status]?.[gender] || status;
  }

  // Get gender-based nationality label
  function getNationalityLabel(nationality: string, gender: string): string {
    const labels: Record<string, Record<string, string>> = {
      brazilian: { male: 'Brasileiro', female: 'Brasileira' },
      foreigner: { male: 'Estrangeiro', female: 'Estrangeira' }
    };

    return labels[nationality]?.[gender] || nationality;
  }

  // Handle CPF formatting
  function handleCPFInput(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.cpf = formatCPF(input.value);
    validateField('cpf', formData.cpf);
  }

  // Handle birth date change and update capacity
  function handleBirthDateChange(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.birth = input.value;
    validateField('birth', formData.birth);
  }

  const validationSchema = {
    // Personal Information
    name: {
      validate: (value: string) => (value ? '' : 'Nome é obrigatório'),
      message: 'Nome é obrigatório'
    },
    last_name: {
      validate: (value: string) => (value ? '' : 'Sobrenome é obrigatório'),
      message: 'Sobrenome é obrigatório'
    },
    cpf: {
      validate: validateCPFRequired,
      message: 'CPF inválido'
    },
    rg: {
      validate: (value: string) => (value ? '' : 'RG é obrigatório'),
      message: 'RG é obrigatório'
    },
    birth: {
      validate: validateBirthDateRequired,
      message: 'Data de nascimento é obrigatória'
    },
    profession: {
      validate: (value: string) => (value ? '' : 'Profissão é obrigatória'),
      message: 'Profissão é obrigatória'
    },
    mother_name: {
      validate: (value: string) => (value ? '' : 'Nome da mãe é obrigatório'),
      message: 'Nome da mãe é obrigatório'
    },

    // Login Information
    email: {
      validate: validateEmailRequired,
      message: 'Email inválido'
    },
    password: {
      validate: (value: string) => {
        // Only validate password if creating a new customer or if a value is provided for existing customers
        if (!customer || value) {
          return validatePasswordRequired(value) || '';
        }
        return '';
      },
      message: 'Senha inválida'
    },
    password_confirmation: {
      validate: (value: string) => {
        // Only validate if creating a new customer or if password field has a value
        if (!customer || formData.customer_attributes.password) {
          const validator = createPasswordConfirmationValidator(
            () => formData.customer_attributes.password
          );
          return validator(value) || '';
        }
        return '';
      },
      message: 'As senhas não coincidem'
    }
  };

  // Updated validateField function
  function validateField(fieldName: string, value: any) {
    // Handle nested fields (like customer_attributes.email)
    if (fieldName.includes('.')) {
      const [parent, child] = fieldName.split('.');
      // Map nested fields to their root validator
      if (parent === 'customer_attributes') {
        if (child === 'email') {
          fieldName = 'email';
        } else if (child === 'password') {
          fieldName = 'password';
        } else if (child === 'password_confirmation') {
          fieldName = 'password_confirmation';
        }
      }
    }

    // If we have a validator for this field, use it
    if (validationSchema[fieldName]) {
      errors[fieldName] = validationSchema[fieldName].validate(value);
    }
  }

  // Function to validate the entire form at once
  function validateForm(): boolean {
    let isValid = true;

    // Validate all required fields
    for (const [field, validator] of Object.entries(validationSchema)) {
      let valueToValidate;

      // Handle special cases for nested fields
      if (field === 'email') {
        valueToValidate = formData.customer_attributes.email;
      } else if (field === 'password') {
        valueToValidate = formData.customer_attributes.password;
      } else if (field === 'password_confirmation') {
        valueToValidate = formData.customer_attributes.password_confirmation;
      } else {
        // Regular top-level fields
        valueToValidate = formData[field];
      }

      // Run the validation
      const error = validator.validate(valueToValidate);
      errors[field] = error;

      // Mark fields as touched during form submission
      touched[field] = true;

      // Check validity
      if (error) {
        isValid = false;
      }
    }

    return isValid;
  }

  // Helper function to reset validation state
  function resetValidation() {
    errors = {};
    touched = {};
  }

  // Helper to check if a specific field is valid
  function isFieldValid(fieldName: string): boolean {
    return !errors[fieldName] || !touched[fieldName];
  }

  // Helper to get all validation errors as an array
  function getValidationErrors(): string[] {
    return Object.values(errors).filter((error) => error !== '');
  }

  // Handle field blur
  function handleBlur(fieldName: string, value: any) {
    touched[fieldName] = true;
    validateField(fieldName, value);
  }

  // Handle form submission
  function handleSubmit() {
    // Mark all fields as touched
    Object.keys(formData).forEach((key) => (touched[key] = true));

    if (!validateForm()) {
      return;
    }

    // Prepare data for submission
    const submitData = {
      profile_customer: {
        ...formData,
        // Sync email from customer_attributes to emails_attributes
        emails_attributes: [
          {
            email: formData.customer_attributes.email
          }
        ]
      }
    };

    // Clear form draft on successful submission
    clearFormDraft();

    dispatch('submit', submitData);
  }

  function handleCancel() {
    dispatch('cancel');
  }
</script>

<!-- Add beforeunload event to warn about unsaved changes -->
<svelte:window
  on:beforeunload={(event) => {
    if (formIsDirty) {
      event.preventDefault();
      return (event.returnValue = 'Você tem alterações não salvas. Tem certeza que deseja sair?');
    }
  }}
/>

<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 id="customer-form-title" class="card-title">
      {customer ? 'Editar Cliente' : 'Novo Cliente'}
    </h2>

    <!-- Form with ARIA attributes -->
    <form
      on:submit|preventDefault={handleSubmit}
      class="space-y-6"
      aria-labelledby="customer-form-title"
    >
      <!-- Error summary for accessibility -->
      {#if Object.values(errors).some((error) => error && touched[error])}
        <div role="alert" class="alert alert-error mb-4">
          <span>Por favor, corrija os erros abaixo:</span>
          <ul>
            {#each Object.entries(errors) as [field, error]}
              {#if error && touched[field]}
                <li>{error}</li>
              {/if}
            {/each}
          </ul>
        </div>
      {/if}

      <!-- Personal Information Section -->
      <div class="divider" aria-label="Seção de informações pessoais">Informações Pessoais</div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Name -->
        <div class="form-control w-full">
          <label for="name" class="label justify-start">
            <span class="label-text font-medium">Nome *</span>
          </label>
          <input
            id="name"
            type="text"
            class="input input-bordered w-full {errors.name && touched.name ? 'input-error' : ''}"
            bind:value={formData.name}
            on:blur={() => handleBlur('name', formData.name)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.name && touched.name ? 'true' : 'false'}
            aria-describedby={errors.name && touched.name ? 'name-error' : undefined}
            data-testid="customer-name-input"
          />
          {#if errors.name && touched.name}
            <div id="name-error" class="text-error text-sm mt-1">{errors.name}</div>
          {/if}
        </div>

        <!-- Last Name -->
        <div class="form-control w-full">
          <label for="last_name" class="label justify-start">
            <span class="label-text font-medium">Sobrenome *</span>
          </label>
          <input
            id="last_name"
            type="text"
            class="input input-bordered w-full {errors.last_name && touched.last_name
              ? 'input-error'
              : ''}"
            bind:value={formData.last_name}
            on:blur={() => handleBlur('last_name', formData.last_name)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.last_name && touched.last_name ? 'true' : 'false'}
            aria-describedby={errors.last_name && touched.last_name ? 'last_name-error' : undefined}
            data-testid="customer-lastname-input"
          />
          {#if errors.last_name && touched.last_name}
            <div id="last_name-error" class="text-error text-sm mt-1">{errors.last_name}</div>
          {/if}
        </div>

        <!-- CPF -->
        <div class="form-control w-full">
          <label for="cpf" class="label justify-start">
            <span class="label-text font-medium">CPF *</span>
          </label>
          <input
            id="cpf"
            type="text"
            class="input input-bordered w-full {errors.cpf && touched.cpf ? 'input-error' : ''}"
            bind:value={formData.cpf}
            on:input={handleCPFInput}
            on:blur={() => handleBlur('cpf', formData.cpf)}
            disabled={isLoading}
            placeholder="000.000.000-00"
            maxlength="14"
            aria-required="true"
            aria-invalid={errors.cpf && touched.cpf ? 'true' : 'false'}
            aria-describedby={errors.cpf && touched.cpf ? 'cpf-error' : undefined}
            data-testid="customer-cpf-input"
          />
          {#if errors.cpf && touched.cpf}
            <div id="cpf-error" class="text-error text-sm mt-1">{errors.cpf}</div>
          {/if}
        </div>

        <!-- RG -->
        <div class="form-control w-full">
          <label for="rg" class="label justify-start">
            <span class="label-text font-medium">RG *</span>
          </label>
          <input
            id="rg"
            type="text"
            class="input input-bordered w-full {errors.rg && touched.rg ? 'input-error' : ''}"
            bind:value={formData.rg}
            on:blur={() => handleBlur('rg', formData.rg)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.rg && touched.rg ? 'true' : 'false'}
            aria-describedby={errors.rg && touched.rg ? 'rg-error' : undefined}
            data-testid="customer-rg-input"
          />
          {#if errors.rg && touched.rg}
            <div id="rg-error" class="text-error text-sm mt-1">{errors.rg}</div>
          {/if}
        </div>

        <!-- Birth Date -->
        <div class="form-control w-full">
          <label for="birth" class="label justify-start">
            <span class="label-text font-medium">Data de Nascimento *</span>
          </label>
          <input
            id="birth"
            type="date"
            class="input input-bordered w-full {errors.birth && touched.birth ? 'input-error' : ''}"
            bind:value={formData.birth}
            on:change={handleBirthDateChange}
            on:blur={() => handleBlur('birth', formData.birth)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.birth && touched.birth ? 'true' : 'false'}
            aria-describedby={(errors.birth && touched.birth) || capacityMessage
              ? 'birth-message'
              : undefined}
            data-testid="customer-birth-input"
          />
          {#if (errors.birth && touched.birth) || capacityMessage}
            <div
              id="birth-message"
              class="text-sm mt-1 {errors.birth && touched.birth ? 'text-error' : 'text-warning'}"
            >
              {errors.birth || capacityMessage}
            </div>
          {/if}
        </div>

        <!-- Gender -->
        <div class="form-control w-full">
          <label for="gender" class="label justify-start">
            <span class="label-text font-medium">Gênero *</span>
          </label>
          <select
            id="gender"
            class="select select-bordered w-full"
            bind:value={formData.gender}
            disabled={isLoading}
            aria-required="true"
            data-testid="customer-gender-input"
          >
            <option value="male">Masculino</option>
            <option value="female">Feminino</option>
          </select>
        </div>

        <!-- Civil Status -->
        <div class="form-control w-full">
          <label for="civil_status" class="label justify-start">
            <span class="label-text font-medium">Estado Civil *</span>
          </label>
          <select
            id="civil_status"
            class="select select-bordered w-full"
            bind:value={formData.civil_status}
            disabled={isLoading}
            aria-required="true"
            data-testid="customer-civil-status-input"
          >
            <option value="single">{getCivilStatusLabel('single', formData.gender)}</option>
            <option value="married">{getCivilStatusLabel('married', formData.gender)}</option>
            <option value="divorced">{getCivilStatusLabel('divorced', formData.gender)}</option>
            <option value="widower">{getCivilStatusLabel('widower', formData.gender)}</option>
            <option value="union">{getCivilStatusLabel('union', formData.gender)}</option>
          </select>
        </div>

        <!-- Nationality -->
        <div class="form-control w-full">
          <label for="nationality" class="label justify-start">
            <span class="label-text font-medium">Nacionalidade *</span>
          </label>
          <select
            id="nationality"
            class="select select-bordered w-full"
            bind:value={formData.nationality}
            disabled={isLoading}
            aria-required="true"
            data-testid="customer-nationality-input"
          >
            <option value="brazilian">{getNationalityLabel('brazilian', formData.gender)}</option>
            <option value="foreigner">{getNationalityLabel('foreigner', formData.gender)}</option>
          </select>
        </div>

        <!-- Profession -->
        <div class="form-control w-full">
          <label for="profession" class="label justify-start">
            <span class="label-text font-medium">Profissão *</span>
          </label>
          <input
            id="profession"
            type="text"
            class="input input-bordered w-full {errors.profession && touched.profession
              ? 'input-error'
              : ''}"
            bind:value={formData.profession}
            on:blur={() => handleBlur('profession', formData.profession)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.profession && touched.profession ? 'true' : 'false'}
            aria-describedby={errors.profession && touched.profession
              ? 'profession-error'
              : undefined}
            data-testid="customer-profession-input"
          />
          {#if errors.profession && touched.profession}
            <div id="profession-error" class="text-error text-sm mt-1">{errors.profession}</div>
          {/if}
        </div>

        <!-- Mother's Name -->
        <div class="form-control w-full">
          <label for="mother_name" class="label justify-start">
            <span class="label-text font-medium">Nome da Mãe *</span>
          </label>
          <input
            id="mother_name"
            type="text"
            class="input input-bordered w-full {errors.mother_name && touched.mother_name
              ? 'input-error'
              : ''}"
            bind:value={formData.mother_name}
            on:blur={() => handleBlur('mother_name', formData.mother_name)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.mother_name && touched.mother_name ? 'true' : 'false'}
            aria-describedby={errors.mother_name && touched.mother_name
              ? 'mother_name-error'
              : undefined}
            data-testid="customer-mother-name-input"
          />
          {#if errors.mother_name && touched.mother_name}
            <div id="mother_name-error" class="text-error text-sm mt-1">{errors.mother_name}</div>
          {/if}
        </div>

        <!-- Status -->
        <div class="form-control w-full">
          <label for="status" class="label justify-start">
            <span class="label-text font-medium">Status</span>
          </label>
          <select
            id="status"
            class="select select-bordered w-full"
            bind:value={formData.status}
            disabled={isLoading}
            data-testid="customer-status-input"
          >
            <option value="active">Ativo</option>
            <option value="inactive">Inativo</option>
            <option value="deceased">Falecido</option>
          </select>
        </div>
      </div>

      <!-- Login Information Section -->
      <div class="divider" aria-label="Seção de informações de acesso">Informações de Acesso</div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Email -->
        <div class="form-control w-full">
          <label for="email" class="label justify-start">
            <span class="label-text font-medium">Email *</span>
          </label>
          <input
            id="email"
            type="email"
            class="input input-bordered w-full {errors.email && touched.email ? 'input-error' : ''}"
            bind:value={formData.customer_attributes.email}
            on:blur={() => handleBlur('email', formData.customer_attributes.email)}
            disabled={isLoading}
            placeholder="cliente@exemplo.com"
            aria-required="true"
            aria-invalid={errors.email && touched.email ? 'true' : 'false'}
            aria-describedby={errors.email && touched.email ? 'email-error' : undefined}
            data-testid="customer-email-input"
          />
          {#if errors.email && touched.email}
            <div id="email-error" class="text-error text-sm mt-1">{errors.email}</div>
          {/if}
        </div>

        <!-- Phone -->
        <div class="form-control w-full">
          <label for="phone" class="label justify-start">
            <span class="label-text font-medium">Telefone</span>
          </label>
          <input
            id="phone"
            type="tel"
            class="input input-bordered w-full"
            bind:value={formData.phones_attributes[0].phone_number}
            disabled={isLoading}
            placeholder="+55 11 98765-4321"
            data-testid="customer-phone-input"
          />
        </div>

        <!-- Password -->
        <div class="form-control w-full">
          <label for="password" class="label justify-start">
            <span class="label-text font-medium">
              {customer ? 'Nova Senha (deixe em branco para manter)' : 'Senha *'}
            </span>
          </label>
          <input
            id="password"
            type="password"
            class="input input-bordered w-full {errors.password && touched.password
              ? 'input-error'
              : ''}"
            bind:value={formData.customer_attributes.password}
            on:blur={() => handleBlur('password', formData.customer_attributes.password)}
            disabled={isLoading}
            placeholder="Mínimo 6 caracteres"
            aria-required={customer ? 'false' : 'true'}
            aria-invalid={errors.password && touched.password ? 'true' : 'false'}
            aria-describedby={errors.password && touched.password ? 'password-error' : undefined}
            data-testid="customer-password-input"
          />
          {#if errors.password && touched.password}
            <div id="password-error" class="text-error text-sm mt-1">{errors.password}</div>
          {/if}
        </div>

        <!-- Password Confirmation -->
        <div class="form-control w-full">
          <label for="password_confirmation" class="label justify-start">
            <span class="label-text font-medium">
              {customer ? 'Confirmar Nova Senha' : 'Confirmar Senha *'}
            </span>
          </label>
          <input
            id="password_confirmation"
            type="password"
            class="input input-bordered w-full {errors.password_confirmation &&
            touched.password_confirmation
              ? 'input-error'
              : ''}"
            bind:value={formData.customer_attributes.password_confirmation}
            on:blur={() =>
              handleBlur(
                'password_confirmation',
                formData.customer_attributes.password_confirmation
              )}
            disabled={isLoading}
            placeholder="Digite a senha novamente"
            aria-required={customer ? 'false' : 'true'}
            aria-invalid={errors.password_confirmation && touched.password_confirmation
              ? 'true'
              : 'false'}
            aria-describedby={errors.password_confirmation && touched.password_confirmation
              ? 'password_confirmation-error'
              : undefined}
            data-testid="customer-password-confirmation-input"
          />
          {#if errors.password_confirmation && touched.password_confirmation}
            <div id="password_confirmation-error" class="text-error text-sm mt-1">
              {errors.password_confirmation}
            </div>
          {/if}
        </div>
      </div>

      <!-- Address Section -->
      <div class="divider" aria-label="Seção de endereço">Endereço</div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- ZIP Code -->
        <div class="form-control w-full">
          <label for="zip_code" class="label justify-start">
            <span class="label-text font-medium">CEP</span>
          </label>
          <input
            id="zip_code"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.addresses_attributes[0].zip_code}
            disabled={isLoading}
            placeholder="00000-000"
            data-testid="customer-zipcode-input"
          />
        </div>

        <!-- Street -->
        <div class="form-control w-full">
          <label for="street" class="label justify-start">
            <span class="label-text font-medium">Rua</span>
          </label>
          <input
            id="street"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.addresses_attributes[0].street}
            disabled={isLoading}
            data-testid="customer-street-input"
          />
        </div>

        <!-- Number -->
        <div class="form-control w-full">
          <label for="number" class="label justify-start">
            <span class="label-text font-medium">Número</span>
          </label>
          <input
            id="number"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.addresses_attributes[0].number}
            disabled={isLoading}
            data-testid="customer-number-input"
          />
        </div>

        <!-- Neighborhood -->
        <div class="form-control w-full">
          <label for="neighborhood" class="label justify-start">
            <span class="label-text font-medium">Bairro</span>
          </label>
          <input
            id="neighborhood"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.addresses_attributes[0].neighborhood}
            disabled={isLoading}
            data-testid="customer-neighborhood-input"
          />
        </div>

        <!-- City -->
        <div class="form-control w-full">
          <label for="city" class="label justify-start">
            <span class="label-text font-medium">Cidade</span>
          </label>
          <input
            id="city"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.addresses_attributes[0].city}
            disabled={isLoading}
            data-testid="customer-city-input"
          />
        </div>

        <!-- State -->
        <div class="form-control w-full">
          <label for="state" class="label justify-start">
            <span class="label-text font-medium">Estado</span>
          </label>
          <select
            id="state"
            class="select select-bordered w-full"
            bind:value={formData.addresses_attributes[0].state}
            disabled={isLoading}
            data-testid="customer-state-input"
          >
            <option value="">Selecione...</option>
            {#each states as state}
              <option value={state.value}>{state.label}</option>
            {/each}
          </select>
        </div>
      </div>

      <!-- Bank Account Section -->
      <div class="divider" aria-label="Seção de dados bancários">Dados Bancários</div>

      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Bank Name -->
        <div class="form-control w-full">
          <label for="bank_name" class="label justify-start">
            <span class="label-text font-medium">Banco</span>
          </label>
          <input
            id="bank_name"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.bank_accounts_attributes[0].bank_name}
            disabled={isLoading}
            data-testid="customer-bank-name-input"
          />
        </div>

        <!-- Account Type -->
        <div class="form-control w-full">
          <label for="type_account" class="label justify-start">
            <span class="label-text font-medium">Tipo de Conta</span>
          </label>
          <select
            id="type_account"
            class="select select-bordered w-full"
            bind:value={formData.bank_accounts_attributes[0].type_account}
            disabled={isLoading}
            data-testid="customer-account-type-input"
          >
            <option value="Corrente">Corrente</option>
            <option value="Poupança">Poupança</option>
          </select>
        </div>

        <!-- Agency -->
        <div class="form-control w-full">
          <label for="agency" class="label justify-start">
            <span class="label-text font-medium">Agência</span>
          </label>
          <input
            id="agency"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.bank_accounts_attributes[0].agency}
            disabled={isLoading}
            placeholder="0000-0"
            data-testid="customer-agency-input"
          />
        </div>

        <!-- Account -->
        <div class="form-control w-full">
          <label for="account" class="label justify-start">
            <span class="label-text font-medium">Conta</span>
          </label>
          <input
            id="account"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.bank_accounts_attributes[0].account}
            disabled={isLoading}
            placeholder="00000-0"
            data-testid="customer-account-input"
          />
        </div>

        <!-- Operation -->
        <div class="form-control w-full">
          <label for="operation" class="label justify-start">
            <span class="label-text font-medium">Operação</span>
          </label>
          <input
            id="operation"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.bank_accounts_attributes[0].operation}
            disabled={isLoading}
            data-testid="customer-operation-input"
          />
        </div>

        <!-- PIX with reactive options -->
        <div class="form-control w-full">
          <label for="pix" class="label justify-start">
            <span class="label-text font-medium">Chave PIX</span>
          </label>

          <!-- PIX Key Type Options -->
          <div class="flex gap-2 mb-2">
            <button
              type="button"
              class="btn btn-sm btn-outline"
              disabled={!formData.customer_attributes.email || isLoading}
              on:click={() =>
                (formData.bank_accounts_attributes[0].pix = formData.customer_attributes.email)}
              aria-label="Usar e-mail como chave PIX"
              data-testid="pix-email-button"
            >
              E-mail
            </button>

            <button
              type="button"
              class="btn btn-sm btn-outline"
              disabled={!formData.cpf || isLoading}
              on:click={() =>
                (formData.bank_accounts_attributes[0].pix = formData.cpf.replace(/\D/g, ''))}
              aria-label="Usar CPF como chave PIX"
              data-testid="pix-cpf-button"
            >
              CPF
            </button>

            <button
              type="button"
              class="btn btn-sm btn-outline"
              disabled={!formData.phones_attributes[0].phone_number || isLoading}
              on:click={() =>
                (formData.bank_accounts_attributes[0].pix =
                  formData.phones_attributes[0].phone_number.replace(/\D/g, ''))}
              aria-label="Usar telefone como chave PIX"
              data-testid="pix-phone-button"
            >
              Telefone
            </button>
          </div>

          <input
            id="pix"
            type="text"
            class="input input-bordered w-full"
            bind:value={formData.bank_accounts_attributes[0].pix}
            disabled={isLoading}
            data-testid="customer-pix-input"
          />
          <div class="text-sm text-gray-500 mt-2">
            Escolha um dos botões acima para preencher automaticamente.
          </div>
        </div>

        <!-- Unsaved changes warning -->
        {#if formIsDirty}
          <div class="alert alert-info" role="status">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              class="stroke-current shrink-0 w-6 h-6"
              ><path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              ></path></svg
            >
            <span
              >Você tem alterações não salvas. Se sair desta página, os dados preenchidos serão
              salvos temporariamente.</span
            >
          </div>
        {/if}

        <!-- Actions -->
        <div class="card-actions justify-end mt-6">
          <button
            type="button"
            class="btn btn-ghost"
            on:click={handleCancel}
            disabled={isLoading}
            aria-label="Cancelar e voltar"
            data-testid="customer-cancel-button"
          >
            Cancelar
          </button>
          <button
            type="submit"
            class="btn btn-primary"
            disabled={isLoading}
            aria-busy={isLoading ? 'true' : 'false'}
            data-testid="customer-submit-button"
          >
            {#if isLoading}
              <span class="loading loading-spinner"></span>
            {/if}
            {customer ? 'Atualizar' : 'Criar Cliente'}
          </button>
        </div>
      </div>
    </form>
  </div>
</div>
