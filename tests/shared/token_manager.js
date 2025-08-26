/**
 * JWT Token Manager
 *
 * This module handles JWT token authentication, storage, and refresh
 * for all test types. Provides persistent token storage and automatic
 * token refresh when needed.
 */

const fs = require('fs');
const path = require('path');
const axios = require('axios');

class TokenManager {
  constructor(config = null) {
    this.config = config || this.loadConfig();
    this.tokens = new Map(); // In-memory token cache
    this.tokenFile = path.join(__dirname, '../.tokens.json');
    this.refreshThreshold = 5 * 60 * 1000; // 5 minutes before expiry

    // Load persisted tokens on startup
    this.loadPersistedTokens();
  }

  /**
   * Load test configuration
   */
  loadConfig() {
    const configPath = path.join(__dirname, '../test_config.json');
    if (fs.existsSync(configPath)) {
      return JSON.parse(fs.readFileSync(configPath, 'utf8'));
    }
    return {};
  }

  /**
   * Load persisted tokens from file
   */
  loadPersistedTokens() {
    try {
      if (fs.existsSync(this.tokenFile)) {
        const tokenData = JSON.parse(fs.readFileSync(this.tokenFile, 'utf8'));

        // Only load non-expired tokens
        Object.entries(tokenData).forEach(([key, data]) => {
          if (this.isTokenValid(data)) {
            this.tokens.set(key, data);
          }
        });
      }
    } catch (error) {
      console.warn('Could not load persisted tokens:', error.message);
    }
  }

  /**
   * Persist tokens to file
   */
  persistTokens() {
    try {
      const tokenData = {};
      this.tokens.forEach((data, key) => {
        if (this.isTokenValid(data)) {
          tokenData[key] = data;
        }
      });

      fs.writeFileSync(this.tokenFile, JSON.stringify(tokenData, null, 2));
    } catch (error) {
      console.warn('Could not persist tokens:', error.message);
    }
  }

  /**
   * Check if token is valid and not expired
   */
  isTokenValid(tokenData) {
    if (!tokenData || !tokenData.token) {
      return false;
    }

    if (tokenData.expiresAt && Date.now() >= tokenData.expiresAt) {
      return false;
    }

    return true;
  }

  /**
   * Check if token needs refresh (within threshold of expiry)
   */
  shouldRefreshToken(tokenData) {
    if (!tokenData || !tokenData.expiresAt) {
      return false;
    }

    return Date.now() >= (tokenData.expiresAt - this.refreshThreshold);
  }

  /**
   * Parse JWT token to get expiration time
   */
  parseTokenExpiry(token) {
    try {
      // JWT tokens have 3 parts separated by dots
      const parts = token.split('.');
      if (parts.length !== 3) {
        return null;
      }

      // Decode the payload (second part)
      const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());

      // Return expiration time in milliseconds
      return payload.exp ? payload.exp * 1000 : null;
    } catch (error) {
      console.warn('Could not parse JWT token:', error.message);
      return null;
    }
  }

  /**
   * Authenticate and get token for a specific user type
   */
  async authenticate(userType = 'default', credentials = null) {
    const cacheKey = `${userType}_token`;

    // Check if we have a valid cached token
    const cachedToken = this.tokens.get(cacheKey);
    if (cachedToken && this.isTokenValid(cachedToken) && !this.shouldRefreshToken(cachedToken)) {
      console.log(`✅ Using cached token for ${userType}`);
      return cachedToken.token;
    }

    // Get credentials
    const authCredentials = credentials || this.getCredentialsForUserType(userType);
    if (!authCredentials) {
      throw new Error(`No credentials found for user type: ${userType}`);
    }

    try {
      const baseURL = process.env.BASE_URL || this.config.api?.baseUrl || 'http://localhost:3000';
      const tokenEndpoint = this.config.api?.auth?.tokenEndpoint || '/auth/login';

      console.log(`🔐 Authenticating ${userType} user...`);

      const response = await axios.post(
        `${baseURL}${tokenEndpoint}`,
        authCredentials,
        {
          headers: { 'Content-Type': 'application/json' },
          timeout: this.config.api?.timeout || 10000
        }
      );

      // Extract token from various possible response formats
      const token = response.data.token ||
                   response.data.access_token ||
                   response.data.auth_token ||
                   response.data.jwt ||
                   response.data.data?.token;

      if (!token) {
        throw new Error('No token found in authentication response');
      }

      // Parse token expiry
      const expiresAt = this.parseTokenExpiry(token) || (Date.now() + (60 * 60 * 1000)); // Default 1 hour

      // Store token data
      const tokenData = {
        token,
        userType,
        expiresAt,
        obtainedAt: Date.now(),
        credentials: authCredentials
      };

      this.tokens.set(cacheKey, tokenData);
      this.persistTokens();

      console.log(`✅ Authentication successful for ${userType} (expires: ${new Date(expiresAt).toISOString()})`);
      return token;

    } catch (error) {
      console.error(`❌ Authentication failed for ${userType}:`, error.message);

      // Clean up any invalid cached token
      this.tokens.delete(cacheKey);
      this.persistTokens();

      throw error;
    }
  }

  /**
   * Get credentials for specific user type
   */
  getCredentialsForUserType(userType) {
    const credentials = {
      default: this.config.api?.auth?.testCredentials,
      admin: {
        email: process.env.TEST_ADMIN_EMAIL || 'admin@e2etest.procstudio.com',
        password: process.env.TEST_ADMIN_PASSWORD || 'E2ETestPass123!'
      },
      user: {
        email: process.env.TEST_USER_EMAIL || 'user@e2etest.procstudio.com',
        password: process.env.TEST_USER_PASSWORD || 'E2ETestPass123!'
      },
      lawyer: {
        email: process.env.TEST_LAWYER_EMAIL || 'lawyer@e2etest.procstudio.com',
        password: process.env.TEST_LAWYER_PASSWORD || 'E2ETestPass123!'
      }
    };

    return credentials[userType] || credentials.default;
  }

  /**
   * Get authentication headers for requests
   */
  async getAuthHeaders(userType = 'default', additionalHeaders = {}) {
    const token = await this.authenticate(userType);

    return {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...additionalHeaders
    };
  }

  /**
   * Make authenticated request
   */
  async authenticatedRequest(method, endpoint, data = null, options = {}) {
    const userType = options.userType || 'default';
    const customHeaders = options.headers || {};

    const baseURL = process.env.BASE_URL || this.config.api?.baseUrl || 'http://localhost:3000';
    const headers = await this.getAuthHeaders(userType, customHeaders);

    const config = {
      method: method.toUpperCase(),
      url: `${baseURL}${endpoint}`,
      headers,
      timeout: this.config.api?.timeout || 30000
    };

    if (data) {
      config.data = data;
    }

    try {
      const response = await axios(config);
      return response;
    } catch (error) {
      // If we get 401, try to refresh token and retry once
      if (error.response?.status === 401 && !options.isRetry) {
        console.log(`🔄 Token expired, refreshing for ${userType}...`);

        // Clear cached token and try again
        this.tokens.delete(`${userType}_token`);
        this.persistTokens();

        // Retry once with fresh token
        return this.authenticatedRequest(method, endpoint, data, { ...options, isRetry: true });
      }

      throw error;
    }
  }

  /**
   * Get token info for debugging
   */
  getTokenInfo(userType = 'default') {
    const cacheKey = `${userType}_token`;
    const tokenData = this.tokens.get(cacheKey);

    if (!tokenData) {
      return { status: 'not_found' };
    }

    return {
      status: this.isTokenValid(tokenData) ? 'valid' : 'expired',
      userType: tokenData.userType,
      obtainedAt: new Date(tokenData.obtainedAt).toISOString(),
      expiresAt: new Date(tokenData.expiresAt).toISOString(),
      needsRefresh: this.shouldRefreshToken(tokenData)
    };
  }

  /**
   * Refresh token if needed
   */
  async refreshTokenIfNeeded(userType = 'default') {
    const cacheKey = `${userType}_token`;
    const tokenData = this.tokens.get(cacheKey);

    if (!tokenData || !this.isTokenValid(tokenData)) {
      return await this.authenticate(userType);
    }

    if (this.shouldRefreshToken(tokenData)) {
      console.log(`🔄 Refreshing token for ${userType}...`);
      this.tokens.delete(cacheKey);
      return await this.authenticate(userType, tokenData.credentials);
    }

    return tokenData.token;
  }

  /**
   * Clear all tokens
   */
  clearAllTokens() {
    this.tokens.clear();

    try {
      if (fs.existsSync(this.tokenFile)) {
        fs.unlinkSync(this.tokenFile);
      }
    } catch (error) {
      console.warn('Could not delete token file:', error.message);
    }

    console.log('🗑️  All tokens cleared');
  }

  /**
   * Clear tokens for specific user type
   */
  clearTokensForUser(userType) {
    const cacheKey = `${userType}_token`;
    this.tokens.delete(cacheKey);
    this.persistTokens();
    console.log(`🗑️  Token cleared for ${userType}`);
  }

  /**
   * Get all cached tokens (for debugging)
   */
  getAllTokens() {
    const tokens = {};
    this.tokens.forEach((data, key) => {
      tokens[key] = {
        userType: data.userType,
        obtainedAt: new Date(data.obtainedAt).toISOString(),
        expiresAt: new Date(data.expiresAt).toISOString(),
        isValid: this.isTokenValid(data),
        needsRefresh: this.shouldRefreshToken(data)
      };
    });
    return tokens;
  }

  /**
   * Validate token with server
   */
  async validateTokenWithServer(userType = 'default') {
    try {
      const response = await this.authenticatedRequest('GET', '/auth/validate', null, { userType });
      return response.status === 200;
    } catch (error) {
      console.warn(`Token validation failed for ${userType}:`, error.message);
      return false;
    }
  }

  /**
   * Setup tokens for test environment
   */
  async setupTestTokens() {
    console.log('🔧 Setting up test tokens...');

    const userTypes = ['default', 'admin', 'user', 'lawyer'];
    const results = {};

    for (const userType of userTypes) {
      try {
        const token = await this.authenticate(userType);
        results[userType] = { success: true, token: token ? 'present' : 'missing' };
      } catch (error) {
        results[userType] = { success: false, error: error.message };
      }
    }

    console.log('🔧 Test token setup results:', results);
    return results;
  }
}

// Create singleton instance
const tokenManager = new TokenManager();

// Helper functions for backward compatibility
const authenticate = (userType, credentials) => tokenManager.authenticate(userType, credentials);
const getAuthHeaders = (userType, additionalHeaders) => tokenManager.getAuthHeaders(userType, additionalHeaders);
const authenticatedRequest = (method, endpoint, data, options) => tokenManager.authenticatedRequest(method, endpoint, data, options);

module.exports = {
  TokenManager,
  tokenManager,
  authenticate,
  getAuthHeaders,
  authenticatedRequest
};

// Cleanup on exit
process.on('exit', () => {
  tokenManager.persistTokens();
});

process.on('SIGINT', () => {
  tokenManager.persistTokens();
  process.exit(0);
});

process.on('SIGTERM', () => {
  tokenManager.persistTokens();
  process.exit(0);
});
