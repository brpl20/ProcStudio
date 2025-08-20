/**
 * Law Area Types
 * Based on backend LawAreaSerializer
 */

export interface LawAreaAttributes {
  id: number;
  name: string;
  code: string;
  description: string | null;
  active: boolean;
  sort_order: number;
  full_name: string;
  is_main_area: boolean;
  is_sub_area: boolean;
  is_system_area: boolean;
  is_custom_area: boolean;
  depth: number;
  hierarchy_path: Array<{
    id: number;
    name: string;
  }>;
  created_by_team: {
    id: number;
    name: string;
    subdomain: string;
  } | null;
  sub_areas_count: number;
  powers_count: number;
}

export interface LawAreaData {
  id: string;
  type: 'law_area';
  attributes: LawAreaAttributes;
  relationships?: {
    parent_area?: {
      data: {
        id: string;
        type: 'law_area';
      } | null;
    };
    sub_areas?: {
      data: Array<{
        id: string;
        type: 'law_area';
      }>;
    };
    powers?: {
      data: Array<{
        id: string;
        type: 'power';
      }>;
    };
  };
}

export interface LawAreasListResponse {
  data: LawAreaData[];
  included?: Array<LawAreaData | PowerData>;
  meta?: {
    total_count: number;
    main_areas_count: number;
    sub_areas_count: number;
  };
}

export interface LawAreaResponse {
  data: LawAreaData;
  included?: Array<LawAreaData | PowerData>;
}

export interface CreateLawAreaRequest {
  law_area: {
    name: string;
    code: string;
    description?: string;
    active?: boolean;
    sort_order?: number;
    parent_area_id?: number;
  };
}

export interface UpdateLawAreaRequest {
  law_area: Partial<{
    name: string;
    code: string;
    description: string;
    active: boolean;
    sort_order: number;
    parent_area_id: number;
  }>;
}

// Import PowerData for relationships
import type { PowerData } from './power.types';