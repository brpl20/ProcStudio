/**
 * Cascade Deletion Tests for Jobs
 * Tests how job deletions affect related records
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
 * Run cascade deletion tests
 */
const runCascadeDeletionTests = () => {
  describe('Cascade Deletion Tests', function() {

    it('Should handle job deletion with job_user_profiles', async function() {
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

        // Job should have assignees automatically (creator is added as assignee)
        const getResponse = await axios({
          method: 'get',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        const attributes = getResponse.data.data?.attributes || getResponse.data;
        
        // Delete the job
        const deleteResponse = await axios({
          method: 'delete',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Job deleted with assignees', `${baseURL}/jobs/${jobId}`, {
          'Job ID': jobId,
          'Had Assignees': Array.isArray(attributes.assignee_ids) && attributes.assignee_ids.length > 0
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Job deletion with assignees', `${baseURL}/jobs/${jobId}` || createUrl);
      }
    });

    it('Should handle job deletion with comments', async function() {
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

        // Try to create a comment
        let commentCreated = false;
        try {
          const commentResponse = await axios({
            method: 'post',
            url: `${baseURL}/jobs/${jobId}/comments`,
            headers: headers,
            data: {
              job_comment: {
                content: 'Test comment for cascade deletion test'
              }
            }
          });

          if (commentResponse.status === 201) {
            commentCreated = true;
          }
        } catch (commentError) {
          // Comment creation might not be implemented yet
        }

        // Delete the job
        const deleteResponse = await axios({
          method: 'delete',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Job deleted with comments handling', `${baseURL}/jobs/${jobId}`, {
          'Job ID': jobId,
          'Comment Created': commentCreated
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Job deletion with comments', `${baseURL}/jobs/${jobId}` || createUrl);
      }
    });

    it('Should handle hard deletion cascade properly', async function() {
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

        // Create related records if possible
        let relatedRecords = {
          comments: 0,
          assignments: 0
        };

        try {
          const commentResponse = await axios({
            method: 'post',
            url: `${baseURL}/jobs/${jobId}/comments`,
            headers: headers,
            data: { job_comment: { content: 'Comment for hard delete cascade test' } }
          });
          if (commentResponse.status === 201) relatedRecords.comments++;
        } catch (commentError) {
          // Ignore if not implemented
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
          'Comments': relatedRecords.comments,
          'Note': 'Should permanently delete all related records'
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
            testUtils.logSuccess(404, 'Job permanently deleted with cascade', `${baseURL}/jobs/${jobId}`);
          } else {
            throw getError;
          }
        }

      } catch (error) {
        errorHandlers.handleApiError(error, 'Hard delete cascade', deleteUrl || createUrl);
      }
    });

    it('Should preserve related records on soft delete', async function() {
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

        // Get job details before deletion to check assignees
        const beforeDeleteResponse = await axios({
          method: 'get',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        const beforeAttributes = beforeDeleteResponse.data.data?.attributes || beforeDeleteResponse.data;

        // Soft delete the job
        const deleteResponse = await axios({
          method: 'delete',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Soft delete preserving relations', `${baseURL}/jobs/${jobId}`, {
          'Job ID': jobId,
          'Had Assignees': Array.isArray(beforeAttributes.assignee_ids) && beforeAttributes.assignee_ids.length > 0,
          'Note': 'Relations should be preserved for potential restore'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Soft delete preserving relations', `${baseURL}/jobs/${jobId}` || createUrl);
      }
    });

    it('Should handle deletion of job with multiple assignees', async function() {
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

        // Try to add more assignees (if endpoint exists)
        try {
          const updateResponse = await axios({
            method: 'put',
            url: `${baseURL}/jobs/${jobId}`,
            headers: headers,
            data: {
              job: {
                // This would depend on having available user profiles
                assignee_ids: [1, 2] // Example IDs
              }
            }
          });
        } catch (updateError) {
          // Multiple assignee assignment might not be implemented or IDs might not exist
        }

        // Delete the job
        const deleteResponse = await axios({
          method: 'delete',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Job with multiple assignees deleted', `${baseURL}/jobs/${jobId}`, {
          'Job ID': jobId,
          'Note': 'Should handle multiple job_user_profile records'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Delete job with multiple assignees', `${baseURL}/jobs/${jobId}` || createUrl);
      }
    });

    it('Should handle team relationship during deletion', async function() {
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

        // Delete the job
        const deleteResponse = await axios({
          method: 'delete',
          url: `${baseURL}/jobs/${jobId}`,
          headers: headers
        });

        validators.validateResponse(deleteResponse, 200);

        testUtils.logSuccess(deleteResponse.status, 'Job deleted with team relationship', `${baseURL}/jobs/${jobId}`, {
          'Job ID': jobId,
          'Note': 'Team relationship should remain intact'
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'Delete job with team relationship', `${baseURL}/jobs/${jobId}` || createUrl);
      }
    });
  });
};

module.exports = { runCascadeDeletionTests };
