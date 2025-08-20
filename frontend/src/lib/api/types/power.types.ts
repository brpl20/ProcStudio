/**
 * Power Types
 * Based on backend PowerSerializer
 */

export type PowerCategory = 'administrative' | 'judicial' | 'extrajudicial';

export interface PowerAttributes {
  id: number;
  description: string;
  category: PowerCategory;
  law_area_id: number | null;
  is_base: boolean;
  category_name: string;
  law_area: {
    id: number;
    name: string;
    code: string;
    full_name: string;
    parent_area: {
      id: number;
      name: string;
      code: string;
    } | null;
  } | null;
  full_description: string;
  is_custom: boolean;
  created_by_team: {
    id: number;
    name: string;
  } | null;
}

export interface PowerData {
  id: string;
  type: 'power';
  attributes: PowerAttributes;
}

export interface PowersListResponse {
  data: PowerData[];
  meta?: {
    total_count: number;
  };
}

export interface PowerResponse {
  data: PowerData;
}

export interface CreatePowerRequest {
  power: {
    description: string;
    category: PowerCategory;
    law_area_id?: number;
    is_base: boolean;
  };
}

export interface UpdatePowerRequest {
  power: Partial<{
    description: string;
    category: PowerCategory;
    law_area_id: number;
    is_base: boolean;
  }>;
}