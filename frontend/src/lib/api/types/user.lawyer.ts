/**
 * User and UserProfile Types
 * Transformation to Lawyer
 * Based on backend UserSerializer and UserProfileSerializer
 */
// TD: Deprecar Origin
import type { BankAccountAttributes, PhoneAttributes, AddressAttributes } from './user.types';

export interface Lawyer {
  id: string;
  type: 'lawyer';
  attributes: {
    role: 'lawyer';
    name: string;
    last_name?: string;
    status?: string;
    access_email: string;
    user_id?: number;
    office_id?: number | null;
    gender?: 'male' | 'female';
    oab: string;
    rg?: string;
    cpf?: string;
    nationality?: string;
    origin?: string | null;
    civil_status?: string;
    birth?: string;
    mother_name?: string | null;
    deleted: boolean;
    bank_accounts?: BankAccountAttributes[];
    phones?: PhoneAttributes[];
    addresses?: AddressAttributes[];
    avatar_url?: string;
  };
}
