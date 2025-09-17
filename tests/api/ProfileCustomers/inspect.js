#!/usr/bin/env node

/**
 * Standalone backend inspector runner
 * Usage: node api/ProfileCustomers/inspect.js [options]
 */

const { inspectBackend } = require('./backend_inspector');

// Parse command line arguments
const args = process.argv.slice(2);
const options = {
  verbose: args.includes('-v') || args.includes('--verbose'),
  quiet: args.includes('-q') || args.includes('--quiet'),
  clear: args.includes('--clear-cache')
};

if (args.includes('-h') || args.includes('--help')) {
  console.log(`
ProfileCustomer Backend Inspector

Usage: node api/ProfileCustomers/inspect.js [options]

Options:
  -v, --verbose      Show detailed information
  -q, --quiet        Minimal output
  --clear-cache      Clear the cache before inspecting
  -h, --help         Show this help message

This tool inspects ProfileCustomer backend files for changes.
  `);
  process.exit(0);
}

// Run inspection
inspectBackend(options);