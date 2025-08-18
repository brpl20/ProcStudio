const API_BASE_URL = 'http://localhost:3000/api/v1';
const DEBUG_MODE = true; // Ativar para logs detalhados

// ===== INTERFACES =====
interface RegisterResponse {
  success: boolean;
  message?: string;
  data?: any;
}

interface LoginResponse {
  success: boolean;
  token?: string;
  user?: any;
  message?: string;
  needs_profile_completion?: boolean;
  missing_fields?: string[];
  role?: string;
  name?: string;
  last_name?: string;
  oab?: string;
}

interface ProfileCompletionData {
  cpf?: string;
  rg?: string;
  gender?: string;
  civil_status?: string;
  nationality?: string;
  birth?: string;
  phone?: string;
}

interface ProfileCompletionResponse {
  success: boolean;
  message?: string;
  data?: any;
}

interface ProfileAdminData {
  id: string;
  type: string;
  attributes: {
    role: string;
    name: string;
    last_name: string;
    access_email: string;
    phones: any[];
    bank_accounts: any[];
    deleted: boolean;
    emails: any[];
  };
}

interface AdminData {
  id: string;
  type: string;
  attributes: {
    access_email: string;
    status: string;
    deleted: boolean;
  };
  relationships: {
    profile_admin: {
      data: {
        id: string;
        type: string;
      };
    };
  };
}

interface AdminsListResponse {
  data?: AdminData[];
  included?: ProfileAdminData[];
  message?: string;
}

// ===== TEAM INTERFACES =====
interface TeamData {
  id: string;
  type: string;
  attributes: {
    name: string;
    description?: string;
    status: string;
    created_at: string;
    updated_at: string;
    deleted: boolean;
  };
  relationships?: {
    admins?: {
      data: Array<{
        id: string;
        type: string;
      }>;
    };
  };
}

interface TeamResponse {
  data?: TeamData;
  included?: any[];
  message?: string;
}

interface MyTeamResponse {
  data?: TeamData;
  included?: any[];
  message?: string;
}

interface UpdateTeamData {
  name: string;
  description?: string;
}

interface UpdateTeamResponse {
  data?: TeamData;
  message?: string;
}

interface TeamMembersResponse {
  data?: any[];
  included?: any[];
  message?: string;
}

// ===== UTILITY FUNCTIONS =====
function logRequest(method: string, url: string, body?: any) {
  if (DEBUG_MODE) {
    console.log(`🔵 ${method} REQUEST:`, { url, body });
  }
}

function logResponse(method: string, response: Response, data: any) {
  if (DEBUG_MODE) {
    console.log(`🔵 ${method} RESPONSE:`, {
      status: response.status,
      ok: response.ok,
      data: data
    });
  }
}

async function handleApiResponse(response: Response, method: string) {
  const responseData = await response.json();
  logResponse(method, response, responseData);

  if (!response.ok) {
    // Trata resposta com formato específico de erro
    if (responseData.errors && Array.isArray(responseData.errors)) {
      throw new Error(responseData.errors.join(', '));
    }
    throw new Error(responseData.message || `Erro na requisição ${method}`);
  }

  return responseData;
}

class ApiService {
  // ===== AUTHENTICATION METHODS =====

  async register(email: string, password: string, oab: string): Promise<RegisterResponse> {
    const url = `${API_BASE_URL}/public/admin_registration`;
    const body = {
      admin: {
        email: email,
        password: password,
        password_confirmation: password,
        oab: oab
      }
    };

    logRequest('REGISTER', url, body);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      });

      return await handleApiResponse(response, 'REGISTER');
    } catch (error) {
      console.error('❌ Erro no registro:', error);
      throw error;
    }
  }

  async login(email: string, password: string): Promise<LoginResponse> {
    const url = `${API_BASE_URL}/login`;
    const body = {
      email: email,
      password: password
    };

    logRequest('LOGIN', url, body);

    try {
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(body)
      });

      const responseData = await handleApiResponse(response, 'LOGIN');

      // Salva o token se retornado pela API
      if (responseData.token) {
        localStorage.setItem('authToken', responseData.token);
        if (DEBUG_MODE) {
          console.log('✅ Token salvo no localStorage');
        }
      }

      return responseData;
    } catch (error) {
      console.error('❌ Erro no login:', error);
      throw error;
    }
  }

  logout(): void {
    localStorage.removeItem('authToken');
  }

  getToken(): string | null {
    return localStorage.getItem('authToken');
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }

  // ===== PROFILE METHODS =====

  async completeProfile(profileData: ProfileCompletionData): Promise<ProfileCompletionResponse> {
    const url = `${API_BASE_URL}/admin/profile/complete`;
    const token = this.getToken();
    const body = {
      admin: profileData
    };

    logRequest('COMPLETE_PROFILE', url, { ...body, token: token ? 'presente' : 'ausente' });

    try {
      const response = await fetch(url, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(body)
      });

      return await handleApiResponse(response, 'COMPLETE_PROFILE');
    } catch (error) {
      console.error('❌ Erro ao completar perfil:', error);
      throw error;
    }
  }

  // ===== ADMIN MANAGEMENT METHODS =====

  async getAdmins(): Promise<AdminsListResponse> {
    const url = `${API_BASE_URL}/admins`;
    const token = this.getToken();

    logRequest('GET_ADMINS', url, { token: token ? 'presente' : 'ausente' });

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(token && { Authorization: `Bearer ${token}` })
        }
      });

      return await handleApiResponse(response, 'GET_ADMINS');
    } catch (error) {
      console.error('❌ Erro ao buscar admins:', error);
      throw error;
    }
  }

  // ===== TEAM MANAGEMENT METHODS =====

  async getMyTeam(): Promise<MyTeamResponse> {
    const url = `${API_BASE_URL}/my_team`;
    const token = this.getToken();

    logRequest('GET_MY_TEAM', url, { token: token ? 'presente' : 'ausente' });

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(token && { Authorization: `Bearer ${token}` })
        }
      });

      return await handleApiResponse(response, 'GET_MY_TEAM');
    } catch (error) {
      console.error('❌ Erro ao buscar meu time:', error);
      throw error;
    }
  }

  async getTeamById(teamId: string): Promise<TeamResponse> {
    const url = `${API_BASE_URL}/teams/${teamId}`;
    const token = this.getToken();

    logRequest('GET_TEAM_BY_ID', url, { teamId, token: token ? 'presente' : 'ausente' });

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(token && { Authorization: `Bearer ${token}` })
        }
      });

      return await handleApiResponse(response, 'GET_TEAM_BY_ID');
    } catch (error) {
      console.error('❌ Erro ao buscar time por ID:', error);
      throw error;
    }
  }

  async updateTeam(teamId: string, teamData: UpdateTeamData): Promise<UpdateTeamResponse> {
    const url = `${API_BASE_URL}/teams/${teamId}`;
    const token = this.getToken();
    const body = {
      team: teamData
    };

    logRequest('UPDATE_TEAM', url, { teamId, body, token: token ? 'presente' : 'ausente' });

    try {
      const response = await fetch(url, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
          ...(token && { Authorization: `Bearer ${token}` })
        },
        body: JSON.stringify(body)
      });

      return await handleApiResponse(response, 'UPDATE_TEAM');
    } catch (error) {
      console.error('❌ Erro ao atualizar time:', error);
      throw error;
    }
  }

  async getMyTeamMembers(): Promise<TeamMembersResponse> {
    const url = `${API_BASE_URL}/my_team/members`;
    const token = this.getToken();

    logRequest('GET_MY_TEAM_MEMBERS', url, { token: token ? 'presente' : 'ausente' });

    try {
      const response = await fetch(url, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(token && { Authorization: `Bearer ${token}` })
        }
      });

      return await handleApiResponse(response, 'GET_MY_TEAM_MEMBERS');
    } catch (error) {
      console.error('❌ Erro ao buscar membros do time:', error);
      throw error;
    }
  }

  // ===== UTILITY METHODS =====

  async testConnection(): Promise<any> {
    const url = `${API_BASE_URL}/health`;

    logRequest('TEST_CONNECTION', url);

    try {
      const response = await fetch(url);
      return await handleApiResponse(response, 'TEST_CONNECTION');
    } catch (error) {
      console.error('❌ Erro ao testar conexão:', error);
      throw error;
    }
  }
}

export const api = new ApiService();
