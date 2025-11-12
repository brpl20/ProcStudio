<script lang="ts">
  import Cpf from '../forms_commons/Cpf.svelte';
  import Rg from '../forms_commons/Rg.svelte';
  import Gender from '../forms_commons/Gender.svelte';
  import CivilStatus from '../forms_commons/CivilStatus.svelte';
  import Nationality from '../forms_commons/Nationality.svelte';
  import Birth from '../forms_commons/Birth.svelte';

  let {
    personalInfo = $bindable({
      cpf: '',
      rg: '',
      gender: '',
      civil_status: '',
      nationality: 'brazilian',
      birth: '',
      mother_name: ''
    })
  } = $props();
</script>

<div class="grid grid-cols-1 md:grid-cols-2 gap-5">
  <div class="space-y-2">
    <Cpf bind:value={personalInfo.cpf} required={true} />
  </div>

  <div class="space-y-2">
    <Rg bind:value={personalInfo.rg} required={true} />
  </div>

  <div class="space-y-2">
    <Gender bind:value={personalInfo.gender} required={true} />
  </div>

  <div class="space-y-2">
    <CivilStatus bind:value={personalInfo.civil_status} gender={personalInfo.gender} required={true} />
  </div>

  <div class="space-y-2">
    <Nationality bind:value={personalInfo.nationality} gender={personalInfo.gender} required={true} />
  </div>

  <div class="space-y-2">
    <Birth bind:value={personalInfo.birth} required={true} />
  </div>

  <div class="md:col-span-2 space-y-2">
    <label class="block text-sm font-medium text-[#01013D]" for="user-mother_name">
      Nome da Mãe <span class="text-red-500">*</span>
    </label>
    <input
      id="user-mother_name"
      type="text"
      placeholder="Nome completo da mãe"
      class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:border-[#0277EE] focus:ring-2 focus:ring-[#0277EE]/20 outline-none transition-all duration-200 text-[#01013D] placeholder-gray-400"
      bind:value={personalInfo.mother_name}
      required={true}
    />
  </div>
</div>
