<script lang="ts">
  import Email from '../forms_commons/Email.svelte';
  import PasswordWithValidation from '../forms_commons/PasswordWithValidation.svelte';
  import PasswordConfirmation from '../forms_commons/PasswordConfirmation.svelte';

  // A prop 'credentials' agora está dentro da declaração $props()
  let {
    credentials = $bindable({
      email: '',
      password: '',
      password_confirmation: ''
    })
  } = $props();
</script>

<div class="space-y-4">
  <Email bind:value={credentials.email} required={true} />
  <PasswordWithValidation
    bind:value={credentials.password}
    name="password"
    placeholder="Digite sua senha"
    required={true}
    showRequirements={true}
  />
  <PasswordConfirmation
    password={credentials.password}
    bind:value={credentials.password_confirmation}
    name="password_confirmation"
    placeholder="Confirme sua senha"
    required={true}
  />
</div>