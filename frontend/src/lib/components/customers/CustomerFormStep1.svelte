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

  $: capacityInfo = getCapacityFromBirthDate(formData.birth);
  $: capacityMessage = capacityInfo?.message || '';
  $: isProfessionRequired = formData.capacity !== 'unable';
  $: isEmailRequired = formData.capacity !== 'unable';
  $: isEmailDisabled = formData.capacity === 'unable';

  const states: BrazilianState[] = BRAZILIAN_STATES;

  function handleBlur(fieldName: string, value: any) {
    dispatch('fieldBlur', { field: fieldName, value });
  }

  function handleBirthDateChange(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.birth = input.value;
    dispatch('birthDateChange', { value: formData.birth });
  }
</script>

<div class="space-y-6">
  <!-- Informações Pessoais Section -->
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
      <h3 class="text-lg font-semibold text-white flex items-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
        Informações Pessoais
      </h3>
    </div>

    <div class="p-6 bg-[#eef0ef]">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Name -->
        <div class="form-control w-full">
          <label for="name" class="block text-sm font-medium text-gray-700 mb-2">
            Nome <span class="text-red-500">*</span>
          </label>
          <input
            id="name"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400 {errors.name && touched.name ? 'border-red-500 focus:ring-red-500' : ''}"
            bind:value={formData.name}
            onblur={() => handleBlur('name', formData.name)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.name && touched.name ? 'true' : 'false'}
            aria-describedby={errors.name && touched.name ? 'name-error' : undefined}
            data-testid="customer-name-input"
          />
          {#if errors.name && touched.name}
            <p id="name-error" class="text-red-500 text-xs mt-1.5 flex items-center gap-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.name}
            </p>
          {/if}
        </div>

        <!-- Last Name -->
        <div class="form-control w-full">
          <label for="last_name" class="block text-sm font-medium text-gray-700 mb-2">
            Sobrenome <span class="text-red-500">*</span>
          </label>
          <input
            id="last_name"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400 {errors.last_name && touched.last_name ? 'border-red-500 focus:ring-red-500' : ''}"
            bind:value={formData.last_name}
            onblur={() => handleBlur('last_name', formData.last_name)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.last_name && touched.last_name ? 'true' : 'false'}
            aria-describedby={errors.last_name && touched.last_name ? 'last_name-error' : undefined}
            data-testid="customer-lastname-input"
          />
          {#if errors.last_name && touched.last_name}
            <p id="last_name-error" class="text-red-500 text-xs mt-1.5 flex items-center gap-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.last_name}
            </p>
          {/if}
        </div>

        <!-- CPF -->
        <Cpf
          bind:value={formData.cpf}
          errors={errors.cpf}
          touched={touched.cpf}
          disabled={isLoading}
          oninput={(e) => dispatch('cpfInput', e.detail)}
          onblur={(e) => handleBlur('cpf', e.detail.value)}
          testId="customer-cpf-input"
        />

        <!-- RG -->
        <div class="form-control w-full">
          <label for="rg" class="block text-sm font-medium text-gray-700 mb-2">
            RG <span class="text-red-500">*</span>
          </label>
          <input
            id="rg"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400 {errors.rg && touched.rg ? 'border-red-500 focus:ring-red-500' : ''}"
            bind:value={formData.rg}
            onblur={() => handleBlur('rg', formData.rg)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.rg && touched.rg ? 'true' : 'false'}
            aria-describedby={errors.rg && touched.rg ? 'rg-error' : undefined}
            data-testid="customer-rg-input"
          />
          {#if errors.rg && touched.rg}
            <p id="rg-error" class="text-red-500 text-xs mt-1.5 flex items-center gap-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.rg}
            </p>
          {/if}
        </div>

        <!-- Birth Date -->
        <div class="form-control w-full">
          <label for="birth" class="block text-sm font-medium text-gray-700 mb-2">
            Data de Nascimento <span class="text-red-500">*</span>
          </label>
          <input
            id="birth"
            type="date"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 {errors.birth && touched.birth ? 'border-red-500 focus:ring-red-500' : ''}"
            bind:value={formData.birth}
            onchange={handleBirthDateChange}
            onblur={() => handleBlur('birth', formData.birth)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.birth && touched.birth ? 'true' : 'false'}
            aria-describedby={(errors.birth && touched.birth) || capacityMessage ? 'birth-message' : undefined}
            data-testid="customer-birth-input"
          />
          {#if (errors.birth && touched.birth) || capacityMessage}
            <p id="birth-message" class="text-xs mt-1.5 flex items-center gap-1 {errors.birth && touched.birth ? 'text-red-500' : 'text-amber-600'}">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.birth || capacityMessage}
            </p>
          {/if}
        </div>

        <!-- Gender -->
        <div class="form-control w-full">
          <label for="gender" class="block text-sm font-medium text-gray-700 mb-2">
            Gênero <span class="text-red-500">*</span>
          </label>
          <select
            id="gender"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 cursor-pointer"
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
          <label for="civil_status" class="block text-sm font-medium text-gray-700 mb-2">
            Estado Civil <span class="text-red-500">*</span>
          </label>
          <select
            id="civil_status"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 cursor-pointer"
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
          <label for="nationality" class="block text-sm font-medium text-gray-700 mb-2">
            Nacionalidade <span class="text-red-500">*</span>
          </label>
          <select
            id="nationality"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 cursor-pointer"
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
          <label for="profession" class="block text-sm font-medium text-gray-700 mb-2">
            Profissão {isProfessionRequired ? '' : '(Opcional)'}
            {#if isProfessionRequired}<span class="text-red-500">*</span>{/if}
          </label>
          <input
            id="profession"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400 {errors.profession && touched.profession && isProfessionRequired ? 'border-red-500 focus:ring-red-500' : ''} {!isProfessionRequired ? 'opacity-60' : ''}"
            bind:value={formData.profession}
            onblur={() => handleBlur('profession', formData.profession)}
            disabled={isLoading || !isProfessionRequired}
            aria-required={isProfessionRequired ? 'true' : 'false'}
            aria-invalid={errors.profession && touched.profession && isProfessionRequired ? 'true' : 'false'}
            aria-describedby={errors.profession && touched.profession && isProfessionRequired ? 'profession-error' : undefined}
            data-testid="customer-profession-input"
          />
          {#if !isProfessionRequired}
            <p class="text-xs text-gray-600 mt-1.5">Não obrigatório para menores de 16 anos</p>
          {/if}
          {#if errors.profession && touched.profession && isProfessionRequired}
            <p id="profession-error" class="text-red-500 text-xs mt-1.5 flex items-center gap-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.profession}
            </p>
          {/if}
        </div>

        <!-- Mother's Name -->
        <div class="form-control w-full">
          <label for="mother_name" class="block text-sm font-medium text-gray-700 mb-2">
            Nome da Mãe <span class="text-red-500">*</span>
          </label>
          <input
            id="mother_name"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400 {errors.mother_name && touched.mother_name ? 'border-red-500 focus:ring-red-500' : ''}"
            bind:value={formData.mother_name}
            onblur={() => handleBlur('mother_name', formData.mother_name)}
            disabled={isLoading}
            aria-required="true"
            aria-invalid={errors.mother_name && touched.mother_name ? 'true' : 'false'}
            aria-describedby={errors.mother_name && touched.mother_name ? 'mother_name-error' : undefined}
            data-testid="customer-mother-name-input"
          />
          {#if errors.mother_name && touched.mother_name}
            <p id="mother_name-error" class="text-red-500 text-xs mt-1.5 flex items-center gap-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.mother_name}
            </p>
          {/if}
        </div>

        <!-- Capacity Selection -->
        <div class="form-control w-full">
          <label for="capacity" class="block text-sm font-medium text-gray-700 mb-2">
            Capacidade
          </label>
          <select
            id="capacity"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 cursor-pointer"
            bind:value={formData.capacity}
            disabled={isLoading}
            data-testid="customer-capacity-input"
          >
            <option value="able">Capaz</option>
            <option value="relatively">Relativamente Incapaz</option>
            <option value="unable">Absolutamente Incapaz</option>
          </select>
          {#if capacityMessage}
            <p class="text-xs text-amber-600 mt-1.5">{capacityMessage}</p>
          {/if}
        </div>
      </div>
    </div>
  </div>

  <!-- Informações de Acesso Section -->
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
      <h3 class="text-lg font-semibold text-white flex items-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
        </svg>
        Informações de Acesso
      </h3>
    </div>

    <div class="p-6 bg-[#eef0ef]">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
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
            onblur={() => handleBlur('email', formData.customer_attributes.email)}
          />
          {#if !isEmailRequired}
            <p class="text-xs text-gray-600 mt-1.5">
              Este email pode ser compartilhado com a conta do responsável
            </p>
          {/if}
        </div>

        <!-- Phone -->
        <div class="form-control w-full">
          <label for="phone" class="block text-sm font-medium text-gray-700 mb-2">
            Telefone
          </label>
          <input
            id="phone"
            type="tel"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.phones_attributes[0].number}
            disabled={isLoading}
            placeholder="+55 11 98765-4321"
            data-testid="customer-phone-input"
          />
        </div>

        <!-- Password -->
        <div class="form-control w-full">
          <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
            {customer ? 'Nova Senha (deixe em branco para manter)' : 'Senha'}
            {#if !customer}<span class="text-red-500">*</span>{/if}
          </label>
          <input
            id="password"
            type="password"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400 {errors.password && touched.password ? 'border-red-500 focus:ring-red-500' : ''}"
            bind:value={formData.customer_attributes.password}
            onblur={() => handleBlur('password', formData.customer_attributes.password)}
            disabled={isLoading}
            placeholder="Mínimo 6 caracteres"
            aria-required={customer ? 'false' : 'true'}
            aria-invalid={errors.password && touched.password ? 'true' : 'false'}
            aria-describedby={errors.password && touched.password ? 'password-error' : undefined}
            data-testid="customer-password-input"
          />
          {#if errors.password && touched.password}
            <p id="password-error" class="text-red-500 text-xs mt-1.5 flex items-center gap-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.password}
            </p>
          {/if}
        </div>

        <!-- Password Confirmation -->
        <div class="form-control w-full">
          <label for="password_confirmation" class="block text-sm font-medium text-gray-700 mb-2">
            {customer ? 'Confirmar Nova Senha' : 'Confirmar Senha'}
            {#if !customer}<span class="text-red-500">*</span>{/if}
          </label>
          <input
            id="password_confirmation"
            type="password"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400 {errors.password_confirmation && touched.password_confirmation ? 'border-red-500 focus:ring-red-500' : ''}"
            bind:value={formData.customer_attributes.password_confirmation}
            onblur={() => handleBlur('password_confirmation', formData.customer_attributes.password_confirmation)}
            disabled={isLoading}
            placeholder="Digite a senha novamente"
            aria-required={customer ? 'false' : 'true'}
            aria-invalid={errors.password_confirmation && touched.password_confirmation ? 'true' : 'false'}
            aria-describedby={errors.password_confirmation && touched.password_confirmation ? 'password_confirmation-error' : undefined}
            data-testid="customer-password-confirmation-input"
          />
          {#if errors.password_confirmation && touched.password_confirmation}
            <p id="password_confirmation-error" class="text-red-500 text-xs mt-1.5 flex items-center gap-1">
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
              </svg>
              {errors.password_confirmation}
            </p>
          {/if}
        </div>
      </div>
    </div>
  </div>

  <!-- Endereço Section -->
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
      <h3 class="text-lg font-semibold text-white flex items-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        Endereço
      </h3>
    </div>

    <div class="p-6 bg-[#eef0ef]">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- ZIP Code -->
        <div class="form-control w-full">
          <label for="zip_code" class="block text-sm font-medium text-gray-700 mb-2">
            CEP
          </label>
          <input
            id="zip_code"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.addresses_attributes[0].zip_code}
            disabled={isLoading}
            placeholder="00000-000"
            data-testid="customer-zipcode-input"
          />
        </div>

        <!-- Street -->
        <div class="form-control w-full">
          <label for="street" class="block text-sm font-medium text-gray-700 mb-2">
            Rua
          </label>
          <input
            id="street"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.addresses_attributes[0].street}
            disabled={isLoading}
            data-testid="customer-street-input"
          />
        </div>

        <!-- Number -->
        <div class="form-control w-full">
          <label for="number" class="block text-sm font-medium text-gray-700 mb-2">
            Número
          </label>
          <input
            id="number"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.addresses_attributes[0].number}
            disabled={isLoading}
            data-testid="customer-number-input"
          />
        </div>

        <!-- Neighborhood -->
        <div class="form-control w-full">
          <label for="neighborhood" class="block text-sm font-medium text-gray-700 mb-2">
            Bairro
          </label>
          <input
            id="neighborhood"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.addresses_attributes[0].neighborhood}
            disabled={isLoading}
            data-testid="customer-neighborhood-input"
          />
        </div>

        <!-- City -->
        <div class="form-control w-full">
          <label for="city" class="block text-sm font-medium text-gray-700 mb-2">
            Cidade
          </label>
          <input
            id="city"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.addresses_attributes[0].city}
            disabled={isLoading}
            data-testid="customer-city-input"
          />
        </div>

        <!-- State -->
        <div class="form-control w-full">
          <label for="state" class="block text-sm font-medium text-gray-700 mb-2">
            Estado
          </label>
          <select
            id="state"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 cursor-pointer"
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
    </div>
  </div>

  <!-- Dados Bancários Section -->
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
      <h3 class="text-lg font-semibold text-white flex items-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h18M7 15h1m4 0h1m-7 4h12a3 3 0 003-3V8a3 3 0 00-3-3H6a3 3 0 00-3 3v8a3 3 0 003 3z" />
        </svg>
        Dados Bancários
      </h3>
    </div>

    <div class="p-6 bg-[#eef0ef]">
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
    </div>
  </div>

  <!-- Informações Previdenciárias Section -->
  <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
    <div class="bg-gradient-to-r from-[#01013D] to-[#01013D] px-6 py-4">
      <h3 class="text-lg font-semibold text-white flex items-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
        Informações Previdenciárias
      </h3>
    </div>

    <div class="p-6 bg-[#eef0ef]">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Benefit Number -->
        <div class="form-control w-full">
          <label for="number_benefit" class="block text-sm font-medium text-gray-700 mb-2">
            Número de Benefício <span class="text-gray-500 text-xs">(Opcional)</span>
          </label>
          <input
            id="number_benefit"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.number_benefit}
            disabled={isLoading}
            placeholder="Número do benefício INSS"
            data-testid="customer-benefit-input"
          />
        </div>

        <!-- NIT -->
        <div class="form-control w-full">
          <label for="nit" class="block text-sm font-medium text-gray-700 mb-2">
            NIT <span class="text-gray-500 text-xs">(Opcional)</span>
          </label>
          <input
            id="nit"
            type="text"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.nit}
            disabled={isLoading}
            placeholder="Número de Inscrição do Trabalhador"
            data-testid="customer-nit-input"
          />
        </div>

        <!-- INSS Password -->
        <div class="form-control w-full md:col-span-2">
          <label for="inss_password" class="block text-sm font-medium text-gray-700 mb-2">
            Senha do MeuINSS <span class="text-gray-500 text-xs">(Opcional)</span>
          </label>
          <input
            id="inss_password"
            type="password"
            class="w-full px-4 py-2.5 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-[#01013D] focus:border-transparent transition-all duration-200 text-gray-900 placeholder-gray-400"
            bind:value={formData.inss_password}
            disabled={isLoading}
            placeholder="Senha de acesso ao MeuINSS"
            data-testid="customer-inss-password-input"
          />
          <div class="flex items-start gap-2 mt-2 text-xs text-amber-600 bg-amber-50 p-3 rounded-lg border border-amber-200">
            <svg class="w-4 h-4 mt-0.5 flex-shrink-0" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd" />
            </svg>
            <span>Esta informação é armazenada de forma segura e criptografada</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>