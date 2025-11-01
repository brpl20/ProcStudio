<!-- /src/lib/components/forms_commons/Password.svelte -->
<script lang="ts">
  // Usamos uma única chamada de $props() para todas as propriedades
  let { 
    value = $bindable(''), 
    required = false,
    label = 'Senha' // Adicionamos uma prop para o rótulo, com 'Senha' como padrão
  } = $props();
</script>

<div class="form-control w-full">
  <label for={label} class="label">
    <span class="label-text">{label}</span>
  </label>
  <input
    type="password"
    id={label}
    placeholder="Digite a senha"
    class="input input-bordered w-full"
    bind:value={value}
    {required}
  />
</div>