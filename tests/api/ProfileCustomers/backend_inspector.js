#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

// Configuration
const BACKEND_PATHS = {
  model: '../../../api/app/models/profile_customer.rb',
  controller: '../../../api/app/controllers/api/v1/profile_customers_controller.rb', 
  serializer: '../../../api/app/serializers/profile_customer_serializer.rb',
  service: '../../../api/app/services/profile_customers/',
  filter: '../../../api/app/models/filters/profile_customer_filter.rb',
  policy: '../../../api/app/policies/customer/profile_customer_policy.rb',
  validator: '../../../api/app/validators/'
};

const CACHE_FILE = path.join(__dirname, '.backend_cache.json');

// Color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

// Calculate file hash
function getFileHash(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    return crypto.createHash('md5').update(content).digest('hex');
  } catch (err) {
    return null;
  }
}

// Load cache
function loadCache() {
  try {
    if (fs.existsSync(CACHE_FILE)) {
      return JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
    }
  } catch (err) {
    // Ignore errors
  }
  return {};
}

// Save cache
function saveCache(cache) {
  try {
    fs.writeFileSync(CACHE_FILE, JSON.stringify(cache, null, 2));
  } catch (err) {
    // Ignore errors
  }
}

// Get file info
function getFileInfo(filePath) {
  const fullPath = path.resolve(__dirname, filePath);
  
  if (!fs.existsSync(fullPath)) {
    return { exists: false, path: fullPath };
  }
  
  const stats = fs.statSync(fullPath);
  const hash = getFileHash(fullPath);
  
  // Count lines and methods/actions
  const content = fs.readFileSync(fullPath, 'utf8');
  const lines = content.split('\n').length;
  
  let methods = 0;
  let actions = [];
  
  if (filePath.includes('controller')) {
    // Count controller actions
    const actionMatches = content.match(/^\s*def\s+(\w+)/gm) || [];
    actions = actionMatches.map(m => m.replace(/^\s*def\s+/, ''));
    methods = actions.length;
  } else if (filePath.includes('model') || filePath.includes('serializer')) {
    // Count model/serializer methods
    const methodMatches = content.match(/^\s*def\s+/gm) || [];
    methods = methodMatches.length;
  }
  
  return {
    exists: true,
    path: fullPath,
    size: stats.size,
    modified: stats.mtime,
    hash,
    lines,
    methods,
    actions
  };
}

// Inspect backend files
function inspectBackend(options = {}) {
  const cache = loadCache();
  const results = {
    timestamp: new Date().toISOString(),
    changes: [],
    warnings: [],
    components: {}
  };
  
  console.log(`\n${colors.cyan}${colors.bright}═══ ProfileCustomer Backend Inspector ═══${colors.reset}\n`);
  
  for (const [component, filePath] of Object.entries(BACKEND_PATHS)) {
    // Skip directories for now
    if (component === 'service' || component === 'validator') {
      continue;
    }
    
    const info = getFileInfo(filePath);
    results.components[component] = info;
    
    if (!info.exists) {
      results.warnings.push(`${component} file not found: ${filePath}`);
      console.log(`${colors.yellow}⚠ ${component.padEnd(12)}${colors.reset} - File not found`);
      continue;
    }
    
    const cacheKey = `${component}_${info.path}`;
    const cachedHash = cache[cacheKey];
    
    if (cachedHash && cachedHash !== info.hash) {
      results.changes.push({
        component,
        path: filePath,
        type: 'modified'
      });
      
      console.log(`${colors.red}✗ ${component.padEnd(12)}${colors.reset} - ${colors.yellow}MODIFIED${colors.reset} (${info.lines} lines, ${info.methods} methods)`);
      
      if (options.verbose) {
        console.log(`  Path: ${filePath}`);
        console.log(`  Last modified: ${info.modified}`);
      }
    } else if (!cachedHash) {
      results.changes.push({
        component,
        path: filePath,
        type: 'new'
      });
      
      console.log(`${colors.blue}+ ${component.padEnd(12)}${colors.reset} - ${colors.green}NEW${colors.reset} (${info.lines} lines, ${info.methods} methods)`);
    } else {
      console.log(`${colors.green}✓ ${component.padEnd(12)}${colors.reset} - No changes (${info.lines} lines, ${info.methods} methods)`);
    }
    
    // Update cache
    cache[cacheKey] = info.hash;
    
    // Show controller actions if verbose
    if (options.verbose && component === 'controller' && info.actions.length > 0) {
      console.log(`  Actions: ${info.actions.join(', ')}`);
    }
  }
  
  // Check for service files
  const servicePath = path.resolve(__dirname, BACKEND_PATHS.service);
  if (fs.existsSync(servicePath)) {
    const serviceFiles = fs.readdirSync(servicePath).filter(f => f.endsWith('.rb'));
    if (serviceFiles.length > 0) {
      console.log(`\n${colors.cyan}Services:${colors.reset}`);
      serviceFiles.forEach(file => {
        const info = getFileInfo(path.join(BACKEND_PATHS.service, file));
        console.log(`  ${colors.green}✓${colors.reset} ${file} (${info.lines} lines)`);
      });
      results.components.services = serviceFiles;
    }
  }
  
  // Summary
  console.log(`\n${colors.cyan}${colors.bright}Summary:${colors.reset}`);
  
  if (results.changes.length > 0) {
    console.log(`${colors.yellow}⚠ ${results.changes.length} file(s) changed since last inspection${colors.reset}`);
    
    if (!options.quiet) {
      console.log(`\n${colors.yellow}Changed components:${colors.reset}`);
      results.changes.forEach(change => {
        console.log(`  - ${change.component} (${change.type})`);
      });
      console.log(`\n${colors.cyan}Run individual tests to verify changes:${colors.reset}`);
      results.changes.forEach(change => {
        if (change.component === 'controller') {
          console.log(`  ${colors.bright}npm run test:profile:customer${colors.reset}`);
        }
      });
    }
  } else {
    console.log(`${colors.green}✓ No backend changes detected${colors.reset}`);
  }
  
  if (results.warnings.length > 0) {
    console.log(`\n${colors.red}Warnings:${colors.reset}`);
    results.warnings.forEach(warning => {
      console.log(`  - ${warning}`);
    });
  }
  
  // Save cache
  saveCache(cache);
  
  console.log(`\n${colors.cyan}═══════════════════════════════════════${colors.reset}\n`);
  
  return results;
}

// CLI mode
if (require.main === module) {
  const args = process.argv.slice(2);
  const options = {
    verbose: args.includes('-v') || args.includes('--verbose'),
    quiet: args.includes('-q') || args.includes('--quiet'),
    clear: args.includes('--clear-cache')
  };
  
  if (options.clear) {
    try {
      fs.unlinkSync(CACHE_FILE);
      console.log(`${colors.green}Cache cleared${colors.reset}`);
    } catch (err) {
      // Ignore
    }
  }
  
  if (args.includes('-h') || args.includes('--help')) {
    console.log(`
ProfileCustomer Backend Inspector

Usage: node backend_inspector.js [options]

Options:
  -v, --verbose      Show detailed information
  -q, --quiet        Minimal output
  --clear-cache      Clear the cache before inspecting
  -h, --help         Show this help message

This tool inspects ProfileCustomer backend files for changes and reports
any modifications since the last inspection.
    `);
    process.exit(0);
  }
  
  const results = inspectBackend(options);
  
  // Exit with error code if changes detected
  if (results.changes.length > 0) {
    process.exit(1);
  }
}

module.exports = { inspectBackend };