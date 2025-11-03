import { writable } from 'svelte/store';
import api from '../api'; // Usando sua estrutura de API existente

// ====================== ADICIONADO: Placeholder para api.users.sendInvite ======================
// Em um ambiente real, esta função deve ser implementada em seu arquivo 'api.ts'
// e fazer uma chamada HTTP real para o endpoint de convite do seu backend.
if (!api.users.sendInvite) {
  api.users.sendInvite = async (email: string) => {
    console.log("Simulando envio de convite para o email:", email);
    // Simula um atraso de API e um retorno de sucesso
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve({ success: true, message: `Convite enviado para ${email} com sucesso!` });
      }, 500);
    });
  };
}
// ==============================================================================================

// Interfaces
export interface UserFormData {
  basicInfo: { name: string; last_name: string; role: string; status: string; oab: string; };
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
  mode: 'create' | 'edit' | 'invite' | null; // Adicionado 'invite'
  formData: UserFormData;
  loading: boolean;
  error: string | null;
  success: boolean;
  editingUserId: number | null;
  editingUserProfileId: number | null;
}

// Estado Inicial
export const initialState: UserFormState = {
  mode: null,
  loading: false,
  error: null,
  success: false,
  editingUserId: null,
  editingUserProfileId: null,
  formData: {
    basicInfo: { name: '', last_name: '', role: 'lawyer', status: 'active', oab: '' },
    personalInfo: { cpf: '', rg: '', gender: '', civil_status: 'single', nationality: 'brazilian', birth: '', mother_name: '' },
    contactInfo: { phone: '', address: { street: '', number: '', complement: '', neighborhood: '', city: '', state: '', zip_code: '' } },
    credentials: { email: '', password: '', password_confirmation: '' },
    bankAccount: { bank_name: '', bank_number: '', type_account: '', agency: '', account: '', operation: '', pix: '' },
  }
};

// Store
function createUnifiedUserFormStore() {
  const { subscribe, set, update } = writable<UserFormState>(initialState);

  const methods = {
    startCreate() {
      set({ ...initialState, mode: 'create' });
    },

    startEdit(user: any) {
      const bankAccount = user.attributes?.bank_account || {};

      const formData: UserFormData = {
        basicInfo: { name: user.attributes?.name || '', last_name: user.attributes?.last_name || '', role: user.attributes?.role || 'lawyer', status: user.attributes?.status || 'active', oab: user.attributes?.oab || '' },
        personalInfo: { cpf: user.attributes?.cpf || '', rg: user.attributes?.rg || '', gender: user.attributes?.gender || '', civil_status: user.attributes?.civil_status || '', nationality: user.attributes?.nationality || 'brazilian', birth: user.attributes?.birth || '', mother_name: user.attributes?.mother_name || '' },
        contactInfo: { phone: user.attributes?.phones?.[0]?.phone_number || '', address: { street: user.attributes?.addresses?.[0]?.street || '', number: user.attributes?.addresses?.[0]?.number || '', complement: user.attributes?.addresses?.[0]?.complement || '', neighborhood: user.attributes?.addresses?.[0]?.neighborhood || '', city: user.attributes?.addresses?.[0]?.city || '', state: user.attributes?.addresses?.[0]?.state || '', zip_code: user.attributes?.addresses?.[0]?.zip_code || '' } },
        credentials: { email: user.attributes?.access_email || '', password: '', password_confirmation: '' },
        bankAccount: {
          id: bankAccount.id || undefined,
          bank_name: bankAccount.bank_name || '',
          bank_number: bankAccount.bank_number || '',
          type_account: bankAccount.type_account || '',
          agency: bankAccount.agency || '',
          account: bankAccount.account || '',
          operation: bankAccount.operation || '',
          pix: bankAccount.pix || '',
        },
      };

      update(state => ({
        ...state,
        mode: 'edit',
        formData,
        editingUserId: user.id,
        editingUserProfileId: user.attributes.user_profile_id,
        error: null,
        success: false
      }));
    },

    // ====================== NOVO MÉTODO: startInvite ======================
    startInvite() {
      // Reseta para um estado inicial limpo, configurando apenas o modo 'invite'
      // e garantindo que apenas o campo de e-mail seja relevante para o formulário.
      set({
        ...initialState,
        mode: 'invite',
        formData: {
          ...initialState.formData,
          credentials: { email: '', password: '', password_confirmation: '' }, // Apenas e-mail é usado para convite
          // Limpa outros campos para garantir que o formulário de convite seja mínimo
          basicInfo: { ...initialState.formData.basicInfo, name: '', last_name: '', oab: '' },
          personalInfo: { ...initialState.formData.personalInfo, cpf: '', rg: '', gender: '', birth: '' },
          contactInfo: { ...initialState.formData.contactInfo, phone: '', address: { street: '', number: '', complement: '', neighborhood: '', city: '', state: '', zip_code: '' } },
          bankAccount: { ...initialState.formData.bankAccount, bank_name: '', bank_number: '', type_account: '', agency: '', account: '', operation: '', pix: '' }
        }
      });
    },
    // ======================================================================

    reset() {
      set(initialState);
    },

    async submit() {
      update(state => ({ ...state, loading: true, error: null }));
      let currentState!: UserFormState;
      update(state => { currentState = state; return state; });

      try {
        let response;
        const { mode, formData, editingUserId, editingUserProfileId } = currentState;
        
        // ====================== LÓGICA DE SUBMISSÃO PARA MODO 'invite' ======================
        if (mode === 'invite') {
          // A documentação sugere api.users.sendInvite(this.formData.email)
          response = await api.users.sendInvite(formData.credentials.email);
        } else {
        // ====================== LÓGICA EXISTENTE PARA 'create' / 'edit' ======================
          const bankData = formData.bankAccount;
          const hasBankData = bankData.bank_name && bankData.agency && bankData.account;

          if (mode === 'create') {
            const payload = {
              user_profile: {
                name: formData.basicInfo.name,
                last_name: formData.basicInfo.last_name,
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
                addresses_attributes: formData.contactInfo.address.street ? [formData.contactInfo.address] : [],
                bank_account_attributes: hasBankData ? bankData : undefined
              }
            };
            response = await api.users.createUserProfile(payload);

          } else if (mode === 'edit') {
            const payload = {
              user_profile: {
                id: editingUserProfileId,
                name: formData.basicInfo.name,
                last_name: formData.basicInfo.last_name,
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
                addresses_attributes: formData.contactInfo.address.street ? [formData.contactInfo.address] : [],
                bank_account_attributes: hasBankData ? bankData : undefined
              }
            };
            response = await api.users.updateUserProfile(editingUserId, payload);
          }
        } // Fim do if/else para modos de submissão


        if (response && response.success !== false) {
          update(state => ({ ...state, loading: false, success: true, error: null }));
        } else {
          throw new Error(response?.message || 'Ocorreu um erro desconhecido.');
        }
      } catch (err: any) {
        update(state => ({ ...state, loading: false, success: false, error: err.message }));
      }
    }
  };

  return { subscribe, ...methods };
}

export const userFormStore = createUnifiedUserFormStore();