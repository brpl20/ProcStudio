<script lang="ts">
  import FileUpload from '../forms_commons/FileUpload.svelte';

  type Props = {
    logoFile?: File[];
    logoPreview?: string | null;
    contractFiles?: File[];
    onLogoChange?: (event: Event) => void;
    onContractsChange?: (event: Event) => void;
  };

  const {
    logoFile = $bindable([]),
    logoPreview = null,
    contractFiles = $bindable([]),
    onLogoChange,
    onContractsChange
  }: Props = $props();
</script>

<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
  <!-- Logo -->
  <FileUpload
    bind:files={logoFile}
    id="office-logo"
    labelText="Logo do Escritório"
    accept="image/*"
    multiple={false}
    preview={true}
    previewUrl={logoPreview}
    hint="Formatos aceitos: JPG, PNG, GIF, WEBP"
    onchange={onLogoChange}
  />

  <!-- Social Contracts -->
  <FileUpload
    bind:files={contractFiles}
    id="office-contracts"
    labelText="Contratos Sociais"
    accept=".pdf,.docx"
    multiple={true}
    hint="Formatos aceitos: PDF, DOCX"
    onchange={onContractsChange}
  />
</div>