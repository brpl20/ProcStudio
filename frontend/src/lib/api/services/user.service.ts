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
  UserData,
  UserProfileData
} from '../types';

export class UserService {
  constructor(private http: HttpClient) {}

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
   * Delete a user
   */
  async deleteUser(userId: string): Promise<void> {
    return this.http.delete<void>(`${API_ENDPOINTS.USERS}/${userId}`);
  }

  /**
   * Get all user profiles
   */
  async getUserProfiles(): Promise<{ data: UserProfileData[] }> {
    return this.http.get<{ data: UserProfileData[] }>(API_ENDPOINTS.USER_PROFILES);
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
          (item: any) => item.type === 'user_profile' && item.id === profileId
        ) as UserProfileData;
      }
    }
    return undefined;
  }
}
