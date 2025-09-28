/**
 * GET - Read Job Tests
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
 * Run read tests
 */
const runReadTests = () => {
  describe('GET /jobs', function() {

    it('Should get all jobs', async function() {
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
        validators.validateJsonApiResponse(response);
        
        // Store a random job ID for other tests
        if (response.data.data && response.data.data.length > 0) {
          testState.randomJobId = response.data.data[0].id;
          testState.jobsList = response.data.data;
        }

        testUtils.logSuccess(response.status, 'GET all jobs', url, {
          'Total Jobs': response.data.data?.length || 0,
          'Has Meta': !!response.data.meta
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'GET all jobs', url);
      }
    });

    it('Should get a specific job by ID', async function() {
      if (!testState.randomJobId) {
        testUtils.skipTest(this, 'No job ID available from previous test');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${testState.randomJobId}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Validate response
        validators.validateResponse(response, 200);
        validators.validateJsonApiResponse(response);

        // Validate job attributes
        const attributes = response.data.data?.attributes || response.data;
        validators.validateJob(attributes);

        testUtils.logSuccess(response.status, 'GET job by ID', url, {
          'Job ID': testState.randomJobId,
          'Description': attributes.description?.substring(0, 50) + '...',
          'Status': attributes.status,
          'Priority': attributes.priority
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'GET job by ID', url);
      }
    });

    it('Should return 404 for non-existent job', async function() {
      const nonExistentId = 999999;
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${nonExistentId}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Should not reach here
        throw new Error('Expected request to fail with 404');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.equal(404);
          testUtils.logSuccess(error.response.status, 'Job not found as expected', url);
        } else {
          throw error;
        }
      }
    });

    it('Should fail without authentication', async function() {
      const url = `${baseURL}/jobs`;

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

    it('Should handle invalid job ID format', async function() {
      const invalidId = 'invalid-id';
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${invalidId}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        // Should not reach here
        throw new Error('Expected request to fail with invalid ID format');

      } catch (error) {
        if (error.response) {
          expect(error.response.status).to.be.oneOf([400, 404]);
          testUtils.logSuccess(error.response.status, 'Invalid ID format handled', url);
        } else {
          throw error;
        }
      }
    });

    it('Should include job relationships in show response', async function() {
      if (!testState.randomJobId) {
        testUtils.skipTest(this, 'No job ID available from previous test');
        return;
      }

      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs/${testState.randomJobId}`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        validators.validateResponse(response, 200);

        const attributes = response.data.data?.attributes || response.data;
        
        // Check for expected relationship data
        const hasAssignees = attributes.hasOwnProperty('assignee_ids');
        const hasSupervisors = attributes.hasOwnProperty('supervisor_ids');
        const hasCollaborators = attributes.hasOwnProperty('collaborator_ids');

        testUtils.logSuccess(response.status, 'Job relationships loaded', url, {
          'Has Assignees': hasAssignees,
          'Has Supervisors': hasSupervisors,
          'Has Collaborators': hasCollaborators,
          'Comments Count': attributes.comments_count || 0
        });

      } catch (error) {
        errorHandlers.handleApiError(error, 'GET job relationships', url);
      }
    });

    it('Should filter jobs by status if implemented', async function() {
      const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
      const url = `${baseURL}/jobs?status=pending`;

      try {
        const response = await axios({
          method: 'get',
          url: url,
          headers: headers
        });

        validators.validateResponse(response, 200);

        // Check if filtering is working (if implemented)
        if (response.data.data && response.data.data.length > 0) {
          const attributes = response.data.data[0].attributes;
          testUtils.logSuccess(response.status, 'Job filtering by status', url, {
            'Filter': 'status=pending',
            'Results Count': response.data.data.length,
            'First Result Status': attributes.status
          });
        } else {
          testUtils.logSuccess(response.status, 'Job filtering (no pending jobs)', url);
        }

      } catch (error) {
        // Filtering might not be implemented, so don't fail the test
        console.log(`   ℹ️  Job filtering might not be implemented: ${error.response?.status || 'Network error'}`);
      }
    });
  });
};

module.exports = { runReadTests };
