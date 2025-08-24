<!-- components/customers/CustomerForm.svelte -->
<script lang="ts">
  import { createEventDispatcher, onMount } from 'svelte';
  import { 
    validateCPFRequired, 
    formatCPF,
    validateEmailRequired,
    validatePasswordRequired,
    createPasswordConfirmationValidator,
    validateBirthDateRequired,
    getCapacityFromBirthDate,
    formatBirthDate,
    parseBrazilianDate,
    validationRules
  } from '../../validation';
  
  export let customer: any = null;
  export let isLoading: boolean = false;

  const dispatch = createEventDispatcher<{
    submit: any;
    cancel: void;
  }>();

  // Form data with nested structure for API
  let formData = {
    customer_type: 'physical_person',
    name: '',
    last_name: '',
    status: 'active',
    cpf: '',
    rg: '',
    birth: '',
    gender: 'male',
    civil_status: 'single',
    nationality: 'brazilian',
    capacity: 'able',
    profession: '',
    mother_name: '',
    customer_attributes: {
      email: '',
      password: '',
      password_confirmation: ''
    },
    addresses_attributes: [
      {
        description: 'Home Address',
        zip_code: '',
        street: '',
        city: '',
        number: '',
        neighborhood: '',
        state: ''
      }
    ],
    phones_attributes: [
      {
        phone_number: ''
      }
    ],
    emails_attributes: [
      {
        email: ''
      }
    ],
    bank_accounts_attributes: [
      {
        bank_name: '',
        type_account: 'Corrente',
        agency: '',
        account: '',
        operation: '',
        pix: ''
      }
    ]
  };

  // Validation errors
  let errors: Record<string, string> = {};
  let touched: Record<string, boolean> = {};
  let capacityMessage = '';

  // Get gender-based civil status label
  function getCivilStatusLabel(status: string, gender: string): string {
    const labels: Record<string, Record<string, string>> = {
      single: { male: 'Solteiro', female: 'Solteira' },
      married: { male: 'Casado', female: 'Casada' },
      divorced: { male: 'Divorciado', female: 'Divorciada' },
      widower: { male: 'Viúvo', female: 'Viúva' },
      union: { male: 'Em união estável', female: 'Em união estável' }
    };
    
    return labels[status]?.[gender] || status;
  }

  // Handle CPF formatting
  function handleCPFInput(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.cpf = formatCPF(input.value);
    validateField('cpf', formData.cpf);
  }

  // Handle birth date change and update capacity
  function handleBirthDateChange(event: Event) {
    const input = event.target as HTMLInputElement;
    formData.birth = input.value;
    
    const capacityInfo = getCapacityFromBirthDate(formData.birth);
    if (capacityInfo) {
      formData.capacity = capacityInfo.capacity;
      capacityMessage = capacityInfo.message || '';
    }
    
    validateField('birth', formData.birth);
  }

  // Field validation
  function validateField(fieldName: string, value: any) {
    switch(fieldName) {
      case 'cpf':
        errors.cpf = validateCPFRequired(value) || '';
        break;
      case 'email':
        errors.email = validateEmailRequired(value) || '';
        break;
      case 'password':
        errors.password = validatePasswordRequired(value) || '';
        break;
      case 'password_confirmation': {
        const validator = createPasswordConfirmationValidator(() => formData.customer_attributes.password);
        errors.password_confirmation = validator(value) || '';
        break;
      }
      case 'birth':
        errors.birth = validateBirthDateRequired(value) || '';
        break;
      case 'name':
        errors.name = value ? '' : 'Nome é obrigatório';
        break;
      case 'last_name':
        errors.last_name = value ? '' : 'Sobrenome é obrigatório';
        break;
      case 'rg':
        errors.rg = value ? '' : 'RG é obrigatório';
        break;
      case 'profession':
        errors.profession = value ? '' : 'Profissão é obrigatória';
        break;
      case 'mother_name':
        errors.mother_name = value ? '' : 'Nome da mãe é obrigatório';
        break;
    }
  }

  // Handle field blur
  function handleBlur(fieldName: string, value: any) {
    touched[fieldName] = true;
    validateField(fieldName, value);
  }

  // Validate entire form
  function validateForm(): boolean {
    let isValid = true;
    
    // Validate required fields
    validateField('name', formData.name);
    validateField('last_name', formData.last_name);
    validateField('cpf', formData.cpf);
    validateField('rg', formData.rg);
    validateField('birth', formData.birth);
    validateField('profession', formData.profession);
    validateField('mother_name', formData.mother_name);
    validateField('email', formData.customer_attributes.email);
    
    if (!customer) {
      validateField('password', formData.customer_attributes.password);
      validateField('password_confirmation', formData.customer_attributes.password_confirmation);
    }
    
    // Check if there are any errors
    for (const error of Object.values(errors)) {
      if (error) {
        isValid = false;
        break;
      }
    }
    
    return isValid;
  }

  // Handle form submission
  function handleSubmit() {
    // Mark all fields as touched
    Object.keys(formData).forEach(key => touched[key] = true);
    
    if (!validateForm()) {
      return;
    }

    // Prepare data for submission
    const submitData = {
      profile_customer: {
        ...formData,
        // Sync email from customer_attributes to emails_attributes
        emails_attributes: [
          {
            email: formData.customer_attributes.email
          }
        ]
      }
    };

    dispatch('submit', submitData);
  }

  function handleCancel() {
    dispatch('cancel');
  }

  // Brazilian states
  const states = [
    { value: 'AC', label: 'Acre' },
    { value: 'AL', label: 'Alagoas' },
    { value: 'AP', label: 'Amapá' },
    { value: 'AM', label: 'Amazonas' },
    { value: 'BA', label: 'Bahia' },
    { value: 'CE', label: 'Ceará' },
    { value: 'DF', label: 'Distrito Federal' },
    { value: 'ES', label: 'Espírito Santo' },
    { value: 'GO', label: 'Goiás' },
    { value: 'MA', label: 'Maranhão' },
    { value: 'MT', label: 'Mato Grosso' },
    { value: 'MS', label: 'Mato Grosso do Sul' },
    { value: 'MG', label: 'Minas Gerais' },
    { value: 'PA', label: 'Pará' },
    { value: 'PB', label: 'Paraíba' },
    { value: 'PR', label: 'Paraná' },
    { value: 'PE', label: 'Pernambuco' },
    { value: 'PI', label: 'Piauí' },
    { value: 'RJ', label: 'Rio de Janeiro' },
    { value: 'RN', label: 'Rio Grande do Norte' },
    { value: 'RS', label: 'Rio Grande do Sul' },
    { value: 'RO', label: 'Rondônia' },
    { value: 'RR', label: 'Roraima' },
    { value: 'SC', label: 'Santa Catarina' },
    { value: 'SP', label: 'São Paulo' },
    { value: 'SE', label: 'Sergipe' },
    { value: 'TO', label: 'Tocantins' }
  ];
</script>

<div class="card bg-base-100 shadow-xl">
  <div class="card-body">
    <h2 class="card-title">
      {customer ? 'Editar Cliente' : 'Novo Cliente'}
    </h2>

    <form on:submit|preventDefault={handleSubmit} class="space-y-6">
      <!-- Personal Information Section -->
      <div class="divider">Informações Pessoais</div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Name -->
        <div class="form-control">
          <label for="name" class="label">
            <span class="label-text">Nome *</span>
          </label>
          <input
            id="name"
            type="text"
            class="input input-bordered {errors.name && touched.name ? 'input-error' : ''}"
            bind:value={formData.name}
            on:blur={() => handleBlur('name', formData.name)}
            disabled={isLoading}
          />
          {#if errors.name && touched.name}
            <label class="label">
              <span class="label-text-alt text-error">{errors.name}</span>
            </label>
          {/if}
        </div>

        <!-- Last Name -->
        <div class="form-control">
          <label for="last_name" class="label">
            <span class="label-text">Sobrenome *</span>
          </label>
          <input
            id="last_name"
            type="text"
            class="input input-bordered {errors.last_name && touched.last_name ? 'input-error' : ''}"
            bind:value={formData.last_name}
            on:blur={() => handleBlur('last_name', formData.last_name)}
            disabled={isLoading}
          />
          {#if errors.last_name && touched.last_name}
            <label class="label">
              <span class="label-text-alt text-error">{errors.last_name}</span>
            </label>
          {/if}
        </div>

        <!-- CPF -->
        <div class="form-control">
          <label for="cpf" class="label">
            <span class="label-text">CPF *</span>
          </label>
          <input
            id="cpf"
            type="text"
            class="input input-bordered {errors.cpf && touched.cpf ? 'input-error' : ''}"
            bind:value={formData.cpf}
            on:input={handleCPFInput}
            on:blur={() => handleBlur('cpf', formData.cpf)}
            disabled={isLoading}
            placeholder="000.000.000-00"
            maxlength="14"
          />
          {#if errors.cpf && touched.cpf}
            <label class="label">
              <span class="label-text-alt text-error">{errors.cpf}</span>
            </label>
          {/if}
        </div>

        <!-- RG -->
        <div class="form-control">
          <label for="rg" class="label">
            <span class="label-text">RG *</span>
          </label>
          <input
            id="rg"
            type="text"
            class="input input-bordered {errors.rg && touched.rg ? 'input-error' : ''}"
            bind:value={formData.rg}
            on:blur={() => handleBlur('rg', formData.rg)}
            disabled={isLoading}
          />
          {#if errors.rg && touched.rg}
            <label class="label">
              <span class="label-text-alt text-error">{errors.rg}</span>
            </label>
          {/if}
        </div>

        <!-- Birth Date -->
        <div class="form-control">
          <label for="birth" class="label">
            <span class="label-text">Data de Nascimento *</span>
          </label>
          <input
            id="birth"
            type="date"
            class="input input-bordered {errors.birth && touched.birth ? 'input-error' : ''}"
            bind:value={formData.birth}
            on:change={handleBirthDateChange}
            on:blur={() => handleBlur('birth', formData.birth)}
            disabled={isLoading}
          />
          {#if errors.birth && touched.birth}
            <label class="label">
              <span class="label-text-alt text-error">{errors.birth}</span>
            </label>
          {/if}
          {#if capacityMessage}
            <label class="label">
              <span class="label-text-alt text-warning">{capacityMessage}</span>
            </label>
          {/if}
        </div>

        <!-- Gender -->
        <div class="form-control">
          <label for="gender" class="label">
            <span class="label-text">Gênero *</span>
          </label>
          <select
            id="gender"
            class="select select-bordered"
            bind:value={formData.gender}
            disabled={isLoading}
          >
            <option value="male">Masculino</option>
            <option value="female">Feminino</option>
          </select>
        </div>

        <!-- Civil Status -->
        <div class="form-control">
          <label for="civil_status" class="label">
            <span class="label-text">Estado Civil *</span>
          </label>
          <select
            id="civil_status"
            class="select select-bordered"
            bind:value={formData.civil_status}
            disabled={isLoading}
          >
            <option value="single">{getCivilStatusLabel('single', formData.gender)}</option>
            <option value="married">{getCivilStatusLabel('married', formData.gender)}</option>
            <option value="divorced">{getCivilStatusLabel('divorced', formData.gender)}</option>
            <option value="widower">{getCivilStatusLabel('widower', formData.gender)}</option>
            <option value="union">{getCivilStatusLabel('union', formData.gender)}</option>
          </select>
        </div>

        <!-- Nationality -->
        <div class="form-control">
          <label for="nationality" class="label">
            <span class="label-text">Nacionalidade *</span>
          </label>
          <select
            id="nationality"
            class="select select-bordered"
            bind:value={formData.nationality}
            disabled={isLoading}
          >
            <option value="brazilian">Brasileiro</option>
            <option value="foreigner">Estrangeiro</option>
          </select>
        </div>

        <!-- Profession -->
        <div class="form-control">
          <label for="profession" class="label">
            <span class="label-text">Profissão *</span>
          </label>
          <input
            id="profession"
            type="text"
            class="input input-bordered {errors.profession && touched.profession ? 'input-error' : ''}"
            bind:value={formData.profession}
            on:blur={() => handleBlur('profession', formData.profession)}
            disabled={isLoading}
          />
          {#if errors.profession && touched.profession}
            <label class="label">
              <span class="label-text-alt text-error">{errors.profession}</span>
            </label>
          {/if}
        </div>

        <!-- Mother's Name -->
        <div class="form-control">
          <label for="mother_name" class="label">
            <span class="label-text">Nome da Mãe *</span>
          </label>
          <input
            id="mother_name"
            type="text"
            class="input input-bordered {errors.mother_name && touched.mother_name ? 'input-error' : ''}"
            bind:value={formData.mother_name}
            on:blur={() => handleBlur('mother_name', formData.mother_name)}
            disabled={isLoading}
          />
          {#if errors.mother_name && touched.mother_name}
            <label class="label">
              <span class="label-text-alt text-error">{errors.mother_name}</span>
            </label>
          {/if}
        </div>

        <!-- Status -->
        <div class="form-control">
          <label for="status" class="label">
            <span class="label-text">Status</span>
          </label>
          <select
            id="status"
            class="select select-bordered"
            bind:value={formData.status}
            disabled={isLoading}
          >
            <option value="active">Ativo</option>
            <option value="inactive">Inativo</option>
            <option value="deceased">Falecido</option>
          </select>
        </div>
      </div>

      <!-- Login Information Section -->
      <div class="divider">Informações de Acesso</div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Email -->
        <div class="form-control">
          <label for="email" class="label">
            <span class="label-text">Email *</span>
          </label>
          <input
            id="email"
            type="email"
            class="input input-bordered {errors.email && touched.email ? 'input-error' : ''}"
            bind:value={formData.customer_attributes.email}
            on:blur={() => handleBlur('email', formData.customer_attributes.email)}
            disabled={isLoading}
            placeholder="cliente@exemplo.com"
          />
          {#if errors.email && touched.email}
            <label class="label">
              <span class="label-text-alt text-error">{errors.email}</span>
            </label>
          {/if}
        </div>

        <!-- Password -->
        <div class="form-control">
          <label for="password" class="label">
            <span class="label-text">
              {customer ? 'Nova Senha (deixe em branco para manter)' : 'Senha *'}
            </span>
          </label>
          <input
            id="password"
            type="password"
            class="input input-bordered {errors.password && touched.password ? 'input-error' : ''}"
            bind:value={formData.customer_attributes.password}
            on:blur={() => handleBlur('password', formData.customer_attributes.password)}
            disabled={isLoading}
            placeholder="Mínimo 6 caracteres"
          />
          {#if errors.password && touched.password}
            <label class="label">
              <span class="label-text-alt text-error">{errors.password}</span>
            </label>
          {/if}
        </div>

        <!-- Password Confirmation -->
        <div class="form-control">
          <label for="password_confirmation" class="label">
            <span class="label-text">
              {customer ? 'Confirmar Nova Senha' : 'Confirmar Senha *'}
            </span>
          </label>
          <input
            id="password_confirmation"
            type="password"
            class="input input-bordered {errors.password_confirmation && touched.password_confirmation ? 'input-error' : ''}"
            bind:value={formData.customer_attributes.password_confirmation}
            on:blur={() => handleBlur('password_confirmation', formData.customer_attributes.password_confirmation)}
            disabled={isLoading}
            placeholder="Digite a senha novamente"
          />
          {#if errors.password_confirmation && touched.password_confirmation}
            <label class="label">
              <span class="label-text-alt text-error">{errors.password_confirmation}</span>
            </label>
          {/if}
        </div>
      </div>

      <!-- Address Section -->
      <div class="divider">Endereço</div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- ZIP Code -->
        <div class="form-control">
          <label for="zip_code" class="label">
            <span class="label-text">CEP</span>
          </label>
          <input
            id="zip_code"
            type="text"
            class="input input-bordered"
            bind:value={formData.addresses_attributes[0].zip_code}
            disabled={isLoading}
            placeholder="00000-000"
          />
        </div>

        <!-- Street -->
        <div class="form-control">
          <label for="street" class="label">
            <span class="label-text">Rua</span>
          </label>
          <input
            id="street"
            type="text"
            class="input input-bordered"
            bind:value={formData.addresses_attributes[0].street}
            disabled={isLoading}
          />
        </div>

        <!-- Number -->
        <div class="form-control">
          <label for="number" class="label">
            <span class="label-text">Número</span>
          </label>
          <input
            id="number"
            type="text"
            class="input input-bordered"
            bind:value={formData.addresses_attributes[0].number}
            disabled={isLoading}
          />
        </div>

        <!-- Neighborhood -->
        <div class="form-control">
          <label for="neighborhood" class="label">
            <span class="label-text">Bairro</span>
          </label>
          <input
            id="neighborhood"
            type="text"
            class="input input-bordered"
            bind:value={formData.addresses_attributes[0].neighborhood}
            disabled={isLoading}
          />
        </div>

        <!-- City -->
        <div class="form-control">
          <label for="city" class="label">
            <span class="label-text">Cidade</span>
          </label>
          <input
            id="city"
            type="text"
            class="input input-bordered"
            bind:value={formData.addresses_attributes[0].city}
            disabled={isLoading}
          />
        </div>

        <!-- State -->
        <div class="form-control">
          <label for="state" class="label">
            <span class="label-text">Estado</span>
          </label>
          <select
            id="state"
            class="select select-bordered"
            bind:value={formData.addresses_attributes[0].state}
            disabled={isLoading}
          >
            <option value="">Selecione...</option>
            {#each states as state}
              <option value={state.value}>{state.label}</option>
            {/each}
          </select>
        </div>
      </div>

      <!-- Contact Section -->
      <div class="divider">Contato</div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Phone -->
        <div class="form-control">
          <label for="phone" class="label">
            <span class="label-text">Telefone</span>
          </label>
          <input
            id="phone"
            type="tel"
            class="input input-bordered"
            bind:value={formData.phones_attributes[0].phone_number}
            disabled={isLoading}
            placeholder="+55 11 98765-4321"
          />
        </div>
      </div>

      <!-- Bank Account Section -->
      <div class="divider">Dados Bancários</div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <!-- Bank Name -->
        <div class="form-control">
          <label for="bank_name" class="label">
            <span class="label-text">Banco</span>
          </label>
          <input
            id="bank_name"
            type="text"
            class="input input-bordered"
            bind:value={formData.bank_accounts_attributes[0].bank_name}
            disabled={isLoading}
          />
        </div>

        <!-- Account Type -->
        <div class="form-control">
          <label for="type_account" class="label">
            <span class="label-text">Tipo de Conta</span>
          </label>
          <select
            id="type_account"
            class="select select-bordered"
            bind:value={formData.bank_accounts_attributes[0].type_account}
            disabled={isLoading}
          >
            <option value="Corrente">Corrente</option>
            <option value="Poupança">Poupança</option>
          </select>
        </div>

        <!-- Agency -->
        <div class="form-control">
          <label for="agency" class="label">
            <span class="label-text">Agência</span>
          </label>
          <input
            id="agency"
            type="text"
            class="input input-bordered"
            bind:value={formData.bank_accounts_attributes[0].agency}
            disabled={isLoading}
            placeholder="0000-0"
          />
        </div>

        <!-- Account -->
        <div class="form-control">
          <label for="account" class="label">
            <span class="label-text">Conta</span>
          </label>
          <input
            id="account"
            type="text"
            class="input input-bordered"
            bind:value={formData.bank_accounts_attributes[0].account}
            disabled={isLoading}
            placeholder="00000-0"
          />
        </div>

        <!-- Operation -->
        <div class="form-control">
          <label for="operation" class="label">
            <span class="label-text">Operação</span>
          </label>
          <input
            id="operation"
            type="text"
            class="input input-bordered"
            bind:value={formData.bank_accounts_attributes[0].operation}
            disabled={isLoading}
          />
        </div>

        <!-- PIX -->
        <div class="form-control">
          <label for="pix" class="label">
            <span class="label-text">Chave PIX</span>
          </label>
          <input
            id="pix"
            type="text"
            class="input input-bordered"
            bind:value={formData.bank_accounts_attributes[0].pix}
            disabled={isLoading}
          />
        </div>
      </div>

      <!-- Actions -->
      <div class="card-actions justify-end mt-6">
        <button type="button" class="btn btn-ghost" on:click={handleCancel} disabled={isLoading}>
          Cancelar
        </button>
        <button type="submit" class="btn btn-primary" disabled={isLoading}>
          {#if isLoading}
            <span class="loading loading-spinner"></span>
          {/if}
          {customer ? 'Atualizar' : 'Criar Cliente'}
        </button>
      </div>
    </form>
  </div>
</div>