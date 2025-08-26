#!/usr/bin/env node

/**
 * Simple Authentication Only Test
 *
 * This script tests ONLY the authentication method to verify
 * JWT token retrieval works with your specific API setup.
 */

const axios = require('axios');
const fs = require('fs');
const path = require('path');

async function testAuthOnly() {
  console.log('🔐 Testing Authentication Only');
  console.log('════════════════════════════════');

  try {
    // Load config
    console.log('📋 Loading configuration...');
    const configPath = path.join(__dirname, 'test_config.json');
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

    // Display config info
    console.log(`📍 API Base URL: ${config.api.baseUrl}`);
    console.log(`🔑 Auth Endpoint: ${config.api.auth.tokenEndpoint}`);
    console.log(`👤 Test User: ${config.api.auth.testCredentials.email}`);

    // Build auth URL
    const authUrl = `${config.api.baseUrl}${config.api.auth.tokenEndpoint}`;
    console.log(`\n🌐 Full Auth URL: ${authUrl}`);

    // Test authentication
    console.log('\n🚀 Attempting authentication...');

    const response = await axios.post(authUrl, config.api.auth.testCredentials, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      timeout: 10000
    });

    console.log(`📊 Response Status: ${response.status}`);
    console.log(`📦 Response Headers:`, response.headers['content-type']);

    // Look for token in different possible locations
    const token = response.data.token ||
                  response.data.access_token ||
                  response.data.auth_token ||
                  response.data.jwt ||
                  response.data.data?.token;

    if (token) {
      console.log('✅ SUCCESS! Token received');
      console.log(`🎫 Token (first 30 chars): ${token.substring(0, 30)}...`);
      console.log(`📏 Token Length: ${token.length} characters`);

      // Validate JWT format
      const parts = token.split('.');
      if (parts.length === 3) {
        console.log('✅ Token has valid JWT format (3 parts)');

        // Try to decode header and payload (for info only)
        try {
          const header = JSON.parse(Buffer.from(parts[0], 'base64').toString());
          const payload = JSON.parse(Buffer.from(parts[1], 'base64').toString());
          console.log(`🔍 Token Algorithm: ${header.alg}`);
          console.log(`⏰ Token Expires: ${payload.exp ? new Date(payload.exp * 1000).toISOString() : 'Not specified'}`);
        } catch (decodeError) {
          console.log('ℹ️  Could not decode token payload (might be encrypted)');
        }
      } else {
        console.log('⚠️  Token does not appear to be in JWT format');
      }

      console.log('\n🎉 AUTHENTICATION TEST PASSED!');
      console.log('✅ Your auth setup is working correctly');
      return true;

    } else {
      console.log('❌ FAILED! No token found in response');
      console.log('📋 Full Response Data:');
      console.log(JSON.stringify(response.data, null, 2));
      return false;
    }

  } catch (error) {
    console.log('❌ AUTHENTICATION FAILED');
    console.log(`💥 Error: ${error.message}`);

    if (error.response) {
      console.log(`📊 Status Code: ${error.response.status}`);
      console.log(`📋 Response Data:`, error.response.data);

      if (error.response.status === 401) {
        console.log('🔒 This looks like invalid credentials');
      } else if (error.response.status === 404) {
        console.log('🔍 This looks like wrong endpoint URL');
      } else if (error.response.status === 500) {
        console.log('🚨 This looks like a server error');
      }
    } else if (error.code === 'ECONNREFUSED') {
      console.log('🌐 Cannot connect to server - is it running?');
      console.log('💡 Try: bundle exec rails server');
    } else if (error.code === 'ETIMEDOUT') {
      console.log('⏰ Request timed out - server might be slow');
    }

    return false;
  }
}

// Run the test
if (require.main === module) {
  console.log('Simple Auth Test for ProcStudio API\n');

  testAuthOnly().then(success => {
    if (success) {
      console.log('\n✅ Ready for full API testing!');
      console.log('🚀 Next step: npm run test:api');
      process.exit(0);
    } else {
      console.log('\n❌ Fix authentication issues before running full tests');
      console.log('🔧 Check your credentials and server setup');
      process.exit(1);
    }
  }).catch(error => {
    console.log('💥 Test crashed:', error.message);
    process.exit(1);
  });
}
