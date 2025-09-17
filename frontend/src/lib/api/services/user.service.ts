/**
 * User Service
 * Handles user and user profile management
 */

import { HttpClient } from '../utils/http-client';
import { API_ENDPOINTS } from '../config';
import type {
  UsersListResponse,
  UserResponse,
  CreateUserRequest,
  UpdateUserRequest,
  UpdateUserProfileRequest,
  UserProfileData,
  ApiSuccessResponse,
  WhoAmIResponse
} from '../types';

export class UserService {
  constructor(private http: HttpClient) {}

  /**
   * Get current user information (whoami)
   * Returns complete user profile with avatar, team, offices, etc.
   */
  async whoami(): Promise<WhoAmIResponse> {
    return this.http.get<WhoAmIResponse>(API_ENDPOINTS.WHOAMI);
  }

  /**
   * Get all users
   */
  async getUsers(): Promise<UsersListResponse> {
    return this.http.get<UsersListResponse>(API_ENDPOINTS.USERS);
  }

  /**
   * Get a specific user by ID
   */
  async getUser(userId: string): Promise<UserResponse> {
    return this.http.get<UserResponse>(`${API_ENDPOINTS.USERS}/${userId}`);
  }

  /**
   * Create a new user
   */
  async createUser(userData: CreateUserRequest): Promise<UserResponse> {
    return this.http.post<UserResponse>(API_ENDPOINTS.USERS, userData);
  }

  /**
   * Update a user
   */
  async updateUser(userId: string, userData: UpdateUserRequest): Promise<UserResponse> {
    return this.http.put<UserResponse>(`${API_ENDPOINTS.USERS}/${userId}`, userData);
  }

  /**
   * Soft delete a user
   */
  async deleteUser(userId: string): Promise<ApiSuccessResponse<{ id: string }>> {
    return this.http.delete<ApiSuccessResponse<{ id: string }>>(`${API_ENDPOINTS.USERS}/${userId}`);
  }

  /**
   * Hard delete a user (permanent)
   */
  async deleteUserPermanently(userId: string): Promise<ApiSuccessResponse<{ id: string }>> {
    return this.http.delete<ApiSuccessResponse<{ id: string }>>(
      `${API_ENDPOINTS.USERS}/${userId}?destroy_fully=true`
    );
  }

  /**
   * Restore a soft-deleted user
   */
  async restoreUser(userId: string): Promise<UserResponse> {
    return this.http.post<UserResponse>(`${API_ENDPOINTS.USERS}/${userId}/restore`, {});
  }

  /**
   * Get all user profiles
   */
  async getUserProfiles(options?: {
    signal?: AbortSignal;
  }): Promise<ApiSuccessResponse<UserProfileData[]>> {
    return this.http.get<ApiSuccessResponse<UserProfileData[]>>(
      API_ENDPOINTS.USER_PROFILES,
      options
    );
  }

  /**
   * Create a new user profile
   */
  async createUserProfile(
    profileData: Partial<UserProfileData>
  ): Promise<{ data: UserProfileData }> {
    return this.http.post<{ data: UserProfileData }>(API_ENDPOINTS.USER_PROFILES, profileData);
  }

  /**
   * Get a specific user profile
   */
  async getUserProfile(profileId: string): Promise<{ data: UserProfileData }> {
    return this.http.get<{ data: UserProfileData }>(`${API_ENDPOINTS.USER_PROFILES}/${profileId}`);
  }

  /**
   * Update a user profile
   */
  async updateUserProfile(
    profileId: string,
    profileData: UpdateUserProfileRequest
  ): Promise<{ data: UserProfileData }> {
    return this.http.put<{ data: UserProfileData }>(
      `${API_ENDPOINTS.USER_PROFILES}/${profileId}`,
      profileData
    );
  }

  /**
   * Upload avatar for user profile
   */
  async uploadAvatar(profileId: string, file: File): Promise<{ data: UserProfileData }> {
    const formData = new FormData();
    formData.append('user_profile[avatar]', file);
    return this.http.put<{ data: UserProfileData }>(
      `${API_ENDPOINTS.USER_PROFILES}/${profileId}`,
      formData,
      {
        headers: {
          // Let browser set Content-Type with boundary for multipart/form-data
        }
      }
    );
  }

  /**
   * Remove avatar from user profile
   */
  async removeAvatar(profileId: string): Promise<{ data: UserProfileData }> {
    return this.http.put<{ data: UserProfileData }>(`${API_ENDPOINTS.USER_PROFILES}/${profileId}`, {
      user_profile: { remove_avatar: true }
    });
  }

  /**
   * Update avatar color for user profile
   */
  async updateAvatarColor(profileId: string, color: string): Promise<{ data: UserProfileData }> {
    return this.http.put<{ data: UserProfileData }>(`${API_ENDPOINTS.USER_PROFILES}/${profileId}`, {
      user_profile: { avatar_color: color }
    });
  }

  /**
   * Soft delete a user profile
   */
  async deleteUserProfile(profileId: string): Promise<ApiSuccessResponse<{ id: string }>> {
    return this.http.delete<ApiSuccessResponse<{ id: string }>>(
      `${API_ENDPOINTS.USER_PROFILES}/${profileId}`
    );
  }

  /**
   * Hard delete a user profile (permanent)
   */
  async deleteUserProfilePermanently(
    profileId: string
  ): Promise<ApiSuccessResponse<{ id: string }>> {
    return this.http.delete<ApiSuccessResponse<{ id: string }>>(
      `${API_ENDPOINTS.USER_PROFILES}/${profileId}?destroy_fully=true`
    );
  }

  /**
   * Restore a soft-deleted user profile
   */
  async restoreUserProfile(profileId: string): Promise<{ data: UserProfileData }> {
    return this.http.post<{ data: UserProfileData }>(
      `${API_ENDPOINTS.USER_PROFILES}/${profileId}/restore`,
      {}
    );
  }

  /**
   * Helper to extract user profile from included data
   */
  extractUserProfile(
    response: UserResponse | UsersListResponse,
    userId: string
  ): UserProfileData | undefined {
    if ('included' in response && response.included) {
      const userData =
        'data' in response && Array.isArray(response.data)
          ? response.data.find((u) => u.id === userId)
          : (response as UserResponse).data;

      if (userData?.relationships?.user_profile?.data) {
        const profileId = userData.relationships.user_profile.data.id;
        return response.included.find(
          (item): item is UserProfileData => item.type === 'user_profile' && item.id === profileId
        );
      }
    }
    return undefined;
  }
}
