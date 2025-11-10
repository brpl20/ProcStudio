<script lang="ts">
  let {
    value = $bindable(''),
    id = 'phone',
    labelText = 'Telefone',
    placeholder = '(00) 00000-0000',
    required = false,
    disabled = false,
    showLabel = true,
    wrapperClass = '',
    inputClass = ''
  } = $props();

  function formatPhone(phoneValue: string): string {
    const digits = phoneValue.replace(/\D/g, '');

    // Handle different phone number lengths
    if (digits.length <= 10) {
      // Landline: (XX) XXXX-XXXX
      return digits.replace(/(\d{2})(\d)/, '($1) $2').replace(/(\d{4})(\d)/, '$1-$2');
    } else if (digits.length === 11) {
      // Mobile: (XX) XXXXX-XXXX
      return digits.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
    } else {
      // Fallback for longer numbers
      return digits
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{5})(\d)/, '$1-$2')
        .substring(0, 15);
    }
  }

  function handleInput(event: Event) {
    const target = event.target as HTMLInputElement;
    value = formatPhone(target.value);
  }
</script>

<div class="form-control w-full {wrapperClass}">
  {#if showLabel}
    <label for={id} class="label justify-start pb-1">
      <span class="label-text font-medium">
        {labelText}
        {#if required}<span class="text-error">*</span>{/if}
      </span>
    </label>
  {/if}
  <input
    {id}
    type="tel"
    class="input input-bordered w-full {inputClass}"
    {value}
    oninput={handleInput}
    {placeholder}
    {disabled}
    maxlength="15"
    aria-required={required ? 'true' : 'false'}
  />
</div>
