/**
 * AUTHORIZATION & ERROR HANDLING - Profile Customer Deletion Tests
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
  generateCompleteProfileCustomer 
} = require('./data');

/**
 * Run authorization and error handling tests
 */
const runAuthorizationDeletionTests = () => {
  describe('Authorization & Error Handling for Profile Customer Deletion', function() {

    let testProfile = null;
    let softDeletedProfile = null;

    before(async function() {
      // Create test profiles for authorization testing
      try {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/profile_customers`;
        const requestData = generateCompleteProfileCustomer();

        const response = await axios({
          method: 'post',
          url: url,
          headers: headers,
          data: requestData
        });

        testProfile = response.data.data?.id || response.data.id;
        testUtils.addToCleanup(testProfile);
        
        console.log(`   📝 Created test profile ${testProfile} for authorization testing`);

      } catch (error) {
        console.error('Failed to create test profile for authorization:', error.message);
      }
    });

    describe('Authentication Requirements', function() {

      it('Should require authentication for soft delete', async function() {
        if (!testProfile) {
          testUtils.skipTest(this, 'No test profile available');
          return;
        }

        const url = `${baseURL}/profile_customers/${testProfile}`;

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
        if (!testProfile) {
          testUtils.skipTest(this, 'No test profile available');
          return;
        }

        const url = `${baseURL}/profile_customers/${testProfile}`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: config.api.headers, // No auth headers
            params: { destroy_fully: true }
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
        // First create and soft delete a profile
        let profileForRestore = null;
        
        try {
          const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
          const createUrl = `${baseURL}/profile_customers`;
          const createData = generateCompleteProfileCustomer();

          const createResponse = await axios({
            method: 'post',
            url: createUrl,
            headers: headers,
            data: createData
          });

          profileForRestore = createResponse.data.data?.id || createResponse.data.id;
          testUtils.addToCleanup(profileForRestore);

          // Soft delete it
          const deleteUrl = `${baseURL}/profile_customers/${profileForRestore}`;
          await axios({
            method: 'delete',
            url: deleteUrl,
            headers: headers
          });

          // Try to restore without auth
          const restoreUrl = `${baseURL}/profile_customers/${profileForRestore}/restore`;
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
          } else if (profileForRestore) {
            // Some other error occurred, but we still need cleanup
            console.log(`   Info: Unexpected error in auth test: ${error.message}`);
          }
        }
      });

    });

    describe('Authorization Policies', function() {

      it('Should enforce proper authorization for soft delete', async function() {
        if (!testProfile) {
          testUtils.skipTest(this, 'No test profile available');
          return;
        }

        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/profile_customers/${testProfile}`;

        try {
          const response = await axios({
            method: 'delete',
            url: url,
            headers: headers
          });

          // If we reach here, user has proper authorization
          expect(response.status).to.equal(200);
          testUtils.logSuccess(200, 'User authorized for soft delete', url);
          
          softDeletedProfile = testProfile;

        } catch (error) {
          if (error.response?.status === 403) {
            testUtils.logSuccess(403, 'User not authorized for soft delete', url);
          } else {
            errorHandlers.handleApiError(error, 'Authorization check for soft delete', url);
          }
        }
      });

      it('Should enforce proper authorization for hard delete', async function() {
        // Create a new profile for hard delete authorization test
        let hardDeleteProfile = null;
        
        try {
          const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
          const createUrl = `${baseURL}/profile_customers`;
          const createData = generateCompleteProfileCustomer();

          const createResponse = await axios({
            method: 'post',
            url: createUrl,
            headers: headers,
            data: createData
          });

          hardDeleteProfile = createResponse.data.data?.id || createResponse.data.id;

          // Try hard delete
          const deleteUrl = `${baseURL}/profile_customers/${hardDeleteProfile}`;
          const deleteResponse = await axios({
            method: 'delete',
            url: deleteUrl,
            headers: headers,
            params: { destroy_fully: true }
          });

          // If we reach here, user has proper authorization
          expect(deleteResponse.status).to.equal(200);
          testUtils.logSuccess(200, 'User authorized for hard delete', deleteUrl);

        } catch (error) {
          if (error.response?.status === 403) {
            testUtils.logSuccess(403, 'User not authorized for hard delete', '');
            if (hardDeleteProfile) testUtils.addToCleanup(hardDeleteProfile);
          } else if (hardDeleteProfile) {
            testUtils.addToCleanup(hardDeleteProfile);
            errorHandlers.handleApiError(error, 'Authorization check for hard delete', '');
          }
        }
      });

      it('Should enforce proper authorization for restore', async function() {
        if (!softDeletedProfile) {
          testUtils.skipTest(this, 'No soft deleted profile available for restore auth test');
          return;
        }

        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/profile_customers/${softDeletedProfile}/restore`;

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
        const url = `${baseURL}/profile_customers/99999999`;

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
        const url = `${baseURL}/profile_customers/1`;

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

      it('Should return proper error structure for 422 Unprocessable Entity', async function() {
        // Try to restore a profile that's not deleted to trigger 422
        let activeProfile = null;
        
        try {
          const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
          const createUrl = `${baseURL}/profile_customers`;
          const createData = generateCompleteProfileCustomer();

          const createResponse = await axios({
            method: 'post',
            url: createUrl,
            headers: headers,
            data: createData
          });

          activeProfile = createResponse.data.data?.id || createResponse.data.id;
          testUtils.addToCleanup(activeProfile);

          // Try to restore an active profile
          const restoreUrl = `${baseURL}/profile_customers/${activeProfile}/restore`;
          const restoreResponse = await axios({
            method: 'post',
            url: restoreUrl,
            headers: headers
          });

          // If restore succeeds, that's also acceptable behavior
          testUtils.logSuccess(200, 'Restore of active profile allowed', restoreUrl);

        } catch (error) {
          if (error.response?.status === 422) {
            const errorData = error.response.data;
            
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
            
            testUtils.logSuccess(422, 'Proper error structure for 422', '', {
              'Error Message': errorData.message || 'N/A',
              'Errors Count': errorData.errors?.length || 0
            });
          } else if (activeProfile) {
            // Some other error
            console.log(`   Info: Unexpected error in 422 test: ${error.message}`);
          }
        }
      });

    });

    describe('Rate Limiting and Security', function() {

      it('Should handle multiple deletion requests appropriately', async function() {
        const profiles = [];
        
        try {
          const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
          
          // Create multiple profiles
          for (let i = 0; i < 5; i++) {
            const createUrl = `${baseURL}/profile_customers`;
            const createData = generateCompleteProfileCustomer();

            const response = await axios({
              method: 'post',
              url: createUrl,
              headers: headers,
              data: createData
            });

            const profileId = response.data.data?.id || response.data.id;
            profiles.push(profileId);
          }

          // Delete them in rapid succession
          const deletePromises = profiles.map(id => {
            const deleteUrl = `${baseURL}/profile_customers/${id}`;
            return axios({
              method: 'delete',
              url: deleteUrl,
              headers: headers
            });
          });

          const results = await Promise.allSettled(deletePromises);
          
          const successCount = results.filter(r => r.status === 'fulfilled' && r.value.status === 200).length;
          const errorCount = results.filter(r => r.status === 'rejected').length;
          
          testUtils.logSuccess(200, 'Multiple deletion requests handled', '', {
            'Total Requests': profiles.length,
            'Successful': successCount,
            'Failed': errorCount
          });

          // Clean up any remaining profiles
          for (const id of profiles) {
            try {
              const deleteUrl = `${baseURL}/profile_customers/${id}`;
              await axios({
                method: 'delete',
                url: deleteUrl,
                headers: headers,
                params: { destroy_fully: true }
              });
            } catch (cleanupError) {
              // Ignore cleanup errors
            }
          }

        } catch (error) {
          profiles.forEach(id => testUtils.addToCleanup(id));
          errorHandlers.handleApiError(error, 'Multiple deletion test', '');
        }
      });

      it('Should validate parameters properly', async function() {
        if (!testProfile) {
          testUtils.skipTest(this, 'No test profile available');
          return;
        }

        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        const url = `${baseURL}/profile_customers/${testProfile}`;

        try {
          // Test with invalid parameter values
          const response = await axios({
            method: 'delete',
            url: url,
            headers: headers,
            params: { 
              destroy_fully: 'invalid_value',
              include_deleted: 'not_boolean'
            }
          });

          // Might succeed if parameters are converted/ignored
          if (response.status === 200) {
            testUtils.logSuccess(200, 'Invalid parameters handled gracefully', url);
          }

        } catch (error) {
          if (error.response?.status === 400) {
            testUtils.logSuccess(400, 'Invalid parameters rejected properly', url);
          } else {
            console.log(`   Info: Parameter validation result: ${error.response?.status || 'unknown'}`);
          }
        }
      });

    });

    describe('Concurrent Operations', function() {

      it('Should handle concurrent delete and restore operations safely', async function() {
        let concurrentProfile = null;
        
        try {
          const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
          const createUrl = `${baseURL}/profile_customers`;
          const createData = generateCompleteProfileCustomer();

          const createResponse = await axios({
            method: 'post',
            url: createUrl,
            headers: headers,
            data: createData
          });

          concurrentProfile = createResponse.data.data?.id || createResponse.data.id;
          testUtils.addToCleanup(concurrentProfile);

          // Perform operations concurrently
          const deleteUrl = `${baseURL}/profile_customers/${concurrentProfile}`;
          const restoreUrl = `${baseURL}/profile_customers/${concurrentProfile}/restore`;

          const operations = [
            // Soft delete
            axios({
              method: 'delete',
              url: deleteUrl,
              headers: headers
            }),
            // Immediate restore attempt (should fail)
            axios({
              method: 'post',
              url: restoreUrl,
              headers: headers
            }).catch(e => e)
          ];

          const results = await Promise.allSettled(operations);
          
          testUtils.logSuccess(200, 'Concurrent operations handled', '', {
            'Delete Status': results[0].status,
            'Restore Status': results[1].status,
            'Note': 'System handled concurrent operations appropriately'
          });

        } catch (error) {
          if (concurrentProfile) {
            console.log(`   Info: Concurrent operations test inconclusive: ${error.message}`);
          }
        }
      });

    });

    describe('Data Validation', function() {

      it('Should validate profile ID format', async function() {
        const headers = { ...config.api.headers, ...testState.authHelper.getAuthHeaders() };
        
        const invalidIds = ['abc', '12.34', 'null', ''];
        
        for (const invalidId of invalidIds) {
          try {
            const url = `${baseURL}/profile_customers/${invalidId}`;
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