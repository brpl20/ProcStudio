<script>
  import { createEventDispatcher } from 'svelte';
  import { onMount } from 'svelte';
  import api from '../../api';
  import Cnpj from '../forms_commons/Cnpj.svelte';
  import Address from '../forms_commons/Address.svelte';

  export let office = null;

  const dispatch = createEventDispatcher();
  const isEdit = !!office;

  let formData = {
    name: '',
    cnpj: '',
    oab_id: '',
    oab_status: '',
    oab_inscricao: '',
    oab_link: '',
    society: 'individual',
    foundation: '',
    site: '',
    accounting_type: 'simple',
    quote_value: '',
    number_of_quotes: '',
    phones_attributes: [{ phone_number: '' }],
    addresses_attributes: [
      {
        street: '',
        number: '',
        complement: '',
        neighborhood: '',
        city: '',
        state: '',
        zip_code: '',
        address_type: 'main'
      }
    ],
    emails_attributes: [{ email: '' }],
    bank_accounts_attributes: [
      {
        bank_name: '',
        type_account: '',
        agency: '',
        account: '',
        operation: '',
        pix: ''
      }
    ]
  };

  let logoFile = null;
  let contractFiles = [];
  let logoPreview = null;
  let loading = false;
  let error = null;
  let success = null;

  // Partnership management
  let lawyers = [];
  let partners = [
    {
      lawyer_id: '',
      lawyer_name: '',
      partnership_type: '',
      ownership_percentage: 100,
      is_managing_partner: false,
      pro_labore_amount: 0
    }
  ];
  let profitDistribution = 'proportional';
  let createSocialContract = false;
  let partnersWithProLabore = true;
  const minimumWage = 1320.0;
  const inssCeiling = 7507.49;
  let proLaboreErrors = {};

  // Reactive statement to debug lawyers changes (commented out to prevent infinite loops)
  // $: {
  //   console.log('Lawyers array updated:', lawyers.length, lawyers);
  // }

  const societyOptions = [
    { value: 'individual', label: 'Individual' },
    { value: 'company', label: 'Sociedade' }
  ];

  const accountingOptions = [
    { value: 'simple', label: 'Simples Nacional' },
    { value: 'real_profit', label: 'Lucro Real' },
    { value: 'presumed_profit', label: 'Lucro Presumido' }
  ];

  const partnershipTypes = [
    { value: 'socio', label: 'Sócio' },
    { value: 'associado', label: 'Associado' },
    { value: 'socio_de_servico', label: 'Sócio de Serviço' }
  ];

  function handleClose() {
    dispatch('close');
  }

  function handleLogoChange(event) {
    const file = event.target.files?.[0];
    if (file) {
      logoFile = file;
      // Create preview
      const reader = new FileReader();
      reader.onload = (e) => {
        logoPreview = e.target.result;
      };
      reader.readAsDataURL(file);
    }
  }

  function handleContractsChange(event) {
    const files = Array.from(event.target.files || []);
    contractFiles = files;
  }

  // Partnership management functions
  function handlePartnerChange(index, field, value) {
    console.log('handlePartnerChange called:', { index, field, value });

    partners = partners.map((partner, i) => {
      if (i === index) {
        if (field === 'lawyer_id' && value && typeof value === 'object') {
          console.log('Setting lawyer for partner:', {
            partnerId: value.id,
            lawyerName: value.attributes
          });
          return {
            ...partner,
            lawyer_id: value.id,
            lawyer_name: `${value.attributes.name} ${value.attributes.last_name}`
          };
        } else if (field === 'ownership_percentage') {
          const newPercentage = Math.max(0, Math.min(100, Number(value) || 0));

          // Special logic for 2 partners - adjust other partner automatically
          if (partners.length === 2) {
            const otherIndex = index === 0 ? 1 : 0;
            const updatedPartners = [...partners];
            updatedPartners[index] = { ...partner, ownership_percentage: newPercentage };
            updatedPartners[otherIndex] = {
              ...updatedPartners[otherIndex],
              ownership_percentage: 100 - newPercentage
            };
            return i === index ? updatedPartners[index] : updatedPartners[i];
          } else {
            return { ...partner, ownership_percentage: newPercentage };
          }
        } else if (field === 'pro_labore_amount') {
          const amount = Number(value) || 0;
          const error = validateProLaboreAmount(amount);

          // Update errors
          if (error) {
            proLaboreErrors[index] = error;
          } else {
            delete proLaboreErrors[index];
          }
          proLaboreErrors = { ...proLaboreErrors };

          return { ...partner, pro_labore_amount: amount };
        } else {
          return { ...partner, [field]: value };
        }
      }
      return partner;
    });
  }

  function addPartner() {
    if (lawyers.length <= partners.length) {
      return;
    }

    // If adding second partner, split 50/50
    if (partners.length === 1) {
      partners[0] = { ...partners[0], ownership_percentage: 50 };
    }

    // Add new partner
    partners = [
      ...partners,
      {
        lawyer_id: '',
        lawyer_name: '',
        partnership_type: '',
        ownership_percentage: partners.length === 1 ? 50 : 0,
        is_managing_partner: false,
        pro_labore_amount: 0
      }
    ];

    console.log('Added new partner, total partners:', partners.length);
  }

  function removePartner(index) {
    if (partners.length === 1) {
      return;
    }

    partners = partners.filter((_, i) => i !== index);

    // Adjust percentages if now 2 partners
    if (partners.length === 2) {
      partners = partners.map((partner, i) => ({
        ...partner,
        ownership_percentage: 50
      }));
    }
  }

  function getAvailableLawyers(currentIndex) {
    const selectedIds = partners
      .map((partner, index) => (index !== currentIndex ? partner.lawyer_id : null))
      .filter((id) => id && id !== '');

    const availableLawyers = lawyers.filter((lawyer) => !selectedIds.includes(lawyer.id));
    console.log(`getAvailableLawyers(${currentIndex}):`, {
      totalLawyers: lawyers.length,
      selectedIds,
      availableLawyers: availableLawyers.length,
      availableLawyersData: availableLawyers,
      lawyersStructure: availableLawyers.map((l) => ({
        id: l.id,
        name: l.attributes?.name,
        lastName: l.attributes?.last_name,
        fullStructure: l
      }))
    });

    return availableLawyers;
  }

  function getTotalPercentage() {
    return partners.reduce((total, partner) => total + (partner.ownership_percentage || 0), 0);
  }

  function isOverPercentage() {
    return getTotalPercentage() > 100;
  }

  function validateProLaboreAmount(amount) {
    if (amount < 0) {
      return 'Valor não pode ser negativo';
    }
    if (amount > 0 && amount < minimumWage) {
      return `Valor deve ser maior ou igual ao salário mínimo (R$ ${minimumWage.toLocaleString('pt-BR', { minimumFractionDigits: 2 })})`;
    }
    return null;
  }

  function addPhone() {
    formData.phones_attributes = [...formData.phones_attributes, { phone_number: '' }];
  }

  function removePhone(index) {
    if (formData.phones_attributes.length > 1) {
      formData.phones_attributes = formData.phones_attributes.filter((_, i) => i !== index);
    }
  }

  function addEmail() {
    formData.emails_attributes = [...formData.emails_attributes, { email: '' }];
  }

  function removeEmail(index) {
    if (formData.emails_attributes.length > 1) {
      formData.emails_attributes = formData.emails_attributes.filter((_, i) => i !== index);
    }
  }

  function addAddress() {
    formData.addresses_attributes = [
      ...formData.addresses_attributes,
      {
        street: '',
        number: '',
        complement: '',
        neighborhood: '',
        city: '',
        state: '',
        zip_code: '',
        address_type: 'secondary'
      }
    ];
  }

  function removeAddress(index) {
    if (formData.addresses_attributes.length > 1) {
      formData.addresses_attributes = formData.addresses_attributes.filter((_, i) => i !== index);
    }
  }

  function addBankAccount() {
    formData.bank_accounts_attributes = [
      ...formData.bank_accounts_attributes,
      {
        bank_name: '',
        type_account: '',
        agency: '',
        account: '',
        operation: '',
        pix: ''
      }
    ];
  }

  function removeBankAccount(index) {
    if (formData.bank_accounts_attributes.length > 1) {
      formData.bank_accounts_attributes = formData.bank_accounts_attributes.filter(
        (_, i) => i !== index
      );
    }
  }

  async function handleSubmit() {
    try {
      loading = true;
      error = null;
      success = null;

      // Prepare the data
      const payload = {
        ...formData,
        quote_value: formData.quote_value ? parseFloat(formData.quote_value) : undefined,
        number_of_quotes: formData.number_of_quotes
          ? parseInt(formData.number_of_quotes)
          : undefined,
        logo: logoFile,
        // Partnership data
        user_offices_attributes: partners
          .filter((p) => p.lawyer_id && p.partnership_type)
          .map((p) => ({
            user_id: p.lawyer_id,
            partnership_type: p.partnership_type,
            partnership_percentage: p.ownership_percentage?.toString(),
            pro_labore_amount: p.pro_labore_amount,
            is_managing_partner: p.is_managing_partner || false,
            _destroy: false
          })),
        // Additional partnership metadata
        profit_distribution: profitDistribution,
        create_social_contract: createSocialContract,
        partners_with_pro_labore: partnersWithProLabore
      };

      // Filter out empty values
      payload.phones_attributes = payload.phones_attributes.filter((p) => p.phone_number.trim());
      payload.emails_attributes = payload.emails_attributes.filter((e) => e.email.trim());
      payload.addresses_attributes = payload.addresses_attributes.filter((a) => a.street.trim());
      payload.bank_accounts_attributes = payload.bank_accounts_attributes.filter((b) =>
        b.bank_name.trim()
      );

      let response;
      if (isEdit) {
        response = await api.offices.updateOffice(office.id, payload);
      } else {
        response = await api.offices.createOffice(payload);
      }

      if (response.success) {
        // Upload contracts if any
        if (contractFiles.length > 0 && response.data?.id) {
          try {
            await api.offices.uploadSocialContracts(response.data.id, contractFiles);
          } catch (contractError) {
            console.warn('Error uploading contracts:', contractError);
            // Don't fail the whole operation, just warn
          }
        }

        success = response.message || `Escritório ${isEdit ? 'atualizado' : 'criado'} com sucesso!`;
        setTimeout(() => {
          dispatch('success');
        }, 1500);
      } else {
        error = response.message || 'Erro ao salvar escritório';
      }
    } catch (err) {
      console.error('Form submit error:', err);
      error = err.message || 'Erro ao salvar escritório';
    } finally {
      loading = false;
    }
  }

  function formatPhone(value) {
    // Remove non-digits
    const digits = value.replace(/\D/g, '');

    // Apply phone mask
    if (digits.length <= 10) {
      // (00) 0000-0000
      return digits.replace(/(\d{2})(\d)/, '($1) $2').replace(/(\d{4})(\d)/, '$1-$2');
    } else {
      // (00) 00000-0000
      return digits
        .replace(/(\d{2})(\d)/, '($1) $2')
        .replace(/(\d{5})(\d)/, '$1-$2')
        .substr(0, 15);
    }
  }

  async function loadLawyers() {
    try {
      console.log('Loading lawyers from user profiles...');

      // Get user profiles directly - the API returns { success: true, message: "...", data: [...] }
      const response = await api.users.getUserProfiles();
      console.log('User profiles response:', response);

      // Now the response should have the correct structure: { success: true, data: UserProfileData[] }
      if (response.success && response.data && Array.isArray(response.data)) {
        console.log('Processing profiles data:', response.data);

        // All profiles in the test data have role: "lawyer", so we map them directly
        lawyers = response.data
          .filter((profile) => {
            console.log('Checking profile:', profile);
            return profile.attributes?.role === 'lawyer';
          })
          .map((profile) => {
            console.log('Mapping profile:', profile.attributes);
            return {
              id: profile.attributes.user_id || profile.id,
              attributes: {
                name: profile.attributes.name,
                last_name: profile.attributes.last_name,
                role: profile.attributes.role,
                email: profile.attributes.access_email,
                user_id: profile.attributes.user_id
              }
            };
          });

        console.log('Final lawyers array:', lawyers);
        console.log(`Loaded ${lawyers.length} lawyers successfully!`);
      } else {
        console.warn('No data in user profiles response or data is not an array:', response);
        lawyers = [];
      }
    } catch (err) {
      console.error('Error loading lawyers:', err);
      lawyers = [];
    }
  }

  onMount(async () => {
    await loadLawyers();
    if (office) {
      // Populate form with existing data
      formData = {
        name: office.name || '',
        cnpj: office.cnpj || '',
        oab_id: office.oab_id || '',
        oab_status: office.oab_status || '',
        oab_inscricao: office.oab_inscricao || '',
        oab_link: office.oab_link || '',
        society: office.society || 'individual',
        foundation: office.foundation || '',
        site: office.site || '',
        accounting_type: office.accounting_type || 'simple',
        quote_value: office.quote_value?.toString() || '',
        number_of_quotes: office.number_of_quotes?.toString() || '',
        phones_attributes:
          office.phones?.length > 0
            ? office.phones.map((p) => ({ phone_number: p.phone_number, id: p.id }))
            : [{ phone_number: '' }],
        addresses_attributes:
          office.addresses?.length > 0
            ? office.addresses.map((a) => ({
              street: a.street || '',
              number: a.number || '',
              complement: a.complement || '',
              neighborhood: a.neighborhood || '',
              city: a.city || '',
              state: a.state || '',
              zip_code: a.zip_code || '',
              address_type: a.address_type || 'main',
              id: a.id
            }))
            : [
              {
                street: '',
                number: '',
                complement: '',
                neighborhood: '',
                city: '',
                state: '',
                zip_code: '',
                address_type: 'main'
              }
            ],
        emails_attributes:
          office.emails?.length > 0
            ? office.emails.map((e) => ({ email: e.email, id: e.id }))
            : [{ email: '' }],
        bank_accounts_attributes:
          office.bank_accounts?.length > 0
            ? office.bank_accounts.map((b) => ({
              bank_name: b.bank_name || '',
              type_account: b.type_account || '',
              agency: b.agency || '',
              account: b.account || '',
              operation: b.operation || '',
              pix: b.pix || '',
              id: b.id
            }))
            : [
              {
                bank_name: '',
                type_account: '',
                agency: '',
                account: '',
                operation: '',
                pix: ''
              }
            ]
      };

      if (office.logo_url) {
        logoPreview = office.logo_url;
      }
    }
  });
</script>

<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
  <div class="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto">
    <!-- Header -->
    <div
      class="sticky top-0 bg-white border-b border-gray-200 p-6 flex justify-between items-center"
    >
      <h2 class="text-2xl font-bold text-gray-900">
        {isEdit ? 'Editar Escritório' : 'Novo Escritório'}
      </h2>
      <button class="btn btn-ghost btn-circle" on:click={handleClose}>✕</button>
    </div>

    <!-- Form Content -->
    <div class="p-6 space-y-8">
      {#if success}
        <div class="alert alert-success">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="stroke-current shrink-0 h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>{success}</span>
        </div>
      {/if}

      {#if error}
        <div class="alert alert-error">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="stroke-current shrink-0 h-6 w-6"
            fill="none"
            viewBox="0 0 24 24"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z"
            />
          </svg>
          <span>{error}</span>
        </div>
      {/if}

      <!-- Basic Information -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Informações Básicas</h3>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Nome do Escritório *</span>
              </label>
              <input
                type="text"
                class="input input-bordered w-full"
                bind:value={formData.name}
                placeholder="Nome do escritório"
                required
              />
            </div>

            <Cnpj required bind:value={formData.cnpj} id="office-cnpj" labelText={'CNPJ'} />

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Tipo de Sociedade</span>
              </label>
              <select class="select select-bordered w-full" bind:value={formData.society}>
                {#each societyOptions as option}
                  <option value={option.value}>{option.label}</option>
                {/each}
              </select>
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Enquadramento Contábil</span>
              </label>
              <select class="select select-bordered w-full" bind:value={formData.accounting_type}>
                {#each accountingOptions as option}
                  <option value={option.value}>{option.label}</option>
                {/each}
              </select>
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Data de Fundação</span>
              </label>
              <input type="date" class="input input-bordered w-full" bind:value={formData.foundation} />
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Site</span>
              </label>
              <input type="url" class="input input-bordered w-full" bind:value={formData.site} />
            </div>
          </div>
        </div>
      </div>

      <!-- OAB Information -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Informações OAB</h3>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">OAB ID</span>
              </label>
              <input
                type="text"
                class="input input-bordered w-full"
                bind:value={formData.oab_id}
                placeholder="Número OAB"
              />
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Status OAB</span>
              </label>
              <input
                type="text"
                class="input input-bordered w-full"
                bind:value={formData.oab_status}
                placeholder="Status na OAB"
              />
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Inscrição OAB</span>
              </label>
              <input
                type="text"
                class="input input-bordered w-full"
                bind:value={formData.oab_inscricao}
                placeholder="Número da inscrição"
              />
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Link OAB</span>
              </label>
              <input
                type="url"
                class="input input-bordered w-full"
                bind:value={formData.oab_link}
                placeholder="Link do perfil na OAB"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Financial Information -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Informações Financeiras</h3>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Valor da Cota</span>
              </label>
              <input
                type="number"
                class="input input-bordered w-full"
                bind:value={formData.quote_value}
                placeholder="0.00"
                step="0.01"
                min="0"
              />
            </div>

            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Número de Cotas</span>
              </label>
              <input
                type="number"
                class="input input-bordered w-full"
                bind:value={formData.number_of_quotes}
                placeholder="0"
                min="0"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Phones -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <div class="flex justify-between items-center mb-4">
            <h3 class="card-title text-lg font-semibold">Telefones</h3>
            <button class="btn btn-outline btn-sm" on:click={addPhone}>➕ Adicionar</button>
          </div>

          {#each formData.phones_attributes as phone, index (index)}
            <div class="flex gap-2 mb-2">
              <input
                type="tel"
                class="input input-bordered flex-1"
                bind:value={phone.phone_number}
                on:input={(e) => (phone.phone_number = formatPhone(e.target.value))}
                placeholder="(00) 00000-0000"
                maxlength="15"
              />
              {#if formData.phones_attributes.length > 1}
                <button class="btn btn-error btn-sm" on:click={() => removePhone(index)}>🗑️</button>
              {/if}
            </div>
          {/each}
        </div>
      </div>

      <!-- Emails -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <div class="flex justify-between items-center mb-4">
            <h3 class="card-title text-lg font-semibold">E-mails</h3>
            <button class="btn btn-outline btn-sm" on:click={addEmail}>➕ Adicionar</button>
          </div>

          {#each formData.emails_attributes as email, index (index)}
            <div class="flex gap-2 mb-2">
              <input
                type="email"
                class="input input-bordered flex-1"
                bind:value={email.email}
                placeholder="email@exemplo.com"
              />
              {#if formData.emails_attributes.length > 1}
                <button class="btn btn-error btn-sm" on:click={() => removeEmail(index)}>🗑️</button>
              {/if}
            </div>
          {/each}
        </div>
      </div>

      <!-- Addresses -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <div class="flex justify-between items-center mb-4">
            <h3 class="card-title text-lg font-semibold">Endereços</h3>
            <button class="btn btn-outline btn-sm" on:click={addAddress} type="button">➕ Adicionar</button>
          </div>

          {#each formData.addresses_attributes as address, idx (idx)}
            <Address
              bind:address={formData.addresses_attributes[idx]}
              index={idx}
              showRemoveButton={formData.addresses_attributes.length > 1}
              on:remove={() => removeAddress(idx)}
            />
          {/each}
        </div>
      </div>

      <!-- Bank Accounts -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <div class="flex justify-between items-center mb-4">
            <h3 class="card-title text-lg font-semibold">Contas Bancárias</h3>
            <button class="btn btn-outline btn-sm" on:click={addBankAccount}>➕ Adicionar</button>
          </div>

          {#each formData.bank_accounts_attributes as bank, index (index)}
            <div class="border rounded p-4 mb-4">
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Nome do Banco</span>
                  </label>
                  <input
                    type="text"
                    class="input input-bordered input-sm w-full"
                    bind:value={bank.bank_name}
                    placeholder="Nome do banco"
                  />
                </div>

                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Tipo de Conta</span>
                  </label>
                  <input
                    type="text"
                    class="input input-bordered input-sm w-full"
                    bind:value={bank.type_account}
                    placeholder="Corrente, Poupança"
                  />
                </div>

                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Agência</span>
                  </label>
                  <input
                    type="text"
                    class="input input-bordered input-sm w-full"
                    bind:value={bank.agency}
                    placeholder="0000"
                  />
                </div>

                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Conta</span>
                  </label>
                  <input
                    type="text"
                    class="input input-bordered input-sm w-full"
                    bind:value={bank.account}
                    placeholder="00000-0"
                  />
                </div>

                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Operação</span>
                  </label>
                  <input
                    type="text"
                    class="input input-bordered input-sm w-full"
                    bind:value={bank.operation}
                    placeholder="000"
                  />
                </div>

                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">PIX</span>
                  </label>
                  <input
                    type="text"
                    class="input input-bordered input-sm w-full"
                    bind:value={bank.pix}
                    placeholder="Chave PIX"
                  />
                </div>
              </div>

              {#if formData.bank_accounts_attributes.length > 1}
                <div class="flex justify-end mt-2">
                  <button class="btn btn-error btn-sm" on:click={() => removeBankAccount(index)}
                    >🗑️ Remover</button
                  >
                </div>
              {/if}
            </div>
          {/each}
        </div>
      </div>

      <!-- Partners Section -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Sócios do Escritório</h3>

          <!-- Debug info -->
          <div class="alert alert-info mb-4">
            <div>
              <div class="text-sm">
                <strong>Debug:</strong>
                {lawyers.length} advogados carregados
                {#if lawyers.length > 0}
                  <div class="mt-2">
                    {#each lawyers as lawyer, i}
                      <div class="text-xs">
                        {i + 1}: ID={lawyer.id}, Nome={lawyer.attributes?.name}
                        {lawyer.attributes?.last_name}
                      </div>
                    {/each}
                  </div>
                {/if}
              </div>
            </div>
          </div>

          {#each partners as partner, index (index)}
            <div class="border rounded-lg p-4 mb-4 bg-base-50">
              <div class="flex justify-between items-center mb-4">
                <h4 class="font-semibold text-base">Sócio {index + 1}</h4>
                {#if partners.length > 1}
                  <button class="btn btn-error btn-sm" on:click={() => removePartner(index)}>
                    🗑️
                  </button>
                {/if}
              </div>

              <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                <!-- Lawyer Selection -->
                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Advogado</span>
                  </label>
                  <select
                    class="select select-bordered w-full"
                    value={partner.lawyer_id}
                    on:change={(e) => {
                      console.log('Lawyer selection changed:', e.target.value);
                      const selectedLawyer = lawyers.find((l) => l.id === e.target.value);
                      console.log('Found lawyer:', selectedLawyer);
                      if (selectedLawyer) {
                        handlePartnerChange(index, 'lawyer_id', selectedLawyer);
                      }
                    }}
                  >
                    <option value="">Selecione o Advogado</option>
                    {#each lawyers.filter((lawyer) => !partners.some((p, i) => i !== index && p.lawyer_id === lawyer.id)) as lawyer}
                      <option value={lawyer.id}>
                        {lawyer.attributes?.name || 'Nome não encontrado'}
                        {lawyer.attributes?.last_name || 'Sobrenome não encontrado'}
                      </option>
                    {/each}
                  </select>
                </div>

                <!-- Partnership Type -->
                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Função</span>
                  </label>
                  <select
                    class="select select-bordered w-full"
                    bind:value={partner.partnership_type}
                    on:change={(e) =>
                      handlePartnerChange(index, 'partnership_type', e.target.value)}
                  >
                    <option value="">Selecione a Função</option>
                    {#each partnershipTypes as type}
                      <option value={type.value}>{type.label}</option>
                    {/each}
                  </select>
                </div>

                <!-- Ownership Percentage -->
                <div class="form-control flex flex-col">
                  <label class="label pb-1">
                    <span class="label-text">Participação (%)</span>
                  </label>
                  <div class="flex items-center gap-2">
                    <input
                      type="number"
                      class="input input-bordered w-20"
                      min="0"
                      max="100"
                      step="0.01"
                      bind:value={partner.ownership_percentage}
                      on:input={(e) =>
                        handlePartnerChange(index, 'ownership_percentage', e.target.value)}
                    />
                    <span>%</span>
                  </div>

                  <!-- Range slider for 2 partners -->
                  {#if partners.length === 2}
                    <div class="mt-2">
                      <label class="label">
                        <span class="label-text-alt">Ajuste proporcional</span>
                      </label>
                      <input
                        type="range"
                        class="range range-sm"
                        min="0"
                        max="100"
                        bind:value={partner.ownership_percentage}
                        on:input={(e) =>
                          handlePartnerChange(index, 'ownership_percentage', e.target.value)}
                      />
                    </div>
                  {/if}
                </div>
              </div>

              <!-- Managing Partner checkbox for "socio" -->
              {#if partner.partnership_type === 'socio'}
                <div class="form-control">
                  <label class="label cursor-pointer justify-start gap-2">
                    <input
                      type="checkbox"
                      class="checkbox checkbox-primary"
                      bind:checked={partner.is_managing_partner}
                      on:change={(e) =>
                        handlePartnerChange(index, 'is_managing_partner', e.target.checked)}
                    />
                    <span class="label-text">Sócio Administrador</span>
                  </label>
                </div>
              {/if}
            </div>
          {/each}

          <!-- Percentage warning -->
          {#if isOverPercentage()}
            <div class="alert alert-warning">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="stroke-current shrink-0 h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"
                />
              </svg>
              <span
                >O total de participação ({getTotalPercentage()}%) excede 100%. Ajuste as
                porcentagens para que somem no máximo 100%.</span
              >
            </div>
          {/if}

          <!-- Add Partner Button -->
          <div class="flex flex-col items-start">
            <button
              class="btn btn-outline"
              disabled={lawyers.length <= partners.length}
              on:click={addPartner}
            >
              ➕ Adicionar Sócio
            </button>

            {#if lawyers.length <= partners.length}
              <p class="text-sm text-gray-500 mt-2">
                Cadastre mais advogados para alterar seu quadro societário.
                <a href="#" class="link link-primary">Cadastrar novo usuário</a>
              </p>
            {/if}
          </div>
        </div>
      </div>

      <!-- Profit Distribution Section -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Distribuição de Lucros</h3>

          <div class="form-control flex flex-col mb-4">
            <label class="label pb-1">
              <span class="label-text">Como será a distribuição de lucros?</span>
            </label>

            <div class="flex gap-6">
              <label class="label cursor-pointer">
                <input
                  type="radio"
                  class="radio radio-primary"
                  bind:group={profitDistribution}
                  value="proportional"
                />
                <span class="label-text ml-2">Proporcional à participação</span>
              </label>

              <label class="label cursor-pointer">
                <input
                  type="radio"
                  class="radio radio-primary"
                  bind:group={profitDistribution}
                  value="disproportional"
                />
                <span class="label-text ml-2">Desproporcional</span>
              </label>
            </div>
          </div>

          {#if profitDistribution === 'proportional'}
            <div class="alert alert-info">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="stroke-current shrink-0 h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <div>
                <div class="font-bold">
                  Os lucros serão distribuídos proporcionalmente à participação de cada sócio.
                </div>
                <div class="text-sm mt-2">
                  <strong>Distribuição atual:</strong>
                  {#each partners as partner}
                    {#if partner.lawyer_name}
                      <div class="flex justify-between">
                        <span>{partner.lawyer_name}:</span>
                        <span class="font-bold">{partner.ownership_percentage}%</span>
                      </div>
                    {/if}
                  {/each}
                </div>
              </div>
            </div>
          {:else}
            <div class="alert alert-warning">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="stroke-current shrink-0 h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"
                />
              </svg>
              <span
                >Distribuição desproporcional será definida de acordo com cada trabalho/processo.</span
              >
            </div>
          {/if}
        </div>
      </div>

      <!-- Social Contract Section -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Contrato Social</h3>

          <div class="form-control">
            <label class="label cursor-pointer justify-start gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-primary"
                bind:checked={createSocialContract}
              />
              <span class="label-text">Sim, desejo criar um contrato social</span>
            </label>
          </div>

          {#if createSocialContract}
            <div class="alert alert-info mt-4">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="stroke-current shrink-0 h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <span>A lógica para criação do contrato social será implementada posteriormente.</span
              >
            </div>
          {/if}
        </div>
      </div>

      <!-- Pro-Labore Section -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Pro-Labore</h3>

          <div class="form-control mb-4">
            <label class="label cursor-pointer justify-start gap-2">
              <input
                type="checkbox"
                class="checkbox checkbox-primary"
                bind:checked={partnersWithProLabore}
              />
              <span class="label-text">Sim, os sócios retirarão pro-labore</span>
            </label>
          </div>

          {#if partnersWithProLabore}
            <div class="alert alert-info mb-4">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="stroke-current shrink-0 h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
                />
              </svg>
              <div>
                <div class="font-bold">Faixas de Valor:</div>
                <div class="text-sm mt-1">
                  <div>
                    • Salário Mínimo: R$ {minimumWage.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2
                    })}
                  </div>
                  <div>
                    • Teto INSS: R$ {inssCeiling.toLocaleString('pt-BR', {
                      minimumFractionDigits: 2
                    })}
                  </div>
                  <div class="mt-1">Valor R$ 0,00 = sócio não receberá pro-labore</div>
                </div>
              </div>
            </div>

            <div class="space-y-4">
              <h4 class="font-semibold">Valores de Pro-Labore por Sócio:</h4>

              {#each partners as partner, index}
                {#if partner.lawyer_name}
                  <div class="border rounded p-4">
                    <div class="flex justify-between items-center mb-2">
                      <span class="font-bold">{partner.lawyer_name}</span>
                      <span class="text-sm text-gray-500">
                        {partnershipTypes.find((t) => t.value === partner.partnership_type)
                          ?.label || partner.partnership_type}
                      </span>
                    </div>

                    <div class="flex items-center gap-2">
                      <span class="w-20">Pro-Labore:</span>
                      <span class="text-lg">R$</span>
                      <input
                        type="number"
                        class="input input-bordered input-sm w-32"
                        min="0"
                        step="0.01"
                        bind:value={partner.pro_labore_amount}
                        on:input={(e) =>
                          handlePartnerChange(index, 'pro_labore_amount', e.target.value)}
                        class:input-error={proLaboreErrors[index]}
                      />
                    </div>

                    {#if proLaboreErrors[index]}
                      <div class="text-error text-sm mt-1">
                        ⚠️ {proLaboreErrors[index]}
                      </div>
                    {:else if partner.pro_labore_amount === 0}
                      <div class="text-success text-sm mt-1">
                        ✓ Este sócio não receberá pro-labore
                      </div>
                    {:else if partner.pro_labore_amount > 0}
                      <div class="text-success text-sm mt-1">✓ Valor válido</div>
                    {/if}
                  </div>
                {/if}
              {/each}

              {#if partners.filter((p) => p.lawyer_name).length === 0}
                <div class="alert alert-warning">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="stroke-current shrink-0 h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z"
                    />
                  </svg>
                  <span>Adicione e selecione sócios para definir os valores de pro-labore.</span>
                </div>
              {/if}
            </div>
          {/if}
        </div>
      </div>

      <!-- File Attachments -->
      <div class="card bg-base-100 shadow">
        <div class="card-body">
          <h3 class="card-title text-lg font-semibold mb-4">Anexos</h3>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Logo -->
            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Logo do Escritório</span>
              </label>
              <input
                type="file"
                class="file-input file-input-bordered w-full"
                accept="image/*"
                on:change={handleLogoChange}
              />
              {#if logoPreview}
                <div class="mt-2">
                  <img
                    src={logoPreview}
                    alt="Preview do logo"
                    class="w-24 h-24 object-cover rounded"
                  />
                </div>
              {/if}
              <div class="label">
                <span class="label-text-alt">Formatos aceitos: JPG, PNG, GIF, WEBP</span>
              </div>
            </div>

            <!-- Social Contracts -->
            <div class="form-control flex flex-col">
              <label class="label pb-1">
                <span class="label-text">Contratos Sociais</span>
              </label>
              <input
                type="file"
                class="file-input file-input-bordered w-full"
                accept=".pdf,.docx"
                multiple
                on:change={handleContractsChange}
              />
              {#if contractFiles.length > 0}
                <div class="mt-2 space-y-1">
                  {#each contractFiles as file}
                    <div class="badge badge-outline">{file.name}</div>
                  {/each}
                </div>
              {/if}
              <div class="label">
                <span class="label-text-alt">Formatos aceitos: PDF, DOCX</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer -->
    <div class="sticky bottom-0 bg-white border-t border-gray-200 p-6 flex justify-end gap-4">
      <button class="btn btn-ghost" on:click={handleClose} disabled={loading}> Cancelar </button>
      <button class="btn btn-primary" on:click={handleSubmit} disabled={loading}>
        {#if loading}
          <span class="loading loading-spinner loading-sm"></span>
        {/if}
        {isEdit ? 'Atualizar' : 'Criar'} Escritório
      </button>
    </div>
  </div>
</div>
