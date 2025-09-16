/**
 * GET - Read Profile Customer Tests (Show & Index)
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

/**
 * Run read tests (show and index)
 */
const runReadTests = () => {
  describe('GET /profile_customers/:id (Show)', function() {

    it('Should retrieve a specific profile customer', async function() {
      if (!testState.createdProfileCustomerId && !testState.randomProfileCustomerId) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileId}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Validate response
        validators.validateResponse(response, 200);
        validators.validateJsonApiResponse(response);

        // Validate data structure
        const data = response.data.data || response.data;
        expect(data).to.have.property('id');
        expect(data.id.toString()).to.equal(profileId.toString());
        
        const attributes = data.attributes || data;
        validators.validateProfileCustomer(attributes);

        // Log success
        testUtils.logSuccess(response.status, 'Get profile customer', url, {
          'ID': profileId,
          'Name': `${attributes.name} ${attributes.last_name}`,
          'Type': attributes.customer_type,
          'Status': attributes.status
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Get profile customer', url);
      }
    });

    it('Should include relationships when requested', async function() {
      if (!testState.createdProfileCustomerId && !testState.randomProfileCustomerId) {
        testUtils.skipTest(this, 'No profile customer ID available');
        return;
      }

      const profileId = testState.createdProfileCustomerId || testState.randomProfileCustomerId;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/${profileId}`;
      const params = {
        include: 'addresses,phones,emails,bank_accounts'
      };

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers,
          params: params
        });

        validators.validateResponse(response, 200);
        
        const data = response.data.data || response.data;
        
        // Check for included relationships
        if (response.data.included) {
          expect(response.data.included).to.be.an('array');
          testUtils.logSuccess(response.status, 'Get with relationships', url, {
            'Included count': response.data.included.length
          });
        } else {
          testUtils.logSuccess(response.status, 'Get with relationships', url);
        }

      } catch (error) {
        errorHandlers.handleApiError(error, 'Get with relationships', url);
      }
    });

    it('Should return 404 for non-existent profile customer', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers/99999999`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Should not reach here
        throw new Error('Expected 404 error for non-existent profile');

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

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: config.api.headers // No auth headers
        });

        // Should not reach here
        throw new Error('Expected request to fail without authentication');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(401);
          testUtils.logSuccess(error.response.status, 'Authentication required', url);
        } else {
          throw error;
        }
      }
    });
  });

  describe('GET /profile_customers (Index)', function() {

    it('Should list all profile customers', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Validate response
        validators.validateResponse(response, 200);
        validators.validateJsonApiResponse(response);

        // Store list for other tests
        const data = response.data.data || response.data;
        expect(data).to.be.an('array');
        testState.profileCustomersList = data;

        // Get a random profile for other tests
        if (data.length > 0) {
          const randomIndex = Math.floor(Math.random() * data.length);
          testState.randomProfileCustomerId = data[randomIndex].id;
        }

        testUtils.logSuccess(response.status, 'List profile customers', url, {
          'Total count': data.length,
          'Random ID selected': testState.randomProfileCustomerId
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'List profile customers', url);
      }
    });


    it('Should filter by status', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      const params = {
        status: 'active'
      };

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers,
          params: params
        });

        validators.validateResponse(response, 200);
        
        const data = response.data.data || response.data;
        expect(data).to.be.an('array');
        
        // Verify all returned items have the filtered status
        data.forEach(item => {
          const attributes = item.attributes || item;
          if (attributes.status) {
            expect(attributes.status).to.equal('active');
          }
        });

        testUtils.logSuccess(response.status, 'Filtered list', url, {
          'Filter': 'status=active',
          'Results': data.length
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Filtered list', url);
      }
    });

    it('Should search by name', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      const params = {
        q: 'test' // Search query
      };

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers,
          params: params
        });

        validators.validateResponse(response, 200);
        
        const data = response.data.data || response.data;
        expect(data).to.be.an('array');

        testUtils.logSuccess(response.status, 'Search results', url, {
          'Query': params.q,
          'Results': data.length
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Search', url);
      }
    });

  });
};

module.exports = { runReadTests };