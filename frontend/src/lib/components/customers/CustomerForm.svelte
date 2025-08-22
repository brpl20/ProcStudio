<!-- components/customers/CustomerForm.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import { createCustomerValidationStore } from '../../validation/validationStore';
  import { validateEmailRequired } from '../../validation/email';
  import { validationRules } from '../../validation';
  import type { Customer, CreateCustomerRequest, UpdateCustomerRequest, CustomerStatus } from '../../api/types/customer.types';
  
  export let customer: Customer | null = null;
  export let isLoading: boolean = false;
  
  const dispatch = createEventDispatcher<{
    submit: CreateCustomerRequest | UpdateCustomerRequest;
    cancel: void;
  }>();
  
  // Create validation store
  const validation = createCustomerValidationStore();
  
  // Form data
  let formData = {
    email: customer?.email || '',
    access_email: customer?.access_email || '',
    password: '',
    password_confirmation: '',
    status: (customer?.status || 'active') as CustomerStatus
  };
  
  // Initialize form with existing customer data
  if (customer) {
    validation.setFieldValue('email', formData.email);
    validation.setFieldValue('access_email', formData.access_email);
  }
  
  // Handle field validation on blur
  function handleFieldBlur(fieldName: string, value: string) {
    validation.validateField(fieldName, value, true);
  }
  
  // Handle field input (update value without validation)
  function handleFieldInput(fieldName: string, value: string) {
    formData[fieldName] = value;
    validation.setFieldValue(fieldName, value);
  }
  
  // Validate password confirmation separately
  function handlePasswordConfirmationBlur() {
    validation.validateField('password_confirmation', formData.password_confirmation, true);
    if (formData.password && formData.password_confirmation) {
      validation.validatePasswordConfirmation(formData.password, formData.password_confirmation);
    }
  }
  
  // Custom validation for the form
  function validateForm(): boolean {
    // Validate basic fields
    let isValid = validation.validateAll(formData);
    
    // Additional validation for required fields
    if (!formData.email) {
      validation.validateField('email', '', true);
      isValid = false;
    }
    
    if (!customer) {
      // For new customers, password is required
      if (!formData.password) {
        validation.validateField('password', '', true);
        isValid = false;
      }
      
      if (!formData.password_confirmation) {
        validation.validateField('password_confirmation', '', true);
        isValid = false;
      }
      
      // Check password confirmation
      if (formData.password && formData.password_confirmation) {
        if (!validation.validatePasswordConfirmation(formData.password, formData.password_confirmation)) {
          isValid = false;
        }
      }
    } else if (formData.password) {
      // For existing customers, only validate if password is provided
      if (formData.password && formData.password.length < 6) {
        validation.validateField('password', formData.password, true);
        isValid = false;
      }
      
      if (formData.password && formData.password_confirmation) {
        if (!validation.validatePasswordConfirmation(formData.password, formData.password_confirmation)) {
          isValid = false;
        }
      }
    }
    
    return isValid;
  }
  
  function handleSubmit(): void {
    if (!validateForm()) return;
    
    const data: CreateCustomerRequest | UpdateCustomerRequest = {
      email: formData.email,
      status: formData.status
    };
    
    if (formData.access_email) {
      data.access_email = formData.access_email;
    }
    
    if (formData.password) {
      data.password = formData.password;
      data.password_confirmation = formData.password_confirmation;
    }
    
    dispatch('submit', data);
  }
  
  function handleCancel(): void {
    dispatch('cancel');
  }
  
  // Get field validation state
  $: emailField = $validation.email;
  $: passwordField = $validation.password;
  $: passwordConfirmationField = $validation.password_confirmation;
</script>

<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">
      {customer ? 'Editar Cliente' : 'Novo Cliente'}
    </h2>
    
    <form on:submit|preventDefault={handleSubmit} class="space-y-4">
      <!-- Email Field -->
      <div class="form-control">
        <label for="email" class="label">
          <span class="label-text">Email *</span>
        </label>
        <input
          id="email"
          type="email"
          class="input input-bordered {emailField?.error && emailField?.touched ? 'input-error' : ''}"
          bind:value={formData.email}
          on:input={(e) => handleFieldInput('email', e.currentTarget.value)}
          on:blur={(e) => handleFieldBlur('email', e.currentTarget.value)}
          disabled={isLoading}
          placeholder="cliente@exemplo.com"
        />
        {#if emailField?.error && emailField?.touched}
          <label class="label">
            <span class="label-text-alt text-error">{emailField.error}</span>
          </label>
        {/if}
      </div>
      
      <!-- Access Email Field -->
      <div class="form-control">
        <label for="access_email" class="label">
          <span class="label-text">Email de Acesso</span>
        </label>
        <input
          id="access_email"
          type="email"
          class="input input-bordered"
          bind:value={formData.access_email}
          on:input={(e) => handleFieldInput('access_email', e.currentTarget.value)}
          disabled={isLoading}
          placeholder="Opcional - email alternativo para acesso"
        />
      </div>
      
      <!-- Status Field -->
      <div class="form-control">
        <label for="status" class="label">
          <span class="label-text">Status</span>
        </label>
        <select
          id="status"
          class="select select-bordered"
          bind:value={formData.status}
          disabled={isLoading}
        >
          <option value="active">Ativo</option>
          <option value="inactive">Inativo</option>
          <option value="deceased">Falecido</option>
        </select>
      </div>
      
      <div class="divider">Senha</div>
      
      <!-- Password Field -->
      <div class="form-control">
        <label for="password" class="label">
          <span class="label-text">
            {customer ? 'Nova Senha (deixe em branco para manter a atual)' : 'Senha *'}
          </span>
        </label>
        <input
          id="password"
          type="password"
          class="input input-bordered {passwordField?.error && passwordField?.touched ? 'input-error' : ''}"
          bind:value={formData.password}
          on:input={(e) => handleFieldInput('password', e.currentTarget.value)}
          on:blur={(e) => handleFieldBlur('password', e.currentTarget.value)}
          disabled={isLoading}
          placeholder="Mínimo 6 caracteres"
        />
        {#if passwordField?.error && passwordField?.touched}
          <label class="label">
            <span class="label-text-alt text-error">{passwordField.error}</span>
          </label>
        {/if}
      </div>
      
      <!-- Password Confirmation Field -->
      <div class="form-control">
        <label for="password_confirmation" class="label">
          <span class="label-text">
            {customer ? 'Confirmar Nova Senha' : 'Confirmar Senha *'}
          </span>
        </label>
        <input
          id="password_confirmation"
          type="password"
          class="input input-bordered {passwordConfirmationField?.error && passwordConfirmationField?.touched ? 'input-error' : ''}"
          bind:value={formData.password_confirmation}
          on:input={(e) => handleFieldInput('password_confirmation', e.currentTarget.value)}
          on:blur={handlePasswordConfirmationBlur}
          disabled={isLoading}
          placeholder="Digite a senha novamente"
        />
        {#if passwordConfirmationField?.error && passwordConfirmationField?.touched}
          <label class="label">
            <span class="label-text-alt text-error">{passwordConfirmationField.error}</span>
          </label>
        {/if}
      </div>
      
      <!-- Actions -->
      <div class="card-actions justify-end mt-6">
        <button
          type="button"
          class="btn btn-ghost"
          on:click={handleCancel}
          disabled={isLoading}
        >
          Cancelar
        </button>
        <button
          type="submit"
          class="btn btn-primary"
          disabled={isLoading}
        >
          {#if isLoading}
            <span class="loading loading-spinner"></span>
          {/if}
          {customer ? 'Atualizar' : 'Criar'}
        </button>
      </div>
    </form>
    
    <!-- Show validation errors summary for debugging (optional) -->
    {#if $validation.errors?.length > 0}
      <div class="alert alert-warning mt-4">
        <div class="flex flex-col">
          <span>Corrija os seguintes erros:</span>
          <ul class="list-disc list-inside">
            {#each $validation.errors as error}
              <li>{error}</li>
            {/each}
          </ul>
        </div>
      </div>
    {/if}
  </div>
</div>