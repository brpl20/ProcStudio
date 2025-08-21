<script lang="ts">
  import api from '../api/index';

  export let isOpen = false;
  export let userData: any = {};
  export let missingFields: string[] = [];
  export let onComplete: (result: any) => void = () => {};
  export let onClose: () => void = () => {};

  const formData = {
    cpf: '',
    rg: '',
    gender: '',
    civil_status: '',
    nationality: 'brazilian',
    birth: '',
    phone: ''
  };

  let loading = false;
  let message = '';
  let isSuccess = false;

  // Opções para os selects
  const genderOptions = [
    { value: 'male', label: 'Masculino' },
    { value: 'female', label: 'Feminino' }
  ];

  const civilStatusOptions = [
    { value: 'single', labelMale: 'Solteiro', labelFemale: 'Solteira' },
    { value: 'married', labelMale: 'Casado', labelFemale: 'Casada' },
    { value: 'divorced', labelMale: 'Divorciado', labelFemale: 'Divorciada' },
    { value: 'widower', labelMale: 'Viúvo', labelFemale: 'Viúva' },
    { value: 'union', labelMale: 'União Estável', labelFemale: 'União Estável' }
  ];

  const nationalityOptions = [
    { value: 'brazilian', label: 'Brasileira' },
    { value: 'foreigner', label: 'Estrangeira' }
  ];

  function isFieldRequired(fieldName: string): boolean {
    return missingFields.includes(fieldName);
  }

  function formatPhoneInput(event: Event) {
    const input = event.target as HTMLInputElement;
    let value = input.value.replace(/\D/g, ''); // Remove tudo que não é dígito

    if (value.length <= 11) {
      // Formato: (XX) XXXXX-XXXX para celular ou (XX) XXXX-XXXX para fixo
      if (value.length >= 11) {
        value = value.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3');
      } else if (value.length >= 10) {
        value = value.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
      } else if (value.length >= 6) {
        value = value.replace(/(\d{2})(\d{4})(\d*)/, '($1) $2-$3');
      } else if (value.length >= 2) {
        value = value.replace(/(\d{2})(\d*)/, '($1) $2');
      }
    }

    formData.phone = value;
  }

  function validateBrazilianPhone(phone: string): boolean {
    // Aceita formato (XX) XXXXX-XXXX ou (XX) XXXX-XXXX
    const phonePattern = /^\(\d{2}\)\s\d{4,5}-\d{4}$/;
    return phonePattern.test(phone);
  }

  function getCivilStatusLabel(option: any): string {
    // Prioridade: gender do userData (do backend) > gender do form
    const currentGender = userData?.gender || formData.gender;

    if (currentGender === 'female') {
      return option.labelFemale;
    } else {
      // Default para masculino se não tiver gender definido ou se for 'male'
      return option.labelMale;
    }
  }

  function closeModal() {
    if (!loading) {
      onClose();
    }
  }

  function handleBackdropClick(event: MouseEvent) {
    if (event.target === event.currentTarget) {
      closeModal();
    }
  }

  async function handleSubmit() {
    // Verifica se todos os campos obrigatórios foram preenchidos
    const requiredFields = missingFields.filter((field) => {
      return (
        !formData[field as keyof typeof formData] ||
        formData[field as keyof typeof formData].trim() === ''
      );
    });

    if (requiredFields.length > 0) {
      message = `Campos obrigatórios não preenchidos: ${requiredFields.join(', ')}`;
      isSuccess = false;
      return;
    }

    // Validação básica do CPF (apenas formato)
    if (isFieldRequired('cpf') && formData.cpf) {
      const cpfPattern = /^\d{3}\.\d{3}\.\d{3}-\d{2}$|^\d{11}$/;
      if (!cpfPattern.test(formData.cpf)) {
        message = 'CPF deve estar no formato: 000.000.000-00 ou 00000000000';
        isSuccess = false;
        return;
      }
    }

    // Validação da data de nascimento
    if (isFieldRequired('birth') && formData.birth) {
      const birthDate = new Date(formData.birth);
      const today = new Date();
      if (birthDate >= today) {
        message = 'Data de nascimento deve ser anterior à data atual';
        isSuccess = false;
        return;
      }
    }

    // Validação do telefone brasileiro
    if (isFieldRequired('phone') && formData.phone) {
      if (!validateBrazilianPhone(formData.phone)) {
        message = 'Telefone deve estar no formato: (XX) XXXXX-XXXX ou (XX) XXXX-XXXX';
        isSuccess = false;
        return;
      }
    }

    loading = true;
    message = '';

    try {
      // Prepara os dados apenas com os campos que foram preenchidos
      const dataToSend: any = {};
      Object.keys(formData).forEach((key) => {
        const value = formData[key as keyof typeof formData];
        if (value && value.trim() !== '') {
          dataToSend[key] = value.trim();
        }
      });

      const result = await api.auth.completeProfile(dataToSend);
      message = 'Perfil completado com sucesso!';
      isSuccess = true;

      // Aguarda um pouco para mostrar a mensagem de sucesso
      setTimeout(() => {
        onComplete(result);
      }, 1500);
    } catch (error: any) {
      message = error.message;
      isSuccess = false;
    } finally {
      loading = false;
    }
  }
</script>

<!-- Modal Backdrop -->
{#if isOpen}
  <div
    class="modal modal-open"
    on:click={handleBackdropClick}
    role="button"
    tabindex="0"
    on:keydown={(e) => e.key === 'Escape' && closeModal()}
  >
    <div class="modal-box max-w-4xl max-h-[90vh] overflow-y-auto" role="dialog" aria-modal="true">
      <div class="flex justify-between items-center mb-6">
        <h2 class="text-2xl font-bold text-base-content">Complete seu Perfil</h2>
        <button
          type="button"
          class="btn btn-circle btn-ghost"
          on:click={closeModal}
          disabled={loading}
        >
          ✕
        </button>
      </div>

      <div>
        <div class="alert alert-info mb-6">
          <div>
            <div class="font-semibold">Informações do Usuário</div>
            <p class="text-sm mt-2">
              <strong>Nome:</strong>
              {userData.name}
              {userData.last_name}
            </p>
            <p class="text-sm"><strong>OAB:</strong> {userData.oab}</p>
            <p class="text-sm"><strong>Função:</strong> {userData.role}</p>
          </div>
        </div>

        <form on:submit|preventDefault={handleSubmit}>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            {#if isFieldRequired('cpf')}
              <div class="form-control">
                <label class="label" for="cpf">
                  <span class="label-text font-semibold">CPF *</span>
                </label>
                <input
                  type="text"
                  id="cpf"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.cpf}
                  placeholder="000.000.000-00"
                  required
                  disabled={loading}
                />
              </div>
            {/if}

            {#if isFieldRequired('rg')}
              <div class="form-control">
                <label class="label" for="rg">
                  <span class="label-text font-semibold">RG *</span>
                </label>
                <input
                  type="text"
                  id="rg"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.rg}
                  placeholder="00.000.000-0"
                  required
                  disabled={loading}
                />
              </div>
            {/if}

            {#if isFieldRequired('gender')}
              <div class="form-control">
                <label class="label" for="gender">
                  <span class="label-text font-semibold">Gênero *</span>
                </label>
                <select
                  id="gender"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.gender}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each genderOptions as option}
                    <option value={option.value}>{option.label}</option>
                  {/each}
                </select>
              </div>
            {/if}

            {#if isFieldRequired('civil_status')}
              <div class="form-control">
                <label class="label" for="civil_status">
                  <span class="label-text font-semibold">Estado Civil *</span>
                </label>
                <select
                  id="civil_status"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.civil_status}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each civilStatusOptions as option}
                    <option value={option.value}>{getCivilStatusLabel(option)}</option>
                  {/each}
                </select>
              </div>
            {/if}

            {#if isFieldRequired('nationality')}
              <div class="form-control">
                <label class="label" for="nationality">
                  <span class="label-text font-semibold">Nacionalidade *</span>
                </label>
                <select
                  id="nationality"
                  class="select select-bordered"
                  class:select-disabled={loading}
                  bind:value={formData.nationality}
                  required
                  disabled={loading}
                >
                  <option value="">Selecione...</option>
                  {#each nationalityOptions as option}
                    <option value={option.value}>{option.label}</option>
                  {/each}
                </select>
              </div>
            {/if}

            {#if isFieldRequired('birth')}
              <div class="form-control">
                <label class="label" for="birth">
                  <span class="label-text font-semibold">Data de Nascimento *</span>
                </label>
                <input
                  type="date"
                  id="birth"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.birth}
                  required
                  disabled={loading}
                />
              </div>
            {/if}

            {#if isFieldRequired('phone')}
              <div class="form-control">
                <label class="label" for="phone">
                  <span class="label-text font-semibold">Telefone *</span>
                </label>
                <input
                  type="tel"
                  id="phone"
                  class="input input-bordered"
                  class:input-disabled={loading}
                  bind:value={formData.phone}
                  placeholder="(45) 98405-5504"
                  required
                  disabled={loading}
                  on:input={formatPhoneInput}
                  maxlength="15"
                />
              </div>
            {/if}
          </div>

          {#if message}
            <div class="alert mt-4" class:alert-success={isSuccess} class:alert-error={!isSuccess}>
              <span>{message}</span>
            </div>
          {/if}

          <div class="modal-action">
            <button type="button" class="btn btn-outline" on:click={closeModal} disabled={loading}>
              Cancelar
            </button>
            <button type="submit" class="btn btn-primary" class:loading disabled={loading}>
              {loading ? 'Salvando...' : 'Completar Perfil'}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
{/if}
