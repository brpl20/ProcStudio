<script lang="ts">
  import Cpf from '../forms_commons/Cpf.svelte';
  import Rg from '../forms_commons/Rg.svelte';
  import Gender from '../forms_commons/Gender.svelte';
  import CivilStatus from '../forms_commons/CivilStatus.svelte';
  import Nationality from '../forms_commons/Nationality.svelte';
  import Birth from '../forms_commons/Birth.svelte';

  // A prop 'personalInfo' agora está dentro da declaração $props()
  let {
    personalInfo = $bindable({
      cpf: '',
      rg: '',
      gender: '',
      civil_status: '',
      nationality: 'brazilian',
      birth: '',
      mother_name: '' // NOVO: Adicionado mother_name à estrutura de dados
    })
  } = $props();
</script>

<div class="divider pt-2">Informações Pessoais</div>

<!-- O grid agora pode ter um campo que ocupa mais espaço -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <Cpf bind:value={personalInfo.cpf} required={true} />
  <Rg bind:value={personalInfo.rg} required={true} />
  <Gender bind:value={personalInfo.gender} required={true} />
  <CivilStatus bind:value={personalInfo.civil_status} required={true} />
  <Nationality bind:value={personalInfo.nationality} required={true} />
  <Birth bind:value={personalInfo.birth} required={true} />

  <!-- NOVO: Adicionado o campo para o nome da mãe -->
  <div class="form-control md:col-span-2">
    <label class="label" for="user-mother_name">
      <span class="label-text">Nome da Mãe</span>
    </label>
    <input
      id="user-mother_name"
      type="text"
      placeholder="Nome completo da mãe"
      class="input input-bordered w-full"
      bind:value={personalInfo.mother_name}
      required={true}
    />
  </div>
</div>