# frozen_string_literal: true

module Users
  class CreationService
    def self.create_user(params:, current_team:, current_user:)
      user = User.new(params)
      user.team = determine_team(current_team, current_user)

      if user.save
        Result.success(user)
      else
        Result.failure(user.errors.full_messages)
      end
    end

    def self.determine_team(current_team, current_user)
      current_team || current_user.team
    end

    class Result
      attr_reader :data, :errors

      def initialize(success:, data: nil, errors: nil)
        @success = success
        @data = data
        @errors = errors
      end

      def success?
        @success
      end

      def failure?
        !@success
      end

      def self.success(data)
        new(success: true, data: data)
      end

      def self.failure(errors)
        new(success: false, errors: errors)
      end
    end
  end
end
