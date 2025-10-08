<script lang="ts">
  /* Move to: forms_office_wrappers
   */
  import FormSection from '../ui/FormSection.svelte';
  import SocietyName from '../forms_commons/SocietyName.svelte';
  import Cnpj from '../forms_commons/Cnpj.svelte';
  import SocietyType from '../forms_commons/SocietyType.svelte';
  import AccountingType from '../forms_commons/AccountingType.svelte';
  import FoundationDate from '../forms_commons/FoundationDate.svelte';
  import Site from '../forms_commons/Site.svelte';
  import type { FormValidationConfig } from '../../schemas/new-office-form';
  import { validateCNPJOptional } from '../../validation/cnpj';

  type Props = {
    formData?: {
      name: string;
      cnpj: string;
      society: string;
      accounting_type: string;
      foundation: string;
      site?: string;
    };
    title?: string;
    showSite?: boolean;
    cnpjRequired?: boolean;
    cnpjDisabled?: boolean;
    cnpjValidate?: boolean;
    foundationRequired?: boolean;
    onValidationConfigChange?: (config: FormValidationConfig) => void;
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
    showSite = true,
    cnpjRequired = false,
    cnpjDisabled = false,
    cnpjValidate = true,
    foundationRequired = false,
    onValidationConfigChange
  }: Props = $props();

  // Auto-generate validation configuration based on props
  // Track previous values to prevent infinite loops
  let previousConfig = $state<string>('');

  $effect(() => {
    if (onValidationConfigChange) {
      const validationConfig: FormValidationConfig = {
        name: { required: true }, // Name is always required
        cnpj: {
          required: cnpjRequired,
          customValidator: cnpjValidate ? validateCNPJOptional : undefined
        },
        society: { required: false },
        accounting_type: { required: false },
        foundation: { required: foundationRequired },
        site: { required: false }
      };

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
      <SocietyName
        bind:value={formData.name}
        id="office-name"
        labelText="Nome do Escritório"
        placeholder="Nome do escritório"
        required
      />

      <Cnpj
        bind:value={formData.cnpj}
        id="office-cnpj"
        labelText="CNPJ"
        required={cnpjRequired}
        disabled={cnpjDisabled}
        validate={cnpjValidate}
      />

      <SocietyType
        bind:value={formData.society}
        id="office-society"
        labelText="Tipo de Sociedade"
      />

      <AccountingType
        bind:value={formData.accounting_type}
        id="office-accounting-type"
        labelText="Enquadramento Contábil"
      />

      <FoundationDate
        bind:value={formData.foundation}
        id="office-foundation"
        labelText="Data de Fundação"
      />

      <Site bind:value={formData.site} id="office-site" labelText="Site" />
    </div>
  {/snippet}
</FormSection>
