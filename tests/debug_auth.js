#!/usr/bin/env node

/**
 * Debug Authentication Response
 *
 * This script helps debug the actual response structure from your auth endpoint
 * to understand why the isolated test works but the generated tests don't.
 */

const axios = require('axios');
const fs = require('fs');
const path = require('path');

async function debugAuth() {
  console.log('🔍 Debugging Authentication Response Structure');
  console.log('═══════════════════════════════════════════════');

  try {
    // Load config
    const configPath = path.join(__dirname, 'test_config.json');
    const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

    const authUrl = `${config.api.baseUrl}${config.api.auth.tokenEndpoint}`;
    console.log(`🌐 Auth URL: ${authUrl}`);
    console.log(`👤 Credentials: ${config.api.auth.testCredentials.email}`);

    const response = await axios.post(authUrl, config.api.auth.testCredentials, {
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      timeout: 10000
    });

    console.log(`\n📊 Response Status: ${response.status}`);
    console.log(`📋 Full Response Structure:`);
    console.log('═'.repeat(50));
    console.log(JSON.stringify(response.data, null, 2));
    console.log('═'.repeat(50));

    // Test different token extraction methods
    console.log('\n🔍 Token Extraction Tests:');
    console.log('───────────────────────────');

    const tokenTests = {
      'response.data.token': response.data.token,
      'response.data.access_token': response.data.access_token,
      'response.data.auth_token': response.data.auth_token,
      'response.data.jwt': response.data.jwt,
      'response.data.data?.token': response.data.data?.token,
      'response.data.user?.token': response.data.user?.token,
      'response.data.authentication?.token': response.data.authentication?.token,
      'response.data.session?.token': response.data.session?.token
    };

    let foundToken = null;
    let foundMethod = null;

    Object.entries(tokenTests).forEach(([method, value]) => {
      const status = value ? '✅ FOUND' : '❌ Not found';
      console.log(`${method}: ${status}`);

      if (value && !foundToken) {
        foundToken = value;
        foundMethod = method;
      }
    });

    if (foundToken) {
      console.log(`\n🎯 WORKING METHOD: ${foundMethod}`);
      console.log(`🎫 Token: ${foundToken.substring(0, 30)}...`);

      // Generate the correct extraction code
      console.log('\n📝 Code to use in generated tests:');
      console.log('─'.repeat(40));
      console.log(`authToken = ${foundMethod};`);
      console.log('─'.repeat(40));

    } else {
      console.log('\n❌ NO TOKEN FOUND in any expected location!');
    }

    // Show what the isolated test is doing differently
    console.log('\n🔬 Isolated Test Method:');
    const isolatedMethod = response.data.token ||
                          response.data.access_token ||
                          response.data.auth_token ||
                          response.data.jwt ||
                          response.data.data?.token;

    console.log(`Result: ${isolatedMethod ? '✅ ' + isolatedMethod.substring(0, 30) + '...' : '❌ Not found'}`);

    // Show what the generated test is doing
    console.log('\n🤖 Generated Test Method:');
    const generatedMethod = response.data.token || response.data.access_token || response.data.auth_token;
    console.log(`Result: ${generatedMethod ? '✅ ' + generatedMethod.substring(0, 30) + '...' : '❌ Not found'}`);

    if (isolatedMethod && !generatedMethod) {
      console.log('\n💡 FOUND THE ISSUE!');
      console.log('The isolated test finds the token but the generated test doesn\'t.');
      console.log('The token is likely in a nested location that the generated test doesn\'t check.');
    }

  } catch (error) {
    console.error('❌ Debug failed:', error.message);
    if (error.response) {
      console.error('Response data:', error.response.data);
    }
  }
}

// Run the debug
debugAuth();
