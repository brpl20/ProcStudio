<script lang="ts">
  import Email from '../forms_commons/Email.svelte';
  import Password from '../forms_commons/Password.svelte';

  let {
    credentials = $bindable({
      email: '',
      password: '',
      password_confirmation: ''
    }),
    isEditMode = false
  } = $props();
</script>

<div class="space-y-5">
  <div class="space-y-2">
    <Email bind:value={credentials.email} required={true} />
  </div>
  
  {#if !isEditMode}
    <div class="space-y-2">
      <Password
        bind:value={credentials.password}
        id="password"
        labelText="Senha"
        placeholder="Digite uma senha segura"
        required={false}
      />
    </div>
    
    <div class="space-y-2">
      <Password
        bind:value={credentials.password_confirmation}
        id="password_confirmation"
        labelText="Confirmar Senha"
        placeholder="Digite a senha novamente"
        required={false}
      />
    </div>
  {/if}
</div>
