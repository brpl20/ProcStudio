import api from '../api';

export interface UserFormData {
  basicInfo: { name: string; last_name: string; social_name?: string; role: string; status: string; oab: string; };
  personalInfo: { cpf: string; rg: string; gender: string; civil_status: string; nationality: string; birth: string; mother_name: string; };
  contactInfo: { phone: string; address: { street: string; number: string; complement: string; neighborhood: string; city: string; state: string; zip_code: string; }; };
  credentials: { email: string; password?: string; password_confirmation?: string; };
  bankAccount: {
    id?: number;
    bank_name: string;
    bank_number: string;
    type_account: string;
    agency: string;
    account: string;
    operation: string;
    pix: string;
  };
}

export interface UserFormState {
  mode: 'create' | 'edit' | 'invite' | null;
  formData: UserFormData;
  loading: boolean;
  error: string | null;
  success: boolean;
  editingUserId: number | null;
  editingUserProfileId: number | null;
  // --- NOVAS PROPRIEDADES PARA MÚLTIPLOS CONVITES ---
  inviteEmails: string[];
}

// Estado Inicial
const getInitialFormData = (): UserFormData => ({
  basicInfo: { name: '', last_name: '', social_name: '', role: 'lawyer', status: 'active', oab: '' },
  personalInfo: { cpf: '', rg: '', gender: '', civil_status: 'single', nationality: 'brazilian', birth: '', mother_name: '' },
  contactInfo: { phone: '', address: { street: '', number: '', complement: '', neighborhood: '', city: '', state: '', zip_code: '' } },
  credentials: { email: '', password: '', password_confirmation: '' },
  bankAccount: { bank_name: '', bank_number: '', type_account: '', agency: '', account: '', operation: '', pix: '' },
});

// Create a Svelte 5 rune-based store
class UserFormStore {
  mode = $state<'create' | 'edit' | 'invite' | null>(null);
  open = $state<boolean>(false);
  formData = $state<UserFormData>(getInitialFormData());
  loading = $state(false);
  error = $state<string | null>(null);
  success = $state(false);
  editingUserId = $state<number | null>(null);
  editingUserProfileId = $state<number | null>(null);

  // --- NOVO ESTADO PARA OS E-MAILS DE CONVITE ---
  inviteEmails = $state<string[]>([]);

  // --- NOVAS FUNÇÕES PARA GERENCIAR A LISTA DE E-MAILS ---
  addEmail(email: string) {
    this.error = null;
    const trimmedEmail = email.trim();

    if (!trimmedEmail) return;

    // Validação de formato de e-mail simples
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(trimmedEmail)) {
      this.error = `O e-mail "${trimmedEmail}" parece ser inválido.`;
      return;
    }

    // Validação de e-mail duplicado
    if (this.inviteEmails.includes(trimmedEmail)) {
      this.error = `O e-mail "${trimmedEmail}" já foi adicionado à lista.`;
      return;
    }

    this.inviteEmails.push(trimmedEmail);
  }

  removeEmail(index: number) {
    this.inviteEmails.splice(index, 1);
  }

  startCreate() {
    this.close();
    this.mode = 'create';
    this.open = true
  }

  startEdit(user: any) {
    const bankAccount = user.attributes?.bank_accounts?.[0] || {};

    this.formData = {
      basicInfo: {
        name: user.attributes?.name || '',
        last_name: user.attributes?.last_name || '',
        social_name: user.attributes?.social_name || '',
        role: user.attributes?.role || 'lawyer',
        status: user.attributes?.status || 'active',
        oab: user.attributes?.oab || ''
      },
      personalInfo: {
        cpf: user.attributes?.cpf || '',
        rg: user.attributes?.rg || '',
        gender: user.attributes?.gender || '',
        civil_status: user.attributes?.civil_status || '',
        nationality: user.attributes?.nationality || 'brazilian',
        birth: user.attributes?.birth || '',
        mother_name: user.attributes?.mother_name || ''
      },
      contactInfo: {
        phone: user.attributes?.phones?.[0]?.phone_number || '',
        address: {
          street: user.attributes?.addresses?.[0]?.street || '',
          number: user.attributes?.addresses?.[0]?.number || '',
          complement: user.attributes?.addresses?.[0]?.complement || '',
          neighborhood: user.attributes?.addresses?.[0]?.neighborhood || '',
          city: user.attributes?.addresses?.[0]?.city || '',
          state: user.attributes?.addresses?.[0]?.state || '',
          zip_code: user.attributes?.addresses?.[0]?.zip_code || ''
        }
      },
      credentials: {
        email: user.attributes?.access_email || '',
        password: '',
        password_confirmation: ''
      },
      bankAccount: {
        id: bankAccount.id || undefined,
        bank_name: bankAccount.bank_name || '',
        bank_number: bankAccount.bank_number || '',
        type_account: bankAccount.account_type || '',
        agency: bankAccount.agency || '',
        account: bankAccount.account || '',
        operation: bankAccount.operation || '',
        pix: bankAccount.pix || '',
      },
    };

    this.mode = 'edit';
    this.open = true
    this.editingUserId = user.id;
    this.editingUserProfileId = user.attributes.user_profile_id;
    this.error = null;
    this.success = false;
  }

  startInvite() {
    this.close();
    this.mode = 'invite';
    this.open = true
  }

  close() {
    this.mode = null;
    this.open = false;
    this.formData = getInitialFormData();
    this.loading = false;
    this.error = null;
    this.success = false;
    this.editingUserId = null;
    this.editingUserProfileId = null;
    this.inviteEmails = []; // Limpa a lista de convites
  }

  reset() {
    this.close();
  }

  async submit() {
    this.loading = true;
    this.error = null;

    try {
      let response;
      const { mode, formData, editingUserId, editingUserProfileId, inviteEmails } = this;

      if (mode === 'invite') {
        // --- LÓGICA ATUALIZADA PARA MÚLTIPLOS CONVITES ---
        if (inviteEmails.length === 0) {
            throw new Error('Adicione pelo menos um e-mail para enviar convites.');
        }
        // Envia todos os convites em paralelo para melhor performance
        const invitePromises = inviteEmails.map(email => api.users.sendInvite(email));
        response = await Promise.all(invitePromises);

      } else {
        const { bankAccount } = formData;
        const hasBankData = bankAccount.bank_name && bankAccount.agency && bankAccount.account;

        const formattedBankData: any = {
          id: bankAccount.id,
          bank_name: bankAccount.bank_name,
          account_type: bankAccount.type_account,
          agency: bankAccount.agency,
          account: bankAccount.account,
          pix: bankAccount.pix,
        };

        if (bankAccount.operation) {
          formattedBankData.operation = bankAccount.operation;
        }

        if (mode === 'create') {
          const payload = {
            user_profile: {
              name: formData.basicInfo.name,
              last_name: formData.basicInfo.last_name,
              social_name: formData.basicInfo.social_name,
              role: formData.basicInfo.role,
              oab: formData.basicInfo.oab,
              cpf: formData.personalInfo.cpf,
              rg: formData.personalInfo.rg,
              gender: formData.personalInfo.gender,
              civil_status: formData.personalInfo.civil_status,
              nationality: formData.personalInfo.nationality,
              birth: formData.personalInfo.birth,
              mother_name: formData.personalInfo.mother_name,
              user_attributes: {
                email: formData.credentials.email,
                password: formData.credentials.password,
                password_confirmation: formData.credentials.password_confirmation,
                status: formData.basicInfo.status
              },
              phones_attributes: formData.contactInfo.phone ? [{ phone_number: formData.contactInfo.phone }] : [],
              addresses_attributes: formData.contactInfo.address.street ? [{
                street: formData.contactInfo.address.street,
                number: formData.contactInfo.address.number,
                complement: formData.contactInfo.address.complement || '',
                neighborhood: formData.contactInfo.address.neighborhood || '',
                city: formData.contactInfo.address.city,
                state: formData.contactInfo.address.state,
                zip_code: formData.contactInfo.address.zip_code
              }] : [],
              bank_accounts_attributes: hasBankData ? [formattedBankData] : []
            }
          };
          response = await api.users.createUserProfile(payload);

        } else if (mode === 'edit') {
          const payload = {
            user_profile: {
              id: editingUserProfileId,
              name: formData.basicInfo.name,
              last_name: formData.basicInfo.last_name,
              social_name: formData.basicInfo.social_name,
              role: formData.basicInfo.role,
              oab: formData.basicInfo.oab,
              cpf: formData.personalInfo.cpf,
              rg: formData.personalInfo.rg,
              gender: formData.personalInfo.gender,
              civil_status: formData.personalInfo.civil_status,
              nationality: formData.personalInfo.nationality,
              birth: formData.personalInfo.birth,
              mother_name: formData.personalInfo.mother_name,
              user_attributes: {
                id: editingUserId,
                status: formData.basicInfo.status
              },
              phones_attributes: formData.contactInfo.phone ? [{ phone_number: formData.contactInfo.phone }] : [],
              addresses_attributes: formData.contactInfo.address.street ? [{
                street: formData.contactInfo.address.street,
                number: formData.contactInfo.address.number,
                complement: formData.contactInfo.address.complement || '',
                neighborhood: formData.contactInfo.address.neighborhood || '',
                city: formData.contactInfo.address.city,
                state: formData.contactInfo.address.state,
                zip_code: formData.contactInfo.address.zip_code
              }] : [],
              bank_accounts_attributes: hasBankData ? [formattedBankData] : []
            }
          };
          response = await api.users.updateUserProfile(editingUserProfileId, payload);
        }
      }

      // Se a resposta for um array (de Promise.all), verifica se todos os itens dentro são bem-sucedidos.
      const isSuccess = Array.isArray(response)
          ? response.every(res => res && res.success !== false)
          : response && response.success !== false;

      if (isSuccess) {
        this.loading = false;
        this.success = true;
        this.error = null;
      } else {
        throw new Error(response?.message || 'Ocorreu um erro desconhecido.');
      }
    } catch (err: any) {
      this.loading = false;
      this.success = false;
      this.error = err.message || 'Erro ao processar a solicitação.';
    }
  }
}

export const userFormStore = new UserFormStore();