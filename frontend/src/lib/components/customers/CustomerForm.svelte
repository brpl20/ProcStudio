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

  // File upload data
  let uploadedFiles: File[] = [];
  let fileInput: HTMLInputElement;
  
  // Toggle for social security information
  let showSocialSecurityInfo = false;
  
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
    deceased_at: '',
    number_benefit: '',
    nit: '',
    inss_password: '',
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

  // Guardian form data (for unable persons)
  const guardianFormData = {
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

  // Multi-step form control
  let currentStep = 1;
  let totalSteps = 2; // Default: 1-uploads, 2-client data
  let showGuardianForm = false;

  // Checkbox states for copying data
  let useSameAddress = false;
  let useSameBankAccount = false;

  // Update total steps based on capacity
  $: {
    if (formData.capacity === 'unable' || formData.capacity === 'relatively') {
      totalSteps = 3; // 1-uploads, 2-client data, 3-guardian data
      showGuardianForm = true;
    } else {
      totalSteps = 2; // 1-uploads, 2-client data
      showGuardianForm = false;
      if (currentStep > 2) {
        currentStep = 2;
      }
    }
  }

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
  const guardianErrors: Record<string, string> = {};
  const guardianTouched: Record<string, boolean> = {};
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
    // Show age-based warning message
    capacityMessage = capacityInfo.message || '';
  }
  
  // Age validation for guardian
  $: guardianAgeValidation = formData.birth && guardianFormData.birth 
    ? validateGuardianAge(guardianFormData.birth, formData.birth)
    : { isValid: true, message: '' };
  $: formIsDirty = JSON.stringify(formData) !== JSON.stringify(initialFormData);
  $: if (formIsDirty) {
    saveFormDraft();
  }
  $: isProfessionRequired = formData.capacity !== 'unable';
  $: isEmailRequired = formData.capacity !== 'unable';
  $: isEmailDisabled = formData.capacity === 'unable';
  $: guardianLabel = formData.capacity === 'unable' ? 'Representante Legal' : 'Assistente Legal';

  // Clear email when capacity changes to unable
  $: if (formData.capacity === 'unable' && formData.customer_attributes.email) {
    formData.customer_attributes.email = '';
    formData.emails_attributes[0].email = '';
  }

  // Copy address data when checkbox is checked
  $: if (useSameAddress) {
    guardianFormData.addresses_attributes[0] = { ...formData.addresses_attributes[0] };
  }

  // Copy bank account data when checkbox is checked
  $: if (useSameBankAccount) {
    guardianFormData.bank_accounts_attributes[0] = { ...formData.bank_accounts_attributes[0] };
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
      validate: (value: string) => {
        // Only required if capacity is not 'unable'
        if (formData.capacity === 'unable') {
          return '';
        }
        return value ? '' : 'Profissão é obrigatória';
      },
      message: 'Profissão é obrigatória'
    },
    mother_name: {
      validate: (value: string) => (value ? '' : 'Nome da mãe é obrigatório'),
      message: 'Nome da mãe é obrigatório'
    },

    // Login Information
    email: {
      validate: (value: string) => {
        // Email is optional for unable persons
        if (formData.capacity === 'unable') {
          // If provided, it should be valid, but it's not required
          if (!value || value === '') {
            return ''; // No error for empty email
          }
          // If they do provide an email, validate it
          return validateEmailRequired(value);
        }
        return validateEmailRequired(value);
      },
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

  // Validate guardian form
  function validateGuardianForm(): boolean {
    let isValid = true;

    // Required fields for guardian
    const requiredFields = ['name', 'last_name', 'cpf', 'rg', 'birth', 'profession', 'mother_name'];

    for (const field of requiredFields) {
      if (!guardianFormData[field]) {
        guardianErrors[field] = `${field} é obrigatório`;
        guardianTouched[field] = true;
        isValid = false;
      }
    }

    // Validate email and password for guardian
    if (!guardianFormData.customer_attributes.email) {
      guardianErrors['email'] = 'Email é obrigatório';
      guardianTouched['email'] = true;
      isValid = false;
    }

    if (!guardianFormData.customer_attributes.password) {
      guardianErrors['password'] = 'Senha é obrigatória';
      guardianTouched['password'] = true;
      isValid = false;
    }

    if (
      guardianFormData.customer_attributes.password !==
      guardianFormData.customer_attributes.password_confirmation
    ) {
      guardianErrors['password_confirmation'] = 'As senhas não coincidem';
      guardianTouched['password_confirmation'] = true;
      isValid = false;
    }

    return isValid;
  }

  // Handle file upload
  function handleFileUpload(event: Event) {
    const target = event.target as HTMLInputElement;
    if (target.files) {
      uploadedFiles = [...uploadedFiles, ...Array.from(target.files)];
    }
  }
  
  function removeFile(index: number) {
    uploadedFiles = uploadedFiles.filter((_, i) => i !== index);
  }
  
  // Navigate to step
  function goToStep(step: number) {
    if (step >= 1 && step <= totalSteps) {
      // Validate current step before moving
      if (step > currentStep) {
        if (currentStep === 1) {
          // No validation needed for file uploads
          currentStep = step;
        } else if (currentStep === 2 && validateForm()) {
          currentStep = step;
        }
      } else {
        // Going backwards, no validation needed
        currentStep = step;
      }
    }
  }
  
  // Handle form submission
  function handleSubmit() {
    // Step 1: File uploads - just move to next step
    if (currentStep === 1) {
      currentStep = 2;
      return;
    }
    
    // Step 2: Client data
    if (currentStep === 2 && showGuardianForm) {
      // Mark all fields as touched
      Object.keys(formData).forEach((key) => (touched[key] = true));

      if (!validateForm()) {
        return;
      }

      currentStep = 3;
      return;
    }

    // Step 3: Guardian form validation
    if (currentStep === 3 && showGuardianForm) {
      // Check age validation
      if (!guardianAgeValidation.isValid) {
        // Show error message
        alert(guardianAgeValidation.message);
        return;
      }
      if (!validateGuardianForm()) {
        return;
      }
    }

    // Final submission
    // Mark all fields as touched
    Object.keys(formData).forEach((key) => (touched[key] = true));

    if (!validateForm()) {
      return;
    }

    // Generate passwords
    const customerPassword = generateStrongPassword();
    const guardianPassword = showGuardianForm ? generateStrongPassword() : '';
    
    // Prepare data for submission
    let submitData;

    if (showGuardianForm) {
      // For persons with representatives, we'll need to handle this differently
      // The parent component will need to make two API calls and establish the relationship
      submitData = {
        // First person (unable or relatively incapable)
        represented: {
          ...formData,
          // For unable persons, don't send email if it's empty
          emails_attributes: formData.customer_attributes.email
            ? [
              {
                email: formData.customer_attributes.email
              }
            ]
            : [],
          // Don't send empty email in customer_attributes either
          customer_attributes: {
            ...formData.customer_attributes,
            email: formData.customer_attributes.email || undefined,
            password: customerPassword,
            password_confirmation: customerPassword
          }
        },
        // Second person (representative or assistant)
        representor: {
          ...guardianFormData,
          emails_attributes: [
            {
              email: guardianFormData.customer_attributes.email
            }
          ],
          customer_attributes: {
            ...guardianFormData.customer_attributes,
            password: guardianPassword,
            password_confirmation: guardianPassword
          }
        },
        // Relationship type
        relationship_type: formData.capacity === 'unable' ? 'representation' : 'assistance'
      };
    } else {
      submitData = {
        profile_customer: {
          ...formData,
          // Sync email from customer_attributes to emails_attributes
          emails_attributes: [
            {
              email: formData.customer_attributes.email
            }
          ],
          customer_attributes: {
            ...formData.customer_attributes,
            password: customerPassword,
            password_confirmation: customerPassword
          }
        }
      };
    }

    // Clear form draft on successful submission
    clearFormDraft();

    // Include uploaded files in submission
    dispatch('submit', { data: submitData, files: uploadedFiles });
  }

  // Handle previous step
  function handlePreviousStep() {
    if (currentStep > 1) {
      currentStep--;
    }
  }
  
  // Handle person form field events
  function handlePersonFieldBlur(event: CustomEvent, isGuardian: boolean = false) {
    const { field, value } = event.detail;
    if (isGuardian) {
      guardianTouched[field] = true;
      validateGuardianField(field, value);
    } else {
      handleBlur(field, value);
    }
  }
  
  function handlePersonCPFInput(event: CustomEvent, isGuardian: boolean = false) {
    if (isGuardian) {
      guardianFormData.cpf = formatCPF(guardianFormData.cpf);
    } else {
      handleCPFInput(event.detail);
    }
  }
  
  function validateGuardianField(field: string, value: any) {
    // Implement validation for guardian fields
    const validator = validationRules[field];
    if (validator) {
      guardianErrors[field] = validator.validate(value);
    }
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

    <!-- Steps indicator for multi-step form -->
    {#if showGuardianForm}
      <ul class="steps w-full mb-6">
        <li class="step {currentStep >= 1 ? 'step-primary' : ''}">Dados do Cliente</li>
        <li class="step {currentStep >= 2 ? 'step-primary' : ''}">
          Dados do {guardianLabel}
        </li>
      </ul>
    {/if}

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

      <!-- Step 1: Customer Information -->
      {#if currentStep === 1}
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
              aria-describedby={errors.last_name && touched.last_name
                ? 'last_name-error'
                : undefined}
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
              class="input input-bordered w-full {errors.birth && touched.birth
                ? 'input-error'
                : ''}"
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
              <span class="label-text font-medium"
                >Profissão {isProfessionRequired ? '*' : '(Opcional)'}</span
              >
            </label>
            <input
              id="profession"
              type="text"
              class="input input-bordered w-full {errors.profession &&
              touched.profession &&
              isProfessionRequired
                ? 'input-error'
                : ''}"
              bind:value={formData.profession}
              on:blur={() => handleBlur('profession', formData.profession)}
              disabled={isLoading || !isProfessionRequired}
              aria-required={isProfessionRequired ? 'true' : 'false'}
              aria-invalid={errors.profession && touched.profession && isProfessionRequired
                ? 'true'
                : 'false'}
              aria-describedby={errors.profession && touched.profession && isProfessionRequired
                ? 'profession-error'
                : undefined}
              data-testid="customer-profession-input"
            />
            {#if !isProfessionRequired}
              <div class="text-sm text-gray-500 mt-1">Não obrigatório para menores de 16 anos</div>
            {/if}
            {#if errors.profession && touched.profession && isProfessionRequired}
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

          <!-- Capacity Selection -->
          <div class="form-control w-full">
            <label for="capacity" class="label justify-start">
              <span class="label-text font-medium">Capacidade</span>
            </label>
            <select
              id="capacity"
              class="select select-bordered w-full"
              bind:value={formData.capacity}
              disabled={isLoading}
              data-testid="customer-capacity-input"
            >
              <option value="able">Capaz</option>
              <option value="relatively">Relativamente Incapaz</option>
              <option value="unable">Absolutamente Incapaz</option>
            </select>
            {#if capacityMessage}
              <div class="text-sm text-warning mt-1">{capacityMessage}</div>
            {/if}
          </div>
        </div>

        <!-- Login Information Section -->
        <div class="divider" aria-label="Seção de informações de acesso">Informações de Acesso</div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Email -->
          <div class="form-control w-full">
            <label for="email" class="label justify-start">
              <span class="label-text font-medium"
                >Email {isEmailRequired ? '*' : '(Opcional)'}</span
              >
            </label>
            <input
              id="email"
              type="email"
              class="input input-bordered w-full {errors.email && touched.email && isEmailRequired
                ? 'input-error'
                : ''}"
              bind:value={formData.customer_attributes.email}
              on:blur={() => handleBlur('email', formData.customer_attributes.email)}
              disabled={isLoading || isEmailDisabled}
              placeholder="cliente@exemplo.com"
              aria-required={isEmailRequired ? 'true' : 'false'}
              aria-invalid={errors.email && touched.email && isEmailRequired ? 'true' : 'false'}
              aria-describedby={errors.email && touched.email && isEmailRequired
                ? 'email-error'
                : undefined}
              data-testid="customer-email-input"
            />
            {#if !isEmailRequired}
              <div class="text-sm text-gray-500 mt-1">
                Este email pode ser compartilhado com a conta do responsável
              </div>
            {/if}
            {#if errors.email && touched.email && isEmailRequired}
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
        </div>

        <!-- Social Security Information Section -->
        <div class="divider" aria-label="Seção de informações previdenciárias">
          Informações Previdenciárias
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Benefit Number -->
          <div class="form-control w-full">
            <label for="number_benefit" class="label justify-start">
              <span class="label-text font-medium">Número de Benefício (Opcional)</span>
            </label>
            <input
              id="number_benefit"
              type="text"
              class="input input-bordered w-full"
              bind:value={formData.number_benefit}
              disabled={isLoading}
              placeholder="Número do benefício INSS"
              data-testid="customer-benefit-input"
            />
          </div>

          <!-- NIT -->
          <div class="form-control w-full">
            <label for="nit" class="label justify-start">
              <span class="label-text font-medium">NIT (Opcional)</span>
            </label>
            <input
              id="nit"
              type="text"
              class="input input-bordered w-full"
              bind:value={formData.nit}
              disabled={isLoading}
              placeholder="Número de Inscrição do Trabalhador"
              data-testid="customer-nit-input"
            />
          </div>

          <!-- INSS Password -->
          <div class="form-control w-full md:col-span-2">
            <label for="inss_password" class="label justify-start">
              <span class="label-text font-medium">Senha do MeuINSS (Opcional)</span>
            </label>
            <input
              id="inss_password"
              type="password"
              class="input input-bordered w-full"
              bind:value={formData.inss_password}
              disabled={isLoading}
              placeholder="Senha de acesso ao MeuINSS"
              data-testid="customer-inss-password-input"
            />
            <div class="text-sm text-warning mt-1">
              Esta informação é armazenada de forma segura e criptografada
            </div>
          </div>
        </div>
      {/if}
      <!-- End of Step 1 -->

      <!-- Step 2: Guardian/Assistant Information -->
      {#if currentStep === 2 && showGuardianForm}
        <div class="divider" aria-label="Seção de informações do {guardianLabel.toLowerCase()}">
          Informações Pessoais - {guardianLabel}
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Guardian Name -->
          <div class="form-control w-full">
            <label for="guardian_name" class="label justify-start">
              <span class="label-text font-medium">Nome *</span>
            </label>
            <input
              id="guardian_name"
              type="text"
              class="input input-bordered w-full {guardianErrors.name && guardianTouched.name
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.name}
              on:blur={() => (guardianTouched.name = true)}
              disabled={isLoading}
              aria-required="true"
              data-testid="guardian-name-input"
            />
            {#if guardianErrors.name && guardianTouched.name}
              <div class="text-error text-sm mt-1">{guardianErrors.name}</div>
            {/if}
          </div>

          <!-- Guardian Last Name -->
          <div class="form-control w-full">
            <label for="guardian_last_name" class="label justify-start">
              <span class="label-text font-medium">Sobrenome *</span>
            </label>
            <input
              id="guardian_last_name"
              type="text"
              class="input input-bordered w-full {guardianErrors.last_name &&
              guardianTouched.last_name
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.last_name}
              on:blur={() => (guardianTouched.last_name = true)}
              disabled={isLoading}
              aria-required="true"
              data-testid="guardian-last-name-input"
            />
            {#if guardianErrors.last_name && guardianTouched.last_name}
              <div class="text-error text-sm mt-1">{guardianErrors.last_name}</div>
            {/if}
          </div>

          <!-- Guardian CPF -->
          <div class="form-control w-full">
            <label for="guardian_cpf" class="label justify-start">
              <span class="label-text font-medium">CPF *</span>
            </label>
            <input
              id="guardian_cpf"
              type="text"
              class="input input-bordered w-full {guardianErrors.cpf && guardianTouched.cpf
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.cpf}
              on:input={(e) => {
                guardianFormData.cpf = formatCPF(e.target.value);
              }}
              on:blur={() => (guardianTouched.cpf = true)}
              disabled={isLoading}
              placeholder="000.000.000-00"
              maxlength="14"
              aria-required="true"
              data-testid="guardian-cpf-input"
            />
            {#if guardianErrors.cpf && guardianTouched.cpf}
              <div class="text-error text-sm mt-1">{guardianErrors.cpf}</div>
            {/if}
          </div>

          <!-- Guardian RG -->
          <div class="form-control w-full">
            <label for="guardian_rg" class="label justify-start">
              <span class="label-text font-medium">RG *</span>
            </label>
            <input
              id="guardian_rg"
              type="text"
              class="input input-bordered w-full {guardianErrors.rg && guardianTouched.rg
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.rg}
              on:blur={() => (guardianTouched.rg = true)}
              disabled={isLoading}
              aria-required="true"
              data-testid="guardian-rg-input"
            />
            {#if guardianErrors.rg && guardianTouched.rg}
              <div class="text-error text-sm mt-1">{guardianErrors.rg}</div>
            {/if}
          </div>

          <!-- Guardian Birth Date -->
          <div class="form-control w-full">
            <label for="guardian_birth" class="label justify-start">
              <span class="label-text font-medium">Data de Nascimento *</span>
            </label>
            <input
              id="guardian_birth"
              type="date"
              class="input input-bordered w-full {guardianErrors.birth && guardianTouched.birth
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.birth}
              on:blur={() => (guardianTouched.birth = true)}
              disabled={isLoading}
              aria-required="true"
              data-testid="guardian-birth-input"
            />
            {#if guardianErrors.birth && guardianTouched.birth}
              <div class="text-error text-sm mt-1">{guardianErrors.birth}</div>
            {/if}
          </div>

          <!-- Guardian Profession -->
          <div class="form-control w-full">
            <label for="guardian_profession" class="label justify-start">
              <span class="label-text font-medium">Profissão *</span>
            </label>
            <input
              id="guardian_profession"
              type="text"
              class="input input-bordered w-full {guardianErrors.profession &&
              guardianTouched.profession
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.profession}
              on:blur={() => (guardianTouched.profession = true)}
              disabled={isLoading}
              aria-required="true"
              data-testid="guardian-profession-input"
            />
            {#if guardianErrors.profession && guardianTouched.profession}
              <div class="text-error text-sm mt-1">{guardianErrors.profession}</div>
            {/if}
          </div>

          <!-- Guardian Mother Name -->
          <div class="form-control w-full">
            <label for="guardian_mother_name" class="label justify-start">
              <span class="label-text font-medium">Nome da Mãe *</span>
            </label>
            <input
              id="guardian_mother_name"
              type="text"
              class="input input-bordered w-full {guardianErrors.mother_name &&
              guardianTouched.mother_name
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.mother_name}
              on:blur={() => (guardianTouched.mother_name = true)}
              disabled={isLoading}
              aria-required="true"
              data-testid="guardian-mother-input"
            />
            {#if guardianErrors.mother_name && guardianTouched.mother_name}
              <div class="text-error text-sm mt-1">{guardianErrors.mother_name}</div>
            {/if}
          </div>

          <!-- Guardian Email -->
          <div class="form-control w-full">
            <label for="guardian_email" class="label justify-start">
              <span class="label-text font-medium">Email *</span>
            </label>
            <input
              id="guardian_email"
              type="email"
              class="input input-bordered w-full {guardianErrors.email && guardianTouched.email
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.customer_attributes.email}
              on:blur={() => (guardianTouched.email = true)}
              disabled={isLoading}
              placeholder="responsavel@exemplo.com"
              aria-required="true"
              data-testid="guardian-email-input"
            />
            {#if guardianErrors.email && guardianTouched.email}
              <div class="text-error text-sm mt-1">{guardianErrors.email}</div>
            {/if}
          </div>

          <!-- Guardian Password -->
          <div class="form-control w-full">
            <label for="guardian_password" class="label justify-start">
              <span class="label-text font-medium">Senha *</span>
            </label>
            <input
              id="guardian_password"
              type="password"
              class="input input-bordered w-full {guardianErrors.password &&
              guardianTouched.password
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.customer_attributes.password}
              on:blur={() => (guardianTouched.password = true)}
              disabled={isLoading}
              placeholder="Mínimo 6 caracteres"
              aria-required="true"
              data-testid="guardian-password-input"
            />
            {#if guardianErrors.password && guardianTouched.password}
              <div class="text-error text-sm mt-1">{guardianErrors.password}</div>
            {/if}
          </div>

          <!-- Guardian Password Confirmation -->
          <div class="form-control w-full">
            <label for="guardian_password_confirmation" class="label justify-start">
              <span class="label-text font-medium">Confirmar Senha *</span>
            </label>
            <input
              id="guardian_password_confirmation"
              type="password"
              class="input input-bordered w-full {guardianErrors.password_confirmation &&
              guardianTouched.password_confirmation
                ? 'input-error'
                : ''}"
              bind:value={guardianFormData.customer_attributes.password_confirmation}
              on:blur={() => (guardianTouched.password_confirmation = true)}
              disabled={isLoading}
              placeholder="Digite a senha novamente"
              aria-required="true"
              data-testid="guardian-password-confirm-input"
            />
            {#if guardianErrors.password_confirmation && guardianTouched.password_confirmation}
              <div class="text-error text-sm mt-1">{guardianErrors.password_confirmation}</div>
            {/if}
          </div>
        </div>

        <!-- Guardian Address Section -->
        <div class="divider" aria-label="Seção de endereço">Endereço - {guardianLabel}</div>

        <!-- Checkbox to use same address -->
        <div class="form-control">
          <label class="label cursor-pointer justify-start gap-2">
            <input
              type="checkbox"
              class="checkbox checkbox-primary"
              bind:checked={useSameAddress}
            />
            <span class="label-text">Usar mesmo endereço do representado</span>
          </label>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Guardian ZIP Code -->
          <div class="form-control w-full">
            <label for="guardian_zip_code" class="label justify-start">
              <span class="label-text font-medium">CEP</span>
            </label>
            <input
              id="guardian_zip_code"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.addresses_attributes[0].zip_code}
              disabled={isLoading || useSameAddress}
              placeholder="00000-000"
              data-testid="guardian-zipcode-input"
            />
          </div>

          <!-- Guardian Street -->
          <div class="form-control w-full">
            <label for="guardian_street" class="label justify-start">
              <span class="label-text font-medium">Rua</span>
            </label>
            <input
              id="guardian_street"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.addresses_attributes[0].street}
              disabled={isLoading || useSameAddress}
              data-testid="guardian-street-input"
            />
          </div>

          <!-- Guardian Number -->
          <div class="form-control w-full">
            <label for="guardian_number" class="label justify-start">
              <span class="label-text font-medium">Número</span>
            </label>
            <input
              id="guardian_number"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.addresses_attributes[0].number}
              disabled={isLoading || useSameAddress}
              data-testid="guardian-number-input"
            />
          </div>

          <!-- Guardian Neighborhood -->
          <div class="form-control w-full">
            <label for="guardian_neighborhood" class="label justify-start">
              <span class="label-text font-medium">Bairro</span>
            </label>
            <input
              id="guardian_neighborhood"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.addresses_attributes[0].neighborhood}
              disabled={isLoading || useSameAddress}
              data-testid="guardian-neighborhood-input"
            />
          </div>

          <!-- Guardian City -->
          <div class="form-control w-full">
            <label for="guardian_city" class="label justify-start">
              <span class="label-text font-medium">Cidade</span>
            </label>
            <input
              id="guardian_city"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.addresses_attributes[0].city}
              disabled={isLoading || useSameAddress}
              data-testid="guardian-city-input"
            />
          </div>

          <!-- Guardian State -->
          <div class="form-control w-full">
            <label for="guardian_state" class="label justify-start">
              <span class="label-text font-medium">Estado</span>
            </label>
            <select
              id="guardian_state"
              class="select select-bordered w-full"
              bind:value={guardianFormData.addresses_attributes[0].state}
              disabled={isLoading || useSameAddress}
              data-testid="guardian-state-input"
            >
              <option value="">Selecione...</option>
              {#each states as state}
                <option value={state.value}>{state.label}</option>
              {/each}
            </select>
          </div>
        </div>

        <!-- Guardian Bank Account Section -->
        <div class="divider" aria-label="Seção de dados bancários">
          Dados Bancários - {guardianLabel}
        </div>

        <!-- Checkbox to use same bank account -->
        <div class="form-control">
          <label class="label cursor-pointer justify-start gap-2">
            <input
              type="checkbox"
              class="checkbox checkbox-primary"
              bind:checked={useSameBankAccount}
            />
            <span class="label-text">Usar mesma conta bancária do representado</span>
          </label>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Guardian Bank Name -->
          <div class="form-control w-full">
            <label for="guardian_bank_name" class="label justify-start">
              <span class="label-text font-medium">Banco</span>
            </label>
            <input
              id="guardian_bank_name"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.bank_accounts_attributes[0].bank_name}
              disabled={isLoading || useSameBankAccount}
              data-testid="guardian-bank-name-input"
            />
          </div>

          <!-- Guardian Account Type -->
          <div class="form-control w-full">
            <label for="guardian_type_account" class="label justify-start">
              <span class="label-text font-medium">Tipo de Conta</span>
            </label>
            <select
              id="guardian_type_account"
              class="select select-bordered w-full"
              bind:value={guardianFormData.bank_accounts_attributes[0].type_account}
              disabled={isLoading || useSameBankAccount}
              data-testid="guardian-account-type-input"
            >
              <option value="Corrente">Corrente</option>
              <option value="Poupança">Poupança</option>
            </select>
          </div>

          <!-- Guardian Agency -->
          <div class="form-control w-full">
            <label for="guardian_agency" class="label justify-start">
              <span class="label-text font-medium">Agência</span>
            </label>
            <input
              id="guardian_agency"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.bank_accounts_attributes[0].agency}
              disabled={isLoading || useSameBankAccount}
              placeholder="0000-0"
              data-testid="guardian-agency-input"
            />
          </div>

          <!-- Guardian Account -->
          <div class="form-control w-full">
            <label for="guardian_account" class="label justify-start">
              <span class="label-text font-medium">Conta</span>
            </label>
            <input
              id="guardian_account"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.bank_accounts_attributes[0].account}
              disabled={isLoading || useSameBankAccount}
              placeholder="00000-0"
              data-testid="guardian-account-input"
            />
          </div>

          <!-- Guardian Operation -->
          <div class="form-control w-full">
            <label for="guardian_operation" class="label justify-start">
              <span class="label-text font-medium">Operação</span>
            </label>
            <input
              id="guardian_operation"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.bank_accounts_attributes[0].operation}
              disabled={isLoading || useSameBankAccount}
              data-testid="guardian-operation-input"
            />
          </div>

          <!-- Guardian PIX -->
          <div class="form-control w-full">
            <label for="guardian_pix" class="label justify-start">
              <span class="label-text font-medium">Chave PIX</span>
            </label>
            <input
              id="guardian_pix"
              type="text"
              class="input input-bordered w-full"
              bind:value={guardianFormData.bank_accounts_attributes[0].pix}
              disabled={isLoading || useSameBankAccount}
              data-testid="guardian-pix-input"
            />
          </div>
        </div>
      {/if}
      <!-- End of Step 2 -->

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
            >Você tem alterações não salvas. Se sair desta página, os dados preenchidos serão salvos
            temporariamente.</span
          >
        </div>
      {/if}

      <!-- Actions -->
      <div class="card-actions justify-end mt-6">
        {#if currentStep > 1}
          <button
            type="button"
            class="btn btn-ghost"
            on:click={handlePreviousStep}
            disabled={isLoading}
            aria-label="Voltar"
            data-testid="customer-back-button"
          >
            Voltar
          </button>
        {/if}
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
          disabled={isLoading || (showGuardianForm && currentStep === 1 && !formData.name)}
          aria-busy={isLoading ? 'true' : 'false'}
          data-testid="customer-submit-button"
        >
          {#if isLoading}
            <span class="loading loading-spinner"></span>
          {/if}
          {#if showGuardianForm}
            {#if currentStep === 1}
              Próximo
            {:else if currentStep === 2}
              Criar Cliente e Responsável
            {/if}
          {:else if customer}
            Atualizar
          {:else}
            Criar Cliente
          {/if}
        </button>
      </div>
    </form>
  </div>
</div>
