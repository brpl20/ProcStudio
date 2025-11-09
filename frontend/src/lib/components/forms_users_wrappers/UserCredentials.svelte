<script lang="ts">
  import Email from '../forms_commons/Email.svelte';
  import Password from '../forms_commons/Password.svelte';

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
  <Password
    id="password"
    labelText="Senha"
    bind:value={credentials.password}
    required={true}
  />
  <Password
    id="password_confirmation"
    labelText="Confirmação de Senha"
    bind:value={credentials.password_confirmation}
    required={true}
  />
</div>