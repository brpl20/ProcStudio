<script lang="ts">
  import Phone from '../forms_commons/Phone.svelte';
  // NOVO: Importar a lista de estados brasileiros
  import { BRAZILIAN_STATES } from '$lib/constants/brazilian-states.ts';

  // A estrutura de dados já está correta e não precisa de alteração
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

<div class="divider pt-2">Informações de Contato</div>

<!-- O template (HTML) continua o mesmo, exceto pelo campo de estado -->
<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <div class="md:col-span-2">
    <Phone bind:value={contactInfo.phone} required={true} />
  </div>

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

    <!-- ======================= INÍCIO DA ALTERAÇÃO ======================= -->
    <!-- Trocamos o input de texto por um select -->
    <div class="form-control">
      <label for="state" class="label"><span class="label-text">Estado</span></label>
      <select id="state" class="select select-bordered" bind:value={contactInfo.address.state}>
        <option value="" disabled selected>Selecione um estado</option>
        {#each BRAZILIAN_STATES as state}
            <option value={state.value}>{state.label}</option>
        {/each}
      </select>
    </div>
    <!-- ======================== FIM DA ALTERAÇÃO ======================== -->
    
  </div>
</div>