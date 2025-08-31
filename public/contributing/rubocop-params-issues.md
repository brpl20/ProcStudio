⏺ Based on my research and analysis of your setup, here's how to fix the RuboCop issue with params.expect vs
  params.require:

  The Problem

  You're using:
  - RuboCop Rails 2.33.3 (latest)
  - RuboCop 1.79.2 (latest)
  - Rails 8 with the new params.expect syntax

  The issue is that RuboCop Rails introduced the Rails/StrongParametersExpect cop that automatically converts
  params.require to params.expect, but there are known bugs with nested attributes handling in Rails 8's
  params.expect method.

  The Solution (Without Coding)

  Add this to your .rubocop.yml file to disable the problematic cop:

  # Add this to your .rubocop.yml
  Rails/StrongParametersExpected:
    Enabled: false

  Why This Fixes It

  1. Rails 8 Bug: params.expect has documented issues with nested attributes (accepts_nested_attributes_for)
  2. RuboCop Auto-correction: The cop's auto-correction breaks working nested attributes code
  3. GitHub Issues: There are active issues on RuboCop Rails repo (#1418, #1429) about this exact problem

  Alternative Options

  If you want to keep using the cop but avoid the auto-correction:

  Rails/StrongParametersExpected:
    Enabled: true
    AutoCorrect: false  # Keep the warning but don't auto-fix

  Or exclude specific files:

  Rails/StrongParametersExpected:
    Exclude:
      - 'app/controllers/api/v1/works_controller.rb'

  Current Status (2025)

  The Rails team and RuboCop maintainers are aware of these issues. The params.expect method will eventually be
   fixed to properly handle nested attributes, but for now, sticking with params.require for nested attributes
  is the safe approach.

  Your current fix (reverting to params.require) is correct and follows the recommended practice until Rails
  8's params.expect nested attributes bugs are resolved.
