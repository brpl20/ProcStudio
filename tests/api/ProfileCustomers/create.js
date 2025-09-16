/**
 * POST - Create Profile Customer Tests
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
  generateCompleteProfileCustomer, 
  scenarioData 
} = require('./data');

/**
 * Run create tests
 */
const runCreateTests = () => {
  describe('POST /profile_customers', function() {

    it('Should get all profile customers (auth test)', async function() {
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
        
        testUtils.logSuccess(response.status, 'GET profile customers (auth test)', url, {
          'Auth Token Present': !!testState.authHelper.getToken(),
          'Response Type': typeof response.data,
          'Has Data': !!response.data.data
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'GET profile customers (auth test)', url);
      }
    });

    it('Should create a new profile customer with all attributes', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      const requestData = generateCompleteProfileCustomer();

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        // Validate response
        validators.validateResponse(response, 201);
        validators.validateJsonApiResponse(response);

        // Store created ID for cleanup
        const createdId = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(createdId);
        testState.createdProfileCustomerId = createdId;

        // Validate returned data
        const attributes = response.data.data?.attributes || response.data;
        validators.validateProfileCustomer(attributes);
        
        // Log success
        testUtils.logSuccess(response.status, 'Create profile customer', url, {
          'ID': createdId,
          'Name': `${requestData.profile_customer.name} ${requestData.profile_customer.last_name}`,
          'Type': requestData.profile_customer.customer_type,
          'Email': requestData.profile_customer.customer_attributes.email
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Create profile customer', url);
      }
    });

    it('Should create a physical person profile', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      const requestData = scenarioData.physicalPerson();

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        validators.validateResponse(response, 201);
        
        const createdId = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(createdId);
        
        const attributes = response.data.data?.attributes || response.data;
        expect(attributes.customer_type).to.equal('physical_person');
        
        testUtils.logSuccess(response.status, 'Create physical person', url, {
          'ID': createdId,
          'Type': 'physical_person'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Create physical person', url);
      }
    });

    it('Should create a legal person profile', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      const requestData = scenarioData.legalPerson();

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        validators.validateResponse(response, 201);
        
        const createdId = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(createdId);
        
        const attributes = response.data.data?.attributes || response.data;
        expect(attributes.customer_type).to.equal('legal_person');
        
        testUtils.logSuccess(response.status, 'Create legal person', url, {
          'ID': createdId,
          'Type': 'legal_person'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Create legal person', url);
      }
    });

    it('Should fail to create with invalid data', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      const requestData = {
        profile_customer: {
          // Missing required fields
          name: ''
        }
      };

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        // Should not reach here
        throw new Error('Expected request to fail with validation error');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 422]);
          testUtils.logSuccess(error.response.status, 'Validation failed as expected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail without authentication', async function() {
      const url = `${baseURL}/profile_customers`;
      const requestData = generateCompleteProfileCustomer();

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: config.api.headers, // No auth headers
          data: requestData
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

    it('Should show better error message for invalid data structure', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/profile_customers`;
      
      // Create invalid data with unpermitted parameters
      const invalidRequestData = {
        profile_customer: {
          customer_type: 'physical_person',
          name: 'Test User',
          // Missing required fields to trigger validation errors
          addresses_attributes: [{
            description: 'This field should not be permitted',
            invalid_field: 'This should cause an error',
            zip_code: '01234-567'
          }],
          phones_attributes: [{
            phone_number: '+55 11 98765-4321',
            description: 'This field should not be permitted'
          }]
        }
      };

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: invalidRequestData
        });

        // Should not reach here
        throw new Error('Expected request to fail with validation error');

      } catch (error) {
        if (error.response) {
          console.log('\n🔍 Improved error response:');
          console.log(`   Status: ${error.response.status}`);
          console.log(`   Message: ${error.response.data.message}`);
          console.log(`   Errors: ${JSON.stringify(error.response.data.errors, null, 2)}`);
          
          // Should get a proper error response with detailed information
          expect(error.response.status).to.equal(500);
          expect(error.response.data).to.have.property('message');
          expect(error.response.data).to.have.property('errors');
          
          // In development, should show specific error details
          expect(error.response.data.message).to.include('Development Error');
          expect(error.response.data.message).to.include('unknown attribute');
          
          testUtils.logSuccess(error.response.status, 'Improved error handling working - shows specific errors!', url);
        } else {
          throw error;
        }
      }
    });
  });
};

module.exports = { runCreateTests };