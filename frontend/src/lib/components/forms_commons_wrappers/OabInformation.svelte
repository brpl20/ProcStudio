<script lang="ts">
  /* Move to: forms_office_wrappers
   */
  import FormSection from '../ui/FormSection.svelte';
  import OabId from '../forms_commons/OabId.svelte';
  import OabStatus from '../forms_commons/OabStatus.svelte';
  import Link from '../forms_commons/Link.svelte';

  type Props = {
    formData: {
      oab_id?: string;
      oab_status?: string;
      oab_link?: string;
    };
    title?: string;
    errors?: {
      oab_id?: string | null;
      oab_status?: string | null;
      oab_link?: string | null;
    };
    touched?: {
      oab_id?: boolean;
      oab_status?: boolean;
      oab_link?: boolean;
    };
  };

  let {
    formData = $bindable({
      oab_id: '',
      oab_status: 'active', // Default to active
      oab_link: '' // Default to empty
    }),
    title = 'Informações da OAB',
    errors = {},
    touched = {}
  }: Props = $props();

  // Ensure defaults are always set
  $effect(() => {
    if (!formData.oab_status) {
      formData.oab_status = 'active';
    }
    if (formData.oab_link === undefined) {
      formData.oab_link = '';
    }
  });
</script>

<FormSection {title}>
  {#snippet children()}
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <OabId
        bind:value={formData.oab_id}
        id="office-oab-id"
        type="office"
        labelText="Identificação OAB do Escritório"
        placeholder="ID do escritório na OAB"
        errors={errors?.oab_id}
        touched={touched?.oab_id}
      />

      <!-- Hidden: Status OAB (always active for new offices) -->
      <!-- Hidden: Link OAB (not used for now) -->
    </div>
  {/snippet}
</FormSection>
