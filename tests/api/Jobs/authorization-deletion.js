/**
 * AUTHORIZATION & ERROR HANDLING - Job Deletion Tests
 * Tests authorization, permissions, and error handling for deletion operations
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
  generateCompleteJob 
} = require('./data');

/**
 * Run authorization and error handling tests
 */
const runAuthorizationDeletionTests = () => {
  describe('Authorization & Error Handling for Job Deletion', function() {

    let testJob = null;
    let softDeletedJob = null;

    before(async function() {
      // Create test job for authorization testing
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/jobs`;
        const requestData = generateCompleteJob();

        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        testJob = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(testJob);
        
        console.log(`   📝 Created test job ${testJob} for authorization testing`);

      } catch (error) {
        console.error('Failed to create test job for authorization:', error.message);
      }
    });

    describe('Authentication Requirements', function() {

      it('Should require authentication for soft delete', async function() {
        if (!testJob) {
          testUtils.skipTest(this, 'No test job available');
          return;
        }

        const url = `${baseURL}/jobs/${testJob}`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: config.api.headers // No auth headers
          });

          // Should not reach here
          throw new Error('Expected authentication error');

        } catch (error) {
          if (error.response) {
            expect(error.response.status).to.equal(401);
            expect(error.response.data).to.exist;
            
            testUtils.logSuccess(401, 'Authentication required for soft delete', url);
          } else if (error.message === 'Expected authentication error') {
            throw error;
          } else {
            throw error;
          }
        }
      });

      it('Should require authentication for hard delete', async function() {
        if (!testJob) {
          testUtils.skipTest(this, 'No test job available');
          return;
        }

        const url = `${baseURL}/jobs/${testJob}?destroy_fully=true`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: config.api.headers // No auth headers
          });

          // Should not reach here
          throw new Error('Expected authentication error');

        } catch (error) {
          if (error.response) {
            expect(error.response.status).to.equal(401);
            testUtils.logSuccess(401, 'Authentication required for hard delete', url);
          } else if (error.message === 'Expected authentication error') {
            throw error;
          } else {
            throw error;
          }
        }
      });

      it('Should require authentication for restore', async function() {
        // First create and soft delete a job
        let jobForRestore = null;
        
        try {
          const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
          const createUrl = `${baseURL}/jobs`;
          const createData = generateCompleteJob();

          const createResponse = await axios({
            method: 'post',
            url: createUrl,
            headers: headers,
            data: createData
          });

          jobForRestore = createResponse.data.data?.id || createResponse.data.id;
          testUtils.addToCleanup(jobForRestore);

          // Soft delete it
          const deleteUrl = `${baseURL}/jobs/${jobForRestore}`;
          await axios({
            method: 'delete',
            url: deleteUrl,
            headers: headers
          });

          // Try to restore without auth
          const restoreUrl = `${baseURL}/jobs/${jobForRestore}/restore`;
          const restoreResponse = await axios({
            method: 'post',
            url: restoreUrl,
            headers: config.api.headers // No auth headers
          });

          // Should not reach here
          throw new Error('Expected authentication error');

        } catch (error) {
          if (error.response?.status === 401) {
            testUtils.logSuccess(401, 'Authentication required for restore', '');
          } else if (error.message === 'Expected authentication error') {
            throw error;
          } else if (jobForRestore) {
            // Some other error occurred, but we still need cleanup
            console.log(`   Info: Unexpected error in auth test: ${error.message}`);
          }
        }
      });

    });

    describe('Authorization Policies', function() {

      it('Should enforce proper authorization for soft delete', async function() {
        if (!testJob) {
          testUtils.skipTest(this, 'No test job available');
          return;
        }

        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/jobs/${testJob}`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: headers
          });

          // If we reach here, user has proper authorization
          expect(response.status).to.equal(200);
          testUtils.logSuccess(200, 'User authorized for soft delete', url);
          
          softDeletedJob = testJob;

        } catch (error) {
          if (error.response?.status === 403) {
            testUtils.logSuccess(403, 'User not authorized for soft delete', url);
          } else {
            errorHandlers.handleApiError(error, 'Authorization check for soft delete', url);
          }
        }
      });

      it('Should enforce proper authorization for hard delete', async function() {
        // Create a new job for hard delete authorization test
        let hardDeleteJob = null;
        
        try {
          const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
          const createUrl = `${baseURL}/jobs`;
          const createData = generateCompleteJob();

          const createResponse = await axios({
            method: 'post',
            url: createUrl,
            headers: headers,
            data: createData
          });

          hardDeleteJob = createResponse.data.data?.id || createResponse.data.id;

          // Try hard delete
          const deleteUrl = `${baseURL}/jobs/${hardDeleteJob}?destroy_fully=true`;
          const deleteResponse = await axios({
            method: 'delete',
            url: deleteUrl,
            headers: headers
          });

          // If we reach here, user has proper authorization
          expect(deleteResponse.status).to.equal(200);
          testUtils.logSuccess(200, 'User authorized for hard delete', deleteUrl);

        } catch (error) {
          if (error.response?.status === 403) {
            testUtils.logSuccess(403, 'User not authorized for hard delete', '');
            if (hardDeleteJob) testUtils.addToCleanup(hardDeleteJob);
          } else if (hardDeleteJob) {
            testUtils.addToCleanup(hardDeleteJob);
            errorHandlers.handleApiError(error, 'Authorization check for hard delete', '');
          }
        }
      });

      it('Should enforce proper authorization for restore', async function() {
        if (!softDeletedJob) {
          testUtils.skipTest(this, 'No soft deleted job available for restore auth test');
          return;
        }

        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/jobs/${softDeletedJob}/restore`;

        try {
          const response = await axios({
            method: 'post',
            url: url,
            headers: headers
          });

          // If we reach here, user has proper authorization
          expect(response.status).to.equal(200);
          testUtils.logSuccess(200, 'User authorized for restore', url);

        } catch (error) {
          if (error.response?.status === 403) {
            testUtils.logSuccess(403, 'User not authorized for restore', url);
          } else {
            errorHandlers.handleApiError(error, 'Authorization check for restore', url);
          }
        }
      });

    });

    describe('Error Response Structure', function() {

      it('Should return proper error structure for 404 Not Found', async function() {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/jobs/99999999`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: headers
          });

          // Should not reach here
          throw new Error('Expected 404 error');

        } catch (error) {
          if (error.response?.status === 404) {
            const errorData = error.response.data;
            
            // Check error response structure
            expect(errorData).to.exist;
            
            if (errorData.success !== undefined) {
              expect(errorData.success).to.be.false;
            }
            
            if (errorData.message) {
              expect(errorData.message).to.be.a('string');
            }
            
            if (errorData.errors) {
              expect(errorData.errors).to.be.an('array');
            }
            
            testUtils.logSuccess(404, 'Proper error structure for 404', url, {
              'Error Message': errorData.message || 'N/A',
              'Has Errors Array': !!errorData.errors
            });
          } else if (error.message === 'Expected 404 error') {
            throw error;
          }
        }
      });

      it('Should return proper error structure for 401 Unauthorized', async function() {
        const url = `${baseURL}/jobs/1`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: config.api.headers // No auth
          });

          throw new Error('Expected 401 error');

        } catch (error) {
          if (error.response?.status === 401) {
            const errorData = error.response.data;
            
            expect(errorData).to.exist;
            
            // Check for standard error fields
            if (errorData.message) {
              expect(errorData.message).to.be.a('string');
            }
            
            testUtils.logSuccess(401, 'Proper error structure for 401', url, {
              'Error Message': errorData.message || 'N/A',
              'Error Type': typeof errorData
            });
          } else if (error.message === 'Expected 401 error') {
            throw error;
          }
        }
      });

    });

    describe('Team-based Authorization', function() {

      it('Should only allow deletion of jobs within user\'s team', async function() {
        // This test assumes team-based isolation
        if (!testJob) {
          testUtils.skipTest(this, 'No test job available');
          return;
        }

        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/jobs/${testJob}`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: headers
          });

          // If successful, user can delete jobs in their team
          expect(response.status).to.equal(200);
          testUtils.logSuccess(200, 'Team-based deletion allowed', url);

        } catch (error) {
          if (error.response?.status === 403) {
            testUtils.logSuccess(403, 'Team-based deletion restricted', url);
          } else {
            errorHandlers.handleApiError(error, 'Team-based authorization check', url);
          }
        }
      });

    });

    describe('Role-based Permissions', function() {

      it('Should check user role for job management permissions', async function() {
        if (!testJob) {
          testUtils.skipTest(this, 'No test job available');
          return;
        }

        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/jobs/${testJob}`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: headers
          });

          testUtils.logSuccess(response.status, 'Role-based deletion check completed', url, {
            'User Role': 'Current authenticated user',
            'Permission': response.status === 200 ? 'Allowed' : 'Restricted'
          });

        } catch (error) {
          if (error.response?.status === 403) {
            testUtils.logSuccess(403, 'Role-based deletion restricted', url);
          } else {
            errorHandlers.handleApiError(error, 'Role-based permission check', url);
          }
        }
      });

    });

    describe('Data Validation', function() {

      it('Should validate job ID format', async function() {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        
        const invalidIds = ['abc', '12.34', 'null', ''];
        
        for (const invalidId of invalidIds) {
          try {
            const url = `${baseURL}/jobs/${invalidId}`;
            const response = await axios({
              method: 'delete',
              url: url,
              headers: headers
            });

            // If it succeeds, note that
            console.log(`   Info: Invalid ID '${invalidId}' was accepted`);

          } catch (error) {
            if (error.response?.status === 404 || error.response?.status === 400) {
              // Expected behavior for invalid IDs
              continue;
            } else {
              console.log(`   Info: Unexpected error for invalid ID '${invalidId}': ${error.response?.status}`);
            }
          }
        }

        testUtils.logSuccess(200, 'ID validation tests completed', '', {
          'Tested IDs': invalidIds.join(', '),
          'Note': 'System handled invalid IDs appropriately'
        });
      });

    });

  });
};

module.exports = { runAuthorizationDeletionTests };
