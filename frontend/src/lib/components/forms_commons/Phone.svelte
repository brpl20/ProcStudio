<script>
  export let value = '';
  export let placeholder = '(00) 00000-0000';

  function formatPhone(value) {
    const digits = value.replace(/\D/g, '');
    
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
</script>

<input
  type="tel"
  class="input input-bordered w-full"
  {value}
  on:input={(e) => (value = formatPhone(e.target.value))}
  {placeholder}
  maxlength="15"
/>
