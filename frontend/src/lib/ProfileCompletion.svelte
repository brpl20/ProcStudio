<script lang="ts">
  import { api } from './api';

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
    nationality: 'Brasileira',
    birth: '',
    phone: ''
  };

  let loading = false;
  let message = '';
  let isSuccess = false;

  // Opções para os selects
  const genderOptions = [
    { value: 'M', label: 'Masculino' },
    { value: 'F', label: 'Feminino' },
    { value: 'O', label: 'Outro' }
  ];

  const civilStatusOptions = [
    { value: 'solteiro', label: 'Solteiro(a)' },
    { value: 'casado', label: 'Casado(a)' },
    { value: 'divorciado', label: 'Divorciado(a)' },
    { value: 'viuvo', label: 'Viúvo(a)' },
    { value: 'uniao_estavel', label: 'União Estável' }
  ];

  function isFieldRequired(fieldName: string): boolean {
    return missingFields.includes(fieldName);
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

      const result = await api.completeProfile(dataToSend);
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
    class="modal-backdrop"
    on:click={handleBackdropClick}
    role="button"
    tabindex="0"
    on:keydown={(e) => e.key === 'Escape' && closeModal()}
  >
    <div class="modal-content" role="dialog" aria-modal="true">
      <div class="modal-header">
        <h2>Complete seu Perfil</h2>
        <button type="button" class="close-button" on:click={closeModal} disabled={loading}>
          ×
        </button>
      </div>

      <div class="modal-body">
        <div class="user-info">
          <p>
            <strong>Nome:</strong>
            {userData.name}
            {userData.last_name}
          </p>
          <p><strong>OAB:</strong> {userData.oab}</p>
          <p><strong>Função:</strong> {userData.role}</p>
        </div>

        <form on:submit|preventDefault={handleSubmit}>
          {#if isFieldRequired('cpf')}
            <div class="form-group">
              <label for="cpf">CPF: *</label>
              <input
                type="text"
                id="cpf"
                bind:value={formData.cpf}
                placeholder="000.000.000-00"
                required
                disabled={loading}
              />
            </div>
          {/if}

          {#if isFieldRequired('rg')}
            <div class="form-group">
              <label for="rg">RG: *</label>
              <input
                type="text"
                id="rg"
                bind:value={formData.rg}
                placeholder="00.000.000-0"
                required
                disabled={loading}
              />
            </div>
          {/if}

          {#if isFieldRequired('gender')}
            <div class="form-group">
              <label for="gender">Gênero: *</label>
              <select id="gender" bind:value={formData.gender} required disabled={loading}>
                <option value="">Selecione...</option>
                {#each genderOptions as option}
                  <option value={option.value}>{option.label}</option>
                {/each}
              </select>
            </div>
          {/if}

          {#if isFieldRequired('civil_status')}
            <div class="form-group">
              <label for="civil_status">Estado Civil: *</label>
              <select
                id="civil_status"
                bind:value={formData.civil_status}
                required
                disabled={loading}
              >
                <option value="">Selecione...</option>
                {#each civilStatusOptions as option}
                  <option value={option.value}>{option.label}</option>
                {/each}
              </select>
            </div>
          {/if}

          {#if isFieldRequired('nationality')}
            <div class="form-group">
              <label for="nationality">Nacionalidade: *</label>
              <input
                type="text"
                id="nationality"
                bind:value={formData.nationality}
                required
                disabled={loading}
              />
            </div>
          {/if}

          {#if isFieldRequired('birth')}
            <div class="form-group">
              <label for="birth">Data de Nascimento: *</label>
              <input
                type="date"
                id="birth"
                bind:value={formData.birth}
                required
                disabled={loading}
              />
            </div>
          {/if}

          {#if isFieldRequired('phone')}
            <div class="form-group">
              <label for="phone">Telefone: *</label>
              <input
                type="tel"
                id="phone"
                bind:value={formData.phone}
                placeholder="(00) 00000-0000"
                required
                disabled={loading}
              />
            </div>
          {/if}

          {#if message}
            <div class="message" class:success={isSuccess} class:error={!isSuccess}>
              {message}
            </div>
          {/if}

          <div class="form-actions">
            <button type="button" class="cancel-button" on:click={closeModal} disabled={loading}>
              Cancelar
            </button>
            <button type="submit" class="submit-button" disabled={loading}>
              {loading ? 'Salvando...' : 'Completar Perfil'}
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
{/if}

<style>
  .modal-backdrop {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 1000;
  }

  .modal-content {
    background: white;
    border-radius: 8px;
    width: 90%;
    max-width: 600px;
    max-height: 90vh;
    overflow-y: auto;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  }

  .modal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px;
    border-bottom: 1px solid #eee;
  }

  .modal-header h2 {
    margin: 0;
    font-size: 1.5rem;
  }

  .close-button {
    background: none;
    border: none;
    font-size: 2rem;
    cursor: pointer;
    color: #666;
    padding: 0;
    width: 30px;
    height: 30px;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .close-button:hover {
    color: #000;
  }

  .modal-body {
    padding: 20px;
  }

  .user-info {
    background-color: #f5f5f5;
    padding: 15px;
    border-radius: 4px;
    margin-bottom: 20px;
  }

  .user-info p {
    margin: 5px 0;
  }

  .form-group {
    margin-bottom: 15px;
  }

  .form-group label {
    display: block;
    margin-bottom: 5px;
    font-weight: bold;
  }

  .form-group input,
  .form-group select {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #ddd;
    border-radius: 4px;
    font-size: 14px;
    box-sizing: border-box;
  }

  .form-group input:focus,
  .form-group select:focus {
    outline: none;
    border-color: #007bff;
  }

  .form-group input:disabled,
  .form-group select:disabled {
    background-color: #f5f5f5;
    cursor: not-allowed;
  }

  .message {
    padding: 10px;
    border-radius: 4px;
    margin-bottom: 15px;
    text-align: center;
  }

  .message.success {
    background-color: #d4edda;
    color: #155724;
    border: 1px solid #c3e6cb;
  }

  .message.error {
    background-color: #f8d7da;
    color: #721c24;
    border: 1px solid #f5c6cb;
  }

  .form-actions {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
    margin-top: 20px;
  }

  .cancel-button,
  .submit-button {
    padding: 10px 20px;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  }

  .cancel-button {
    background-color: #6c757d;
    color: white;
  }

  .cancel-button:hover:not(:disabled) {
    background-color: #5a6268;
  }

  .submit-button {
    background-color: #007bff;
    color: white;
  }

  .submit-button:hover:not(:disabled) {
    background-color: #0056b3;
  }

  .cancel-button:disabled,
  .submit-button:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
</style>
