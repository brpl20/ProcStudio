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
    validationRules
  } from '../../validation';

  // Import new modular utilities
  import { BRAZILIAN_STATES } from '../../constants/brazilian-states';
  import type { BrazilianState } from '../../constants/brazilian-states';
  import {
    createDefaultCustomerFormData,
    createDefaultGuardianFormData,
    createDefaultFormState,
    requiresGuardian,
    getGuardianLabel,
    getRelationshipType
  } from '../../schemas/customer-form';
  import type { CustomerFormData, CustomerFormState } from '../../schemas/customer-form';
  import {
    generateStrongPassword,
    saveFormDraft,
    loadFormDraft,
    clearFormDraft,
    validateGuardianAge,
    isFormDirty,
    cloneFormData
  } from '../../utils/form-helpers';

  // Import our new component
  import CustomerPersonalInfoStep from './CustomerPersonalInfoStep.svelte';

  export let customer: any = null;
  // TODO: Add Customer type
  // export let customer: Customer | null = null;

  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    submit: any;
    cancel: void;
  }>();

  // Initialize form data using our new schemas
  let formData: CustomerFormData = createDefaultCustomerFormData();
  const guardianFormData: CustomerFormData = createDefaultGuardianFormData();
  const formState: CustomerFormState = createDefaultFormState();

  // Track initial form data for dirty state
  let initialFormData: CustomerFormData;

  // Destructure form state for easier access
  $: ({
    currentStep,
    totalSteps,
    showGuardianForm,
    useSameAddress,
    useSameBankAccount,
    formIsDirty
  } = formState);

  // Update total steps based on capacity using our helper function
  $: {
    if (requiresGuardian(formData.capacity)) {
      formState.totalSteps = 3; // 1-uploads, 2-client data, 3-guardian data
      formState.showGuardianForm = true;
    } else {
      formState.totalSteps = 2; // 1-uploads, 2-client data
      formState.showGuardianForm = false;
      if (formState.currentStep > 2) {
        formState.currentStep = 2;
      }
    }
  }

  // Use Brazilian states from our constants
  let states: BrazilianState[] = BRAZILIAN_STATES;

  // Validation errors
  let errors: Record<string, string> = {};
  let touched: Record<string, boolean> = {};
  const guardianErrors: Record<string, string> = {};
  const guardianTouched: Record<string, boolean> = {};

  onMount(async () => {
    // States are now loaded from constants, no API call needed
    states = BRAZILIAN_STATES;

    // Try to restore form data from localStorage using our utility
    const savedData = loadFormDraft();
    if (savedData) {
      formData = { ...formData, ...savedData };
      // TODO: Show notification that data was restored
    }

    // Set initial form state for dirty checking
    initialFormData = cloneFormData(formData);
  });

  // Reactive declarations for performance optimization

  // Age validation for guardian using our utility
  $: guardianAgeValidation = formData.birth && guardianFormData.birth
    ? validateGuardianAge(guardianFormData.birth, formData.birth)
    : { isValid: true, message: '' };

  // Update form dirty state using our utility
  $: formState.formIsDirty = isFormDirty(formData, initialFormData);
  $: if (formState.formIsDirty) {
    saveFormDraft(formData);
  }

  $: guardianLabel = getGuardianLabel(formData.capacity);

  // Clear email when capacity changes to unable
  $: if (formData.capacity === 'unable' && formData.customer_attributes.email) {
    formData.customer_attributes.email = '';
    formData.emails_attributes[0].email = '';
  }

  // Copy address data when checkbox is checked using our utility
  $: if (formState.useSameAddress) {
    guardianFormData.addresses_attributes[0] = { ...formData.addresses_attributes[0] };
  }

  // Copy bank account data when checkbox is checked using our utility
  $: if (formState.useSameBankAccount) {
    guardianFormData.bank_accounts_attributes[0] = { ...formData.bank_accounts_attributes[0] };
  }

  // Handle CPF formatting
  function handleCPFInput(event: CustomEvent) {
    formData.cpf = event.detail.value;
    validateField('cpf', formData.cpf);
  }

  // Handle birth date change and update capacity
  function handleBirthDateChange(event: CustomEvent) {
    formData.birth = event.detail.value;
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
    console.log('validateForm called with formData:', formData);
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
      if (error) {
        console.log(`Validation error for field ${field}:`, error, 'value:', valueToValidate);
      }
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

  // Navigate to step
  function goToStep(step: number) {
    if (step >= 1 && step <= totalSteps) {
      // Validate current step before moving
      if (step > currentStep) {
        if (currentStep === 1 && validateForm()) {
          currentStep = step;
        } else if (currentStep === 2 && validateGuardianForm()) {
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
    console.log('handleSubmit called - currentStep:', currentStep, 'showGuardianForm:', showGuardianForm);

    // Step 1: Client data
    if (currentStep === 1 && showGuardianForm) {
      console.log('Step 1 with guardian - validating customer form');
      // Mark all fields as touched
      Object.keys(formData).forEach((key) => (touched[key] = true));

      const isValid = validateForm();
      console.log('Form validation result:', isValid);
      if (!isValid) {
        console.log('Form validation failed, errors:', errors);
        return;
      }

      console.log('Moving to step 2 (guardian form)');
      currentStep = 2;
      return;
    }

    // Step 2: Guardian form validation
    if (currentStep === 2 && showGuardianForm) {
      console.log('Step 2 - validating guardian form');
      // Check age validation
      if (!guardianAgeValidation.isValid) {
        console.log('Guardian age validation failed:', guardianAgeValidation.message);
        // Show error message
        alert(guardianAgeValidation.message);
        return;
      }
      const guardianValid = validateGuardianForm();
      console.log('Guardian form validation result:', guardianValid);
      if (!guardianValid) {
        console.log('Guardian form validation failed, errors:', guardianErrors);
        return;
      }
    }

    // Final submission
    console.log('Final submission - validating all fields');
    // Mark all fields as touched
    Object.keys(formData).forEach((key) => (touched[key] = true));

    const finalValid = validateForm();
    console.log('Final validation result:', finalValid, 'errors:', errors);
    if (!finalValid) {
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
        // Relationship type using our helper function
        relationship_type: getRelationshipType(formData.capacity)
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

    console.log('Dispatching submit event with data:', submitData);
    dispatch('submit', { data: submitData });
    console.log('Submit event dispatched successfully');
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
        <CustomerPersonalInfoStep
          bind:formData
          {errors}
          {touched}
          {isLoading}
          {customer}
          on:fieldBlur={(e) => handleBlur(e.detail.field, e.detail.value)}
          on:cpfInput={handleCPFInput}
          on:birthDateChange={handleBirthDateChange}
        />
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
          on:click={() => console.log('Submit button clicked!')}
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
