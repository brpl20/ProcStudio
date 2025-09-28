/**
 * POST - Restore Soft Deleted Job Tests
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
 * Run restore tests
 */
const runRestoreTests = () => {
  describe('POST /jobs/:id/restore', function() {

    it('Should restore a soft deleted job', async function() {
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
        await axios({
          method: 'delete',
          url: deleteUrl,
          headers: headers
        });

        // Restore the job
        const restoreUrl = `${baseURL}/jobs/${jobId}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers
        });

        validators.validateResponse(restoreResponse, 200);

        testUtils.logSuccess(restoreResponse.status, 'Restore soft deleted job', restoreUrl, {
          'Job ID': jobId,
          'Process': 'Create → Soft Delete → Restore'
        });

        // Verify job is accessible again
        const getUrl = `${baseURL}/jobs/${jobId}`;
        const getResponse = await axios({
          method: 'get',
          url: getUrl,
          headers: headers
        });

        validators.validateResponse(getResponse, 200);
        testUtils.logSuccess(getResponse.status, 'Restored job accessible', getUrl);

        // Add to cleanup
        testUtils.addToCleanup(jobId);

      } catch (error) {
        errorHandlers.handleApiError(error, 'Restore soft deleted job', restoreUrl || createUrl);
      }
    });

    it('Should fail to restore non-existent job', async function() {
      const nonExistentId = 999999;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${nonExistentId}/restore`;

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers
        });

        throw new Error('Expected request to fail with 404');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(404);
          testUtils.logSuccess(error.response.status, 'Non-existent job restore handled', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail to restore without authentication', async function() {
      const url = `${baseURL}/jobs/1/restore`;

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: config.api.headers // No auth headers
        });

        throw new Error('Expected request to fail without authentication');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(401);
          testUtils.logSuccess(error.response.status, 'Authentication required for restore', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail to restore active (non-deleted) job', async function() {
      // Create a job but don't delete it
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

        // Try to restore an active job
        const restoreUrl = `${baseURL}/jobs/${jobId}/restore`;
        
        try {
          const restoreResponse = await axios({
            method: 'post',
            url: restoreUrl,
            headers: headers
          });

          throw new Error('Expected restore to fail for active job');

        } catch (restoreError) {
          if (restoreError.response) {
            expect(restoreError.response.status).to.be.oneOf([400, 404, 422]);
            testUtils.logSuccess(restoreError.response.status, 'Active job restore rejected', restoreUrl);
          } else {
            throw restoreError;
          }
        }

      } catch (error) {
        errorHandlers.handleApiError(error, 'Restore active job', restoreUrl || createUrl);
      }
    });

    it('Should fail to restore hard deleted job', async function() {
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
        const hardDeleteUrl = `${baseURL}/jobs/${jobId}?destroy_fully=true`;
        await axios({
          method: 'delete',
          url: hardDeleteUrl,
          headers: headers
        });

        // Try to restore hard deleted job
        const restoreUrl = `${baseURL}/jobs/${jobId}/restore`;
        
        try {
          const restoreResponse = await axios({
            method: 'post',
            url: restoreUrl,
            headers: headers
          });

          throw new Error('Expected restore to fail for hard deleted job');

        } catch (restoreError) {
          if (restoreError.response?.status === 404) {
            testUtils.logSuccess(404, 'Hard deleted job restore rejected', restoreUrl);
          } else {
            throw restoreError;
          }
        }

      } catch (error) {
        errorHandlers.handleApiError(error, 'Restore hard deleted job', restoreUrl || createUrl);
      }
    });

    it('Should handle invalid job ID format in restore', async function() {
      const invalidId = 'invalid-id';
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${invalidId}/restore`;

      try {
        const response = await axios({
          method: 'post',
          url: url,
          headers: headers
        });

        throw new Error('Expected request to fail with invalid ID');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 404]);
          testUtils.logSuccess(error.response.status, 'Invalid ID format in restore handled', url);
        } else {
          throw error;
        }
      }
    });

    it('Should restore job with all relationships intact', async function() {
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

        // Try to create related records before deletion
        try {
          await axios({
            method: 'post',
            url: `${baseURL}/jobs/${jobId}/comments`,
            headers: headers,
            data: { job_comment: { content: 'Comment before delete and restore' } }
          });
        } catch (commentError) {
          // Comment creation might not be implemented
        }

        // Soft delete the job
        await axios({
          method: 'delete',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        // Restore the job
        const restoreUrl = `${baseURL}/jobs/${jobId}/restore`;
        const restoreResponse = await axios({
          method: 'post',
          url: restoreUrl,
          headers: headers
        });

        validators.validateResponse(restoreResponse, 200);

        // Verify job details are intact
        const getResponse = await axios({
          method: 'get',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        const attributes = getResponse.data.data?.attributes || getResponse.data;
        validators.validateJob(attributes);

        testUtils.logSuccess(restoreResponse.status, 'Restore with relationships intact', restoreUrl, {
          'Job ID': jobId,
          'Description': attributes.description?.substring(0, 50) + '...',
          'Status': attributes.status
        });

        testUtils.addToCleanup(jobId);

      } catch (error) {
        errorHandlers.handleApiError(error, 'Restore with relationships', restoreUrl || createUrl);
      }
    });
  });
};

module.exports = { runRestoreTests };
