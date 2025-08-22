/**
 * API Configuration
 * Central configuration for all API services
 */

export const API_CONFIG = {
  // Use relative URL to leverage Vite proxy in development
  BASE_URL: import.meta.env.DEV ? '/api/v1' : 'http://localhost:3000/api/v1',
  DEBUG_MODE: true,
  TIMEOUT: 30000
} as const;

export const API_ENDPOINTS = {
  // Authentication
  REGISTER: '/public/user_registration',
  LOGIN: '/login',
  LOGOUT: '/logout',

  // Users (formerly Admins)
  USERS: '/users',
  USER_PROFILES: '/user_profiles',
  PROFILE_COMPLETION: '/user_profiles/complete_profile',

  // Teams
  TEAMS: '/teams',
  MY_TEAM: '/my_team',
  MY_TEAM_MEMBERS: '/my_team/members',

  // Law Areas
  LAW_AREAS: '/law_areas',

  // Powers
  POWERS: '/powers',

  // Test
  TEST: '/test',

  // Customer
  CUSTOMERS: '/customers', // GET
  CUSTOMER: '/customers/:id', // GET
  CUSTOMER_CREATE: '/customers', // POST
  CUSTOMER_UPDATE: '/customers/:id', // PUT
  CUSTOMER_DELETE: '/customers/:id' // DELETE
  // Metodos usados no outro frontend, deixado aqui apenas para ficar completo e de conhecimento geral
  // CUSTOMER_RESEND_CONFIRMATION: '/customers/:id/resend_confirmation', // POST
  // CUSTOMER_CONFIRM: '/customer/confirm', // GET (with token query param)
  // CUSTOMER_LOGIN: '/customer/login', // POST
  // CUSTOMER_LOGOUT: '/customer/logout', // DELETE
  // CUSTOMER_RESET_PASSWORD: '/customer/password', // POST
  // CUSTOMER_UPDATE_PASSWORD: '/customer/password' // PUT/PATCH
} as const;
