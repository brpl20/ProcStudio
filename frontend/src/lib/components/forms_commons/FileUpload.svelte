<script lang="ts">
  import type { FormFieldProps } from '../../types/form-field-contract';

  // As propriedades originais são mantidas para garantir a compatibilidade
  interface FileUploadProps extends Omit<FormFieldProps<File[]>, 'value'> {
    files?: File[];
    accept?: string;
    multiple?: boolean;
    preview?: boolean;
    previewUrl?: string | null;
    maxSize?: number; // em bytes
    onchange?: (event: Event) => void;
  }

  type Props = FileUploadProps;

  let {
    files = $bindable([]),
    id = 'file-upload',
    labelText = 'Upload File',
    hint,
    accept = '*/*',
    multiple = false,
    preview = false,
    previewUrl = null,
    maxSize,
    required = false,
    disabled = false,
    errors = null,
    wrapperClass = 'w-full',
    testId,
  }: Props = $props();

  // Função para lidar com a seleção de arquivos
  function handleFileChange(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      if (multiple) {
        // Adiciona novos arquivos à lista existente
        files = [...files, ...Array.from(input.files)];
      } else {
        // Substitui o arquivo atual
        files = Array.from(input.files);
      }
    }
  }

  // Nova função para remover um arquivo da lista
  function removeFile(index: number) {
    files = files.filter((_, i) => i !== index);
  }

  // Função para formatar o tamanho do arquivo, mantida como estava
  function formatFileSize(bytes: number): string {
    if (bytes === 0) {
      return '0 Bytes';
    }
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return `${Math.round((bytes / k ** i) * 100) / 100} ${sizes[i]}`;
  }
</script>

<div class={wrapperClass}>
  <!-- Rótulo principal -->
  {#if labelText}
    <label class="block text-sm font-medium text-[#01013D] mb-2" for={id}>
      {labelText}
      {#if required}<span class="text-red-500 ml-1">*</span>{/if}
    </label>
  {/if}

  <!-- Área de Upload Customizada -->
  <div
    class="relative border-2 border-dashed rounded-lg p-6 text-center transition-colors duration-200"
    class:border-gray-300={!errors}
    class:hover:border-[#0277EE]={!disabled}
    class:hover:bg-blue-50={!disabled}
    class:border-red-500={errors}
    class:bg-gray-50={disabled}
    class:cursor-not-allowed={disabled}
  >
    <label for={id} class="flex flex-col items-center justify-center space-y-2" class:cursor-pointer={!disabled}>
      <!-- Ícone de Upload -->
      <svg class="w-10 h-10 text-gray-400" class:text-gray-300={disabled} fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
      </svg>
      <p class="text-sm font-medium text-gray-600" class:text-gray-400={disabled}>
        <span class="text-[#0277EE] font-semibold">Clique para enviar</span> ou arraste e solte
      </p>
    </label>
    <!-- Input de arquivo real, oculto -->
    <input
      {id}
      type="file"
      class="hidden"
      {accept}
      {multiple}
      {disabled}
      {required}
      on:change={handleFileChange}
      data-testid={testId}
      aria-invalid={!!errors}
    />
  </div>

  <!-- Texto de dica e erro -->
  {#if hint && !errors}
    <p class="mt-2 text-xs text-gray-500">{hint}</p>
  {/if}
  {#if errors}
    <p class="mt-2 text-sm text-red-600">{errors}</p>
  {/if}

  <!-- Preview de Imagem (se habilitado) -->
  {#if preview && previewUrl}
    <div class="mt-4">
      <img
        src={previewUrl}
        alt="Preview do arquivo"
        class="w-24 h-24 object-cover rounded-lg border border-gray-200"
      />
    </div>
  {/if}

  <!-- Lista de Arquivos Selecionados -->
  {#if files.length > 0}
    <div class="mt-4 space-y-2">
      <h4 class="text-sm font-medium text-[#01013D]">Arquivos selecionados:</h4>
      {#each files as file, index (file.name + file.size)}
        <div class="flex items-center justify-between gap-3 bg-gray-50 border border-gray-200 p-2.5 rounded-lg">
          <div class="flex items-center gap-3 overflow-hidden">
            <!-- Ícone de arquivo -->
            <svg class="w-5 h-5 text-[#0277EE] flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path></svg>
            <div class="flex flex-col overflow-hidden">
                <span class="text-sm font-medium text-gray-800 truncate" title={file.name}>{file.name}</span>
                <span class="text-xs text-gray-500">{formatFileSize(file.size)}</span>
            </div>
          </div>
          <!-- Botão de Remover -->
          <button
            type="button"
            class="w-7 h-7 flex-shrink-0 flex items-center justify-center bg-gray-200 rounded-full hover:bg-red-100 hover:text-red-600 text-gray-600 transition-colors"
            on:click={() => removeFile(index)}
            disabled={disabled}
            aria-label="Remover {file.name}"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </div>
      {/each}
    </div>
  {/if}
</div>