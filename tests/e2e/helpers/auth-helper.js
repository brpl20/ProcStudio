/**
 * E2E Authentication Helper for Playwright Tests
 * Handles authentication and session management for e2e tests
 */

const fs = require("fs");
const path = require("path");
const { apiTesting } = require("../../config.js");

class E2EAuthHelper {
  constructor(page, context) {
    this.page = page;
    this.context = context;
    this.baseURL = apiTesting.api.baseUrl;
    this.apiURL = apiTesting.api.baseUrl;
    this.frontendURL = process.env.FRONTEND_URL || "http://localhost:5173";
    this.authStateFile = path.join(__dirname, "../.auth/user.json");
  }

  /**
   * Authenticate via API and save session
   */
  async authenticateViaAPI(credentials = null) {
    const loginCredentials = credentials || apiTesting.api.auth.testCredentials;

    const loginURL = `${this.apiURL}${apiTesting.api.auth.tokenEndpoint}`;
    console.log("🔍 Attempting to authenticate via API:");
    console.log(`   Full Login URL: ${loginURL}`);
    console.log(
      `   Credentials: ${JSON.stringify({ email: loginCredentials.email, password: "***" })}`,
    );
    console.log(`   API Base URL: ${this.baseURL}`);
    console.log(`   Frontend Base URL: ${this.frontendURL}`);

    const response = await this.page.request.post(loginURL, {
      data: loginCredentials,
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });

    console.log(
      `📡 Response Status: ${response.status()} ${response.statusText()}`,
    );

    if (!response.ok()) {
      const body = await response.text();
      console.log(`❌ Response Body: ${body}`);
      throw new Error(
        `Authentication failed: ${response.status()} ${response.statusText()}`,
      );
    }

    const responseData = await response.json();
    const token =
      responseData.token ||
      responseData.access_token ||
      responseData.auth_token ||
      responseData.data?.token ||
      responseData.jwt;

    if (!token) {
      throw new Error("No token received from authentication response");
    }

    console.log(`✅ Authentication successful, token received`);

    // Store token in context
    await this.context.addCookies([
      {
        name: "auth_token",
        value: token,
        domain: new URL(this.frontendURL).hostname,
        path: "/",
        httpOnly: false,
        secure: false,
        sameSite: "Lax",
      },
    ]);

    // Store token in localStorage for frontend
    await this.page.goto(this.frontendURL);
    await this.page.evaluate((token) => {
      localStorage.setItem("auth_token", token);
      localStorage.setItem("user", JSON.stringify({ authenticated: true }));
    }, token);

    // Save authentication state
    await this.saveAuthState();

    return token;
  }

  /**
   * Authenticate via UI login form
   */
  async authenticateViaUI(credentials = null) {
    const loginCredentials = credentials || apiTesting.api.auth.testCredentials;

    console.log("🔍 Attempting to authenticate via UI form");
    await this.page.goto(`${this.frontendURL}/login`);

    // Fill login form
    await this.page.fill(
      '[data-testid="email-input"], input[type="email"], #email',
      loginCredentials.email,
    );
    await this.page.fill(
      '[data-testid="password-input"], input[type="password"], #password',
      loginCredentials.password,
    );

    // Click login button
    await this.page.click(
      '[data-testid="login-btn"], button[type="submit"], button:has-text("Login")',
    );

    // Wait for navigation or success indicator
    await Promise.race([
      this.page.waitForURL("**/dashboard", { timeout: 10000 }),
      this.page.waitForURL("**/home", { timeout: 10000 }),
      this.page.waitForSelector('[data-testid="user-menu"]', {
        timeout: 10000,
      }),
    ]).catch(() => {
      // If no specific navigation, just wait for network idle
      return this.page.waitForLoadState("networkidle");
    });

    console.log(`✅ UI authentication successful`);

    // Save authentication state
    await this.saveAuthState();
  }

  /**
   * Save authentication state to file
   */
  async saveAuthState() {
    const storageState = await this.context.storageState();
    const authDir = path.dirname(this.authStateFile);

    if (!fs.existsSync(authDir)) {
      fs.mkdirSync(authDir, { recursive: true });
    }

    fs.writeFileSync(this.authStateFile, JSON.stringify(storageState, null, 2));
    console.log(`💾 Authentication state saved to: ${this.authStateFile}`);
  }

  /**
   * Load authentication state from file
   */
  async loadAuthState() {
    if (fs.existsSync(this.authStateFile)) {
      const storageState = JSON.parse(
        fs.readFileSync(this.authStateFile, "utf8"),
      );
      await this.context.addCookies(storageState.cookies || []);

      if (storageState.origins && storageState.origins.length > 0) {
        await this.page.goto(this.frontendURL);
        for (const origin of storageState.origins) {
          if (origin.localStorage) {
            await this.page.evaluate((items) => {
              for (const item of items) {
                localStorage.setItem(item.name, item.value);
              }
            }, origin.localStorage);
          }
        }
      }

      console.log(`📥 Authentication state loaded from: ${this.authStateFile}`);
      return true;
    }
    return false;
  }

  /**
   * Check if user is authenticated
   */
  async isAuthenticated() {
    try {
      // Check for auth token in localStorage
      const hasToken = await this.page.evaluate(() => {
        return !!localStorage.getItem("auth_token");
      });

      if (!hasToken) return false;

      // Verify token is valid by making an API request
      const response = await this.page.request.get(
        `${this.apiURL}/users/current`,
        {
          headers: await this.getAuthHeaders(),
        },
      );

      return response.ok();
    } catch (error) {
      console.warn("⚠️ Authentication check failed:", error.message);
      return false;
    }
  }

  /**
   * Get authentication headers for API requests
   */
  async getAuthHeaders() {
    const token = await this.page.evaluate(() =>
      localStorage.getItem("auth_token"),
    );

    if (token) {
      return {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        Accept: "application/json",
      };
    }

    return {
      "Content-Type": "application/json",
      Accept: "application/json",
    };
  }

  /**
   * Clear authentication state
   */
  async clearAuth() {
    console.log("🧹 Clearing authentication state...");

    // Clear localStorage
    await this.page.evaluate(() => {
      localStorage.removeItem("auth_token");
      localStorage.removeItem("user");
    });

    // Clear cookies
    await this.context.clearCookies();

    // Remove auth state file
    if (fs.existsSync(this.authStateFile)) {
      fs.unlinkSync(this.authStateFile);
    }

    console.log("✅ Authentication state cleared");
  }

  /**
   * Setup authentication for test suite
   */
  static async setupAuth(browser, credentials = null) {
    console.log("🔧 Setting up authentication for test suite...");
    const context = await browser.newContext();
    const page = await context.newPage();
    const authHelper = new E2EAuthHelper(page, context);

    await authHelper.authenticateViaAPI(credentials);
    await page.close();
    await context.close();
    console.log("✅ Test suite authentication setup complete");
  }

  /**
   * Get current authenticated user info
   */
  async getCurrentUser() {
    try {
      const response = await this.page.request.get(
        `${this.apiURL}/users/current`,
        {
          headers: await this.getAuthHeaders(),
        },
      );

      if (response.ok()) {
        const userData = await response.json();
        return userData.data || userData;
      }
      return null;
    } catch (error) {
      console.warn("⚠️ Failed to get current user:", error.message);
      return null;
    }
  }

  /**
   * Ensure user is authenticated, authenticate if not
   */
  async ensureAuthenticated(credentials = null) {
    console.log("🔍 Checking authentication status...");

    // Try to load existing auth state first
    const authLoaded = await this.loadAuthState();

    if (authLoaded && (await this.isAuthenticated())) {
      console.log("✅ Already authenticated");
      return;
    }

    console.log("🔑 Not authenticated, attempting to authenticate...");
    await this.authenticateViaAPI(credentials);
  }
}

module.exports = E2EAuthHelper;
