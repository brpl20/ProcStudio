<script lang="ts">
  type Props = {
    value?: string;
    id?: string;
    labelText?: string;
    required?: boolean;
    disabled?: boolean;
    showNewOfficeMessage?: boolean;
  };

  let {
    value = $bindable(''),
    id = 'office-foundation',
    labelText = 'Data de Fundação',
    required = false,
    disabled = false,
    showNewOfficeMessage = false
  }: Props = $props();
</script>

<div class="form-control flex flex-col">
  <label class="label pb-1" for={id}>
    <span class="label-text">
      {labelText}
      {#if showNewOfficeMessage && disabled}
        <div class="tooltip tooltip-info tooltip-right ml-1" data-tip="A data da fundação será definida a partir do registro na OAB">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="inline w-4 h-4 text-info cursor-help"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
        </div>
      {/if}
      {#if required}<span class="text-error">*</span>{/if}
    </span>
  </label>
  <input
    {id}
    type="date"
    class="input input-bordered w-full"
    bind:value
    {required}
    {disabled}
  />
</div>