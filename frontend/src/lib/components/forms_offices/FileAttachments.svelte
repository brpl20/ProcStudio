<script lang="ts">
  type Props = {
    logoPreview?: string | null;
    contractFiles?: File[];
    onLogoChange?: (event: Event) => void;
    onContractsChange?: (event: Event) => void;
  };

  let {
    logoPreview = null,
    contractFiles = [],
    onLogoChange,
    onContractsChange
  }: Props = $props();

  function handleLogoChange(event: Event) {
    if (onLogoChange) {
      onLogoChange(event);
    }
  }

  function handleContractsChange(event: Event) {
    if (onContractsChange) {
      onContractsChange(event);
    }
  }
</script>

<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
  <!-- Logo -->
  <div class="form-control flex flex-col">
    <label class="label pb-1" for="office-logo">
      <span class="label-text">Logo do Escritório</span>
    </label>
    <input
      id="office-logo"
      type="file"
      class="file-input file-input-bordered w-full"
      accept="image/*"
      onchange={handleLogoChange}
    />
    {#if logoPreview}
      <div class="mt-2">
        <img
          src={logoPreview}
          alt="Preview do logo"
          class="w-24 h-24 object-cover rounded"
        />
      </div>
    {/if}
    <div class="label">
      <span class="label-text-alt">Formatos aceitos: JPG, PNG, GIF, WEBP</span>
    </div>
  </div>

  <!-- Social Contracts -->
  <div class="form-control flex flex-col">
    <label class="label pb-1" for="office-contracts">
      <span class="label-text">Contratos Sociais</span>
    </label>
    <input
      id="office-contracts"
      type="file"
      class="file-input file-input-bordered w-full"
      accept=".pdf,.docx"
      multiple
      onchange={handleContractsChange}
    />
    {#if contractFiles.length > 0}
      <div class="mt-2 space-y-1">
        {#each contractFiles as file}
          <div class="badge badge-outline">{file.name}</div>
        {/each}
      </div>
    {/if}
    <div class="label">
      <span class="label-text-alt">Formatos aceitos: PDF, DOCX</span>
    </div>
  </div>
</div>