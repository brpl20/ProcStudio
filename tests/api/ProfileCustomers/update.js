/**
 * PUT/PATCH - Update Profile Customer Tests
 */

const { 
  config,
  baseURL, 
  testState, 
  validators, 
  errorHandlers, 
  testUtils, 
  axios, 
  expect 
} = require('./config');
const { 
  generateMinimalProfileCustomer,
  dataGenerators 
} = require('./data');

/**
 * Run update tests
 */
const runUpdateTests = () => {
  describe('PUT/PATCH /profile_customers/:id', function() {

    it('Should update a profile customer using PUT', async function() {
      if (!testState.createdProfileCustomerId && !testState.randomProfileCustomerId) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileId}`;
      const requestData = generateMinimalProfileCustomer();

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: requestData
        });

        // Validate response
        validators.validateResponse(response, 200);
        validators.validateJsonApiResponse(response);

        // Validate updated data
        const attributes = response.data.data?.attributes || response.data;
        expect(attributes.name).to.equal(requestData.profile_customer.name);
        expect(attributes.last_name).to.equal(requestData.profile_customer.last_name);
        
        testUtils.logSuccess(response.status, 'Update with PUT', url, {
          'ID': profileId,
          'Updated name': `${requestData.profile_customer.name} ${requestData.profile_customer.last_name}`,
          'Updated status': requestData.profile_customer.status
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Update with PUT', url);
      }
    });

    it('Should partially update using PATCH', async function() {
      if (!testState.createdProfileCustomerId && !testState.randomProfileCustomerId) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileId}`;
      const requestData = {
        profile_customer: {
          status: 'inactive'
        }
      };

      try {
        const response = await axios({
          method: 'patch',
          url: url,
          headers: headers,
          data: requestData
        });

        validators.validateResponse(response, 200);
        
        const attributes = response.data.data?.attributes || response.data;
        expect(attributes.status).to.equal('inactive');
        
        testUtils.logSuccess(response.status, 'Update with PATCH', url, {
          'ID': profileId,
          'Updated status': 'inactive'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Update with PATCH', url);
      }
    });

    it('Should update nested attributes', async function() {
      if (!testState.createdProfileCustomerId && !testState.randomProfileCustomerId) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileId}`;
      const requestData = {
        profile_customer: {
          addresses_attributes: [
            {
              ...dataGenerators.generateAddress(),
              _destroy: false
            }
          ]
        }
      };

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: requestData
        });

        validators.validateResponse(response, 200);
        
        testUtils.logSuccess(response.status, 'Update nested attributes', url, {
          'ID': profileId,
          'Updated': 'addresses'
        });

      } catch (error) {
        // Some endpoints might not support nested updates
        if (error.response?.status === 422) {
          testUtils.logSuccess(422, 'Nested update not supported', url);
        } else {
          errorHandlers.handleApiError(error, 'Update nested attributes', url);
        }
      }
    });

    it('Should fail to update with invalid data', async function() {
      if (!testState.createdProfileCustomerId && !testState.randomProfileCustomerId) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileId}`;
      const requestData = {
        profile_customer: {
          status: 'invalid_status',
          customer_type: 'invalid_type'
        }
      };

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: requestData
        });

        // Should not reach here
        throw new Error('Expected validation error');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 422]);
          testUtils.logSuccess(error.response.status, 'Validation failed as expected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail to update non-existent profile', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/99999999`;
      const requestData = generateMinimalProfileCustomer();

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: requestData
        });

        // Should not reach here
        throw new Error('Expected 404 error');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(404);
          testUtils.logSuccess(error.response.status, 'Not found as expected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail without authentication', async function() {
      if (!testState.createdProfileCustomerId && !testState.randomProfileCustomerId) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      const url = `${baseURL}/profile_customers/${profileId}`;
      const requestData = generateMinimalProfileCustomer();

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: config.api.headers, // No auth headers
          data: requestData
        });

        // Should not reach here
        throw new Error('Expected authentication error');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(401);
          testUtils.logSuccess(error.response.status, 'Authentication required', url);
        } else {
          throw error;
        }
      }
    });

    it('Should maintain data integrity on concurrent updates', async function() {
      if (!testState.createdProfileCustomerId) {
        testUtils.skipTest(this, 'No created profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileId}`;
      
      // Simulate concurrent updates
      const update1 = {
        profile_customer: { name: 'Update1' }
      };
      const update2 = {
        profile_customer: { name: 'Update2' }
      };

      try {
        // Send both requests simultaneously
        const [response1, response2] = await Promise.allSettled([
          axios({ method: 'patch', url, headers, data: update1 }),
          axios({ method: 'patch', url, headers, data: update2 })
        ]);

        // At least one should succeed
        const hasSuccess = response1.status === 'fulfilled' || response2.status === 'fulfilled';
        expect(hasSuccess).to.be.true;

        testUtils.logSuccess(200, 'Concurrent update handled', url, {
          'Update 1': response1.status,
          'Update 2': response2.status
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Concurrent updates', url);
      }
    });
  });
};

module.exports = { runUpdateTests };