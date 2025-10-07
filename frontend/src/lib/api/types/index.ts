/**
 * Central export point for all API types
 */

// Auth types
export type {
  User,
  LoginRequest,
  LoginResponse,
  RefreshTokenRequest,
  RefreshTokenResponse,
  LogoutResponse,
  ForgotPasswordRequest,
  ForgotPasswordResponse,
  RegisterRequest,
  RegisterResponse
} from './auth.types';

// User types (excluding duplicates)
export type {
  UserProfileData,
  CreateUserProfileRequest,
  UpdateUserProfileRequest,
  UserProfileResponse,
  UserProfilesListResponse,
  CreateUserProfileResponse,
  UpdateUserProfileResponse,
  DeleteUserProfileResponse
} from './user.types';

// Team types
export * from './team.types';

// Law area types
export * from './law-area.types';

// Power types
export * from './power.types';

// Job types
export * from './job.types';

// Work types
export * from './work.types';

// Customer types
export * from './customer.types';

// Office types (excluding duplicates)
export type {
  Society,
  AccountingType,
  PartnershipType,
  Office,
  OfficeWithLawyers,
  Lawyer,
  UserOffice,
  Compensation,
  CreateOfficeRequest,
  UpdateOfficeRequest,
  OfficesListResponse,
  OfficeResponse,
  CreateOfficeResponse,
  UpdateOfficeResponse,
  DeleteOfficeResponse,
  RestoreOfficeResponse,
  OfficesWithLawyersResponse,
  JsonApiOfficeData,
  JsonApiOfficeWithLawyersData,
  JsonApiOfficeResponse,
  JsonApiOfficesListResponse,
  JsonApiOfficesWithLawyersResponse
} from './office.types';

// Notification types
export * from './notification.types';

// Re-export shared types from office.types
export type { Phone, Address, Email, BankAccount } from './office.types';
