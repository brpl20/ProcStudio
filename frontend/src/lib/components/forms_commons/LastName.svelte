<script lang="ts">
 
  let { 
    value = $bindable(''), 
    required = false 
  } = $props();
</script>

<div class="form-control w-full">
  <label for="last_name" class="label">
    <span class="label-text">Sobrenome</span>
  </label>
  <input
    type="text"
    id="last_name"
    placeholder="Digite o sobrenome"
    class="input input-bordered w-full"
    bind:value={value}
    {required}
  />
</div>