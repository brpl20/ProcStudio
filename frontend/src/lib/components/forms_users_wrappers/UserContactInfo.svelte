<script lang="ts">
  import Phone from '../forms_commons/Phone.svelte';
  import AddressCepWrapper from '../forms_commons_wrappers/AddressCepWrapper.svelte';

  let {
    contactInfo = $bindable({
      phone: '',
      address: {
        street: '',
        number: '',
        complement: '',
        neighborhood: '',
        city: '',
        state: '',
        zip_code: ''
      }
    })
  } = $props();

  let cepValue = $state(contactInfo.address.zip_code || '');
</script>

<div class="space-y-6">
  <div class="space-y-2">
    <Phone bind:value={contactInfo.phone} required={true} />
  </div>

  <div class="pt-4 border-t border-[#eef0ef]">
    <AddressCepWrapper
      bind:address={contactInfo.address}
      bind:cepValue
      title="Endereço"
      useAPIValidation={true}
      showAddressInfo={false}
      config={{
        cep: {
          id: 'user-cep',
          labelText: 'CEP',
          placeholder: '00000-000',
          required: false,
          show: true
        },
        address: {
          id: 'user-address',
          required: false,
          show: true,
          showRemoveButton: false
        }
      }}
    />
  </div>
</div>
