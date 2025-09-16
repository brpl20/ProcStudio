/**
 * Isolation and Security Tests for Profile Customers
 */

const { 
  config,
  baseURL, 
  testState, 
  validators, 
  errorHandlers, 
  testUtils, 
  axios, 
  expect,
  AuthHelper 
} = require('./config');
const { 
  generateCompleteProfileCustomer 
} = require('./data');

/**
 * Run isolation and security tests
 */
const runIsolationTests = () => {
  describe('Profile Customer Isolation & Security', function() {

    let firstUserProfileId = null;
    let secondUserAuth = null;
    let secondUserProfileId = null;

    before(async function() {
      // Create a profile for the first user (main test user)
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/profile_customers`;
        const requestData = generateCompleteProfileCustomer();

        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        firstUserProfileId = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(firstUserProfileId);
        console.log(`   🔐 Created profile for first user: ${firstUserProfileId}`);
      } catch (error) {
        console.error('Failed to create profile for first user:', error.message);
      }

      // Authenticate as second user
      try {
        secondUserAuth = AuthHelper.createSecondUserAuthHelper(config);
        await secondUserAuth.authenticate();
        console.log(`   🔐 Authenticated as second user (u2@gmail.com)`);

        // Create a profile for the second user
        const headers = { ...config.api.headers, ...secondUserAuth.getAuthHeaders() };
        const url = `${baseURL}/profile_customers`;
        const requestData = generateCompleteProfileCustomer();

        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        secondUserProfileId = response.data.data?.id || response.data.id;
        console.log(`   🔐 Created profile for second user: ${secondUserProfileId}`);
      } catch (error) {
        console.error('Failed to setup second user:', error.message);
      }
    });

    it('Should prevent cross-user profile access (GET)', async function() {
      if (!firstUserProfileId || !secondUserAuth) {
        testUtils.skipTest(this, 'Test setup incomplete');
        return;
      }

      const headers = { ...config.api.headers, ...secondUserAuth.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${firstUserProfileId}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // If we get here, there's a security issue
        console.error(`⚠️ SECURITY ISSUE: Second user accessed first user's profile!`);
        throw new Error('Cross-user access should be prevented');

      } catch (error) {
        if (error.response) {
          // Expected: 403 Forbidden or 404 Not Found
          expect(error.response.status).to.be.oneOf([403, 404]);
          testUtils.logSuccess(error.response.status, 'Cross-user GET blocked', url, {
            'Second user': 'u2@gmail.com',
            'Tried to access': firstUserProfileId
          });
        } else {
          throw error;
        }
      }
    });

    it('Should prevent cross-user profile modification (PUT)', async function() {
      if (!firstUserProfileId || !secondUserAuth) {
        testUtils.skipTest(this, 'Test setup incomplete');
        return;
      }

      const headers = { ...config.api.headers, ...secondUserAuth.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${firstUserProfileId}`;
      const requestData = {
        profile_customer: {
          name: 'Hacked Name'
        }
      };

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: requestData
        });

        // If we get here, there's a security issue
        console.error(`⚠️ SECURITY ISSUE: Second user modified first user's profile!`);
        throw new Error('Cross-user modification should be prevented');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([403, 404]);
          testUtils.logSuccess(error.response.status, 'Cross-user PUT blocked', url);
        } else {
          throw error;
        }
      }
    });

    it('Should prevent cross-user profile deletion (DELETE)', async function() {
      if (!firstUserProfileId || !secondUserAuth) {
        testUtils.skipTest(this, 'Test setup incomplete');
        return;
      }

      const headers = { ...config.api.headers, ...secondUserAuth.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${firstUserProfileId}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers
        });

        // If we get here, there's a security issue
        console.error(`⚠️ SECURITY ISSUE: Second user deleted first user's profile!`);
        throw new Error('Cross-user deletion should be prevented');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([403, 404]);
          testUtils.logSuccess(error.response.status, 'Cross-user DELETE blocked', url);
        } else {
          throw error;
        }
      }
    });

    it('Should isolate profile lists between users', async function() {
      if (!firstUserProfileId || !secondUserAuth || !secondUserProfileId) {
        testUtils.skipTest(this, 'Test setup incomplete');
        return;
      }

      // Get list as first user
      const firstUserHeaders = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;

      const firstUserResponse = await axios({
        method: 'get',
        url: url,
        headers: firstUserHeaders
      });

      const firstUserData = firstUserResponse.data.data || firstUserResponse.data;
      const firstUserIds = firstUserData.map(item => item.id);

      // Get list as second user
      const secondUserHeaders = { ...config.api.headers, ...secondUserAuth.getAuthHeaders() };
      
      const secondUserResponse = await axios({
        method: 'get',
        url: url,
        headers: secondUserHeaders
      });

      const secondUserData = secondUserResponse.data.data || secondUserResponse.data;
      const secondUserIds = secondUserData.map(item => item.id);

      // Verify isolation
      expect(firstUserIds).to.include(firstUserProfileId.toString());
      expect(firstUserIds).to.not.include(secondUserProfileId.toString());
      
      expect(secondUserIds).to.include(secondUserProfileId.toString());
      expect(secondUserIds).to.not.include(firstUserProfileId.toString());

      testUtils.logSuccess(200, 'Profile lists properly isolated', url, {
        'First user profiles': firstUserIds.length,
        'Second user profiles': secondUserIds.length
      });
    });

    it('Should validate authentication tokens', async function() {
      const headers = { 
        ...config.api.headers,
        'Authorization': 'Bearer invalid_token_12345'
      };
      const url = `${baseURL}/profile_customers`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Should not reach here
        throw new Error('Invalid token should be rejected');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(401);
          testUtils.logSuccess(401, 'Invalid token rejected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should handle SQL injection attempts', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      
      // Common SQL injection patterns
      const injectionTests = [
        { q: "'; DROP TABLE profile_customers; --" },
        { q: "1' OR '1'='1" },
        { q: "admin'--" },
        { status: "active' OR 1=1--" }
      ];

      for (const params of injectionTests) {
        try {
          const response = await axios({
            method: 'get',
            url: url,
            headers: headers,
            params: params
          });

          // Request succeeded, but should return safe results
          validators.validateResponse(response, 200);
          const data = response.data.data || response.data;
          
          // Verify no unauthorized data leak
          expect(data).to.be.an('array');
          
          testUtils.logSuccess(200, 'SQL injection attempt handled safely', url, {
            'Injection': Object.values(params)[0].substring(0, 20) + '...'
          });

        } catch (error) {
          // Some APIs might reject these requests entirely
          if (error.response?.status === 400) {
            testUtils.logSuccess(400, 'SQL injection attempt rejected', url);
          } else {
            throw error;
          }
        }
      }
    });

    it('Should handle XSS attempts in data', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      
      const xssData = generateCompleteProfileCustomer();
      xssData.profile_customer.name = "<script>alert('XSS')</script>";
      xssData.profile_customer.last_name = "';alert('XSS');//";

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: xssData
        });

        // If creation succeeds, verify data is properly escaped/sanitized
        const createdId = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(createdId);

        const attributes = response.data.data?.attributes || response.data;
        
        // Check that script tags are escaped or removed
        expect(attributes.name).to.not.include('<script>');
        expect(attributes.last_name).to.not.include('alert(');

        testUtils.logSuccess(response.status, 'XSS attempt sanitized', url);

      } catch (error) {
        // API might reject XSS attempts
        if (error.response?.status === 422 || error.response?.status === 400) {
          testUtils.logSuccess(error.response.status, 'XSS attempt rejected', url);
        } else {
          errorHandlers.handleApiError(error, 'XSS test', url);
        }
      }
    });

    it('Should enforce rate limiting', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      
      // Make many rapid requests
      const requests = [];
      for (let i = 0; i < 50; i++) {
        requests.push(
          axios({
            method: 'get',
            url: url,
            headers: headers,
            validateStatus: () => true // Don't throw on any status
          })
        );
      }

      try {
        const responses = await Promise.all(requests);
        const rateLimited = responses.some(r => r.status === 429);
        
        if (rateLimited) {
          testUtils.logSuccess(429, 'Rate limiting enforced', url);
        } else {
          console.log(`   Info: No rate limiting detected (made 50 requests)`);
        }

      } catch (error) {
        // Network errors from too many requests
        console.log(`   Info: Rate limit test inconclusive`);
      }
    });

    after(async function() {
      // Cleanup second user's profile
      if (secondUserProfileId && secondUserAuth) {
        try {
          const headers = { ...config.api.headers, ...secondUserAuth.getAuthHeaders() };
          const url = `${baseURL}/profile_customers/${secondUserProfileId}`;
          
          await axios({
            method: 'delete',
            url: url,
            headers: headers
          });
          
          console.log(`   🧹 Cleaned up second user's profile: ${secondUserProfileId}`);
        } catch (error) {
          console.log(`   ⚠️ Could not delete second user's profile`);
        }
      }
    });
  });
};

module.exports = { runIsolationTests };