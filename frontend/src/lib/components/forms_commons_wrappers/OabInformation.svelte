<script lang="ts">
  import FormSection from '../ui/FormSection.svelte';
  import OabOfficeId from '../forms_commons/OabOfficeId.svelte';
  import OabStatus from '../forms_commons/OabStatus.svelte';
  import OabOfficeInscricao from '../forms_commons/OabOfficeInscricao.svelte';
  import OabOfficeLink from '../forms_commons/OabOfficeLink.svelte';

  type Props = {
    formData: {
      oab_id?: string;
      oab_status?: string;
      oab_inscricao?: string;
      oab_link?: string;
    };
    title?: string;
    errors?: {
      oab_id?: string | null;
      oab_status?: string | null;
      oab_inscricao?: string | null;
      oab_link?: string | null;
    };
    touched?: {
      oab_id?: boolean;
      oab_status?: boolean;
      oab_inscricao?: boolean;
      oab_link?: boolean;
    };
  };

  let {
    formData = $bindable({
      oab_id: '',
      oab_status: '',
      oab_inscricao: '',
      oab_link: ''
    }),
    title = 'Informações da OAB',
    errors = {},
    touched = {}
  }: Props = $props();
</script>

<FormSection {title}>
  {#snippet children()}
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <OabOfficeId 
        bind:value={formData.oab_id}
        id="office-oab-id"
        labelText="Identificação OAB"
        placeholder="ID do escritório na OAB"
        errors={errors?.oab_id}
        touched={touched?.oab_id}
      />

      <OabStatus 
        bind:value={formData.oab_status}
        id="office-oab-status"
        labelText="Status na OAB"
        placeholder="Status na OAB"
        errors={errors?.oab_status}
        touched={touched?.oab_status}
      />

      <OabOfficeInscricao 
        bind:value={formData.oab_inscricao}
        id="office-oab-inscricao"
        labelText="Inscrição OAB"
        placeholder="Número da inscrição"
        errors={errors?.oab_inscricao}
        touched={touched?.oab_inscricao}
      />

      <OabOfficeLink 
        bind:value={formData.oab_link}
        id="office-oab-link"
        labelText="Link OAB"
        placeholder="Link do perfil na OAB"
        errors={errors?.oab_link}
        touched={touched?.oab_link}
      />
    </div>
  {/snippet}
</FormSection>