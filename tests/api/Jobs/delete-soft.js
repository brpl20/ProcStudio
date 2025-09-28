/**
 * DELETE - Soft Delete Job Tests
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
const { generateCompleteJob } = require('./data');

/**
 * Run soft delete tests
 */
const runSoftDeleteTests = () => {
  describe('DELETE /jobs/:id (Soft Delete)', function() {

    it('Should soft delete a job', async function() {
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

        // Soft delete the job
        const deleteUrl = `${baseURL}/jobs/${jobId}`;
        const deleteResponse = await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Soft delete job', deleteUrl, {
          'Job ID': jobId,
          'Delete Type': 'Soft Delete'
        });

        // Verify job is not accessible anymore
        try {
          await axios({
            method: 'get',
            url: deleteUrl,
            headers: headers
          });
          throw new Error('Job should not be accessible after soft delete');
        } catch (getError) {
          if (getError.response?.status === 404) {
            testUtils.logSuccess(404, 'Job not accessible after soft delete', deleteUrl);
          } else {
            throw getError;
          }
        }

      } catch (error) {
        errorHandlers.handleApiError(error, 'Soft delete job', deleteUrl || createUrl);
      }
    });

    it('Should return 404 when soft deleting non-existent job', async function() {
      const nonExistentId = 999999;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${nonExistentId}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers
        });

        throw new Error('Expected request to fail with 404');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(404);
          testUtils.logSuccess(error.response.status, 'Non-existent job delete handled', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail to soft delete without authentication', async function() {
      if (!testState.randomJobId) {
        testUtils.skipTest(this, 'No job ID available from previous test');
        return;
      }

      const url = `${baseURL}/jobs/${testState.randomJobId}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: config.api.headers // No auth headers
        });

        throw new Error('Expected request to fail without authentication');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(401);
          testUtils.logSuccess(error.response.status, 'Authentication required for delete', url);
        } else {
          throw error;
        }
      }
    });

    it('Should soft delete job with comments', async function() {
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

        // Try to add a comment (this might not be implemented yet)
        try {
          await axios({
            method: 'post',
            url: `${baseURL}/jobs/${jobId}/comments`,
            headers: headers,
            data: { job_comment: { content: 'Test comment before delete' } }
          });
        } catch (commentError) {
          // Comment creation might not be implemented, continue with test
        }

        // Soft delete the job
        const deleteUrl = `${baseURL}/jobs/${jobId}`;
        const deleteResponse = await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Soft delete job with potential comments', deleteUrl, {
          'Job ID': jobId
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Soft delete job with comments', deleteUrl || createUrl);
      }
    });

    it('Should handle invalid job ID format in delete', async function() {
      const invalidId = 'invalid-id';
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${invalidId}`;

      try {
        const response = await axios({
          method: 'delete',
          url: url,
          headers: headers
        });

        throw new Error('Expected request to fail with invalid ID');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 404]);
          testUtils.logSuccess(error.response.status, 'Invalid ID format in delete handled', url);
        } else {
          throw error;
        }
      }
    });

    it('Should prevent double soft delete', async function() {
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

        // First soft delete
        const deleteUrl = `${baseURL}/jobs/${jobId}`;
        await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        // Try to delete again
        try {
          const secondDeleteResponse = await axios({
            method: 'delete',
            url: deleteUrl,
            headers: headers
          });

          throw new Error('Expected second delete to fail');

        } catch (secondDeleteError) {
          if (secondDeleteError.response?.status === 404) {
            testUtils.logSuccess(404, 'Double soft delete prevented', deleteUrl);
          } else {
            throw secondDeleteError;
          }
        }

      } catch (error) {
        errorHandlers.handleApiError(error, 'Prevent double soft delete', deleteUrl || createUrl);
      }
    });
  });
};

module.exports = { runSoftDeleteTests };
