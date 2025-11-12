<script lang="ts">
   import Name from '../forms_commons/Name.svelte';
   import LastName from '../forms_commons/LastName.svelte';
   import OabId from '../forms_commons/OabId.svelte';

  let {
    basicInfo = $bindable({
      name: '',
      last_name: '',
      oab: ''
    })
  } = $props();
</script>

<div class="grid grid-cols-1 md:grid-cols-2 gap-5">
  <div class="space-y-2">
    <Name bind:value={basicInfo.name} required={true} />
  </div>
  
  <div class="space-y-2">
    <LastName bind:value={basicInfo.last_name} required={true} />
  </div>

  <div class="md:col-span-2 space-y-2">
    <OabId bind:value={basicInfo.oab} required={true} />
  </div>
</div>
