/**
 * Team Service
 * Handles team management and team member operations
 */

import { HttpClient } from '../utils/http-client';
import { API_ENDPOINTS } from '../config';
import type {
  TeamsListResponse,
  TeamResponse,
  MyTeamResponse,
  UpdateTeamRequest,
  UpdateTeamResponse,
  TeamMembersResponse,
  TeamData,
} from '../types';

export class TeamService {
  constructor(private http: HttpClient) {}

  /**
   * Get all teams (admin only)
   */
  async getTeams(): Promise<TeamsListResponse> {
    return this.http.get<TeamsListResponse>(API_ENDPOINTS.TEAMS);
  }

  /**
   * Get a specific team by ID
   */
  async getTeam(teamId: string | number): Promise<TeamResponse> {
    return this.http.get<TeamResponse>(`${API_ENDPOINTS.TEAMS}/${teamId}`);
  }

  /**
   * Get current user's team
   */
  async getMyTeam(): Promise<MyTeamResponse> {
    return this.http.get<MyTeamResponse>(API_ENDPOINTS.MY_TEAM);
  }

  /**
   * Update current user's team
   */
  async updateMyTeam(teamData: UpdateTeamRequest): Promise<UpdateTeamResponse> {
    return this.http.put<UpdateTeamResponse>(API_ENDPOINTS.MY_TEAM, teamData);
  }

  /**
   * Update a specific team (admin only)
   */
  async updateTeam(
    teamId: string | number,
    teamData: UpdateTeamRequest
  ): Promise<UpdateTeamResponse> {
    return this.http.put<UpdateTeamResponse>(
      `${API_ENDPOINTS.TEAMS}/${teamId}`,
      teamData
    );
  }

  /**
   * Get members of current user's team
   */
  async getMyTeamMembers(): Promise<TeamMembersResponse> {
    return this.http.get<TeamMembersResponse>(API_ENDPOINTS.MY_TEAM_MEMBERS);
  }

  /**
   * Create a new team (admin only)
   */
  async createTeam(teamData: UpdateTeamRequest): Promise<TeamResponse> {
    return this.http.post<TeamResponse>(API_ENDPOINTS.TEAMS, teamData);
  }

  /**
   * Delete a team (admin only)
   */
  async deleteTeam(teamId: string | number): Promise<void> {
    return this.http.delete<void>(`${API_ENDPOINTS.TEAMS}/${teamId}`);
  }

  /**
   * Check if team has subdomain
   */
  hasSubdomain(team: TeamData): boolean {
    return !!team.attributes.subdomain;
  }

  /**
   * Get team status
   */
  getTeamStatus(team: TeamData): 'active' | 'inactive' | 'suspended' {
    return team.attributes.status as 'active' | 'inactive' | 'suspended';
  }

  /**
   * Check if team is active
   */
  isTeamActive(team: TeamData): boolean {
    return team.attributes.status === 'active' && !team.attributes.deleted;
  }
}