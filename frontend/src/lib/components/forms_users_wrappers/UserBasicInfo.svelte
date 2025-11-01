<script lang="ts">
   import Name from '../forms_commons/Name.svelte';
   import LastName from '../forms_commons/LastName.svelte';
   import OabId from '../forms_commons/OabId.svelte';

  // --- CORREÇÃO APLICADA AQUI ---
  // A prop 'basicInfo' agora está dentro da declaração $props()
  let {
    basicInfo = $bindable({
      name: '',
      last_name: '',
      social_name: '',
      oab: ''
    })
  } = $props();
</script>

<!-- O template (HTML) não precisa de nenhuma alteração -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <Name bind:value={basicInfo.name} required={true} />
  <LastName bind:value={basicInfo.last_name} required={true} />
  
  <div class="md:col-span-2">
    <label for="social_name" class="label"><span class="label-text">Nome Social (Opcional)</span></label>
    <input
      type="text"
      id="social_name"
      class="input input-bordered w-full"
      bind:value={basicInfo.social_name}
    />
  </div>

  <div class="md:col-span-2">
    <OabId bind:value={basicInfo.oab} required={true} />
  </div>
</div>