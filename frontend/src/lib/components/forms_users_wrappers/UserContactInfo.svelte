<script lang="ts">
  import Phone from '../forms_commons/Phone.svelte';
  // A importação do AddressCepWrapper foi um erro na orientação anterior,
  // pois os campos de endereço já são individuais. Vamos remover.
  // import AddressCepWrapper from './AddressCepWrapper.svelte'; 

  // --- CORREÇÃO APLICADA AQUI ---
  // Todas as props são declaradas dentro de $props()
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
</script>

<!-- O template (HTML) continua o mesmo -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <div class="md:col-span-2">
    <Phone bind:value={contactInfo.phone} required={true} />
  </div>

  <!-- 
    Aqui usamos os componentes atômicos de endereço diretamente,
    conectados ao objeto `contactInfo.address`.
    Isto está correto e desacoplado.
    (Assumindo que você tem os componentes atômicos como `Cep.svelte`, `Street.svelte`, etc.)
    Se não, usamos inputs normais por enquanto. Vamos usar inputs para simplicidade.
  -->
  <div class="md:col-span-2 mt-4 space-y-4">
    <h4 class="text-lg font-semibold border-b pb-2">Endereço</h4>

    <div class="form-control">
      <label for="zip_code" class="label"><span class="label-text">CEP</span></label>
      <input id="zip_code" type="text" class="input input-bordered" bind:value={contactInfo.address.zip_code} />
    </div>
    
    <div class="form-control">
      <label for="street" class="label"><span class="label-text">Logradouro</span></label>
      <input id="street" type="text" class="input input-bordered" bind:value={contactInfo.address.street} />
    </div>
    
    <div class="form-control">
      <label for="number" class="label"><span class="label-text">Número</span></label>
      <input id="number" type="text" class="input input-bordered" bind:value={contactInfo.address.number} />
    </div>
    
    <div class="form-control">
      <label for="complement" class="label"><span class="label-text">Complemento</span></label>
      <input id="complement" type="text" class="input input-bordered" bind:value={contactInfo.address.complement} />
    </div>

     <div class="form-control">
      <label for="neighborhood" class="label"><span class="label-text">Bairro</span></label>
      <input id="neighborhood" type="text" class="input input-bordered" bind:value={contactInfo.address.neighborhood} />
    </div>
    
    <div class="form-control">
      <label for="city" class="label"><span class="label-text">Cidade</span></label>
      <input id="city" type="text" class="input input-bordered" bind:value={contactInfo.address.city} />
    </div>

    <div class="form-control">
      <label for="state" class="label"><span class="label-text">Estado</span></label>
      <input id="state" type="text" class="input input-bordered" bind:value={contactInfo.address.state} />
    </div>
  </div>
</div>