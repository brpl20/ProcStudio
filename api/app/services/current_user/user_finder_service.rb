# frozen_string_literal: true

module CurrentUser
  class UserFinderService
    def self.find_by_identifier(identifier:, type: nil)
      case type
      when 'profile_id'
        find_by_profile_id(identifier)
      when 'user_id'
        find_by_user_id(identifier)
      else
        auto_detect_user(identifier)
      end
    end

    def self.find_by_profile_id(profile_id)
      profile = UserProfile.find_by(id: profile_id)
      profile&.user
    end

    def self.find_by_user_id(user_id)
      User.find_by(id: user_id)
    end

    def self.auto_detect_user(identifier)
      user = find_by_user_id(identifier)
      user || find_by_profile_id(identifier)
    end

    def self.load_with_associations(user_id)
      User.includes(
        :team,
        :offices,
        :user_offices,
        user_profile: [:office, :phones, :addresses, :bank_accounts, :works, :jobs]
      ).find(user_id)
    end
  end
end
