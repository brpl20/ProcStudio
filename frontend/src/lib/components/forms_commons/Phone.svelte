<script>
  export let value = '';
  export let placeholder = '(00) 00000-0000';

  function formatPhone(value) {
    const digits = value.replace(/\D/g, '');
    if (digits.length <= 10) {
      return digits.replace(/(\d{2})(\d)/, '($1) $2').replace(/(\d{4})(\d)/, '$1-$2');
    } else {
      return digits
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{5})(\d)/, '$1-$2')
        .substr(0, 15);
    }
  }
</script>

<input
  type="tel"
  class="input input-bordered w-full"
  {value}
  on:input={(e) => (value = formatPhone(e.target.value))}
  {placeholder}
  maxlength="15"
/>
