/**
 * Backend Inspector for Jobs
 * Inspects backend changes and caches results
 */

const fs = require('fs');
const path = require('path');

const CACHE_FILE = path.join(__dirname, '.backend_cache.json');

/**
 * Get file stats for backend inspection
 */
const getFileStats = (filePath) => {
  try {
    const stats = fs.statSync(filePath);
    return {
      exists: true,
      size: stats.size,
      mtime: stats.mtime.getTime()
    };
  } catch (error) {
    return { exists: false };
  }
};

/**
 * Files to monitor for changes
 */
const getMonitoredFiles = () => {
  const baseApiPath = path.resolve(__dirname, '../../../api');
  
  return [
    path.join(baseApiPath, 'app/models/job.rb'),
    path.join(baseApiPath, 'app/models/job_comment.rb'),
    path.join(baseApiPath, 'app/models/job_user_profile.rb'),
    path.join(baseApiPath, 'app/controllers/api/v1/jobs_controller.rb'),
    path.join(baseApiPath, 'app/controllers/api/v1/job_comments_controller.rb'),
    path.join(baseApiPath, 'app/serializers/job_serializer.rb'),
    path.join(baseApiPath, 'app/serializers/job_comment_serializer.rb'),
    path.join(baseApiPath, 'db/migrate/create_jobs.rb'),
    path.join(baseApiPath, 'db/migrate/create_job_comments.rb'),
    path.join(baseApiPath, 'db/migrate/create_job_user_profiles.rb')
  ].filter(filePath => fs.existsSync(filePath));
};

/**
 * Load cached inspection results
 */
const loadCache = () => {
  try {
    if (fs.existsSync(CACHE_FILE)) {
      return JSON.parse(fs.readFileSync(CACHE_FILE, 'utf8'));
    }
  } catch (error) {
    console.warn('Failed to load backend inspection cache:', error.message);
  }
  return {};
};

/**
 * Save inspection results to cache
 */
const saveCache = (data) => {
  try {
    fs.writeFileSync(CACHE_FILE, JSON.stringify(data, null, 2));
  } catch (error) {
    console.warn('Failed to save backend inspection cache:', error.message);
  }
};

/**
 * Inspect backend for changes
 */
const inspectBackend = (options = {}) => {
  const { quiet = false } = options;
  
  if (!quiet) {
    console.log('🔍 Inspecting Jobs backend...');
  }
  
  const monitoredFiles = getMonitoredFiles();
  const cache = loadCache();
  const currentStats = {};
  const changes = [];
  
  // Check each monitored file
  monitoredFiles.forEach(filePath => {
    const relativePath = path.relative(process.cwd(), filePath);
    const currentStat = getFileStats(filePath);
    const cachedStat = cache[relativePath];
    
    currentStats[relativePath] = currentStat;
    
    if (!cachedStat) {
      changes.push({
        file: relativePath,
        type: 'new',
        message: 'New file detected'
      });
    } else if (currentStat.exists && cachedStat.exists) {
      if (currentStat.mtime !== cachedStat.mtime) {
        changes.push({
          file: relativePath,
          type: 'modified',
          message: 'File modified since last inspection'
        });
      }
      if (currentStat.size !== cachedStat.size) {
        changes.push({
          file: relativePath,
          type: 'size_change',
          message: `File size changed: ${cachedStat.size} -> ${currentStat.size} bytes`
        });
      }
    } else if (!currentStat.exists && cachedStat.exists) {
      changes.push({
        file: relativePath,
        type: 'deleted',
        message: 'File deleted since last inspection'
      });
    }
  });
  
  // Save current state to cache
  saveCache(currentStats);
  
  if (!quiet) {
    console.log(`📊 Backend inspection complete:`);
    console.log(`   Monitored files: ${monitoredFiles.length}`);
    console.log(`   Changes detected: ${changes.length}`);
    
    if (changes.length > 0) {
      console.log('\n📋 Changes detected:');
      changes.forEach(change => {
        console.log(`   ${change.type.toUpperCase()}: ${change.file} - ${change.message}`);
      });
    }
  }
  
  return {
    monitoredFiles: monitoredFiles.length,
    changes,
    timestamp: new Date().toISOString()
  };
};

module.exports = {
  inspectBackend,
  getMonitoredFiles,
  loadCache,
  saveCache
};
