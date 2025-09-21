<script lang="ts">
  // Rename this Lawyers.svelte -> move to Teams
  // Qual outro nome eu poderia dar para Teams?
  import OfficeFormLawyer from '../components/forms_offices/OfficeFormLawyer.svelte';
  import BasicInformation from '../components/forms_commons_wrappers/BasicInformation.svelte';
  import OabInformation from '../components/forms_commons_wrappers/OabInformation.svelte';
  import ParnershipManagement from '../components/forms_offices_wrappers/PartnershipManagement.svelte';
  import Phone from '../components/forms_commons/Phone.svelte';
  import Email from '../components/forms_commons/Email.svelte';
  import Bank from '../components/forms_commons/Bank.svelte';
  import AddressCepWrapper from '../components/forms_commons_wrappers/AddressCepWrapper.svelte';
  import SocialContractCheckbox from '../components/forms_offices/SocialContractCheckbox.svelte';
  import FileAttachments from '../components/forms_offices/FileAttachments.svelte';
</script>

<div>
  <spam>Basic Info:</spam>
  <BasicInformation />
</div>

<div>
  <spam>Address</spam>
  <AddressCepWrapper />
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
  <spam>OAB Information</spam>
  <OabInformation />
</div>

<div>
  <spam>Componente</spam>
  <OfficeFormLawyer />
</div>

<div>
  <spam>Parnership Management</spam>
  <ParnershipManagement />
</div>

<div>
  <spam>Social Contract Checkbox</spam>
  <SocialContractCheckbox />
</div>

<div>
  <spam>FileAttachments</spam>
  <FileAttachments />
</div>

<style>
</style>
