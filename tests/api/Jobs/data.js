/**
 * Random Data Generators for Job Tests
 */

const { faker } = require("./config");

// Job Status enum values (matching Rails model)
const JOB_STATUS = ['pending', 'in_progress', 'completed', 'cancelled'];

// Job Priority enum values (matching Rails model)
const JOB_PRIORITY = ['low', 'medium', 'high', 'urgent'];

// Job User Profile roles (matching Rails model)
const JOB_ROLES = ['assignee', 'supervisor', 'reviewer', 'collaborator'];

/**
 * Utility functions for random selection
 */
const randomUtils = {
  pickRandom: (array) => array[Math.floor(Math.random() * array.length)],
  
  randomInt: (min, max) => Math.floor(Math.random() * (max - min + 1)) + min,
  
  randomBool: () => Math.random() > 0.5,
  
  generateFutureDate: (daysAhead = 30) => {
    const date = new Date();
    date.setDate(date.getDate() + randomUtils.randomInt(1, daysAhead));
    return date.toISOString().split('T')[0]; // Return YYYY-MM-DD format
  },
  
  generatePastDate: (daysBehind = 30) => {
    const date = new Date();
    date.setDate(date.getDate() - randomUtils.randomInt(1, daysBehind));
    return date.toISOString().split('T')[0]; // Return YYYY-MM-DD format
  }
};

/**
 * Data generators for different entity types
 */
const dataGenerators = {
  /**
   * Generate basic job data
   */
  generateJob: () => {
    const timestamp = Date.now();
    
    return {
      description: `Test job ${timestamp} - ${faker.lorem.sentence()}`,
      deadline: randomUtils.generateFutureDate(),
      status: randomUtils.pickRandom(JOB_STATUS),
      priority: randomUtils.pickRandom(JOB_PRIORITY),
      comment: faker.lorem.paragraph()
    };
  },

  /**
   * Generate job data with assignees
   */
  generateJobWithAssignees: (assigneeIds = []) => {
    const jobData = dataGenerators.generateJob();
    
    if (assigneeIds.length > 0) {
      jobData.assignee_ids = assigneeIds;
    }
    
    return jobData;
  },

  /**
   * Generate job data with all role assignments
   */
  generateJobWithRoles: (assigneeIds = [], supervisorIds = [], collaboratorIds = []) => {
    const jobData = dataGenerators.generateJob();
    
    if (assigneeIds.length > 0) {
      jobData.assignee_ids = assigneeIds;
    }
    
    if (supervisorIds.length > 0) {
      jobData.supervisor_ids = supervisorIds;
    }
    
    if (collaboratorIds.length > 0) {
      jobData.collaborator_ids = collaboratorIds;
    }
    
    return jobData;
  },

  /**
   * Generate job comment data
   */
  generateJobComment: () => {
    return {
      content: faker.lorem.paragraph()
    };
  }
};

/**
 * Generate complete job payload
 */
const generateCompleteJob = () => {
  const timestamp = Date.now();
  
  return {
    job: {
      ...dataGenerators.generateJob(),
      // Optional relationships can be added here based on available data
      // profile_customer_id: null, // Will be set if needed
      // work_id: null, // Will be set if needed
    }
  };
};

/**
 * Generate minimal job for updates
 */
const generateMinimalJob = () => {
  const timestamp = Date.now();
  
  return {
    job: {
      description: `Updated job ${timestamp} - ${faker.lorem.sentence()}`,
      status: randomUtils.pickRandom(JOB_STATUS),
      priority: randomUtils.pickRandom(JOB_PRIORITY)
    }
  };
};

/**
 * Generate test data for specific scenarios
 */
const scenarioData = {
  pendingJob: () => {
    const data = generateCompleteJob();
    data.job.status = 'pending';
    data.job.priority = 'medium';
    return data;
  },

  urgentJob: () => {
    const data = generateCompleteJob();
    data.job.status = 'pending';
    data.job.priority = 'urgent';
    data.job.deadline = randomUtils.generateFutureDate(7); // Due within a week
    return data;
  },

  completedJob: () => {
    const data = generateCompleteJob();
    data.job.status = 'completed';
    data.job.priority = 'low';
    return data;
  },

  overdueJob: () => {
    const data = generateCompleteJob();
    data.job.status = 'pending';
    data.job.priority = 'high';
    data.job.deadline = randomUtils.generatePastDate(7); // Overdue
    return data;
  },

  cancelledJob: () => {
    const data = generateCompleteJob();
    data.job.status = 'cancelled';
    return data;
  },

  jobWithComment: () => {
    const data = generateCompleteJob();
    data.job.comment = `Initial comment: ${faker.lorem.paragraph()}`;
    return data;
  }
};

module.exports = {
  JOB_STATUS,
  JOB_PRIORITY,
  JOB_ROLES,
  randomUtils,
  dataGenerators,
  generateCompleteJob,
  generateMinimalJob,
  scenarioData
};
