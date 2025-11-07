<script lang="ts">
  import type { FormFieldProps } from '../../types/form-field-contract';

  interface FileUploadProps extends Omit<FormFieldProps<File[]>, 'value'> {
    files?: File[];
    accept?: string;
    multiple?: boolean;
    preview?: boolean;
    previewUrl?: string | null;
    maxSize?: number; // in bytes
    onchange?: (event: Event) => void;
  }

  type Props = FileUploadProps;

  let {
    files = $bindable([]),
    id = 'file-upload',
    labelText = 'Upload File',
    placeholder = 'Choose file...',
    hint,
    accept = '*/*',
    multiple = false,
    preview = false,
    previewUrl = null,
    maxSize,
    required = false,
    disabled = false,
    errors = null,
    wrapperClass = 'form-control flex flex-col',
    inputClass = 'file-input file-input-bordered w-full',
    labelClass = 'label pb-1',
    testId,
    ariaLabel,
    ariaDescribedBy,
    onchange
  }: Props = $props();

  function handleFileChange(event: Event) {
    const input = event.target as HTMLInputElement;
    if (input.files) {
      files = Array.from(input.files);
    }
    onchange?.(event);
  }

  function formatFileSize(bytes: number): string {
    if (bytes === 0) {
return '0 Bytes';
}
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i];
  }
</script>

<div class={wrapperClass}>
  {#if labelText}
    <label class={labelClass} for={id}>
      <span class="label-text">
        {labelText}
        {#if required}<span class="text-error">*</span>{/if}
      </span>
    </label>
  {/if}

  <input
    {id}
    type="file"
    class={inputClass}
    class:file-input-error={errors}
    {accept}
    {multiple}
    {disabled}
    {required}
    onchange={handleFileChange}
    data-testid={testId}
    aria-label={ariaLabel || labelText}
    aria-describedby={ariaDescribedBy}
    aria-invalid={!!errors}
  />

  {#if preview && previewUrl}
    <div class="mt-2">
      <img
        src={previewUrl}
        alt="Preview"
        class="w-24 h-24 object-cover rounded"
      />
    </div>
  {/if}

  {#if files.length > 0}
    <div class="mt-2 space-y-1">
      {#each files as file}
        <div class="flex items-center gap-2">
          <div class="badge badge-outline">{file.name}</div>
          <span class="text-xs text-gray-500">
            {formatFileSize(file.size)}
          </span>
        </div>
      {/each}
    </div>
  {/if}

  {#if hint && !errors}
    <div class="label">
      <span class="label-text-alt">{hint}</span>
      {#if maxSize}
        <span class="label-text-alt">
          Max size: {formatFileSize(maxSize)}
        </span>
      {/if}
    </div>
  {/if}

  {#if errors}
    <div class="label">
      <span class="label-text-alt text-error">{errors}</span>
    </div>
  {/if}
</div>