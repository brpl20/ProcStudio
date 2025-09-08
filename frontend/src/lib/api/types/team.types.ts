/**
 * Team Types
 * Based on backend TeamSerializer
 */

export interface TeamAttributes {
  name: string;
  description?: string;
  status: string;
  subdomain?: string;
  created_at: string;
  updated_at: string;
  deleted: boolean;
}

export interface TeamData {
  id: string;
  type: 'team';
  attributes: TeamAttributes;
  relationships?: {
    users?: {
      data: Array<{
        id: string;
        type: 'user';
      }>;
    };
  };
}

export interface TeamResponse {
  data: TeamData;
  included?: TeamData[];
}

export interface TeamsListResponse {
  data: TeamData[];
  meta?: {
    total_count: number;
  };
}

export interface MyTeamResponse {
  data: TeamData;
  included?: TeamData[];
}

export interface UpdateTeamRequest {
  team: Partial<{
    name: string;
    description: string;
    status: string;
    subdomain: string;
  }>;
}

export interface UpdateTeamResponse {
  data: TeamData;
}

export interface TeamMembersResponse {
  data: TeamData[];
  included?: TeamData[];
  meta?: {
    total_count: number;
  };
}
