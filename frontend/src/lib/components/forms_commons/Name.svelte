<!-- 
  Componente Atômico para o campo "Nome".
  Recebe 'value' bindable e 'required' opcional.
-->
<script lang="ts">
  let { 
    value = $bindable(''), 
    required = false 
  } = $props();
</script>

<div class="form-control w-full">
  <label for="name" class="label">
    <span class="label-text">Nome</span>
  </label>
  <input
    type="text"
    id="name"
    placeholder="Digite o nome"
    class="input input-bordered w-full"
    bind:value={value}
    {required}
  />
</div>