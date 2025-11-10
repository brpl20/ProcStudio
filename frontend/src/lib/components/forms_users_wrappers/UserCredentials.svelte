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
    bind:value={credentials.password}
    id="password"
    labelText="Senha"
    placeholder="Digite sua senha"
    required={false}
  />
  <Password
    bind:value={credentials.password_confirmation}
    id="password_confirmation"
    labelText="Confirmar Senha"
    placeholder="Confirme sua senha"
    required={false}
  />
</div>