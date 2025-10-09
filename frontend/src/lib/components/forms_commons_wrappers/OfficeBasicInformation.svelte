<script lang="ts">
  import SocietyBasicInformation from './SocietyBasicInformation.svelte';
  import type { FormValidationConfig } from '../../schemas/new-office-form';
  import type { NewOfficeFormData } from '../../schemas/new-office-form';

  type Props = {
    formData?: NewOfficeFormData;
    title?: string;
    showSite?: boolean;
    cnpjRequired?: boolean;
    cnpjDisabled?: boolean;
    cnpjValidate?: boolean;
    foundationRequired?: boolean;
    foundationDisabled?: boolean;
    societyRequired?: boolean;
    accountingRequired?: boolean;
    siteRequired?: boolean;
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
    title = 'Informações do Escritório',
    showSite = true,
    cnpjRequired = false,
    cnpjDisabled = false,
    cnpjValidate = true,
    foundationRequired = false,
    foundationDisabled = false,
    societyRequired = false,
    accountingRequired = false,
    siteRequired = false,
    onValidationConfigChange
  }: Props = $props();

  // Office-specific field configuration
  const officeFieldsConfig = {
    name: {
      id: 'office-name',
      labelText: 'Nome do Escritório',
      placeholder: 'Nome do escritório',
      required: true, // Always required for offices
      show: true
    },
    cnpj: {
      id: 'office-cnpj',
      labelText: 'CNPJ',
      placeholder: '00.000.000/0000-00',
      required: cnpjRequired,
      disabled: cnpjDisabled,
      validate: cnpjValidate,
      show: true
    },
    society: {
      id: 'office-society',
      labelText: 'Tipo de Sociedade',
      required: societyRequired,
      show: true
    },
    accounting_type: {
      id: 'office-accounting-type',
      labelText: 'Enquadramento Contábil',
      required: accountingRequired,
      show: true
    },
    foundation: {
      id: 'office-foundation',
      labelText: 'Data de Fundação',
      required: foundationRequired,
      disabled: foundationDisabled,
      show: true
    },
    site: {
      id: 'office-site',
      labelText: 'Site',
      placeholder: 'https://...',
      required: siteRequired,
      show: showSite
    }
  };

  // Handle validation config changes from parent component
  function handleValidationConfigChange(config: any) {
    if (onValidationConfigChange) {
      // Convert base config to office-specific FormValidationConfig
      onValidationConfigChange(config as FormValidationConfig);
    }
  }
</script>

<SocietyBasicInformation
  bind:formData={formData}
  {title}
  fieldsConfig={officeFieldsConfig}
  showFoundationMessage={foundationDisabled}
  onValidationConfigChange={handleValidationConfigChange}
/>