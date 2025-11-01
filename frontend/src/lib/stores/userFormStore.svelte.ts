import { writable } from 'svelte/store';
import api from '../api'; // Usando sua estrutura de API existente

// Interfaces
export interface UserFormData {
  basicInfo: { name: string; last_name: string; role: string; status: string; oab: string; };
  personalInfo: { cpf: string; rg: string; gender: string; civil_status: string; nationality: string; birth: string; mother_name: string; };
  contactInfo: { phone: string; address: { street: string; number: string; complement: string; neighborhood: string; city: string; state: string; zip_code: string; }; };
  credentials: { email: string; password?: string; password_confirmation?: string; };
  // Adicione outros campos como bank_account se necessário
}

export interface UserFormState {
  mode: 'create' | 'edit' | null;
  formData: UserFormData;
  loading: boolean;
  error: string | null;
  success: boolean;
  editingUserId: number | null; // ID do usuário em edição
  editingUserProfileId: number | null; // ID do perfil do usuário em edição
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
      const formData: UserFormData = {
        basicInfo: { name: user.attributes?.name || '', last_name: user.attributes?.last_name || '', role: user.attributes?.role || 'lawyer', status: user.attributes?.status || 'active', oab: user.attributes?.oab || '' },
        personalInfo: { cpf: user.attributes?.cpf || '', rg: user.attributes?.rg || '', gender: user.attributes?.gender || '', civil_status: user.attributes?.civil_status || '', nationality: user.attributes?.nationality || 'brazilian', birth: user.attributes?.birth || '', mother_name: user.attributes?.mother_name || '' },
        contactInfo: { phone: user.attributes?.phones?.[0]?.phone_number || '', address: { street: user.attributes?.addresses?.[0]?.street || '', number: user.attributes?.addresses?.[0]?.number || '', complement: user.attributes?.addresses?.[0]?.complement || '', neighborhood: user.attributes?.addresses?.[0]?.neighborhood || '', city: user.attributes?.addresses?.[0]?.city || '', state: user.attributes?.addresses?.[0]?.state || '', zip_code: user.attributes?.addresses?.[0]?.zip_code || '' } },
        credentials: { email: user.attributes?.access_email || '', password: '', password_confirmation: '' },
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

        // ====================================================================
        // AQUI ESTÁ A MUDANÇA
        // ====================================================================

        if (mode === 'create') {
          const payload = {
            user_profile: {
              // Campos que pertencem diretamente ao UserProfile
              name: formData.basicInfo.name,
              last_name: formData.basicInfo.last_name,
              role: formData.basicInfo.role,
              oab: formData.basicInfo.oab,
              // Campos do personalInfo
              cpf: formData.personalInfo.cpf,
              rg: formData.personalInfo.rg,
              gender: formData.personalInfo.gender,
              civil_status: formData.personalInfo.civil_status,
              nationality: formData.personalInfo.nationality,
              birth: formData.personalInfo.birth,
              mother_name: formData.personalInfo.mother_name,

              // Atributos aninhados para o modelo User
              user_attributes: {
                email: formData.credentials.email,
                password: formData.credentials.password,
                password_confirmation: formData.credentials.password_confirmation,
                status: formData.basicInfo.status // <-- O 'status' está no lugar CORRETO
              },

              // Atributos aninhados para Phones e Addresses
              phones_attributes: formData.contactInfo.phone ? [{ phone_number: formData.contactInfo.phone }] : [],
              addresses_attributes: formData.contactInfo.address.street ? [formData.contactInfo.address] : []
            }
          };
          response = await api.users.createUserProfile(payload);

        } else if (mode === 'edit') {
          const payload = {
            user_profile: {
              id: editingUserProfileId,
              // Campos do perfil que podem ser editados
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
              
              // Atributos do usuário para edição
              user_attributes: {
                id: editingUserId,
                status: formData.basicInfo.status // <-- 'status' CORRETO para edição
                // Nota: Não enviamos email/senha na edição, a menos que queiramos mudá-los.
                // Se a senha for alterada, os campos 'password' e 'password_confirmation' devem ser adicionados aqui.
              },
              
              // Adicionar aqui a lógica para editar phones e addresses se necessário
              phones_attributes: formData.contactInfo.phone ? [{ phone_number: formData.contactInfo.phone }] : [],
              addresses_attributes: formData.contactInfo.address.street ? [formData.contactInfo.address] : []
            }
          };
          response = await api.users.updateUserProfile(editingUserId, payload);
        }

        // ====================================================================
        // FIM DA MUDANÇA
        // ====================================================================

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