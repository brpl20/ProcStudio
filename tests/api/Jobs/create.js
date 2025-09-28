/**
 * POST - Create Job Tests
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
  generateCompleteJob, 
  scenarioData 
} = require('./data');

/**
 * Run create tests
 */
const runCreateTests = () => {
  describe('POST /jobs', function() {

    it('Should get all jobs (auth test)', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Validate response
        validators.validateResponse(response, 200);
        
        testUtils.logSuccess(response.status, 'GET jobs (auth test)', url, {
          'Auth Token Present': !!testState.authHelper.getToken(),
          'Response Type': typeof response.data,
          'Has Data': !!response.data.data
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'GET jobs (auth test)', url);
      }
    });

    it('Should create a new job with all attributes', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = generateCompleteJob();

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
        testState.createdJobId = createdId;

        // Validate returned data
        const attributes = response.data.data?.attributes || response.data;
        validators.validateJob(attributes);
        
        // Log success
        testUtils.logSuccess(response.status, 'Create job', url, {
          'ID': createdId,
          'Description': requestData.job.description.substring(0, 50) + '...',
          'Status': requestData.job.status,
          'Priority': requestData.job.priority,
          'Deadline': requestData.job.deadline
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Create job', url);
      }
    });

    it('Should create a pending job', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = scenarioData.pendingJob();

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
        expect(attributes.status).to.equal('pending');
        
        testUtils.logSuccess(response.status, 'Create pending job', url, {
          'ID': createdId,
          'Status': 'pending'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Create pending job', url);
      }
    });

    it('Should create an urgent job', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = scenarioData.urgentJob();

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
        expect(attributes.priority).to.equal('urgent');
        
        testUtils.logSuccess(response.status, 'Create urgent job', url, {
          'ID': createdId,
          'Priority': 'urgent'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Create urgent job', url);
      }
    });

    it('Should create a job with comment', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = scenarioData.jobWithComment();

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
        expect(attributes).to.have.property('comment');
        
        testUtils.logSuccess(response.status, 'Create job with comment', url, {
          'ID': createdId,
          'Has Comment': !!attributes.comment
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Create job with comment', url);
      }
    });

    it('Should fail to create with invalid data', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = {
        job: {
          // Missing required fields like description and deadline
          status: 'pending'
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
      const url = `${baseURL}/jobs`;
      const requestData = generateCompleteJob();

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

    it('Should fail with invalid deadline format', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = generateCompleteJob();
      requestData.job.deadline = 'invalid-date';

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        // Should not reach here
        throw new Error('Expected request to fail with invalid date');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 422]);
          testUtils.logSuccess(error.response.status, 'Invalid date format rejected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail with invalid status', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = generateCompleteJob();
      requestData.job.status = 'invalid_status';

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        // Should not reach here
        throw new Error('Expected request to fail with invalid status');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 422]);
          testUtils.logSuccess(error.response.status, 'Invalid status rejected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail with invalid priority', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs`;
      const requestData = generateCompleteJob();
      requestData.job.priority = 'invalid_priority';

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        // Should not reach here
        throw new Error('Expected request to fail with invalid priority');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 422]);
          testUtils.logSuccess(error.response.status, 'Invalid priority rejected', url);
        } else {
          throw error;
        }
      }
    });
  });
};

module.exports = { runCreateTests };
