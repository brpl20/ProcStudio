# frozen_string_literal: true

module Auth
  class AuthenticationService
    def self.authenticate(email:, password:)
      user = User.find_for_authentication(email: email)
      return Result.failure('Credenciais inválidas') unless user&.valid_password?(password)

      user.reload
      Result.success(user)
    end

    class Result
      attr_reader :user, :error

      def initialize(success:, user: nil, error: nil)
        @success = success
        @user = user
        @error = error
      end

      def success?
        @success
      end

      def failure?
        !@success
      end

      def self.success(user)
        new(success: true, user: user)
      end

      def self.failure(error)
        new(success: false, error: error)
      end
    end
  end
end
