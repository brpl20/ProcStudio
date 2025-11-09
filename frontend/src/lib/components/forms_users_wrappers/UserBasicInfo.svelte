<script lang="ts">
   import Name from '../forms_commons/Name.svelte';
   import LastName from '../forms_commons/LastName.svelte';
   import OabId from '../forms_commons/OabId.svelte';

  
  // A prop 'basicInfo' agora está dentro da declaração $props()
  let {
    basicInfo = $bindable({
      name: '',
      last_name: '',
      oab: ''
    })
  } = $props();
</script>


<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <Name bind:value={basicInfo.name} required={true} />
  <LastName bind:value={basicInfo.last_name} required={true} />

  <div class="md:col-span-2">
    <OabId bind:value={basicInfo.oab} required={true} />
  </div>
</div>