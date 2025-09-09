  The Problem

  Your jobs array contains Svelte proxy objects, not plain JavaScript objects. When you try to access
  job.description, you're accessing it through the proxy, which can sometimes cause issues.

  Solutions

  1. Use $state.snapshot() for logging

  Replace:
  console.log(jobs);
  With:
  console.log($state.snapshot(jobs));

  This gives you the raw data without Svelte's reactive wrappers.

  2. Use $inspect() for debugging

  For development debugging, use:
  $inspect(jobs);

  This is Svelte's built-in debugging tool that handles reactive state properly.

  3. Fix data access (likely cause)

  The real issue is probably that your API response structure doesn't match what you expect. Check if the jobs
  data is nested under an attributes property or similar.

  Try logging the raw response structure:
  const response = await api.jobs.getJobs();
  console.log('Raw response:', $state.snapshot(response));

  The property access (job.description) should work fine with Svelte proxies, so if it's not working, the data
  structure is likely different than expected.