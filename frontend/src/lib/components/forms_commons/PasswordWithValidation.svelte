<script lang="ts">
  /* eslint-disable prefer-const */
  import type { TextFieldProps } from '../../types/form-field-contract';
  import {
    DEFAULT_PASSWORD_CONFIG,
    validatePassword,
    getPasswordFeedback,
    type PasswordConfig
  } from '../../validation/password-config';

  interface PasswordWithValidationProps extends TextFieldProps {
    showStrength?: boolean;
    showRequirements?: boolean;
    showToggle?: boolean;
    config?: PasswordConfig;
    instantValidation?: boolean;
  }

  let {
    value = $bindable(''),
    id = 'password',
    labelText = 'Senha',
    placeholder = 'Digite a senha',
    required = false,
    disabled = false,
    errors = $bindable(null),
    touched = $bindable(false),
    wrapperClass = '',
    inputClass = '',
    testId = undefined,
    showStrength = true,
    showRequirements = true,
    showToggle = true,
    config = DEFAULT_PASSWORD_CONFIG,
    instantValidation = true
  }: PasswordWithValidationProps = $props();

  let showPassword = $state(false);
  let feedback = $state(getPasswordFeedback('', config));

  // Update feedback whenever value changes
  $effect(() => {
    if (!touched) {
      // Clear errors when not touched
      errors = null;
    } else if (instantValidation && value) {
      feedback = getPasswordFeedback(value, config);
      const validation = validatePassword(value, config);
      if (!validation.isValid) {
        errors = validation.errors[0]; // Show first error
      } else {
        errors = null;
      }
    } else if (!value && required) {
      errors = 'Senha é obrigatória';
    }
  });

  function handleBlur() {
    touched = true;
    if (required && !value) {
      errors = 'Senha é obrigatória';
    } else if (value) {
      const validation = validatePassword(value, config);
      if (!validation.isValid) {
        errors = validation.errors[0]; // Show first error
      } else {
        errors = null;
      }
    }
  }

  function togglePasswordVisibility() {
    showPassword = !showPassword;
  }

  // Get progress bar color class
  function getProgressClass(strength: number): string {
    switch (strength) {
      case 0:
      case 1:
        return 'bg-error';
      case 2:
        return 'bg-warning';
      case 3:
        return 'bg-info';
      case 4:
      case 5:
        return 'bg-success';
      default:
        return 'bg-gray-300';
    }
  }
</script>

<div class="form-control w-full {wrapperClass}">
  <label for={id} class="label justify-start pb-1">
    <span class="label-text font-medium">
      {labelText}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>

  <div class="relative">
    <input
      {id}
      type={showPassword ? 'text' : 'password'}
      class="input input-bordered w-full pr-10 {errors && touched ? 'input-error' : ''} {inputClass}"
      bind:value
      onblur={handleBlur}
      {disabled}
      {placeholder}
      aria-required={required ? 'true' : 'false'}
      aria-invalid={errors && touched ? 'true' : 'false'}
      aria-describedby={errors && touched ? `${id}-error` : showRequirements ? `${id}-requirements` : undefined}
      data-testid={testId || `${id}-input`}
    />

    {#if showToggle && value}
      <button
        type="button"
        class="absolute right-2 top-1/2 -translate-y-1/2 btn btn-ghost btn-xs btn-circle"
        onclick={togglePasswordVisibility}
        aria-label={showPassword ? 'Ocultar senha' : 'Mostrar senha'}
      >
        {#if showPassword}
          <!-- Eye closed icon -->
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />
          </svg>
        {:else}
          <!-- Eye open icon -->
          <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
          </svg>
        {/if}
      </button>
    {/if}
  </div>

  {#if showStrength && value}
    <div class="mt-2">
      <!-- Strength bar -->
      <div class="flex items-center gap-2">
        <div class="flex-1">
          <div class="h-2 bg-gray-200 rounded-full overflow-hidden">
            <div
              class="h-full transition-all duration-300 {getProgressClass(feedback.strength)}"
              style="width: {(feedback.strength / 5) * 100}%"
            ></div>
          </div>
        </div>
        <span class="text-xs font-medium {feedback.strengthColor === 'error' ? 'text-error' : feedback.strengthColor === 'warning' ? 'text-warning' : feedback.strengthColor === 'info' ? 'text-info' : 'text-success'}">
          {feedback.strengthLabel}
        </span>
      </div>
    </div>
  {/if}

  {#if showRequirements && value && instantValidation}
    <div id="{id}-requirements" class="mt-2 space-y-1">
      {#each feedback.requirements as req}
        <div class="flex items-center gap-1 text-xs">
          {#if req.met}
            <svg class="w-3 h-3 text-success" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
            </svg>
            <span class="text-success">{req.text}</span>
          {:else}
            <svg class="w-3 h-3 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd" />
            </svg>
            <span class="text-gray-500">{req.text}</span>
          {/if}
        </div>
      {/each}
    </div>
  {/if}

  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}
</div>