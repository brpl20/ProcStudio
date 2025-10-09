<script lang="ts">
  import FormSection from '../ui/FormSection.svelte';
  import SocietyName from '../forms_commons/SocietyName.svelte';
  import Cnpj from '../forms_commons/Cnpj.svelte';
  import SocietyType from '../forms_commons/SocietyType.svelte';
  import AccountingType from '../forms_commons/AccountingType.svelte';
  import FoundationDate from '../forms_commons/FoundationDate.svelte';
  import Site from '../forms_commons/Site.svelte';
  import { validateCNPJOptional } from '../../validation/cnpj';

  // Generic interfaces for base component
  interface BaseValidationRule {
    required?: boolean;
    customValidator?: (value: any) => string | null;
  }

  interface BaseValidationConfig {
    [fieldName: string]: BaseValidationRule;
  }

  interface BaseSocietyFormData {
    name: string;
    cnpj: string;
    society: string;
    accounting_type: string;
    foundation: string;
    site?: string;
  }

  interface FieldConfig {
    id: string;
    labelText: string;
    placeholder?: string;
    required?: boolean;
    disabled?: boolean;
    validate?: boolean;
    show?: boolean;
  }

  interface SocietyFieldsConfig {
    name: FieldConfig;
    cnpj: FieldConfig;
    society: FieldConfig;
    accounting_type: FieldConfig;
    foundation: FieldConfig;
    site: FieldConfig;
  }

  type Props = {
    formData?: BaseSocietyFormData;
    title?: string;
    fieldsConfig: SocietyFieldsConfig;
    showFoundationMessage?: boolean;
    onValidationConfigChange?: (config: BaseValidationConfig) => void;
  };

  let {
    formData = $bindable({
      name: '',
      cnpj: '',
      society: '',
      accounting_type: '',
      foundation: '',
      site: ''
    }),
    title = 'Informações Básicas',
    fieldsConfig,
    showFoundationMessage = false,
    onValidationConfigChange
  }: Props = $props();

  // Auto-generate validation configuration based on fieldsConfig
  // Track previous values to prevent infinite loops
  let previousConfig = $state<string>('');

  $effect(() => {
    if (onValidationConfigChange) {
      const validationConfig: BaseValidationConfig = {};

      // Generate validation config from fieldsConfig
      for (const [fieldName, config] of Object.entries(fieldsConfig)) {
        validationConfig[fieldName] = {
          required: config.required || false,
          customValidator: config.validate && fieldName === 'cnpj' ? validateCNPJOptional : undefined
        };
      }

      // Only call if config actually changed
      const configString = JSON.stringify(validationConfig);
      if (configString !== previousConfig) {
        previousConfig = configString;
        onValidationConfigChange(validationConfig);
      }
    }
  });
</script>

<FormSection {title}>
  {#snippet children()}
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      {#if fieldsConfig.name.show !== false}
        <SocietyName
          bind:value={formData.name}
          id={fieldsConfig.name.id}
          labelText={fieldsConfig.name.labelText}
          placeholder={fieldsConfig.name.placeholder || fieldsConfig.name.labelText}
          required={fieldsConfig.name.required || false}
          disabled={fieldsConfig.name.disabled || false}
        />
      {/if}

      {#if fieldsConfig.cnpj.show !== false}
        <Cnpj
          bind:value={formData.cnpj}
          id={fieldsConfig.cnpj.id}
          labelText={fieldsConfig.cnpj.labelText}
          placeholder={fieldsConfig.cnpj.placeholder}
          required={fieldsConfig.cnpj.required || false}
          disabled={fieldsConfig.cnpj.disabled || false}
          validate={fieldsConfig.cnpj.validate !== false}
        />
      {/if}

      {#if fieldsConfig.society.show !== false}
        <SocietyType
          bind:value={formData.society}
          id={fieldsConfig.society.id}
          labelText={fieldsConfig.society.labelText}
          required={fieldsConfig.society.required || false}
          disabled={fieldsConfig.society.disabled || false}
        />
      {/if}

      {#if fieldsConfig.accounting_type.show !== false}
        <AccountingType
          bind:value={formData.accounting_type}
          id={fieldsConfig.accounting_type.id}
          labelText={fieldsConfig.accounting_type.labelText}
          required={fieldsConfig.accounting_type.required || false}
          disabled={fieldsConfig.accounting_type.disabled || false}
        />
      {/if}

      {#if fieldsConfig.foundation.show !== false}
        <FoundationDate
          bind:value={formData.foundation}
          id={fieldsConfig.foundation.id}
          labelText={fieldsConfig.foundation.labelText}
          required={fieldsConfig.foundation.required || false}
          disabled={fieldsConfig.foundation.disabled || false}
          showNewOfficeMessage={showFoundationMessage}
        />
      {/if}

      {#if fieldsConfig.site.show !== false}
        <Site
          bind:value={formData.site}
          id={fieldsConfig.site.id}
          labelText={fieldsConfig.site.labelText}
          placeholder={fieldsConfig.site.placeholder}
          required={fieldsConfig.site.required || false}
          disabled={fieldsConfig.site.disabled || false}
        />
      {/if}
    </div>
  {/snippet}
</FormSection>