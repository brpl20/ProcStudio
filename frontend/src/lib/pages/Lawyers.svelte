<script lang="ts">
  import OfficeFormLawyer from '../components/teams/OfficeFormLawyer.svelte';
  import LawyerSelector from '../components/teams/LawyerSelector.svelte';
  import Cnpj from '../components/forms_commons/Cnpj.svelte';
  import BasicInformation from '../components/forms_commons_wrappers/BasicInformation.svelte';
  import OabInformation from '../components/forms_commons_wrappers/OabInformation.svelte';
  import Address from '../components/forms_commons/Address.svelte';
  import Cep from '../components/forms_commons/Cep.svelte';
  import Phone from '../components/forms_commons/Phone.svelte';
  import Email from '../components/forms_commons/Email.svelte';
  import Bank from '../components/forms_commons/Bank.svelte';
</script>

<div>
  <spam>Basic Info:</spam>
  <BasicInformation />
</div>

<div>
  <spam>Address</spam>
  <Address />
</div>

<div>
  <spam>Cep</spam>
  <Cep />
</div>

<div>
  <spam>Phone</spam>
  <Phone />
</div>

<div>
  <spam>Email</spam>
  <Email />
</div>

<div>
  <spam>Bank</spam>
  <Bank />
</div>

<div>
  <spam>Componente</spam>
  <OfficeFormLawyer />
</div>

<div>
  <spam>Selecionar Um Advogado</spam>
  <LawyerSelector />
</div>

<div>
  <spam>OAB Information</spam>
  <OabInformation />
</div>

<div>
  <spam>CNPJ</spam>
  <Cnpj required={false} disabled={true} />
</div>

<style>
</style>
