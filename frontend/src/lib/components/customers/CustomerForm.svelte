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

  // Import our step components
  import CustomerFormStep1 from './CustomerFormStep1.svelte';
  import CustomerFormStep2 from './CustomerFormStep2.svelte';

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
  let guardianFormData: CustomerFormData = createDefaultGuardianFormData();
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

  // Validation errors
  let errors: Record<string, string> = {};
  let touched: Record<string, boolean> = {};
  const guardianErrors: Record<string, string> = {};
  const guardianTouched: Record<string, boolean> = {};

  // Populate form data when customer prop changes (for edit mode)
  $: if (customer) {
    // Handle both formats: customer with embedded profile_customer OR direct profile_customer
    const profile = customer.profile_customer || customer;
    const attrs = profile.attributes || profile;

    // If this is a direct ProfileCustomer response, we need to get customer info differently
    const customerData = customer.profile_customer
      ? customer
      : { access_email: attrs.access_email, status: 'active' };

    formData = {
      ...formData,
      // === BASIC PROFILE INFORMATION ===
      customer_type: attrs.customer_type || 'physical_person',
      name: attrs.name || '',
      last_name: attrs.last_name || '',

      // === DOCUMENTS ===
      cpf: attrs.cpf || '',
      cnpj: attrs.cnpj || '',
      rg: attrs.rg || '',

      // === PERSONAL INFO ===
      birth: attrs.birth || '',
      gender: attrs.gender || '',
      civil_status: attrs.civil_status || '',
      nationality: attrs.nationality || 'brazilian',
      capacity: attrs.capacity || 'able',

      // === FAMILY & PERSONAL ===
      mother_name: attrs.mother_name || '',

      // === PROFESSIONAL ===
      profession: attrs.profession || '',
      company: attrs.company || '',

      // === BENEFITS & SOCIAL SECURITY ===
      number_benefit: attrs.number_benefit || '',
      nit: attrs.nit || '',
      inss_password: attrs.inss_password || '',

      // === IDs AND REFERENCES ===
      accountant_id: attrs.accountant_id || null,
      created_by_id: attrs.created_by_id || null,

      // === CUSTOMER LOGIN ATTRIBUTES ===
      customer_attributes: {
        ...formData.customer_attributes,
        email: attrs.access_email || '',
        access_email: attrs.access_email || '',
        status: customerData.status || 'active'
      },

      // === CONTACT INFORMATION ===
      // Phones - handle array from API
      phones_attributes:
        attrs.phones && attrs.phones.length > 0
          ? attrs.phones.map((phone: any) => ({
            id: phone.id || undefined,
            phone_number: phone.phone_number || ''
          }))
          : [{ phone_number: attrs.default_phone || '' }],

      // Emails - handle array from API
      emails_attributes:
        attrs.emails && attrs.emails.length > 0
          ? attrs.emails.map((email: any) => ({
            id: email.id || undefined,
            email: email.email || ''
          }))
          : [{ email: attrs.default_email || '' }],

      // === ADDRESS INFORMATION ===
      // Addresses - handle array from API
      addresses_attributes:
        attrs.addresses && attrs.addresses.length > 0
          ? attrs.addresses.map((addr: any) => ({
            id: addr.id || undefined,
            description: addr.description || '',
            zip_code: addr.zip_code || '',
            street: addr.street || '',
            number: addr.number ? addr.number.toString() : '',
            neighborhood: addr.neighborhood || '',
            city: addr.city || '',
            state: addr.state || ''
          }))
          : [
            {
              description: '',
              zip_code: '',
              street: '',
              number: '',
              neighborhood: '',
              city: attrs.city || '',
              state: ''
            }
          ],

      // === BANKING INFORMATION ===
      // Bank Accounts - handle array from API
      bank_accounts_attributes:
        attrs.bank_accounts && attrs.bank_accounts.length > 0
          ? attrs.bank_accounts.map((bank: any) => ({
            id: bank.id || undefined,
            bank_name: bank.bank_name || '',
            type_account: bank.type_account || '',
            agency: bank.agency || '',
            account: bank.account || '',
            operation: bank.operation || '',
            pix: bank.pix || ''
          }))
          : [
            {
              bank_name: '',
              type_account: '',
              agency: '',
              account: '',
              operation: '',
              pix: ''
            }
          ]
    };

    // Set initial form data for dirty checking in edit mode
    initialFormData = cloneFormData(formData);
    console.log('🎯 CustomerForm populated with data:', {
      customer_type: formData.customer_type,
      name: formData.name,
      phones: formData.phones_attributes.length,
      emails: formData.emails_attributes.length,
      addresses: formData.addresses_attributes.length,
      bank_accounts: formData.bank_accounts_attributes.length
    });
  }

  onMount(async () => {
    // Only try to restore form data from localStorage if not in edit mode
    if (!customer) {
      const savedData = loadFormDraft();
      if (savedData) {
        formData = { ...formData, ...savedData };
        // TODO: Show notification that data was restored
      }
    }

    // Set initial form state for dirty checking (if not already set above)
    if (!customer) {
      initialFormData = cloneFormData(formData);
    }
  });

  // Reactive declarations for performance optimization

  // Age validation for guardian using our utility
  $: guardianAgeValidation =
    formData.birth && guardianFormData.birth
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

  // Handle address copying when checkbox changes
  function handleSameAddressChange(checked: boolean) {
    formState.useSameAddress = checked;
    if (checked && formData.addresses_attributes[0]) {
      guardianFormData.addresses_attributes[0] = { ...formData.addresses_attributes[0] };
    }
  }

  // Handle bank account copying when checkbox changes
  function handleSameBankAccountChange(checked: boolean) {
    formState.useSameBankAccount = checked;
    if (checked && formData.bank_accounts_attributes[0]) {
      guardianFormData.bank_accounts_attributes[0] = { ...formData.bank_accounts_attributes[0] };
    }
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
          formState.currentStep = step;
        } else if (currentStep === 2 && validateGuardianForm()) {
          formState.currentStep = step;
        }
      } else {
        // Going backwards, no validation needed
        formState.currentStep = step;
      }
    }
  }

  // Handle form submission
  function handleSubmit() {
    console.log(
      'handleSubmit called - currentStep:',
      currentStep,
      'showGuardianForm:',
      showGuardianForm
    );

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
      formState.currentStep = 2;
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
      formState.currentStep--;
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
    // Map nested fields to their root validator name
    let validatorKey = field;

    if (field === 'email' || field === 'customer_attributes.email') {
      validatorKey = 'email';
      value = guardianFormData.customer_attributes.email;
    } else if (field === 'password' || field === 'customer_attributes.password') {
      validatorKey = 'password';
      value = guardianFormData.customer_attributes.password;
    } else if (
      field === 'password_confirmation' ||
      field === 'customer_attributes.password_confirmation'
    ) {
      validatorKey = 'password_confirmation';
      value = guardianFormData.customer_attributes.password_confirmation;
    }

    // Apply validation based on field type
    if (validatorKey === 'email') {
      guardianErrors[field] = validateEmailRequired(value);
    } else if (validatorKey === 'password') {
      guardianErrors[field] = validatePasswordRequired(value);
    } else if (validatorKey === 'password_confirmation') {
      const passwordValidator = createPasswordConfirmationValidator(
        () => guardianFormData.customer_attributes.password
      );
      guardianErrors[field] = passwordValidator(value);
    } else if (validatorKey === 'cpf') {
      guardianErrors[field] = validateCPFRequired(value);
    } else if (validatorKey === 'birth') {
      guardianErrors[field] = validateBirthDateRequired(value);
    } else if (
      validatorKey === 'name' ||
      validatorKey === 'last_name' ||
      validatorKey === 'rg' ||
      validatorKey === 'profession' ||
      validatorKey === 'mother_name'
    ) {
      guardianErrors[field] = value ? '' : `${field.replace('_', ' ')} é obrigatório`;
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
        <CustomerFormStep1
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
        <CustomerFormStep2
          bind:formData={guardianFormData}
          errors={guardianErrors}
          touched={guardianTouched}
          {isLoading}
          {guardianLabel}
          useSameAddress={formState.useSameAddress}
          useSameBankAccount={formState.useSameBankAccount}
          on:fieldBlur={(e) => handlePersonFieldBlur(e, true)}
          on:cpfInput={(e) => handlePersonCPFInput(e, true)}
          on:birthDateChange={(e) => {
            guardianFormData.birth = e.detail.value;
            guardianTouched.birth = true;
          }}
          on:useSameAddressChange={(e) => handleSameAddressChange(e.detail.checked)}
          on:useSameBankAccountChange={(e) => handleSameBankAccountChange(e.detail.checked)}
        />
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
