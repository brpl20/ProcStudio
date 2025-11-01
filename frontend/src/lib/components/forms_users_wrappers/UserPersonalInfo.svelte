<script lang="ts">
  import Cpf from '../forms_commons/Cpf.svelte';
  import Rg from '../forms_commons/Rg.svelte';
  import Gender from '../forms_commons/Gender.svelte';
  import CivilStatus from '../forms_commons/CivilStatus.svelte';
  import Nationality from '../forms_commons/Nationality.svelte';
  import Birth from '../forms_commons/Birth.svelte';

  // --- CORREÇÃO APLICADA AQUI ---
  // A prop 'personalInfo' agora está dentro da declaração $props()
  let {
    personalInfo = $bindable({
      cpf: '',
      rg: '',
      gender: '',
      civil_status: '',
      nationality: 'brazilian', // Valor padrão
      birth: ''
    })
  } = $props();
</script>

<!-- O template (HTML) não precisa de nenhuma alteração -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <Cpf bind:value={personalInfo.cpf} required={true} />
  <Rg bind:value={personalInfo.rg} required={true} />
  <Gender bind:value={personalInfo.gender} required={true} />
  <CivilStatus bind:value={personalInfo.civil_status} required={true} />
  <Nationality bind:value={personalInfo.nationality} required={true} />
  <Birth bind:value={personalInfo.birth} required={true} />
</div>