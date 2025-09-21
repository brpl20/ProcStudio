<script lang="ts">
  /* Move to: forms_office_wrappers
   */
  import FormSection from '../ui/FormSection.svelte';
  import OfficeName from '../forms_commons/OfficeName.svelte';
  import Cnpj from '../forms_commons/Cnpj.svelte';
  import SocietyType from '../forms_commons/SocietyType.svelte';
  import AccountingType from '../forms_commons/AccountingType.svelte';
  import FoundationDate from '../forms_commons/FoundationDate.svelte';

  type Props = {
    formData: {
      name: string;
      cnpj: string;
      society: string;
      accounting_type: string;
      foundation: string;
      site?: string;
    };
    title?: string;
    showSite?: boolean;
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
    showSite = true
  }: Props = $props();
</script>

<FormSection {title}>
  {#snippet children()}
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <OfficeName
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
        required={false}
        validate={true}
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

      {#if showSite}
        <div class="form-control flex flex-col">
          <label class="label pb-1" for="office-site">
            <span class="label-text">Site</span>
          </label>
          <input
            id="office-site"
            type="url"
            class="input input-bordered w-full"
            bind:value={formData.site}
            placeholder="https://exemplo.com"
          />
        </div>
      {/if}
    </div>
  {/snippet}
</FormSection>
