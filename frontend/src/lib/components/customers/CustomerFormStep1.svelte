<!-- components/customers/CustomerPersonalInfoStep.svelte -->
<script lang="ts">
  import { createEventDispatcher } from 'svelte';
  import Cpf from '../forms_commons/Cpf.svelte';
  import Email from '../forms_commons/Email.svelte';
  import {
    validateCPFRequired,
    formatCPF,
    validatePasswordRequired,
    createPasswordConfirmationValidator,
    validateBirthDateRequired,
    getCapacityFromBirthDate
  } from '../../validation';

  import { BRAZILIAN_STATES } from '../../constants/brazilian-states';
  import type { BrazilianState } from '../../constants/brazilian-states';
  import Bank from '../forms_commons/Bank.svelte';
  import type { CustomerFormData } from '../../schemas/customer-form';
  import {
    getCivilStatusLabel,
    getNationalityLabel,
    formatCpfForPix,
    formatPhoneForPix
  } from '../../utils/form-helpers';

  export let formData: CustomerFormData;
  export let errors: Record<string, string> = {};
  export let touched: Record<string, boolean> = {};
  export let isLoading: boolean = false;
  export let customer: any = null;

  const dispatch = createEventDispatcher<{
    fieldBlur: { field: string; value: any };
    cpfInput: Event;
    birthDateChange: Event;
  }>();

  // Local reactive variables
  $: capacityInfo = getCapacityFromBirthDate(formData.birth);
  $: capacityMessage = capacityInfo?.message || '';
  $: isProfessionRequired = formData.capacity !== 'unable';
  $: isEmailRequired = formData.capacity !== 'unable';
  $: isEmailDisabled = formData.capacity === 'unable';

  // Brazilian states
  const states: BrazilianState[] = BRAZILIAN_STATES;

  // Event handlers
  function handleBlur(fieldName: string, value: any) {
    dispatch('fieldBlur', { field: fieldName, value });
  }

  function handleBirthDateChange(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.birth = input.value;
    dispatch('birthDateChange', { value: formData.birth });
  }
</script>

<!-- Personal Information Section -->
<div class="divider" aria-label="Seção de informações pessoais">Informações Pessoais</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Name -->
  <div class="form-control w-full">
    <label for="name" class="label justify-start">
      <span class="label-text font-medium">Nome *</span>
    </label>
    <input
      id="name"
      type="text"
      class="input input-bordered w-full {errors.name && touched.name ? 'input-error' : ''}"
      bind:value={formData.name}
      on:blur={() => handleBlur('name', formData.name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.name && touched.name ? 'true' : 'false'}
      aria-describedby={errors.name && touched.name ? 'name-error' : undefined}
      data-testid="customer-name-input"
    />
    {#if errors.name && touched.name}
      <div id="name-error" class="text-error text-sm mt-1">{errors.name}</div>
    {/if}
  </div>

  <!-- Last Name -->
  <div class="form-control w-full">
    <label for="last_name" class="label justify-start">
      <span class="label-text font-medium">Sobrenome *</span>
    </label>
    <input
      id="last_name"
      type="text"
      class="input input-bordered w-full {errors.last_name && touched.last_name
        ? 'input-error'
        : ''}"
      bind:value={formData.last_name}
      on:blur={() => handleBlur('last_name', formData.last_name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.last_name && touched.last_name ? 'true' : 'false'}
      aria-describedby={errors.last_name && touched.last_name ? 'last_name-error' : undefined}
      data-testid="customer-lastname-input"
    />
    {#if errors.last_name && touched.last_name}
      <div id="last_name-error" class="text-error text-sm mt-1">{errors.last_name}</div>
    {/if}
  </div>

  <!-- CPF -->
  <Cpf
    bind:value={formData.cpf}
    errors={errors.cpf}
    touched={touched.cpf}
    disabled={isLoading}
    on:input={(e) => dispatch('cpfInput', e.detail)}
    on:blur={(e) => handleBlur('cpf', e.detail.value)}
    testId="customer-cpf-input"
  />

  <!-- RG -->
  <div class="form-control w-full">
    <label for="rg" class="label justify-start">
      <span class="label-text font-medium">RG *</span>
    </label>
    <input
      id="rg"
      type="text"
      class="input input-bordered w-full {errors.rg && touched.rg ? 'input-error' : ''}"
      bind:value={formData.rg}
      on:blur={() => handleBlur('rg', formData.rg)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.rg && touched.rg ? 'true' : 'false'}
      aria-describedby={errors.rg && touched.rg ? 'rg-error' : undefined}
      data-testid="customer-rg-input"
    />
    {#if errors.rg && touched.rg}
      <div id="rg-error" class="text-error text-sm mt-1">{errors.rg}</div>
    {/if}
  </div>

  <!-- Birth Date -->
  <div class="form-control w-full">
    <label for="birth" class="label justify-start">
      <span class="label-text font-medium">Data de Nascimento *</span>
    </label>
    <input
      id="birth"
      type="date"
      class="input input-bordered w-full {errors.birth && touched.birth ? 'input-error' : ''}"
      bind:value={formData.birth}
      on:change={handleBirthDateChange}
      on:blur={() => handleBlur('birth', formData.birth)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.birth && touched.birth ? 'true' : 'false'}
      aria-describedby={(errors.birth && touched.birth) || capacityMessage
        ? 'birth-message'
        : undefined}
      data-testid="customer-birth-input"
    />
    {#if (errors.birth && touched.birth) || capacityMessage}
      <div
        id="birth-message"
        class="text-sm mt-1 {errors.birth && touched.birth ? 'text-error' : 'text-warning'}"
      >
        {errors.birth || capacityMessage}
      </div>
    {/if}
  </div>

  <!-- Gender -->
  <div class="form-control w-full">
    <label for="gender" class="label justify-start">
      <span class="label-text font-medium">Gênero *</span>
    </label>
    <select
      id="gender"
      class="select select-bordered w-full"
      bind:value={formData.gender}
      disabled={isLoading}
      aria-required="true"
      data-testid="customer-gender-input"
    >
      <option value="male">Masculino</option>
      <option value="female">Feminino</option>
    </select>
  </div>

  <!-- Civil Status -->
  <div class="form-control w-full">
    <label for="civil_status" class="label justify-start">
      <span class="label-text font-medium">Estado Civil *</span>
    </label>
    <select
      id="civil_status"
      class="select select-bordered w-full"
      bind:value={formData.civil_status}
      disabled={isLoading}
      aria-required="true"
      data-testid="customer-civil-status-input"
    >
      <option value="single">{getCivilStatusLabel('single', formData.gender)}</option>
      <option value="married">{getCivilStatusLabel('married', formData.gender)}</option>
      <option value="divorced">{getCivilStatusLabel('divorced', formData.gender)}</option>
      <option value="widower">{getCivilStatusLabel('widower', formData.gender)}</option>
      <option value="union">{getCivilStatusLabel('union', formData.gender)}</option>
    </select>
  </div>

  <!-- Nationality -->
  <div class="form-control w-full">
    <label for="nationality" class="label justify-start">
      <span class="label-text font-medium">Nacionalidade *</span>
    </label>
    <select
      id="nationality"
      class="select select-bordered w-full"
      bind:value={formData.nationality}
      disabled={isLoading}
      aria-required="true"
      data-testid="customer-nationality-input"
    >
      <option value="brazilian">{getNationalityLabel('brazilian', formData.gender)}</option>
      <option value="foreigner">{getNationalityLabel('foreigner', formData.gender)}</option>
    </select>
  </div>

  <!-- Profession -->
  <div class="form-control w-full">
    <label for="profession" class="label justify-start">
      <span class="label-text font-medium"
        >Profissão {isProfessionRequired ? '*' : '(Opcional)'}</span
      >
    </label>
    <input
      id="profession"
      type="text"
      class="input input-bordered w-full {errors.profession &&
      touched.profession &&
      isProfessionRequired
        ? 'input-error'
        : ''}"
      bind:value={formData.profession}
      on:blur={() => handleBlur('profession', formData.profession)}
      disabled={isLoading || !isProfessionRequired}
      aria-required={isProfessionRequired ? 'true' : 'false'}
      aria-invalid={errors.profession && touched.profession && isProfessionRequired
        ? 'true'
        : 'false'}
      aria-describedby={errors.profession && touched.profession && isProfessionRequired
        ? 'profession-error'
        : undefined}
      data-testid="customer-profession-input"
    />
    {#if !isProfessionRequired}
      <div class="text-sm text-gray-500 mt-1">Não obrigatório para menores de 16 anos</div>
    {/if}
    {#if errors.profession && touched.profession && isProfessionRequired}
      <div id="profession-error" class="text-error text-sm mt-1">{errors.profession}</div>
    {/if}
  </div>

  <!-- Mother's Name -->
  <div class="form-control w-full">
    <label for="mother_name" class="label justify-start">
      <span class="label-text font-medium">Nome da Mãe *</span>
    </label>
    <input
      id="mother_name"
      type="text"
      class="input input-bordered w-full {errors.mother_name && touched.mother_name
        ? 'input-error'
        : ''}"
      bind:value={formData.mother_name}
      on:blur={() => handleBlur('mother_name', formData.mother_name)}
      disabled={isLoading}
      aria-required="true"
      aria-invalid={errors.mother_name && touched.mother_name ? 'true' : 'false'}
      aria-describedby={errors.mother_name && touched.mother_name ? 'mother_name-error' : undefined}
      data-testid="customer-mother-name-input"
    />
    {#if errors.mother_name && touched.mother_name}
      <div id="mother_name-error" class="text-error text-sm mt-1">{errors.mother_name}</div>
    {/if}
  </div>

  <!-- Capacity Selection -->
  <div class="form-control w-full">
    <label for="capacity" class="label justify-start">
      <span class="label-text font-medium">Capacidade</span>
    </label>
    <select
      id="capacity"
      class="select select-bordered w-full"
      bind:value={formData.capacity}
      disabled={isLoading}
      data-testid="customer-capacity-input"
    >
      <option value="able">Capaz</option>
      <option value="relatively">Relativamente Incapaz</option>
      <option value="unable">Absolutamente Incapaz</option>
    </select>
    {#if capacityMessage}
      <div class="text-sm text-warning mt-1">{capacityMessage}</div>
    {/if}
  </div>
</div>

<!-- Login Information Section -->
<div class="divider" aria-label="Seção de informações de acesso">Informações de Acesso</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Email -->
  <div class="form-control w-full">
    <Email
      bind:value={formData.customer_attributes.email}
      id="email"
      labelText="Email {isEmailRequired ? '*' : '(Opcional)'}"
      required={isEmailRequired}
      disabled={isLoading || isEmailDisabled}
      placeholder="cliente@exemplo.com"
      errors={errors.email && touched.email && isEmailRequired ? errors.email : ''}
      touched={touched.email}
      testId="customer-email-input"
      on:blur={() => handleBlur('email', formData.customer_attributes.email)}
    />
    {#if !isEmailRequired}
      <div class="text-sm text-gray-500 mt-1">
        Este email pode ser compartilhado com a conta do responsável
      </div>
    {/if}
  </div>

  <!-- Phone -->
  <div class="form-control w-full">
    <label for="phone" class="label justify-start">
      <span class="label-text font-medium">Telefone</span>
    </label>
    <input
      id="phone"
      type="tel"
      class="input input-bordered w-full"
      bind:value={formData.phones_attributes[0].number}
      disabled={isLoading}
      placeholder="+55 11 98765-4321"
      data-testid="customer-phone-input"
    />
  </div>

  <!-- Password -->
  <div class="form-control w-full">
    <label for="password" class="label justify-start">
      <span class="label-text font-medium">
        {customer ? 'Nova Senha (deixe em branco para manter)' : 'Senha *'}
      </span>
    </label>
    <input
      id="password"
      type="password"
      class="input input-bordered w-full {errors.password && touched.password ? 'input-error' : ''}"
      bind:value={formData.customer_attributes.password}
      on:blur={() => handleBlur('password', formData.customer_attributes.password)}
      disabled={isLoading}
      placeholder="Mínimo 6 caracteres"
      aria-required={customer ? 'false' : 'true'}
      aria-invalid={errors.password && touched.password ? 'true' : 'false'}
      aria-describedby={errors.password && touched.password ? 'password-error' : undefined}
      data-testid="customer-password-input"
    />
    {#if errors.password && touched.password}
      <div id="password-error" class="text-error text-sm mt-1">{errors.password}</div>
    {/if}
  </div>

  <!-- Password Confirmation -->
  <div class="form-control w-full">
    <label for="password_confirmation" class="label justify-start">
      <span class="label-text font-medium">
        {customer ? 'Confirmar Nova Senha' : 'Confirmar Senha *'}
      </span>
    </label>
    <input
      id="password_confirmation"
      type="password"
      class="input input-bordered w-full {errors.password_confirmation &&
      touched.password_confirmation
        ? 'input-error'
        : ''}"
      bind:value={formData.customer_attributes.password_confirmation}
      on:blur={() =>
        handleBlur('password_confirmation', formData.customer_attributes.password_confirmation)}
      disabled={isLoading}
      placeholder="Digite a senha novamente"
      aria-required={customer ? 'false' : 'true'}
      aria-invalid={errors.password_confirmation && touched.password_confirmation
        ? 'true'
        : 'false'}
      aria-describedby={errors.password_confirmation && touched.password_confirmation
        ? 'password_confirmation-error'
        : undefined}
      data-testid="customer-password-confirmation-input"
    />
    {#if errors.password_confirmation && touched.password_confirmation}
      <div id="password_confirmation-error" class="text-error text-sm mt-1">
        {errors.password_confirmation}
      </div>
    {/if}
  </div>
</div>

<!-- Address Section -->
<div class="divider" aria-label="Seção de endereço">Endereço</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- ZIP Code -->
  <div class="form-control w-full">
    <label for="zip_code" class="label justify-start">
      <span class="label-text font-medium">CEP</span>
    </label>
    <input
      id="zip_code"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].zip_code}
      disabled={isLoading}
      placeholder="00000-000"
      data-testid="customer-zipcode-input"
    />
  </div>

  <!-- Street -->
  <div class="form-control w-full">
    <label for="street" class="label justify-start">
      <span class="label-text font-medium">Rua</span>
    </label>
    <input
      id="street"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].street}
      disabled={isLoading}
      data-testid="customer-street-input"
    />
  </div>

  <!-- Number -->
  <div class="form-control w-full">
    <label for="number" class="label justify-start">
      <span class="label-text font-medium">Número</span>
    </label>
    <input
      id="number"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].number}
      disabled={isLoading}
      data-testid="customer-number-input"
    />
  </div>

  <!-- Neighborhood -->
  <div class="form-control w-full">
    <label for="neighborhood" class="label justify-start">
      <span class="label-text font-medium">Bairro</span>
    </label>
    <input
      id="neighborhood"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].neighborhood}
      disabled={isLoading}
      data-testid="customer-neighborhood-input"
    />
  </div>

  <!-- City -->
  <div class="form-control w-full">
    <label for="city" class="label justify-start">
      <span class="label-text font-medium">Cidade</span>
    </label>
    <input
      id="city"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.addresses_attributes[0].city}
      disabled={isLoading}
      data-testid="customer-city-input"
    />
  </div>

  <!-- State -->
  <div class="form-control w-full">
    <label for="state" class="label justify-start">
      <span class="label-text font-medium">Estado</span>
    </label>
    <select
      id="state"
      class="select select-bordered w-full"
      bind:value={formData.addresses_attributes[0].state}
      disabled={isLoading}
      data-testid="customer-state-input"
    >
      <option value="">Selecione...</option>
      {#each states as state}
        <option value={state.value}>{state.label}</option>
      {/each}
    </select>
  </div>
</div>

<!-- Bank Account Section -->
<div class="divider" aria-label="Seção de dados bancários">Dados Bancários</div>

<Bank
  bind:bankAccount={formData.bank_accounts_attributes[0]}
  disabled={isLoading}
  showPixHelpers={true}
  pixDocumentType="cpf"
  pixHelperData={{
    email: formData.customer_attributes.email,
    cpf: formData.cpf,
    cnpj: '',
    phone: formData.phones_attributes[0].number
  }}
  labelPrefix="customer-bank"
  className="bg-transparent border-0 p-0 mb-0"
/>

<!-- Social Security Information Section -->
<div class="divider" aria-label="Seção de informações previdenciárias">
  Informações Previdenciárias
</div>

<div class="grid grid-cols-1 md:grid-cols-2 gap-4">
  <!-- Benefit Number -->
  <div class="form-control w-full">
    <label for="number_benefit" class="label justify-start">
      <span class="label-text font-medium">Número de Benefício (Opcional)</span>
    </label>
    <input
      id="number_benefit"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.number_benefit}
      disabled={isLoading}
      placeholder="Número do benefício INSS"
      data-testid="customer-benefit-input"
    />
  </div>

  <!-- NIT -->
  <div class="form-control w-full">
    <label for="nit" class="label justify-start">
      <span class="label-text font-medium">NIT (Opcional)</span>
    </label>
    <input
      id="nit"
      type="text"
      class="input input-bordered w-full"
      bind:value={formData.nit}
      disabled={isLoading}
      placeholder="Número de Inscrição do Trabalhador"
      data-testid="customer-nit-input"
    />
  </div>

  <!-- INSS Password -->
  <div class="form-control w-full md:col-span-2">
    <label for="inss_password" class="label justify-start">
      <span class="label-text font-medium">Senha do MeuINSS (Opcional)</span>
    </label>
    <input
      id="inss_password"
      type="password"
      class="input input-bordered w-full"
      bind:value={formData.inss_password}
      disabled={isLoading}
      placeholder="Senha de acesso ao MeuINSS"
      data-testid="customer-inss-password-input"
    />
    <div class="text-sm text-warning mt-1">
      Esta informação é armazenada de forma segura e criptografada
    </div>
  </div>
</div>
