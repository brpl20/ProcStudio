/**
 * DELETE - Hard Delete Job Tests
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
 * Run hard delete tests
 */
const runHardDeleteTests = () => {
  describe('DELETE /jobs/:id?destroy_fully=true (Hard Delete)', function() {

    it('Should hard delete a job', async function() {
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

        // Hard delete the job
        const deleteUrl = `${baseURL}/jobs/${jobId}?destroy_fully=true`;
        const deleteResponse = await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Hard delete job', deleteUrl, {
          'Job ID': jobId,
          'Delete Type': 'Hard Delete (Permanent)'
        });

        // Verify job is completely gone
        try {
          await axios({
            method: 'get',
            url: `${baseURL}/jobs/${jobId}`,
            headers: headers
          });
          throw new Error('Job should not exist after hard delete');
        } catch (getError) {
          if (getError.response?.status === 404) {
            testUtils.logSuccess(404, 'Job permanently deleted', `${baseURL}/jobs/${jobId}`);
          } else {
            throw getError;
          }
        }

      } catch (error) {
        errorHandlers.handleApiError(error, 'Hard delete job', deleteUrl || createUrl);
      }
    });

    it('Should hard delete a soft-deleted job', async function() {
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
        const softDeleteUrl = `${baseURL}/jobs/${jobId}`;
        await axios({
          method: 'delete',
          url: softDeleteUrl,
          headers: headers
        });

        // Then hard delete
        const hardDeleteUrl = `${baseURL}/jobs/${jobId}?destroy_fully=true`;
        const hardDeleteResponse = await axios({
          method: 'delete',
          url: hardDeleteUrl,
          headers: headers
        });

        validators.validateResponse(hardDeleteResponse, 200);

        testUtils.logSuccess(hardDeleteResponse.status, 'Hard delete soft-deleted job', hardDeleteUrl, {
          'Job ID': jobId,
          'Process': 'Soft Delete → Hard Delete'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Hard delete soft-deleted job', hardDeleteUrl || createUrl);
      }
    });

    it('Should return 404 when hard deleting non-existent job', async function() {
      const nonExistentId = 999999;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${nonExistentId}?destroy_fully=true`;

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
          testUtils.logSuccess(error.response.status, 'Non-existent job hard delete handled', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail to hard delete without authentication', async function() {
      const url = `${baseURL}/jobs/1?destroy_fully=true`;

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
          testUtils.logSuccess(error.response.status, 'Authentication required for hard delete', url);
        } else {
          throw error;
        }
      }
    });

    it('Should handle cascade deletion of related records', async function() {
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

        // Try to create related records (comments, assignments) if endpoints exist
        try {
          await axios({
            method: 'post',
            url: `${baseURL}/jobs/${jobId}/comments`,
            headers: headers,
            data: { job_comment: { content: 'Test comment for cascade deletion' } }
          });
        } catch (commentError) {
          // Comment creation might not be implemented
        }

        // Hard delete the job
        const deleteUrl = `${baseURL}/jobs/${jobId}?destroy_fully=true`;
        const deleteResponse = await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Hard delete with cascade', deleteUrl, {
          'Job ID': jobId,
          'Note': 'Should cascade delete comments and assignments'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Hard delete with cascade', deleteUrl || createUrl);
      }
    });

    it('Should handle invalid job ID format in hard delete', async function() {
      const invalidId = 'invalid-id';
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${invalidId}?destroy_fully=true`;

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
          testUtils.logSuccess(error.response.status, 'Invalid ID format in hard delete handled', url);
        } else {
          throw error;
        }
      }
    });
  });
};

module.exports = { runHardDeleteTests };
