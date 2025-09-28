/**
 * PUT/PATCH - Update Job Tests
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
  generateMinimalJob,
  generateCompleteJob,
  scenarioData 
} = require('./data');

/**
 * Run update tests
 */
const runUpdateTests = () => {
  describe('PUT /jobs/:id', function() {

    it('Should update job with basic attributes', async function() {
      // First create a job to update
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const createUrl = `${baseURL}/jobs`;
      const createData = generateCompleteJob();

      let jobId;
      try {
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        jobId = createResponse.data.data?.id || createResponse.data.id;
        testUtils.addToCleanup(jobId);

        // Now update the job
        const updateUrl = `${baseURL}/jobs/${jobId}`;
        const updateData = generateMinimalJob();

        const updateResponse = await axios({
          method: 'put',
          url: updateUrl,
          headers: headers,
          data: updateData
        });

        validators.validateResponse(updateResponse, 200);
        validators.validateJsonApiResponse(updateResponse);

        const attributes = updateResponse.data.data?.attributes || updateResponse.data;
        expect(attributes.description).to.equal(updateData.job.description);

        testUtils.logSuccess(updateResponse.status, 'Update job', updateUrl, {
          'Job ID': jobId,
          'New Description': updateData.job.description.substring(0, 50) + '...',
          'New Status': updateData.job.status,
          'New Priority': updateData.job.priority
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Update job', updateUrl || createUrl);
      }
    });

    it('Should update job status', async function() {
      // Create a job first
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const createUrl = `${baseURL}/jobs`;
      const createData = scenarioData.pendingJob();

      let jobId;
      try {
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        jobId = createResponse.data.data?.id || createResponse.data.id;
        testUtils.addToCleanup(jobId);

        // Update status to in_progress
        const updateUrl = `${baseURL}/jobs/${jobId}`;
        const updateData = {
          job: {
            status: 'in_progress'
          }
        };

        const updateResponse = await axios({
          method: 'put',
          url: updateUrl,
          headers: headers,
          data: updateData
        });

        validators.validateResponse(updateResponse, 200);

        const attributes = updateResponse.data.data?.attributes || updateResponse.data;
        expect(attributes.status).to.equal('in_progress');

        testUtils.logSuccess(updateResponse.status, 'Update job status', updateUrl, {
          'Job ID': jobId,
          'Old Status': 'pending',
          'New Status': 'in_progress'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Update job status', updateUrl || createUrl);
      }
    });

    it('Should update job priority', async function() {
      // Create a job first
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const createUrl = `${baseURL}/jobs`;
      const createData = scenarioData.pendingJob();

      let jobId;
      try {
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        jobId = createResponse.data.data?.id || createResponse.data.id;
        testUtils.addToCleanup(jobId);

        // Update priority to urgent
        const updateUrl = `${baseURL}/jobs/${jobId}`;
        const updateData = {
          job: {
            priority: 'urgent'
          }
        };

        const updateResponse = await axios({
          method: 'put',
          url: updateUrl,
          headers: headers,
          data: updateData
        });

        validators.validateResponse(updateResponse, 200);

        const attributes = updateResponse.data.data?.attributes || updateResponse.data;
        expect(attributes.priority).to.equal('urgent');

        testUtils.logSuccess(updateResponse.status, 'Update job priority', updateUrl, {
          'Job ID': jobId,
          'Old Priority': 'medium',
          'New Priority': 'urgent'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Update job priority', updateUrl || createUrl);
      }
    });

    it('Should update job deadline', async function() {
      // Create a job first
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const createUrl = `${baseURL}/jobs`;
      const createData = generateCompleteJob();

      let jobId;
      try {
        const createResponse = await axios({
          method: 'post',
          url: createUrl,
          headers: headers,
          data: createData
        });

        jobId = createResponse.data.data?.id || createResponse.data.id;
        testUtils.addToCleanup(jobId);

        // Update deadline
        const newDeadline = new Date();
        newDeadline.setDate(newDeadline.getDate() + 15);
        const deadlineStr = newDeadline.toISOString().split('T')[0];

        const updateUrl = `${baseURL}/jobs/${jobId}`;
        const updateData = {
          job: {
            deadline: deadlineStr
          }
        };

        const updateResponse = await axios({
          method: 'put',
          url: updateUrl,
          headers: headers,
          data: updateData
        });

        validators.validateResponse(updateResponse, 200);

        const attributes = updateResponse.data.data?.attributes || updateResponse.data;
        expect(attributes.deadline).to.equal(deadlineStr);

        testUtils.logSuccess(updateResponse.status, 'Update job deadline', updateUrl, {
          'Job ID': jobId,
          'New Deadline': deadlineStr
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Update job deadline', updateUrl || createUrl);
      }
    });

    it('Should fail to update with invalid data', async function() {
      if (!testState.randomJobId) {
        testUtils.skipTest(this, 'No job ID available from previous test');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${testState.randomJobId}`;
      const updateData = {
        job: {
          status: 'invalid_status'
        }
      };

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: updateData
        });

        // Should not reach here
        throw new Error('Expected request to fail with validation error');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 422]);
          testUtils.logSuccess(error.response.status, 'Invalid update data rejected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail to update non-existent job', async function() {
      const nonExistentId = 999999;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${nonExistentId}`;
      const updateData = generateMinimalJob();

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: updateData
        });

        // Should not reach here
        throw new Error('Expected request to fail with 404');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(404);
          testUtils.logSuccess(error.response.status, 'Non-existent job update rejected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail without authentication', async function() {
      if (!testState.randomJobId) {
        testUtils.skipTest(this, 'No job ID available from previous test');
        return;
      }

      const url = `${baseURL}/jobs/${testState.randomJobId}`;
      const updateData = generateMinimalJob();

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: config.api.headers, // No auth headers
          data: updateData
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
      if (!testState.randomJobId) {
        testUtils.skipTest(this, 'No job ID available from previous test');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${testState.randomJobId}`;
      const updateData = {
        job: {
          deadline: 'invalid-date-format'
        }
      };

      try {
        const response = await axios({
          method: 'put',
          url: url,
          headers: headers,
          data: updateData
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
  });
};

module.exports = { runUpdateTests };
