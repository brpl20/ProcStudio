<script lang="ts">
  import { CEPFormatter } from '../../validation/cep-formatter';
  import { CEPValidator } from '../../validation/cep-validator';
  import { cepService } from '../../api-external/services/cep-service';

  interface AddressInfo {
    logradouro: string;
    complemento?: string;
    bairro: string;
    localidade: string;
    uf: string;
    estado: string;
    cep?: string;
    ibge?: string;
    gia?: string;
    ddd?: string;
    siafi?: string;
  }

  type Props = {
    value?: string;
    errors?: string | null;
    touched?: boolean;
    disabled?: boolean;
    validateFn?: (value: string) => string | null;
    formatFn?: (value: string) => string;
    id?: string;
    required?: boolean;
    labelText?: string;
    placeholder?: string;
    testId?: string;
    inputClass?: string;
    wrapperClass?: string;
    useAPIValidation?: boolean;
    showAddressInfo?: boolean;
    oninput?: (event: CustomEvent) => void;
    onblur?: (event: CustomEvent) => void;
    onvalidate?: (event: CustomEvent) => void;
    onaddressfound?: (event: CustomEvent) => void;
  };

  let {
    value = $bindable(''),
    errors = $bindable(null),
    touched = $bindable(false),
    disabled = false,
    validateFn = CEPValidator.validateRequired,
    formatFn = CEPFormatter.format,
    id = 'cep',
    required = true,
    labelText = 'CEP',
    placeholder = '00000-000',
    testId = undefined,
    inputClass = '',
    wrapperClass = '',
    useAPIValidation = false,
    showAddressInfo = false,
    oninput,
    onblur,
    onvalidate,
    onaddressfound
  }: Props = $props();

  let addressInfo = $state<AddressInfo | null>(null);
  let isValidating = $state(false);
  let validationStatus = $state<'valid' | 'invalid' | null>(null);

  function handleInput(event: Event) {
    const target = event.target as HTMLInputElement;
    let newValue = target.value;

    if (formatFn) {
      newValue = formatFn(newValue);
    }

    value = newValue;
    addressInfo = null;
    validationStatus = null;
    oninput?.(new CustomEvent('input', { detail: { value: newValue, id } }));
  }

  async function handleBlur() {
    touched = true;
    onblur?.(new CustomEvent('blur', { detail: { id, value } }));

    if (!value) {
      if (required) {
        errors = 'CEP é obrigatório';
      } else {
        errors = null;
      }
      onvalidate?.(new CustomEvent('validate', { detail: { id, value, error: errors, addressInfo } }));
      return;
    }

    if (validateFn) {
      const error = validateFn(value);
      errors = error;

      if (!error && useAPIValidation) {
        isValidating = true;
        try {
          const apiResult = await cepService.validate(value);

          if (apiResult.isValid && apiResult.data) {
            validationStatus = 'valid';
            if (showAddressInfo) {
              addressInfo = apiResult.data as AddressInfo;
            }
            onaddressfound?.(new CustomEvent('addressfound', {
              detail: {
                id,
                value,
                address: apiResult.data as AddressInfo
              }
            }));
          } else {
            validationStatus = 'invalid';
          }
        } catch (error) {
          validationStatus = 'invalid';
        } finally {
          isValidating = false;
        }
      }
    }

    onvalidate?.(new CustomEvent('validate', { detail: { id, value, error: errors, addressInfo } }));
  }
</script>

<div class="form-control w-full {wrapperClass}">
  <label for={id} class="label pb-1">
    <span class="label-text">{labelText} {required ? '*' : ''}</span>
  </label>
  <div class="relative">
    <input
      {id}
      type="text"
      class="input input-bordered w-full {errors && touched ? 'input-error' : ''} {validationStatus === 'valid' ? 'border-success' : ''} {validationStatus === 'invalid' ? 'border-error' : ''} {inputClass}"
      bind:value
      oninput={handleInput}
      onblur={handleBlur}
      {disabled}
      {placeholder}
      maxlength="9"
      aria-required={required ? 'true' : 'false'}
      aria-invalid={errors && touched ? 'true' : 'false'}
      aria-describedby={errors && touched ? `${id}-error` : undefined}
      data-testid={testId || `${id}-input`}
    />
    {#if isValidating}
      <div class="absolute right-3 top-1/2 transform -translate-y-1/2">
        <span class="loading loading-spinner loading-sm"></span>
      </div>
    {/if}
  </div>

  {#if errors && touched}
    <div id="{id}-error" class="text-error text-sm mt-1">{errors}</div>
  {/if}

</div>
